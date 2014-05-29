sandboxdir=$(dirname $0)
. $sandboxdir/sb_vars.sh 

STEPNO=0
INI_NODE=0

function make_paths
{
    PATHS=''
    for D in $( find  $TUNGSTEN_SB -maxdepth 1 -type d -name "${SB_PREFIX}*"  )
    do
        if [ -n "$PATHS" ] ; then PATHS="$PATHS,"; fi
        PATHS="${PATHS}${D}"
    done
    export PATHS
}

function check_exit_code
{
    exit_code=$?
    if [ -n "$SBDEBUG" ]
    then
        echo "# exit code: <$exit_code>"
    fi
    if [ "$exit_code" != "0" ] 
    then 
        exit $exit_code 
    fi
}

function multi_trepctl
{
    make_paths
    MULTI_TREPCTL="$TUNGSTEN_SB_NODE2/tungsten/tungsten-replicator/scripts/multi_trepctl --paths=$PATHS"
    FIELDS=--fields=host,rmiPort,service,role,state,seqno,latency
    if [ -z "$1" ]
    then
        $MULTI_TREPCTL $FIELDS
    else
        $MULTI_TREPCTL "$@"
    fi
}

function show_command
{
    command=$1
    if [ -n "$MAKE_INI" ]
    then
        echo $command | perl -pe 's{(./tools/tpm install)}{}; s/\breset\b//; s{./tools/tpm configure (\w+)}{\n\[$1\]}; s/--/\n/g; ' >> $TUNGSTEN_SB/tungsten-node$INI_NODE.ini
    else
        echo $command | perl -pe 'BEGIN{$HN=qx(hostname); chomp $HN}; s/$ENV{HOME}/\$HOME/g; s/=$ENV{USER}\b/=\$USER/g; s/\b$HN\b/\$(hostname)/g; s/--/\\\n\t--/g'
    fi
}

function run_command
{
    command="$1"
    if [ -n "$DRYRUN" -o -n "$SBDEBUG" -o -n "$VERBOSE" ]
    then
        show_command "$command"
    fi
    if [ -z "$DRYRUN" ]
    then
        $command
        check_exit_code
    fi
}

function print_dry
{
    message=$1
    STEPNO=$(($STEPNO+1))
    if [ -n "$DRYRUN" ]
    then
        echo "# --- step $STEPNO --- "
    fi
    if [ -n "$DRYRUN" -o -n "$SBDEBUG" -o -n "$VERBOSE" ]
    then
        echo $message
    fi
    if [ -n "$DRYRUN" ]
    then
        echo "# "
    fi
}

function configure_defaults
{
    NODE=$1   
    if [ -n "$MAKE_INI" ]
    then
        export INI_NODE=$NODE
        echo "# NODE $NODE - Topology: $current_topology" > $TUNGSTEN_SB/tungsten-node$INI_NODE.ini
    fi
    DELTA=$(($NODE*10))
    print_dry "# Configuring node $NODE"
    MYSQL_SB_PATH=$MYSQL_SB_BASE/node$NODE
    TPM_COMMAND="./tools/tpm configure defaults --reset \
        --install-directory=$TUNGSTEN_SB/$SB_PREFIX$NODE \
        --repl-rmi-port=$(($RMI_BASE_PORT+$DELTA)) \
        --user=$USER \
        --replication-port=$(($MYSQL_BASE_PORT+NODE)) \
        --datasource-mysql-conf=$MYSQL_SB_PATH/my.sandbox.cnf \
        --datasource-boot-script=$MYSQL_SB_PATH/msb \
        --datasource-log-directory=$MYSQL_SB_PATH/data \
        $USERNAME_AND_PASSWORD \
        $VALIDATION_CHECKS $MORE_DEFAULTS_OPTIONS \
        --start=true"
    #echo $TPM_COMMAND | perl -pe 's/--/\\\n\t--/g'
    #exit
    #$TPM_COMMAND
    run_command "$TPM_COMMAND"
}

function configure_master
{
    SERVICE=$1
    THL_PORT=$2
    print_dry "# Configuring master for service $SERVICE (thl: $THL_PORT)"
    TPM_COMMAND="./tools/tpm configure $SERVICE \
        --master=$LOCALHOST \
        --replication-host=$LOCALHOST $MORE_MASTER_OPTIONS \
        --thl-port=$THL_PORT "
    run_command "$TPM_COMMAND"
    # check_exit_code
}

function configure_slave
{
    SERVICE=$1
    THL_PORT=$2
    print_dry "# Configuring slave for service $SERVICE (thl: $THL_PORT)"
    TPM_COMMAND="./tools/tpm configure $SERVICE \
        --slaves=$LOCALHOST \
        --replication-host=$LOCALHOST \
        --thl-port=$THL_PORT \
        --master-thl-host=$LOCALHOST \
        --enable-slave-thl-listener=false $MORE_SLAVE_OPTIONS $3 "

    run_command "$TPM_COMMAND"
    #check_exit_code
}

function configure_direct_slave
{
    SERVICE=$1
    THL_PORT=$2
    print_dry "# Configuring direct slave for service $SERVICE (thl: $THL_PORT)"
    TPM_COMMAND="./tools/tpm configure $SERVICE \
        --topology=direct \
        --master=$LOCALHOST \
        --replication-host=$LOCALHOST \
        --direct-datasource-host=$LOCALHOST \
        --thl-port=$THL_PORT \
        --enable-slave-thl-listener=false $3"
    run_command "$TPM_COMMAND"
    # check_exit_code
}


function configure_spoke_slave
{
    SERVICE=$1
    THL_PORT=$2
    MASTER_SERVICE=$3
    configure_slave $SERVICE $THL_PORT "--svc-allow-any-remote-service=true --property=local.service.name=$MASTER_SERVICE --svc-applier-filters=bidiSlave"
}

function configure_hub_slave
{
    SERVICE=$1
    THL_PORT=$2
    configure_slave $SERVICE $THL_PORT "--log-slave-updates=true"
}

function tpm_install
{
    
    TPM_COMMAND="./tools/tpm install $MORE_TPM_INSTALL_OPTIONS "
    run_command "$TPM_COMMAND"
    # check_exit_code
}

function install_with_ini_files
{
    # set -x
    for F in $TUNGSTEN_SB/tungsten-node?.ini
    do
        MORE_TPM_INSTALL_OPTIONS=--ini=$F
        tpm_install
    done
    # set +x
}


function pre_installation
{
    export current_topology=$1
    if [ ! -x ./tools/tpm ]
    then
        echo "This command requires ./tools/tpm"
        echo "Change directory to a tungsten staging directory and try again"
        exit 1
    fi
    will_abort=
    for PREV_INSTANCE in $TUNGSTEN_SB_NODE1 $TUNGSTEN_SB_NODE2 $TUNGSTEN_SB_NODE3 $TUNGSTEN_SB_NODE4
    do
        if [ -d $PREV_INSTANCE ]
        then
            echo "Found a previous installation in $PREV_INSTANCE" 
            will_abort=1
        fi 
    done
    if [ -n "$will_abort" ]
    then
        exit 1
    fi
    if [ ! -d $TUNGSTEN_SB ]
    then
        mkdir $TUNGSTEN_SB
    fi

}

function post_installation
{
    topology=$1 
    if [ -n "$DRYRUN" ]
    then
        return
    fi 
    make_paths
    #MULTI_TREPCTL="$TUNGSTEN_SB_NODE2/tungsten/tungsten-replicator/scripts/multi_trepctl --paths=$PATHS"
    #echo '#!/bin/bash' > $TUNGSTEN_SB/multi_trepctl 
    #echo "$MULTI_TREPCTL \"\$@\"" >> $TUNGSTEN_SB/multi_trepctl
    cp $sandboxdir/{sb_common,sb_vars}.sh $TUNGSTEN_SB
    if [ -f $sandboxdir/sb_dynamic_vars.sh ] 
    then

        echo $DOTS_LINE >  $TUNGSTEN_SB/sb_vars.sh
        echo "# DYNAMIC variables" >>  $TUNGSTEN_SB/sb_vars.sh
        echo $DOTS_LINE >>  $TUNGSTEN_SB/sb_vars.sh
        cat $sandboxdir/sb_dynamic_vars.sh >> $TUNGSTEN_SB/sb_vars.sh
        echo $DOTS_LINE >>  $TUNGSTEN_SB/sb_vars.sh
        cat $sandboxdir/sb_vars.sh >> $TUNGSTEN_SB/sb_vars.sh
    fi
    cp $sandboxdir/{README.md,sb_multi_trepctl,sb_show_cluster,sb_test_sandbox} $TUNGSTEN_SB
    cp $sandboxdir/sb_reset $TUNGSTEN_SB/sb_erase_sandbox
    #chmod +x $TUNGSTEN_SB/multi_trepctl

    for TPATH in $(echo $PATHS | tr ',' ' ')
    do
        TREPCTL="$TPATH/tungsten/tungsten-replicator/bin/trepctl"
        THL="$TPATH/tungsten/tungsten-replicator/bin/thl"
        REPLICATOR="$TPATH/tungsten/tungsten-replicator/bin/replicator"
        LOG="$TPATH/tungsten/tungsten-replicator/log/trepsvc.log"
        CONF="$TPATH/tungsten/tungsten-replicator/conf/"
        echo '#!/bin/bash' > $TPATH/trepctl 
        echo "$TREPCTL \"\$@\"" >> $TPATH/trepctl
        echo '#!/bin/bash' > $TPATH/thlcmd
        echo "$THL \"\$@\"" >> $TPATH/thlcmd
        echo '#!/bin/bash' > $TPATH/replicator
        echo "$REPLICATOR \"\$@\"" >> $TPATH/replicator
        echo '#!/bin/bash' > $TPATH/show_log
        echo "$EDITOR $LOG" >> $TPATH/show_log
        echo '#!/bin/bash' > $TPATH/show_conf
        echo "$EDITOR $CONF" >> $TPATH/show_conf
        echo '#!/bin/bash' > $TPATH/tpm
        echo ". $TUNGSTEN_SB/sb_vars.sh" >> $TPATH/tpm
        echo "if [ ! -d $TPATH/tungsten ] ; then echo './tungsten not found in $TPATH' ; exit 1 ; fi" >> $TPATH/tpm
        echo "cd $TPATH/tungsten" >> $TPATH/tpm
        echo './tools/tpm "$@"' >> $TPATH/tpm
        for F in replicator thlcmd trepctl show_log show_conf tpm
        do
            chmod +x $TPATH/$F
        done
    done
    for F in  $(ls $MYSQL_SB_BASE/n[0-9]) $MYSQL_SB_BASE/{start_all,stop_all,status_all,restart_all,use_all}
    do
        NF=$(basename $F)
        ln -s $F $TUNGSTEN_SB/db_$NF
    done
    for NODE in $(seq 1 $HOW_MANY_NODES)
    do
        if [ -d $TUNGSTEN_SB/$SB_PREFIX$NODE ]
        then
            ln -s $MYSQL_SB_BASE/node$NODE/use $TUNGSTEN_SB/$SB_PREFIX$NODE/db_use
            ln -s $MYSQL_SB_BASE/node$NODE/my.sandbox.cnf $TUNGSTEN_SB/$SB_PREFIX$NODE/my.cnf
        fi
    done
    echo $topology > $TUNGSTEN_SB/topology
    INFO_FILE=$TUNGSTEN_SB/tungsten_sandbox.info
    TUNGSTEN_BUILD=$(grep '^RELEASE' .manifest | awk '{print $2}')
    echo "Tungsten Sandbox  $TUNGSTEN_SANDBOX_VERSION" > $INFO_FILE
    echo "Topology          : $topology" >> $INFO_FILE
    echo "Tungsten build    : $TUNGSTEN_BUILD" >> $INFO_FILE
    echo "Staging directory : $PWD" >> $INFO_FILE
    echo "MySQL Version     : $MYSQL_VERSION" >> $INFO_FILE
    echo "Nodes             : $HOW_MANY_NODES" >> $INFO_FILE
    cat $INFO_FILE
    $sandboxdir/sb_show_cluster
}

function ok_equal
{
    value=$1
    expected=$2
    msg=$3
    
    test_status=''
    errmsg=''
    if [ "$value" == "$expected" ]
    then
        test_status=ok
        pass=$(($pass+1))
    else
        test_status='not ok'
        errmsg="(found <$value> - expected: <$expected>)"
        fail=$(($fail+1))
    fi
    echo "$test_status - $msg - found '$value' $errmsg"
    total_tests=$(($total_tests+1))
}
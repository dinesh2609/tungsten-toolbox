#!/bin/bash
# (C) Copyright 2012 Continuent, Inc - Released under the New BSD License
# Version 1.0.3 - 2012-11-19

CURDIR=`dirname $0`
if [ -f $CURDIR/COMMON_NODES.sh ]
then
    . $CURDIR/COMMON_NODES.sh
else
    export NODE1=
    export NODE2=
    export NODE3=
    export NODE4=
fi

export ALL_NODES=($NODE1 $NODE2 $NODE3 $NODE4)
# indicate which servers will be masters, and which ones will have a slave service
# in case of all-masters topologies, these two arrays will be the same as $ALL_NODES
# These values are used for automated testing

#for master/slave replication
export MASTERS=($NODE2)
export SLAVES=($NODE1 $NODE3 $NODE4)


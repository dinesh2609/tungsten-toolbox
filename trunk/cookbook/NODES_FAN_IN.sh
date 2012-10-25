#!/bin/bash

export NODE1=
export NODE2=
export NODE3=
export NODE4=

export ALL_NODES=($NODE1 $NODE2 $NODE3 $NODE4)
# indicate which servers will be masters, and which ones will have a slave service
# in case of all-masters topologies, these two arrays will be the same as $ALL_NODES
# These values are used for automated testing

# for fan-in replication
export MASTERS=($NODE1 $NODE2 $NODE3)
export SLAVES=($NODE4)

# MMSERVICES are the names used for services when installing multiple masters
export MM_SERVICES=(alpha bravo charlie delta echo foxtrot golf hotel)

export FAN_IN_SLAVE=$NODE4

# This should be the name of the master service installed in the fan-in slave
export FAN_IN_LOCAL_SERVICE=delta

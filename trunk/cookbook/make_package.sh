#!/bin/bash

cd `dirname $0`

if [ -d ./cookbook ]
then
    echo "directory 'cookbook' already exists"
    exit 1
fi

mkdir cookbook
for F in `cat MANIFEST` 
do
    cp $F cookbook
done

tar -c cookbook/ | gzip -c > tungsten-replicator-cookbook.tar.gz

rm -rf cookbook

ls -l tungsten-replicator-cookbook.tar.gz
echo "use deploy_cookbook.sh and tungsten-replicator-cookbook.tar.gz  to deploy the recipes inside your tungsten-replicator installation directory"

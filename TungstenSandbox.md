# TUNGSTEN SANDBOX #
Tungsten Replicator in a single host

This is an ongoing project that installs multiple instances of MySQL database servers with Tungsten Replicator in a single host.
The main purpose is testing.

## INSTALLATION ##

As of version 2.0, tungsten-sandbox is self contained in one file, which you can use anywhere, provided that you can indicate where is the expanded tarball to be used.

## REQUIREMENTS ##
It should work with Tungsten Replicator 2.0.4-167 or later and MySQL Sandbox 3.0.24 or later.
All the requirements for a normal installation of Tungsten should be met. See [the documentation](http://www.continuent.com/downloads/documentation) for details. But notice that the installer will tell you if the requirements are met for most of them.

[MySQL Sandbox](http://mysqlsandbox.net) is necessary for Tungsten Sandbox to work.

## USAGE ##
  1. Create a directory where you want to start a sandbox (by default, it should be $HOME/tsb2)
  1. Make sure that MySQL Sandbox is installed and working properly
  1. unpack the MySQL binary tarball that you want to use, and rename it to the bare version number. The directory must be in $HOME/opt/mysql/X.X.XX, or in a directory refined in $SANDBOX\_BINARY.
> > For example, if you want to use mysql-5.1.57-linux-x86\_64-glibc23.tar.gz,do the folloowing:
```
   mkdir -p $HOME/opt/mysql
   cd $HOME/opt/mysql
   tar -xzf /path/to/mysql-5.1.57-linux-x86_64-glibc23.tar.gz
   mv mysql-5.1.57-linux-x86_64-glibc23 5.1.57
```
  1. in a separate directory, unpack Tungsten Replicator tarball
  1. run tungsten-sandbox -h
```
  $ tungsten-sandbox -h
      Tungsten Tools,  version 2.0.1
    Tungsten Sandbox - Cluster builder
     (C) 2011 Giuseppe Maxia, Continuent, Inc
Syntax: tungsten-sandbox-2.0/tungsten-sandbox [options] operation 
    -n --nodes = number                 How many nodes to install
    -m --mysql-version = name           which MySQL version to use
    -t --tungsten-base = name           Where to install the sandbox
    -i --installation_directory = name  Where tthe Tungsten tarball has been expanded
    -d --group-dir = name               sandbox group directory name
    --topology = name                   Which topology to deploy
    --hub = number                      Which node is a hub
    -s --service = name                 How the service is named
    -x --tsb-prefix = name              Tungsten Sandbox prefix
    -p --base-port = number             Base port for MySQL Sandbox nodes 
    -l --thl-port = number              Port for the THL service 
    -r --rmi-port = number              Port for the RMI service 
    -v --version                        Show Tungsten sandbox version and exit 
    --show-options                      Show Tungsten sandbox collected options and exit 
    --verbose                           Show more information during installation and help 
    -h --help                           display this help
```
  1. Change the defaults using command line options and create your sandbox.  Here's an example to install a 2-node sandbox using MySQL 5.1.58 with port offsets changed to avoid collisions with other sandboxes on the same host.
```
  $ ./tools/tungsten-sandbox -n 2 -m 5.1.58 -p 7300 -l 12300 -r 10300
```

## More than just master-slave ##
As of version 2.0, Tungsten Sandbox can install different topologies. Supported in version 2.0.1 are
  * **master-slave**: the vanilla replication with 1 master and N slaves;
  * **all-masters**: every node is a master and connected to all other nodes with a slave service.
  * **bi-dir**: it's an all masters with two nodes;
  * **star**: a central hub connected in bi-directional master-master to each node;
  * **fan-in**: a single slave receiving updates from many masters.


## CREDITS ##

This sandbox would have been much harder to write without the excellent Tungsten installer developed by Jeff Mace.

## WORK IN PROGRESS ##

This is an ongoing project, with ambitious goals.
More work will follow in the same area.
A simple TODO list:
  * Direct slave sandboxes
  * Mix of MySQL native and Tungsten replication
  * PostgreSQL integration

For this reason, the format of this application may change in future releases.

## AUTHOR ##

Giuseppe Maxia, for Continuent, Inc
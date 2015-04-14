# Tungsten Sandbox for the impatient #

1. install MySQL::Sandbox
> sudo su -

> cpan MySQL::Sandbox

2. download a MySQL binary tarball for your machine. Not a source tarball, nor a rpm. a .tar.gz containing binaries. For this example, let's say you download 5.1.60

3. make the binary directory
> mkdir -p $HOME/opt/mysql
4. install your first MySQL Sandbox:
> make\_sandbox --export\_binaries /path/to/mysql-5.1.xx-blahblah.tar.gz

5. download a recent Tungsten Replicator tarball from http://bit.ly/tr20_builds

6. unpack the Tungsten tarball. For this example, let's say that it's /tmp/tungsten-replicator-2.0.5-463

7. create a directory for the sandbox
> mkdir $HOME/tsb2

8. use Tungsten Sandbox:

> tungsten-sandbox -m 5.1.60 -i  /tmp/tungsten-replicator-2.0.5-463 --topology=all-masters --nodes=5 --verbose
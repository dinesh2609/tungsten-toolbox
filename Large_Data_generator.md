# Large Data Generator #

The **ldg** (Large Data Generator) is a tool that creates and handles large data sets for the purpose of testing replication, especially parallel apply.



## Interface ##

<pre>

Tungsten Tools,  version 1.0<br>
ldg - Large Data Generator<br>
(C) 2011 Giuseppe Maxia, Continuent, Inc<br>
<br>
Syntax: ./ldg [options]<br>
-o --operation = name               Operation to perform<br>
(Allowed: {generate|list|load|delete})<br>
<br>
# Generation options<br>
<br>
--schemas = number                  How many schemas to create<br>
--schema-prefix = name              Name prefix for each database to create<br>
--records = number                  How many records for each schema<br>
--repository = name                 Where to store the datasets<br>
--dataset-name = name               Name of this dataset<br>
--no-binlog                         Disables binary log during generation<br>
--db-host = name                    name of the host to use for data generation<br>
--db-port = number                  database server port<br>
--db-user = name                    database server user<br>
--db-password = name                database server password<br>
--make-sandbox = name               Will use a sandbox to generate data.<br>
--sysbench-threads = number         How many threads for sysbench<br>
--sysbench-duration = number        How many seconds should sysbench run<br>
--sysbench-requests = number        How many requests should sysbench generate<br>
<br>
# management options<br>
<br>
--skip-logs                         Do not copy innodb log files<br>
--mysql-init = name                 path to the mysql init script (/etc/init.d/mysqld)<br>
This command will be called before loading,<br>
to stop the server, and after loading, to start it.<br>
--use-sudo                          act as super user to create the data directory<br>
--run-sysbench = name               Execute "sysbench run" in the given host after loading the data.<br>
-h --help                           Shows this help page.<br>
--i-am-sure                         Option required when asking for dangerous tasks, such as delete datasets.<br>
--verbose                           Gives more information on some operations.<br>
</pre>


## Sample usage ##

### Generate ###
<pre>
ldg -o generate -schemas=3  --records=50000000 --make-sandbox=5.1.57 --no-binlog<br>
[ ... ] <br>
<br>
sysbench 0.4.12:  multi-threaded system evaluation benchmark<br>
<br>
Creating table 'sbtest'...<br>
Creating 50000000 records in table 'sbtest'...<br>
2011-09-13 16:09:00<br>
2011-09-13 16:20:21<br>
+-----------------------------+<br>
| time spent running the test |<br>
+-----------------------------+<br>
| 00:11:21                    |<br>
+-----------------------------+<br>
sysbench 0.4.12:  multi-threaded system evaluation benchmark<br>
<br>
Creating table 'sbtest'...<br>
Creating 50000000 records in table 'sbtest'...<br>
2011-09-13 16:20:21<br>
2011-09-13 16:31:27<br>
+-----------------------------+<br>
| time spent running the test |<br>
+-----------------------------+<br>
| 00:11:06                    |<br>
+-----------------------------+<br>
sysbench 0.4.12:  multi-threaded system evaluation benchmark<br>
<br>
Creating table 'sbtest'...<br>
Creating 50000000 records in table 'sbtest'...<br>
2011-09-13 16:31:27<br>
2011-09-13 16:42:41<br>
+-----------------------------+<br>
| time spent running the test |<br>
+-----------------------------+<br>
| 00:11:14                    |<br>
+-----------------------------+<br>
Copying to repository. Please wait ...<br>
. sandbox server started<br>
Generated data was copied to /home/tungsten/ldg_repo/db_3_rec_50000000<br>
</pre>
### List ###

<pre>
ldg --operation=list<br>
db_3_rec_100000      - date: 2011-09-13 - schemas:   3 - records:     100000 -       5.1.57 - 115M<br>
db_3_rec_10000000    - date: 2011-09-13 - schemas:   3 - records:   10000000 -       5.1.57 - 6.8G<br>
db_3_rec_10M         - date: 2011-09-13 - schemas:   3 - records:   10000000 -       5.5.10 - 6.9G<br>
db_3_rec_50000000    - date: 2011-09-13 - schemas:   3 - records:   50000000 -       5.1.57 - 34G<br>
db_5_rec_5000000     - date: 2011-09-13 - schemas:   5 - records:    5000000 -       5.1.57 - 5.7G<br>
</pre>

<pre>
ldg --operation=list --verbose<br>
data-saved : 2011-09-13<br>
dataset-name : db_3_rec_100000<br>
dataset-size : 115M<br>
innodb-data-file-path : ibdata1:10M:autoextend<br>
innodb-file-per-table : ON<br>
mysql-version : 5.1.57<br>
no-binlog : 1<br>
records : 100000<br>
schemas : 3<br>
--------------------------------------------------------------------------------<br>
data-saved : 2011-09-13<br>
dataset-name : db_3_rec_10000000<br>
dataset-size : 6.8G<br>
innodb-data-file-path : ibdata1:10M:autoextend<br>
innodb-file-per-table : ON<br>
mysql-version : 5.1.57<br>
no-binlog : 1<br>
records : 10000000<br>
schemas : 3<br>
--------------------------------------------------------------------------------<br>
data-saved : 2011-09-13<br>
dataset-name : db_3_rec_10M<br>
dataset-size : 6.9G<br>
innodb-data-file-path : ibdata1:10M:autoextend<br>
innodb-file-per-table : ON<br>
mysql-version : 5.5.10<br>
no-binlog : 1<br>
records : 10000000<br>
schemas : 3<br>
--------------------------------------------------------------------------------<br>
data-saved : 2011-09-13<br>
dataset-name : db_3_rec_50000000<br>
dataset-size : 34G<br>
innodb-data-file-path : ibdata1:10M:autoextend<br>
innodb-file-per-table : ON<br>
mysql-version : 5.1.57<br>
no-binlog : 1<br>
records : 50000000<br>
schemas : 3<br>
--------------------------------------------------------------------------------<br>
data-saved : 2011-09-13<br>
dataset-name : db_5_rec_5000000<br>
dataset-size : 5.7G<br>
innodb-data-file-path : ibdata1:10M:autoextend<br>
innodb-file-per-table : ON<br>
mysql-version : 5.1.57<br>
no-binlog : 1<br>
records : 5000000<br>
schemas : 5<br>
--------------------------------------------------------------------------------<br>
</pre>

### Load ###

TBD
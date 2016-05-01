---
layout: post
title: "Mysql slaver gem"
description: ""
category:
tags: [mysql, devops]
---

<center>
<p>
<img src="/images/replication.png" />
</p>
</center>

I use MySQL a lot, and I usually set up servers in pairs/groups for scaling and/or resilience. So, when I’m setting up a new server, I almost always have to start replication by doing the same little dance;

1. SSH onto the master and record its master status
1. Dump and load the data from the master onto the new slave
1. Stop replication on the slave
1. Issue a change master command on the slave, using the master status values
1. Start replication

After the fiftieth or sixtieth time, this gets pretty tedious. So, I’ve written a little Ruby gem to simplify it. Under the hood, it does exactly the same steps, but it means I can now do the whole process by entering a single command.

Here’s an example;

    $ sudo gem install mysql-slaver

    $ mysql_slaver enslave --master-host mysqldb1 \
        --database myapp_production \
        --replication-user repuser \
        --replication-password passwordrepl

    2014-04-16 13:00:01 CMD: ssh mysqldb1 'mysql -u root  -e "show master status\G"'
    2014-04-16 13:00:02 MASTER STATUS - file: mysql-bin.000001, position: 5656568
    2014-04-16 13:00:02 CMD: mysql -u root  -e "stop slave"
    2014-04-16 13:00:02 CMD: ssh mysqldb1 'mysqldump -h mysqldb1 -u root  --master-data --single-transaction --quick --skip-add-locks --skip-lock-tables --default-character-set=utf8 --compress myapp_production' | mysql -u root  myapp_production
    2014-04-16 13:00:04 CMD: mysql -u root  -e "stop slave; CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=5656568, MASTER_HOST='mysqldb1', MASTER_USER='repuser', MASTER_PASSWORD='passwordrepl'; start slave"

It’s pretty basic, and I’ve already outlined a bunch of features which I think it would be nice to add, but I’ve already found it very useful, and I hope other people will also.

Here is the [repository](https://github.com/digitalronin/mysql-slaver) on GitHub;

    https://github.com/digitalronin/mysql-slaver

There are some pre-requisites and assumptions, which you can find listed out in the README

18/04/14 ETA

The gem now accepts --port and --sock parameters, if you are running mysql on a non-standard port, or using a socket file.

In both cases, the values must be the same on the slave and the master. i.e. if you’re using /tmp/mysql.sock on localhost, the gem expects that to be the socket file on the master, too, and the same for the port number.

22/04/14 ETA

You can now pass in --ssh_port [integer] if ssh is running on a non-standard port on the master server.

Invoking the enslave command with the --no_copy flag will change the slave’s master status to start replicating from the master server’s current log position, without copying the database.

15/08/15 ETA

Added --dry-run option (which outputs the commands which *would be* run, without doing anything)

Added --tables option (takes a space-separated list of tables, and only copies those tables from the target server)


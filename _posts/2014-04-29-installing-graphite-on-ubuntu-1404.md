---
layout: post
title: "Installing Graphite on Ubuntu 14.04"
description: ""
category:
tags: [devops, graphite, ubuntu, trusty]
---

[Graphite](http://graphite.readthedocs.org/) is great stats collection and graphing system, used in a lot of companies to

<center>
<p>
<img src="/images/measureallthethings.jpg" />
</p>
</center>

But, it’s always been something of a [PITA to set up](https://www.digitalocean.com/community/articles/installing-and-configuring-graphite-and-statsd-on-an-ubuntu-12-04-vps).

With the release of Ubuntu 14.04 Trusty Tahr, graphite is now available via apt, so the setup is a lot more straightforward. But there are still a couple of small hoops to jump through.

1. Install these packages using apt-get or aptitude

    * graphite-web
    * graphite-carbon
    * apache2
    * libapache2-mod-wsgi

Of course it is possible to use other webservers, such as Nginx, but the packages provided with Ubuntu 14.04 have an example configuration for Apache, so I’ve stuck with that for the sake of simplicity.

Once you’ve got the packages installed, you need to tell apache to serve the Graphite web interface. You can do that by running these commands (as root);

    rm /etc/apache2/sites-enabled/000-default.conf

    ln -s /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-enabled/

Now setup the user database for django, like this;

    python /usr/lib/python2.7/dist-packages/graphite/manage.py syncdb

This will prompt you to setup an admin user and password. For now, let’s use 'root' and 'foobar'. When that command has finished, you need to edit the file /etc/graphite/local_settings.py

You’ll see a line like this, near the top;

    #SECRET_KEY = 'UNSAFE_DEFAULT'

Uncomment that line and replace UNSAFE_DEFAULT with some long random string.

    SECRET_KEY = 'somelongrandomstring'

Near the end of the file, you need to configure the user and password you created earlier;

    DATABASES = {
        'default': {
            'NAME': '/var/lib/graphite/graphite.db',
            'ENGINE': 'django.db.backends.sqlite3',
            'USER': 'root',
            'PASSWORD': 'foobar',
            'HOST': '',
            'PORT': ''
        }
    }

Note that this is using the default sqlite3 database backend. This is not recommended for production servers, so you will want to change that (and probably a lot of other things) when you’re ready to move your graphite server into production.

You may also need to change a couple of permissions;

    chmod 666 /var/lib/graphite/graphite.db

    chmod 755 /usr/share/graphite-web/graphite.wsgi

Now restart Apache, and you should be good to go. If you visit the IP address of your graphite server from a web browser, you should see the Graphite web interface.

If you have problems, you should be able to see what’s going on by looking in these log files;

    /var/log/apache2/graphite-web_access.log
    /var/log/apache2/graphite-web_error.log


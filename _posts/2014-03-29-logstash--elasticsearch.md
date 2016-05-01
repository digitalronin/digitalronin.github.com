---
layout: post
title: "Logstash + Elasticsearch"
description: "Setting up a logstash+elasticsearch server with Chef Solo"
category:
tags: [chef, vagrant, ubuntu, logstash, elasticsearch]
---

I wanted to play with [logstash](http://logstash.net/), ideally using my current favourite tools of [Vagrant](http://vagrantup.com/) and [Chef](http://www.getchef.com/).

I googled around, but the projects I found that use these tools were too complex for my taste, so I rolled my own.

First, I wanted to start from a very simple Vagrant + Chef Solo + Ubuntu 12.04 configuration.

Here’s one I made, earlier;

    git clone https://github.com/digitalronin/chef_project_template.git logstash
    cd logstash
    rm -rf .git

Now, you’ll need to edit the Vagrantfile and replace my SSH public key with yours. Otherwise, you won’t be able to ssh onto your new vagrant VM as root (I would be able to, but that won’t help you very much).

For more information, checkout [this post](http://digitalronin.github.io/2014/03/21/getting-started-with-chef-and-vagrant/).

Once you’ve done that, you can fire up the VM;

    ./bootstrap_vagrantvm

This will take a few minutes.

Now we have a Vagrant VM, based on Ubuntu 12.04, with Ruby 2.0 as the system ruby, and a basic configuration using Chef Solo.

Now to add logstash.

We’re going to install logstash from a tarball.

    mkdir -p chef/cookbooks/logstash/recipes
    vi chef/cookbooks/logstash/recipes/default.rb

Here’s the content we need;

    # Logstash requires a java runtime
    package "java7-runtime-headless"

    path = "#{Chef::Config[:file_cache_path]}/logstash-1.4.0.tar.gz"
    remote_file path do
      source "https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz"
      action :create_if_missing
      not_if "ls /opt/logstash"
    end

    execute "untar" do
      command "tar xzvf #{path} --directory /opt"
      not_if "ls /opt/logstash"
    end

Now add "recipe[logstash]" to the runlist in chef/server.json;

    {
      "run_list": [
        "recipe[ntp]",
        "recipe[logstash]"
      ]
    }

…and apply our new configuration;

    cd chef
    ./deploy.sh root@192.168.11.11

That’s it. We now have a Vagrant VM with logstash 1.4.0 installed to /opt/logstash

Let’s try it out;

    root@myserver:~# /opt/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'

Run that command, and then type something. You’ll have to wait a little to see the output, presumably because logstash is batching things up;

    root@myserver:~# /opt/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'
    Hello, world
    2014-03-29T13:42:38.437+0000 myserver Hello, world

Press Ctrl-D to exit.

Now let’s add [elasticsearch](http://elasticsearch.org/). The installation recipe is very similar to that for logstash;

    vi chef/cookbooks/elasticsearch/recipes/default.rb

Here’s the content;

    path = "#{Chef::Config[:file_cache_path]}/elasticsearch-1.0.1.tar.gz"
    remote_file path do
      source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.tar.gz"
      action :create_if_missing
      not_if "ls /opt/elasticsearch"
    end

    execute "untar" do
      command "tar xzvf #{path} --directory /opt; ln -s /opt/elasticsearch-1.0.1 /opt/elasticsearch"
      not_if "ls /opt/elasticsearch"
    end

NB: Only certain versions of logstash and elasticsearch play nicely together, out of the box. So, if you change
the version of one, make sure you check that the version of the other is compatible.

Don’t forget to add it to our server.json runlist;

    {
      "run_list": [
        "recipe[ntp]",
        "recipe[logstash]",
        "recipe[elasticsearch]"
      ]
    }

…and apply the new configuration;

    cd chef
    ./deploy.sh root@192.168.11.11

You can now run elasticsearch like this;

    /opt/elasticsearch/bin/elasticsearch


You can confirm that it’s running by logging onto the VM via ssh and running this;

    wget -O - 'http://localhost:9200/_search?pretty'

...which should produce output something like this;

    {
      "took" : 0,
      "timed_out" : false,
      "_shards" : {
        "total" : 0,
        "successful" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : 0,
        "max_score" : 0.0,
        "hits" : [ ]
      }
    }

You can also fire up a web browser on your host machine and visit http://192.168.11.11:9200/

That’s as far as I’m going to go in this blog post, mainly because I don’t know much about Logstash and Elasticsearch (yet).
More information is available [here](http://logstash.net/docs/1.4.0/tutorials/getting-started-with-logstash).

Just remember that our logstash executable is /opt/logstash/bin/logstash when you work through their examples.

All the code for this blog post is [available on github](https://github.com/digitalronin/chef-logstash-elasticsearch).


---
layout: post
title: "Rails 4.1.0 Walking Skeleton"
description: ""
category:
tags: []
---

Like a lot of coders, I enjoy working on new projects, especially when I can play with the latest toys.

Lots of new tools are optimised for development, which means it’s really easy to get something up and running on your laptop. Install, hack, hack, hack, and then you’ve got something you’re ready to show the world.

That’s when you realise that although you might have knocked up your fantastic idea in a few hours of coding, it’s going to take you a lot longer to configure a server to the point where you’re able to deploy your code so that other people can see it.

<center>
<p>
<img src="/images/iheartvector-walking-skeleton1.png" />
</p>
</center>


I like the idea of the idea of a [“Walking Skeleton”](http://blog.codeclimate.com/blog/2014/03/20/kickstart-your-next-project-with-a-walking-skeleton) - i.e. build something that implements just one tiny part of your intended solution, but with all the necessary moving parts in place so that you can focus on putting flesh on the bones, instead of having a daunting chunk of devops work to do when all you want to do is hack. So, I’ve created a project that can be used as a starting point for developing a __deployable__ Rails 4.1 application.

<https://github.com/digitalronin/chef-rails410-server>

It’s an opinionated project, but I’ve tried to keep it as simple as possible, to make it easy for people to swap out whatever components they like.

**The components**

* Ubuntu 12.04
* Chef
* Vagrant
* Ruby 2.1.1
* Rails 4.1.0
* SQLite3
* Haml
* Capistrano and [Recap](https://github.com/tomafro/recap) for deployment
* Nginx + Unicorn
* UFW (firewall)

To use this with a vagrant VM, as per the example, your rails application must be a git repository itself. i.e. it must have its own .git directory. Otherwise the deployment path in the Capfile will not be correct. I wanted the whole project to be a single git repo, so here’s what you need to do to get started;

**Clone the repository**

    git clone https://github.com/digitalronin/chef-rails410-server.git

**Edit the __Vagrantfile__ so that it contains your own public ssh key, rather than mine, then;**

    cd hello
    git init
    git add .
    git commit -m initial
    cd ..
    ./bootstrap_vagrantvm

Around ten minutes later (depending on the speed of your computer), you should have a Vagrant VM running in production mode. If you visit http://192.168.11.11 you should see a “Hello, World” page from your rails app.

Hack away, and use “cap deploy” whenever you want to update your VM to check that everything works correctly in production mode.

__When you’re ready to go into production;__

* Spin up an Ubuntu 12.04 VM at your hosting provider. Make sure you can ssh onto it as root.
* Push your rails app. to a git repo. You will need to be able to access it from your new server.
* Edit the Capfile with the location of your code, and the IP number of your new server
* Run through the steps in bootstrap_vagrantvm, skipping the vagrant lines, and replacing 192.168.11.11 with the IP number of your new server.

Please note that I have only applied minimal security tweaks to this setup. It’s up to you to manage your own security, and I do not accept any responsibility for you getting hacked if you use this project as is.

In particular, deploying code as root is probably quite a bad idea, but it should be easy to adjust that according to your own preference.

I also wouldn’t recommend using SQLite for a “real” application, but I wanted the project to have as little database setup as possible, and SQLite makes that easier.

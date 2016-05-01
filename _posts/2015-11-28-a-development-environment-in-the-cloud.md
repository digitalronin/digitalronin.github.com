---
layout: post
title: "A Development Environment in the Cloud"
description: "How to setup a Google Compute Engine VM and run a web browser on it."
category:
tags: []
---

I'm doing a lot of docker development, these days. So, I'm pushing a lot of docker images to [Google Container Registry](http://gcr.io). That means I'm uploading a lot of binary data - some docker images can be hundreds of megabytes - which isn't much fun over my home ADSL internet connection.

For that reason, among others, I've been toying with the idea of **setting up a VM in the cloud**, and using that as my main development environment. That way, I would have great bandwidth, so pushing docker images, or other bandwidth-heavy tasks, would be a lot less painful.

I use vim and tmux as my main development environment, and those work just fine over ssh to a remote machine, but I also need to be able to access a webserver running on localhost via a decent web browser, when I'm developing.

I could use ssh port forwarding to connect to e.g. a remote development rails server running on the VM, but I wanted find out how to run the browser on the remote machine, and just send the display to my laptop.

## The Idea

Create a VM in the cloud and install everything I need to do development work on it, including a web browser and any other GUI applications I want. Whenever I've finished a session, I'll delete the VM, but leave the cloud disk drive so that, next session, I can just create a new VM (of whatever power and configuration I want for that session), attach it to the disk and pick up wherever I left off.

It's important to delete the VM when you're not using it, because you will be paying for it the whole time it exists, whether you're using it or not. You also have to pay for the disk, but they are pretty cheap compared to servers (On GCE, a 200GB disk would cost you $8/month).

There are a couple of steps involved, so this is a brief guide on how to get it all working.

### My environment

I'm running OSX Yosemite on my Macbook, and I'll be setting up an Ubuntu 14.04 VM in the Google Compute Environment (GCE).

### Pre-requisites

* A GCE account with billing enabled, where you can create VMs
* [The Google Cloud SDK](https://cloud.google.com/sdk/) installed on your local machine, and authenticated to the project where you'll create your VMs

### Step 1. Create your VM and disk

I prefer to do things on the command-line, but you can just as easily use the [GCE web interface](https://console.developers.google.com) for this

    #!/bin/bash

    PROJECT=myproject
    MACHINE_TYPE='n1-standard-1'
    DISK_IMAGE='https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1404-trusty-v20151113'
    DISK_SIZE=10
    SSH_CREDS="sshKeys=david:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnEy5Rrfu6bc7CcmvHpZFjSAChxuvl/uwNQlWbJR3Hj4ZjAV24SKt5rxoJHg/EGObRbif+VVt6dQV3koxcyJpQggVGuwDi6PYEJJe4UmlYqKXduyK+lCkM4FpO8AKw9jbRqqo+X6PJfAv7XljpkQ/aknzYsd/6j+AdyqAykRHvelAxK4Oqf98K6h6XEUEAFbXurm285BeeNdQiHSCNzJancG8nH/y0yGY8Q1VT28SwGfdQ23iTwhQJpSDHBAblc0yoaBt4SMS413A1d/gfHbHnVKslgXYhHSvd+OmUoyHocBjH1fIg1drSzoNyMa6PWiF8vwN5q4L3qyZmzerLBppp david"

    gcloud compute \
      --project "${PROJECT}" \
      instances create "development" \
      --zone "us-central1-b" \
      --machine-type "${MACHINE_TYPE}" \
      --network "default" \
      --metadata "${SSH_CREDS}" \
      --maintenance-policy "MIGRATE" \
      --scopes "https://www.googleapis.com/auth/cloud.useraccounts.readonly","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write" \
      --image "${DISK_IMAGE}" \
      --boot-disk-size "${DISK_SIZE}" \
      --no-boot-disk-auto-delete \
      --boot-disk-type "pd-standard" \
      --boot-disk-device-name "development"

**There are a few things to notice here**;

* Change PROJECT to your GCE project ID.

* I'm creating an "n1-standard-1" machine - that's pretty much the entry level, so not very powerful. I'd recommend sticking to something like this while you're experimenting.
You can always move to something more powerful later, when it's worth spending the extra money.

* Similarly, I'm only creating a 10GB disk, for now.

* I'm using the us-central1-b zone - you might want to pick a zone that's closer to where you live, to minimise latency.

* The SSH_CREDS is important. It's your ssh public key, and GCE is quite picky about the format of this string. I'd recommend using the web interface add pasting your public key into the relevant field, then using the links at the bottom of the page which will show you the gcloud sdk command-line version of what you're about to do, and then copy and paste from there.

**The value shown here is one of my public keys. Don't use that. If you do, I'll be able to ssh to your VM, but you won't!**

* --no-boot-disk-auto-delete   - This tells GCE that we don't want to delete the disk whenever we delete the VM.

This is important if we are going to spend time configuring the environment on our VM - you don't want all of that to disappear every time you throw the VM away. By leaving it in place, we can create and attach a new VM whenever we want.

But, be careful not to leave disks lying around if you really don't want them, because you will be charged for them.

After you run that command, you should see output something like this;

    NAME        ZONE          MACHINE_TYPE  PREEMPTIBLE INTERNAL_IP EXTERNAL_IP    STATUS
    development us-central1-b n1-standard-1             10.240.0.16 130.201.168.48 RUNNING

Make a note of the EXTERNAL_IP. I usually store it into a bash environment variable;

    export IP=130.201.168.48

At this point, you should be able to ssh to your VM.


    ssh -i ~/.ssh/[your private ssh key] david@${IP}


### Step 2. Setup your VM to run GUI applications

We want to be able to run GUI applications on the VM, but display them on our local machine. There are ways of doing this using X11 display forwarding, but that's [dark voodoo](https://unix.stackexchange.com/questions/12755/how-to-forward-x-over-ssh-from-ubuntu-machine).

An easier way is to use [xpra](https://www.xpra.org/), described as "screen for X11."

You need to install this on both the VM and your local machine. The version of xpra that comes with Ubuntu 14.04 is not compatible with the version you can install using [homebrew](http://brew.sh/), so we need to install it from the xpra repository.

SSH to your VM, and run the following commands

    curl http://winswitch.org/gpg.asc | sudo apt-key add -
    sudo bash -c 'echo "deb http://winswitch.org/ trusty main" > /etc/apt/sources.list.d/winswitch.list'
    sudo apt-get update
    sudo apt-get install firefox xpra -y

firefox is nothing to do with xpra, but we'll need to install it (or whatever browser you prefer) at some point, so we may as well do it now.

### Step 3. Start your browser

Still on the VM, run this command

    xpra start :100 --start-child=firefox

That tells xpra to start firefox and make it available to us via the xpra server. The :100 is an abitrary number denoting the virtual display on which to show the browser window.

Now the browser should be running on the VM, and we need to connect to the display from our local machine.

### Step 4. Install xpra locally

On my mac, I installed xpra like this;

    brew cask install xpra

If you're on a different platform, you can find installation instructions on the [xpra website](https://www.xpra.org)

### Step 5. Connect to firefox on the VM

By default, xpra on the mac has a graphical interface which lets you enter a username and password to ssh to your remote machine. But, we're using key-based ssh authentication, so that's no use.

Fortunately, there is a command-line utility, although it's not obvious.

Run this command, on your local machine;

    /opt/homebrew-cask/Caskroom/xpra/latest/Xpra.app/Contents/MacOS/Xpra attach ssh:david@${IP}:100

You need to change 'david' to your username (as per your ssh key, when you created the VM). If you used a different value for the display in the "xpra start" command, you need to use the same number here, instead of 100.

At this point, you should have a firefox window on your local machine. On my mac, the remote window always opens behind my other windows, so look for it if you don't see it right away.

That's it. You're now running a web browser where "localhost" is the VM you just created. A cool feature of xpra is that, like screen, you can kill the "Xpra attach" command anytime, even shutting down your local machine, and just reattach to the session whenever you like.

### Step 6. Delete the VM

The following command will delete the VM, but not the disk (provided you used the the --no-boot-disk-auto-delete flag, when you created the VM)

    gcloud compute \
      --project "${PROJECT}" \
      instances delete "development"

If you do want to delete the disk, you can do so like this;

    gcloud compute \
      --project "${PROJECT}" \
      disks delete "development"

To create a new VM attached to an existing disk, run this;

    gcloud compute \
      --project "${PROJECT}" \
      instances create "development" \
      --zone "us-central1-b" \
      --machine-type "${MACHINE_TYPE}" \
      --network "default" \
      --metadata "${SSH_CREDS}" \
      --maintenance-policy "MIGRATE" \
      --scopes "https://www.googleapis.com/auth/cloud.useraccounts.readonly","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write" \
      --disk "name=development,device-name=development,mode=rw,boot=yes"

You can do all the creating/deleting via the GCE web interface, if you prefer, but I like to have as much as possible scripted, because I'm genuinely lazy.

That's it. It took me a little while to figure this stuff out, so I hope someone finds it useful.


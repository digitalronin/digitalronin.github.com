---
layout: post
title: "Xargs - Unix power tool"
description: ""
category: "coding"
tags: [unix,xargs,scripting,devops,utilities]
---

<center>
<p>
<img src="http://upload.wikimedia.org/wikipedia/commons/b/b5/Wenger_EvoGrip_S17.JPG" width="300" height="200" />
</p>
</center>

One of my favourite unix utilities is the **xargs** command.

From the man page;

    The xargs utility reads space, tab, newline and end-of-file delimited strings from the standard
    input and executes utility with the strings as arguments.

    Any arguments specified on the command line are given to utility upon each invocation, followed
    by some number of the arguments read from the standard input of xargs.  The utility is repeatedly
    executed until standard input is exhausted.

This can be really handy for lots of things.

## Basic xargs

For instance, let's say you have a lot of files in a directory, and you want to remove all of the ones
which contain a particular string - let's say "lolcats".

Without xargs, you might do something like this;

    $ grep -l lolcats * > list
    $ for file in `cat list`; do rm $file; done

(There are better ways to do this without xargs - this is just an example)

With xargs, this can be done like so;

    $ grep -l lolcats * | xargs rm

The list of filenames output from the "grep -l" command becomes the input to xargs, which then gives
the list to the "rm" command.

In more detail, let's say we had 3 files, lol1, lol2 and lol3 in the directory, which contained the string 'lolcats'.

    $ grep -l lolcats
    > lol1
    > lol2
    > lol3

The grep command outputs the names of the matching files, one per line. We could remove them all like this;

    $ rm lol1 lol2 lol3

That's what xargs is doing for you - it takes the multi-line output from the first command and turns it into an argument list for the command you gave it (in this case, "rm").

That's quite handy, but xargs can do a lot more.

## Using xargs to batch long argument lists

Say you've accidentally ended up creating thousands of files in a directory, and you need to delete them all. You might see something like this happen;

    $ rm *
    > /bin/rm: cannot execute [Argument list too long]

So, how do you get rid of the files? One way is to use xargs.

    $ ls | xargs rm

This works because xargs splits its input into chunks of (I think) maximum 255 bytes, and calls the given command ("rm") as many times as necessary until all the input (the list of filenames) has been processed.

## Using xargs to run commands in parallel

My all time favourite xargs trick is using it to run the same command multiple times, in parallel.

Let's say you need to run a command on 300 servers - a script that applies a security patch, perhaps. Here's one way you could do it;

    $ for server in `cat my_list_of_servers`; do ssh $server './run_my_script'; done

That works, but it's going to be a while between server 1 and server 300 getting updated. xargs to the rescue;

    $ cat my_list_of_servers | xargs -n 1 -P 10 -I svr ssh svr ./run_my_script

This will ssh to each of your servers and run the ./run_my_script command, but it will do so in parallel, on ten servers at once, until it's gotten through all 300 servers.

Let's break that down;

    -n 1

This tells xargs that, instead of taking (up to) 255 byte chunks from the input, we want the input to be handled one item at a time - in this case, one server name at a time. So, rather than giving the command we want to run as many arguments as possible, we are giving it one argument. But...

    -P 10

This tells xargs we want to run the command in parallel, with ten invocations running at once.

By default, xargs takes the argument list and appends it to the command you told it to run. But, we don't want the servername to appear at the end, because that would be;

    $ ssh ./run_my_script [server name]

...which wouldn't work. That's what this part does;

    -I svr

This says "whenever you see the string 'svr' in the command I told you to run, replace it with an argument from the input. Since we're taking one server name at a time from the input list, this means the actual command that gets run is something like;

    $ ssh [server name] ./run_my_script

...in batches of ten servers at a time, until we've gotten through all 300 servers. Pretty neat.


xargs can do some *really* powerful things. I'd definitely recommend having a read through the man page.


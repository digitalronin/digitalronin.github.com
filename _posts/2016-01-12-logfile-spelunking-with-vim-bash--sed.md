---
layout: post
title: "Logfile spelunking with vim, bash & sed"
description: ""
category:
tags: [vim, unix]
---

<center>
<p>
<img src="https://upload.wikimedia.org/wikipedia/commons/4/44/Pictograms-nps-land-spelunking-caves.svg" width="150" height="150" />
</p>
</center>

Today I got an alert from my monitoring system about a possible rootkit on one of my servers (false alarm, thanks for asking).

The first thing to do was to look for more details in the rootkit checker logfile. Unfortunately, it's not very informative;

{% highlight text %}
...
[06:55:03]   Scanning for string /usr/src/.puta              [ OK ]
[06:55:03]   Scanning for string /usr/man/man1/man1          [ OK ]
[06:55:03]   Scanning for string /usr/man/man1/man1/lib      [ OK ]
[06:55:03]   Scanning for string /usr/man/man1/man1/lib/.lib [ OK ]
[06:55:03]   Scanning for string /usr/man/man1/man1/lib/.lib/.backup [ OK ]
[06:55:03]
[06:55:03] Info: Starting test name 'shared_libs'
[06:55:03] Performing 'shared libraries' checks
[06:55:03]   Checking for preloading variables               [ None found ]
[06:55:03]   Checking for preloaded libraries                [ None found ]
[06:55:03]
[06:55:03] Info: Starting test name 'shared_libs_path'
[06:55:03]   Checking LD_LIBRARY_PATH variable               [ Not found ]
[06:55:03]
[06:55:03] Info: Starting test name 'properties'
[06:55:03] Performing file properties checks
[06:55:03]   Checking for prerequisites                      [ OK ]
[06:55:05]   /sbin/depmod                                    [ OK ]
[06:55:05]   /sbin/fsck                                      [ OK ]
[06:55:05]   /sbin/ifconfig                                  [ OK ]
...
{% endhighlight %}

...and so on for another 5,000 lines or so.

It wasn't immediately obvious to me what rkhunter was really worried about. So, I decided to compare the log on the affected server with the same log on its twin, which didn't have an alert. However, the timestamps of the two logs were all slightly different, which meant a vanilla `diff` wouldn't give me anything useful, because every line in the two log files was different.

Here's a way around that;

{% highlight bash %}
vi -d <(cat server1.log | sed 's/^\[.*\]//') <(cat server2.log | sed 's/^\[.*\]//')
{% endhighlight %}

This made it really easy to see the important difference in the two log files;

<center>
<p>
<img src="/images/vimdiff.png" />
</p>
</center>

Here's how that command works

{% highlight bash %}
cat server1.log | sed 's/^\[.*\]//'
{% endhighlight %}

This makes `sed` strip the timestamps from the log file, by removing anything between square brackets if it appears at the beginning of a line.

This command is a bit overeager - if there is more than one set of square brackets on a line, like this;

{% highlight text %}
[timestamp] Something else with [a pair of square brackets] on the line
{% endhighlight %}

...then sed would remove everything from the first `[` to the *last* `]`

In this case, that wasn't a problem, but you might need something a bit cleverer, depending on what you're doing.

I could have run that on both files to create two new files, one for each server's logfile, with the timestamps removed, but there is an easier way.

{% highlight text %}
<( ...some bash command here... )
{% endhighlight %}

This is a bit of bash shell magic which allows you to treat the output of a command as if it's a file. So, you can do something like this;

{% highlight bash %}
diff <(cmd1) <(cmd2)
{% endhighlight %}

That would have been fine, in this case, but I find raw `diff` output a bit difficult to interpret.

{% highlight bash %}
vi -d file1 file2
{% endhighlight %}

The `-d` flag starts vim in `diff` mode, comparing two (or more) files and highlighting any differences between them, along with some surrounding context.

Here's the full command again;

{% highlight bash %}
vi -d <(cat server1.log | sed 's/^\[.*\]//') <(cat server2.log | sed 's/^\[.*\]//')
{% endhighlight %}

So, the full command says, "open vim in diff mode, comparing these two files with all the timestamps removed."


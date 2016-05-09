---
layout: post
title: "Dispatch Tmux panes like a boss"
description: ""
category:
tags: [tmux]
image: "https://sanctum.geek.nz/arabesque/wp-content/uploads/2013/03/toggle-pane-zoom.gif"
---

I use [tmux](https://tmux.github.io/) panes all the time. I'm always editing at least one set of source code in one pane, running tests in another and probably running servers and consoles in yet more.

This is all great until I plug my laptop into my external monitor, or unplug it. Going from one physical screen to two, or vice versa, usually means I want my sessions, windows and panes arranged differently. e.g. when I have more screen space, I usually want to see my server's output in a pane on the second monitor, but when I'm just using the laptop, I'll probably have it in a separate session, out of sight, to save space.

I always used to stop and restart things to get the layout I wanted, when I plug in/unplug my second screen, but today I learned that I've been doing it wrong. With tmux, you can send a pane to another window, or even another session, very easily using the `join-pane` command.

Here's how it works. Let's say I've got a tmux session with two windows, 1 & 2. In window 1, I've got two panes, with the word "foo" in the second pane;

~~~
   window 1         window 2
+-----+------+  +------------+
|     | foo  |  |            |
+-----+------+  +------------+
~~~

With the cursor in the "foo" pane, I can send it to the second window like this;

1. Hit your tmux prefix key (mine is Ctrl-a, the default is Ctrl-b), then :  This should bring up a tmux control prompt in a bar at the bottom of the screen.
2. Press j and then the tab key to auto-complete the `join-pane` command (or you can just type the whole thing)
3. Type `-t :2` and hit return.

Your tmux session should now look like this;

~~~
   window 1         window 2
+-----+------+  +------------+
|            |  |            |
|            |  +------------+
|            |  |     foo    |
+-----+------+  +------------+
~~~

The -t flag to join-pane specifies the target window, and :2 tells tmux to send the pane to window 2 of the current session.

You can only send a pane to a window that exists, so if you want a window with only the "foo" pane in it, you need to send the pane and then switch to that window and close the pane you don't want.

You can also send a pane to a different tmux session altogether. e.g. if you had tmux session 3 open in a different terminal window, and you want to send the pane to session 3, window 1, you would use;

`join-pane -t 3:1`

There is a complementary `-s` flag you can give to join-pane to specify the source pane that you want to "pull" to the current tmux window. I haven't found much use for that because it seems quite tricky to specify the exact remote pane I want. I also find it conceptually easier to think about sending the current pane somewhere else than figuring out which remote panes I want to gather into the current window.

Now I can arrange my tmux panes however I want, without having to restart anything.

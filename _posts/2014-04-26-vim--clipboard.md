---
layout: post
title: "Vim + clipboard"
description: ""
category:
tags: [vim, tmux]
---

<center>
<p>
<img src="/images/clipboard-27405_640.png" width="150" height="150" />
<img src="/images/Icon-Vim.svg" width="150" height="150" />
</p>
</center>

For years, I’ve been copying text from console Vim running inside tmux running inside iTerm2 by doing this;

1. Ctrl-a + Z - Zoom the current tmux pane to be full screen (if it wasn’t already)
1. Hold down Alt and drag the mouse over the text I want to copy to the clipboard
1. Ctrl-a + Z - Unzoom the current tmux pane

That’s not too awful, but it’s a lot more cumbersome than the process of copying text from one document to another within the same Vim session (or even within different Vim sessions, thanks to a short macro I wrote).

What makes it worse is when I’m editing a file in a git repository (which is about 95% of the time), I have Vim set up with the [git gutter](https://github.com/airblade/vim-gitgutter) plugin. This shows a single character in column zero indicating whether the current line is an addition, deletion or change compared to the line in the git repo. That’s a nice feature, but those status characters are included whenever I use the mouse+Alt to select a chunk of text.

Today I learned from [this Vimcast](http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/) that I’ve been doing it all wrong.

Simply adding;

    set clipboard=unnamed

to my .vimrc file makes Vim use the system clipboard as its default register. Anything I yank or delete gets added to the system clipboard, and I can paste anything from the clipboard with a single key.

So, the process of getting text from Vim to the system clipboard is now;

1. Use Vim motion commands or visual mode to choose the text on which to operate
2. Press y (or whatever other operation I want to use)

No messing about with zooming/unzooming panes, no need to switch from the keyboard to the mouse while almost dislocating my thumb trying to hold down the Alt key, and no git-gutter characters in the copied text.

Awesome! Thanks, [Drew](http://drewneil.com/)



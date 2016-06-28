---
layout: post
title: "Vim - Incrementing a column of numbers"
description: ""
category:
tags: [vim]
image: "/images/ascending-graph.png"
---

Whenever I'm mocking up a sample web page, I inevitably end up doing something like this;

Create a line;

~~~html
<li id="1">This is item 1</li>
~~~

Copy it a bunch of times;

~~~html
<li id="1">This is item 1</li>
<li id="1">This is item 1</li>
<li id="1">This is item 1</li>
<li id="1">This is item 1</li>
<li id="1">This is item 1</li>
~~~

Then change the numbers to this;

~~~html
<li id="1">This is item 1</li>
<li id="2">This is item 2</li>
<li id="3">This is item 3</li>
<li id="4">This is item 4</li>
<li id="5">This is item 5</li>
~~~

The changing numbers part gets pretty tedious. By default, vim lets you use `Ctrl-a`[^1] to increment the number under the cursor (or the next number after it), but I still need to press it once to go from 1 to 2, then reposition the cursor on the next line, and press `Ctrl-a` twice to go from 1 to 3, and so on. Very repetitive and annoying.

I went looking for a solution, and found the [vim-visual-increment] script. It hooks into the existing 'increment number' command but, if you do that when you're in 'visual block' mode, it uses the first element in the selection as a base, and adds to subsquent elements, multiplying by the sequence number of the element in the selection. So, if you have the following, with the `[]` indicating the selected visual block;

~~~html
<li id="[1]">This is item 1</li>
<li id="[1]">This is item 1</li>
<li id="[1]">This is item 1</li>
<li id="[1]">This is item 1</li>
<li id="[1]">This is item 1</li>
~~~

...then pressing `Ctrl-a` will give you this;

~~~html
<li id="1">This is item 1</li>
<li id="2">This is item 1</li>
<li id="3">This is item 1</li>
<li id="4">This is item 1</li>
<li id="5">This is item 1</li>
~~~

Pretty neat. If you add `set nrformats=alpha` in your `.vimrc` file, you can even turn this;

~~~
This is item A
This is item A
This is item A
This is item A
This is item A
~~~

...into this;

~~~
This is item A
This is item B
This is item C
This is item D
This is item E
~~~

I think this is going to save me a lot of key-pounding. [Check it out][vim-visual-increment]

<hr />

[^1]: Actually, I've got `Ctrl-a` as my [tmux] prefix key, so I really type `Ctrl-a` `a` to do this.

[vim-visual-increment]: https://github.com/triglav/vim-visual-increment
[tmux]: https://tmux.github.io/

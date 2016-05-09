---
layout: post
title: "Vim: Insert debug statements according to filetype"
description: ""
category:
tags: [vim]
image: "http://www.ibmsystemsmag.com/getattachment/c247b44e-07b3-4ca9-9724-d913fb9dc3c2/"
---

I've got a little keybinding in my `.vimrc` file which inserts a debug statement into a file, and then saves it;

{% highlight vim %}
map <Leader>db Odebugger; 1<CR><ESC>:w<CR>
{% endhighlight %}

So, if I'm editing `foo.rb` with my cursor on line 2;

{% highlight ruby %}
1 def hello
2   puts "Hello, world!"
3 end
{% endhighlight %}

Then if I hit `,db` the file will look like this;

{% highlight ruby %}
1 def hello
2   debugger; 1
3   puts "Hello, world!"
4 end
{% endhighlight %}

Saving the file triggers any test runner process that might be watching the file for changes.

FYI the `; 1` is there in case I want to insert a debug statement at the end of a block - in that case, it gives the debugger something to stop on.

This is great for ruby and javascript, but for other languages like elixir, I need to insert a different statement.

In the past, I've done this by creating a custom `.vimrc` file for each project, in which I remap that key combination to whatever is appropriate. But, that gets pretty tedious when you have a lot of projects.

I want to define my editor config once, but have it insert whatever statement is appropriate, according to the language of the file I'm editing.

Here's how I've done it.

Create a file `~/.vim/scripts/debug.vim`

{% highlight vim %}
function InsertDebugStatement()
  let debug = "debugger; 1"  | " default because it works for ruby & javascript

  if (&filetype == "elixir")
    let debug = "TestHelper.enable_debug_logging"
  endif

  exec ":normal O" . debug
  exec ":write"

endfunction

map <Leader>db :call InsertDebugStatement()<CR>

{% endhighlight %}


Then, in my .vimrc;

{% highlight vim %}
source ~/.vim/scripts/debug.vim
{% endhighlight %}

That's it. The key sequence calls the `InsertDebugStatement` function, which uses the current value of `filetype` to insert whatever debug statement is required, and then save the file.


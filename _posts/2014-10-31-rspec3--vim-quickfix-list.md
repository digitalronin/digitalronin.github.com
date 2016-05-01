---
layout: post
title: "RSpec3 + Vim Quickfix List"
description: ""
category: "coding"
tags: vim,rspec
---

I've got vim nicely set up to run my specs in another tmux pane with a few keybindings, using vim-rspec and tslime.

This works really well, but it's even better if I can use the vim quickfix list to jump to each failing spec with a single keypress. I had a setup to do that with RSpec2, but I've upgraded to RSpec3 now, and I had to make a few changes. So, here's my setup, in case it's of use to anyone else.

The trick is to make rspec output a single line for each failing spec, and then open up those lines in the quickfix list.

To get the lines we want, we need a custom rspec output formatter. This is a lot easier in RSpec3 than in earlier versions. Here is the full text of my formatter;

    # For a Rails project, put this in;
    # spec/support/formatters/vim_formatter.rb

    class VimFormatter
      RSpec::Core::Formatters.register self, :example_failed

      def initialize(output)
        @output = output
      end

      def example_failed(notification)
        @output << format(notification) + "\n"
      end

      private

      def format(notification)
        rtn = "%s: %s" % [notification.example.location, notification.exception.message]
        rtn.gsub("\n", ' ')[0,160]
      end
    end

When you run your specs, invoke them like this;

    bundle exec rspec --require=support/formatters/vim_formatter.rb \
      --format VimFormatter --out quickfix.out [whatever specs you want to run]

You can run multiple formatters at once. I usually add "--format progress" to use the Fuubar spec progress bar, as well.

If you have any failures, you'll end up with a line like this in the file quickfix.out, for each failure;

    ./spec/models/some_model_spec.rb:46: expected [foo] got [bar]

The shortened description probably won't be very informative, but it gets hard to read if the lines wrap in the quickfix list. Besides, we only want to use the list for navigation - you've still got all the verbose output in the pane where you ran the specs, anyway (actually, you've probably got the output twice - RSpec3 seems to double up the output on stdout if you specify multiple formatters - I haven't looked into how to fix this yet).

You can load the spec failures into the vim quickfix list by typing;

     :cg quickfix.out

Then, open and switch to the quickfix list using

    :cwindow

From there, you can use your usual quickfix navigation to jump to each failure in turn. By default, you can switch to the quickfix list and then use normal vim navigation to go up/down to the line you want, and press return to open that file in the main window with the cursor on the failing spec. Even better, install the unimpaired vim plugin and you can use ]q to jump to the next failure, and [q to jump to the previous one, without having to switch to the quickfix list (if you're doing that, change 'cwindow' to 'copen', which will open the quickfix list without switching to it).

To tie this all together and integrate it with vim-rspec and tslime, I use a .vimrc file in the project directory that looks like this;

    let g:rspec_command = "Tmux spring rspec --require=support/formatters/vim_formatter.rb --format VimFormatter --out quickfix.out  --format progress {spec}"
    :map <leader>s :cg quickfix.out \| copen<CR>

So, my standard keybindings for running all specs/one specfile/one specific spec kick off the rspec run with the right formatters, and then \<leader\>s opens any failures in the quickfix list.

---
layout: post
title: "Rails Class Renamer"
description: "Tool to rename a class in a Rails project"
category:
tags: [rails, ruby, utilities]
---

I fairly often find myself changing the name of a class, as a project alters over time.

In a rails project, this means I have to;

* Rename the source code (e.g. app/models/foo.rb -> app/models/bar.rb)
* Rename the spec file (e.g. spec/models/foo\_spec.rb -> spec/models/bar\_spec.rb)
* Search and replace in my code, changing e.g. 'Foo' to 'Bar' but not changing 'FooBaz' etc.

Although I really like working in vim, this is one time when I miss having a refactoring IDE.

So, I've written a little tool to make this easier.

Here is the [repository](https://github.com/digitalronin/rails-class-renamer) on GitHub;

    https://github.com/digitalronin/rails-class-renamer

It's pretty basic, but I think it does enough to be useful, and should save me a bit of time - hopefully, you too.

Merry Xmas.


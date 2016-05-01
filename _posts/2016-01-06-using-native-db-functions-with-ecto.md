---
layout: post
title: "Using native DB functions with Ecto"
description: ""
category: "coding"
tags: [elixir, mysql]
---

I'm rewriting an app. in [Elixir](http://elixir-lang.org) which uses a pretty hairy bit of SQL at its core, to select data from a [MySQL](https://www.mysql.com) database.

When I've had to write similar code in [Rails](http://rubyonrails.org/), I've found the in-built query language to be quite frustrating, and I've usually dropped down to raw SQL to get the job done. But, this is my first major Elixir project, so I decided to try and do everything using [Ecto](http://hexdocs.pm/ecto/Ecto.html), and I have to say it's a complete joy to use. Building up a very complex SQL statement from composable query clauses keeps the code very clear and concise. But, that might be the subject of another blog post. For this post, I just want to highlight one specific feature.

At one point in my SQL, I need to select the top N records from a table, in descending order of `value`. If there are records with the same `value`, I want a random selection.

In SQL, I would do something like this;

{% highlight sql %}
SELECT * FROM mytable ORDER BY `value` DESC, RAND() LIMIT 5;
{% endhighlight %}

Using Ecto, the first part is easy enough (assuming `MyObject` is an Ecto model);

{% highlight elixir %}
from obj in MyObject,
  order_by: [desc: obj.value],
  limit:    5
{% endhighlight %}

Adding the `RAND()` part was a little trickier. My first try was this;

{% highlight elixir %}
from obj in MyObject,
  order_by: [desc: obj.value, asc: "RAND()"],
  limit:    5
{% endhighlight %}

But, that just results in a SQL statement with the string literal `'RAND()'` in the ORDER BY clause, which does nothing.

After a little bit of digging, I found Ecto's [fragment/1](http://hexdocs.pm/ecto/Ecto.Query.API.html#fragment/1) function, which allows you to send expressions directly through to the database, with no interpolation. So, the working version of my code looks like this;

{% highlight elixir %}
from obj in MyObject,
  order_by: [desc: obj.value, asc: fragment("RAND()")],
  limit:    5
{% endhighlight %}


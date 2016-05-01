---
layout: post
title: "Building a web application with Phoenix & React.js - Part 1"
description: ""
category:
tags: []
---

There are a few guides which cover combining [Phoenix](http://www.phoenixframework.org/) and [React.js](https://facebook.github.io/react/index.html), but they all seem to assume a certain level of knowledge about the javascript ecosystem, or use a particular combination of magical build tools.

I like to build up from scratch, whenever I can. Otherwise, I don't feel like I really understand what's going on. So, I set out to build a web application that uses Phoenix to serve a JSON API, and a React.js single page application to consume it.

Our application will be a bookshelf manager, which allows you to manage a collection of books. Initially, all we're going to do is store a list of books and render a list page with all the books on it, and a show page for a single book.

### Pre-requisites

You will need the following tools installed locally;

* [Elixir](http://elixir-lang.org/) & [Phoenix](http://www.phoenixframework.org/)
* [npm](https://www.npmjs.com/)

Let's get started.

### Create the Phoenix application

    mix phoenix.new bookshelf --no-brunch --database mysql

Enter "y" when prompted to `Fetch and install dependencies? [Yn]`

There are other options for the database. I'm just using mysql because I already have it installed, and I'm more familiar with it. Run `mix help phoenix.new` to find out the various options.

We won't be using the default [Brunch](http://brunch.io) build tool, hence the `--no-brunch` flag.

That creates the skeleton of our application. Now create the database;

    cd bookshelf
    mix ecto.create

We'll need a `Book` model. We'll start with just a title, author, and the URL of a cover image;

    mix phoenix.gen.json Book books title:string author:string cover_image_url:string

Using `phoenix.gen.json` indicates that we only want a JSON API for this resource, so we won't get HTML views. You should see the following output;

    * creating web/controllers/book_controller.ex
    * creating web/views/book_view.ex
    * creating test/controllers/book_controller_test.exs
    * creating web/views/changeset_view.ex
    * creating priv/repo/migrations/20151220100520_create_book.exs
    * creating web/models/book.ex
    * creating test/models/book_test.exs

    Add the resource to your api scope in web/router.ex:

        resources "/books", BookController, except: [:new, :edit]

    Remember to update your repository by running migrations:

        $ mix ecto.migrate

As per the prompts, edit the `web/router.ex` file, uncomment the api scope and add the resource;

{% highlight elixir %}
scope "/api", Bookshelf do
  pipe_through :api
  resources "/books", BookController, except: [:new, :edit]
end
{% endhighlight %}

Then run the migration to create the books table;

    mix ecto.migrate

Let's add some seed data, so we've got something to work with.

Edit `priv/repo/seeds.exs` and add the following content;

{% highlight elixir %}

alias Bookshelf.Repo
alias Bookshelf.Book

Repo.delete_all Book

Repo.insert! %Book{
  title: "The Checklist Manifesto",
  author: "Atul Gawande",
  cover_image_url: "http://ecx.images-amazon.com/images/I/41KbpPiGF7L._SX324_BO1,204,203,200_.jpg"
}

Repo.insert! %Book{
  title: "Elixir in Action",
  author: "Saša Jurić",
  cover_image_url: "https://images.manning.com/255/340/resize/book/5/2e8efb1-9e6f-462c-9487-04eac07ea623/juric.png"
}

Repo.insert! %Book{
  title: "Programming Phoenix",
  author: "Chris McCord, Bruce Tate, and José Valim",
  cover_image_url: "https://imagery.pragprog.com/products/452/phoenix_xlargebeta.jpg"
}

{% endhighlight %}


Run the script to add the data to our development database;

    mix run priv/repo/seeds.exs

Now, we should have a working JSON API. Let's test it. First, start the application;

    mix phoenix.server

Now, in another terminal, let's make a call to get the list of books;

    curl http://localhost:4000/api/books | python -m json.tool

The ` | python -m json.tool` is just a JSON pretty-printer. Leave it out if you don't have it installed.

This should give us the following output;

{% highlight json %}

{
    "data": [
        {
            "author": "Atul Gawande",
            "cover_image_url": "http://ecx.images-amazon.com/images/I/41KbpPiGF7L._SX324_BO1,204,203,200_.jpg",
            "id": 1,
            "title": "The Checklist Manifesto"
        },
        {
            "author": "Sa\u0161a Juri\u0107",
            "cover_image_url": "https://images.manning.com/255/340/resize/book/5/2e8efb1-9e6f-462c-9487-04eac07ea623/juric.png",
            "id": 2,
            "title": "Elixir in Action"
        },
        {
            "author": "Chris McCord, Bruce Tate, and Jos\u00e9 Valim",
            "cover_image_url": "https://imagery.pragprog.com/products/452/phoenix_xlargebeta.jpg",
            "id": 3,
            "title": "Programming Phoenix"
        }
    ]
}

{% endhighlight %}


So, the list call works. How about the `show` call, to get data for a single book?

    curl http://localhost:4000/api/books/1 | python -m json.tool

This should produce;


{% highlight json %}
{
    "data": {
        "author": "Atul Gawande",
        "cover_image_url": "http://ecx.images-amazon.com/images/I/41KbpPiGF7L._SX324_BO1,204,203,200_.jpg",
        "id": 1,
        "title": "The Checklist Manifesto"
    }
}
{% endhighlight %}

OK, so now we have a working, if basic, API backend.

In the next part of this series, we'll look at the more interesting part - building a React.js frontend.

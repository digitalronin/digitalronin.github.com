---
layout: post
title: "React.js from scratch"
description: ""
category:
tags: react.js
---

<center>
<p>
<img src="https://facebook.github.io/react/img/logo.svg" width="150" height="100" />
</p>
</center>

I've started using React.js on a rails project, and I really like the way it lets me organise front-end code into a individual files, rather than having view code in one file, tightly coupled to javascript code from a completely different file.

That's all great, but I'm depending on rails and the asset pipeline, along with the react-rails gem, to make everything work, and I didn't really understand what each piece was doing. So, I decided to try and put together a React.js application from scratch, only adding the tools I really need.

## The goal

Create a web application that serves a page containing a React.js component.

That's it. No ajax calls, no backend data store, no flux architecture. Just create a react component and put it on a web page. But, I want to do this in such a way that I can add more advanced features as and when I choose.

I'm also going to do all this in containers, because Docker, and I'm going to use make to build everything.

## Step 1: The web server

I'm using Sinatra for this, because it's a lightweight system that I'm reasonably familiar with. Here are the files I'll be starting with;


Gemfile:

    source "https://rubygems.org"
    gem "sinatra"


app.rb


    #!/usr/bin/env ruby

    require 'bundler/setup'
    require 'sinatra'


public/index.html


    <html>
      <head>
      </head>
      <body>
        <h1>Hello, world</h1>
      </body>
    </html>


So, we have a Sinatra app which does nothing but serve up a static HTML file. Now let's create our docker image and run it.


Dockerfile


    FROM ruby:2.2

    RUN mkdir -p /app
    WORKDIR /app

    COPY Gemfile Gemfile.lock ./
    RUN gem install bundler && bundle install --jobs 20 --retry 5

    # Expose port 4567 to the Docker host, so we can access it
    # from the outside.
    EXPOSE 4567

    # The main command to run when the container starts. Also
    # tell sinatra to bind to all interfaces by default.
    CMD ["bundle", "exec", "./app.rb", "-o", "0.0.0.0"]


That's pretty straightforward, but we don't have a Gemfile.lock yet. We're also going to need a way to build and run the docker image.


Makefile


    IMG_TAG   := react-img
    CONTAINER := react-cnt

    # Run bundler in the docker image to create Gemfile.lock
    bundle:
      docker run --rm \
        -v $$(pwd):/app \
        -w /app \
        ruby:2.2 gem install bundler && bundle install --jobs 20 --retry 5

    # Build the docker image which runs the app.
    image:
      docker build -t $(IMG_TAG) .

    # Run the docker image, mounting pwd as /app
    run:
      docker run --rm \
        --net  host \
        --name $(CONTAINER) \
        -e TERM=vt100 \
        -v $$(pwd):/app \
        $(IMG_TAG)


Let's get it working;


    $ make bundle
    $ make image
    $ make run


Now, we can visit the relevant URL and see our Hello, World page. I'm using boot2docker, so I need to access the page via the IP of the boot2docker VM

    http://192.168.59.103:4567/index.html

That IP is the output of;

    $ boot2docker ip

The IP might be different on your machine.

If you're not using boot2docker, then the URL should be;

    http://127.0.0.1:4567/index.html


## Step 2: React.js

That seems like a lot of work for a very minor result, but now we've got a good foundation on which to build.


Let's replace the <h1> with a react component;


public/index.html

    <html>
      <head>
        <script src="https://fb.me/react-0.13.3.js"></script>
        <script src="/application.js"> </script>
      </head>
      <body>
        <div id="react-root" />
      </body>
    </html>


The 'react-root' div is a placeholder. We're going to render our react component there when the page loads.

We're fetching the React.js library from Facebook, and we've told our app to include a javascript file;

    public/application.js

That file doesn't exist yet, but that's where all the javascript will be which defines our react component and renders it into the page. In a real application, you will probably want to organise your files differently, but I'm just going to keep things simple, for now.

This is our component;


components/hello_world.jsx

     var HelloWorld = React.createClass({
       render() {
         return <h1>Hello, React.js world</h1>;
       }
     });


We need to tell our application to render that component into our page. Let's create another component to do that


components/application.jsx


    window.onload = function () {
      React.render(<HelloWorld />, document.getElementById('react-root'));
    }


### Build tools

We need to turn our JSX components into valid javascript. At the time of writing, the React.js documentation has lots of references to something called "react-tools" for this, but if you dig a bit further, that's been deprecated.

The current way to convert jsx into javascript is to use [babel](https://babeljs.io/), so we need to add that to our project. We only need babel to create our application.js file, so we could create a separate docker image containing our build tools, and keep our web application docker image the way it is. But, for this blog post, I'm just going to bundle the build tools with the web application.

To install babel, we need to have npm, and for that we need nodejs. The ruby docker image is based on Debian, so we can use apt to install the packages we need.

Here's what our Dockerfile looks like now;


Dockerfile:

    FROM ruby:2.2

    RUN mkdir -p /app
    WORKDIR /app

    COPY Gemfile Gemfile.lock ./
    RUN gem install bundler && bundle install --jobs 20 --retry 5

    RUN apt-get update && apt-get install -y \
      nodejs \
      npm

    RUN ln -s /usr/bin/nodejs /usr/bin/node
    RUN npm install -g babel

    # Expose port 4567 to the Docker host, so we can access it
    # from the outside.
    EXPOSE 4567

    # The main command to run when the container starts. Also
    # tell sinatra to bind to all interfaces by default.
    CMD ["bundle", "exec", "./app.rb", "-o", "0.0.0.0"]


Note the line which symlinks 'nodejs' to 'node'. Babel expects an executable called 'node' in the path, but the debian package calls it 'nodejs'. The symlink fixes this.

Once we've installed babel, we're going to want to run a shell on our image, so we can poke around. Add the following target to the Makefile;


    shell:
      docker run --rm \
        --name $(CONTAINER) \
        -e TERM=vt100 \
        -v $$(pwd):/app \
        -it $(IMG_TAG) /bin/bash


### Compiling application.js

Let's rebuild our image, and see what babel does for us;


    $ make image
    $ make shell

    # cat components/hello_world.jsx | babel

    "use strict";

    var HelloWorld = React.createClass({
      displayName: "HelloWorld",

      render: function render() {
        return React.createElement(
          "h1",
          null,
          "Hello, world"
        );
      }
    });


So, the output from babel is the javascript translation of our JSX component. It's also translated the ES6 'render() { ... }' into 'render: function() { ... }'

Now, we can build our application.js file like this;

    # cat components/*.jsx | babel > public/application.js

But, since we have make, let's get it to do all the work for us. Add this target to the Makefile;


    compile:
      docker run --rm \
        --name $(CONTAINER) \
        -v $$(pwd):/app \
        $(IMG_TAG) bash -c 'cat components/*.jsx | babel > public/application.js'


Now, we can do this;


    $ make compile
    $ make run

Visit the URL in your browser, and you should see a greeting from our React.js component.

I'm sure there are a lot of other ways we could have achieved the same result, probably with much less typing, but working through this exercise gave me a much clearer understanding of what the available build tools are doing for me and, more importantly, __why__. I hope you found this interesting and/or or useful, too.

The code for this post is available at;

    https://github.com/digitalronin/react-from-scratch



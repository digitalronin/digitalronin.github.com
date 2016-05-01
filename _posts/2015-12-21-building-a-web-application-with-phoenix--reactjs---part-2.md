---
layout: post
title: "Building a web application with Phoenix & React.js - Part 2"
description: ""
category:
tags: []
---

This post follows on from [Building a web application with Phoenix & React.js - Part 1](https://digitalronin.github.io/2015/12/20/building-a-web-application-with-phoenix--reactjs/) in which we covered setting up a Phoenix-powered JSON API

In this post, we will setup a separate folder to manage our frontend application. This will be a single-page application, powered by [React.js](https://facebook.github.io/react/index.html), which will consume our API.

For this example, I'm going to use [Browserify](http://browserify.org/index.html) to create a standalone sub-project.

### Configure Phoenix to serve our single-page application

The output of our build system will be a single javascript file, `main.js`, which we can serve from our Phoenix application by copying it to the directory `priv/static/` We will also need an HTML file, into which we will render our React application.

Edit `priv/static/index.html` and add the following content;

{% highlight html %}
<html>
  <head>
  </head>
  <body>
    <div id="react-root" />
    <script src="js/main.js"></script>
  </body>
</html>
{% endhighlight %}

The empty "react-root" div is where we will render our application.

The last step before we can start on our React application is to configure our Phoenix application to serve the `index.html` file. By default, Phoenix won't serve static HTML files, just CSS, images, fonts, etc.

Edit `lib/bookshelf/endpoint.ex` and look for this section, near the top;

{% highlight elixir %}
plug Plug.Static,
  at: "/", from: :bookshelf, gzip: false,
  only: ~w(css fonts images js favicon.ico robots.txt)
{% endhighlight %}

Add `index.html` to the list.

{% highlight elixir %}
  only: ~w(css fonts images js favicon.ico robots.txt index.html)
{% endhighlight %}

### Create the React.js application

Create a directory for our front-end application

    mkdir frontend
    cd frontend

We will use npm to manage our project dependencies, so we'll need a `package.json` file. Create it with the following content;

{% highlight json %}
{
  "name":     "bookshelf_frontend",
  "version":  "1.0.0"
}
{% endhighlight %}

Now install our dependencies;

    npm install --save react redux react-redux
    npm install --save-dev redux-devtools

The `--save` flag records the dependencies in our `package.json` file, and `--save-dev` saves redux-devtools as a development dependency.

### Add a simple React component
















To confirm we've got everything wired up correctly, we're going to create a "Hello, World!" React compoonent and display it.

Create a js directory, and a js/index.jsx file with the following content;

var React    = require('react')
var ReactDOM = require('react-dom')

{% highlight javascript %}
ReactDOM.render(
  <h1>Hello, World!</h1>,
  document.getElementById('react-root')
)
{% endhighlight %}

### Build the frontend

All our JSX components, and any other elements of our frontend application, will need to be combined into the `main.js` file in the static assets directory of our Phoenix application (this matches the `<script src="js/main.js"></script>` in our `index.html` file.

We will use [Browserify](http://browserify.org/index.html) to package up all the JSX and JS files and concatenate them into the `main.js` file.

If you don't already have it, install browserify like this;

    npm install -g browserify

Now use it to build our application and install it into our Phoenix application;

    browserify -t babelify js/index.jsx > ../priv/static/js/main.js

Now visit `http://localhost:5000/index.html` in your browser, and you should see "Hello, World!"

So, now we have our Phoenix application rendering a React.js component we created.

In the next post, we'll create a simple build system, and connect our React application to the API.


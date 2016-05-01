---
layout: post
title: "Redux Demo. App. - part 1"
description: ""
category:
tags: [javascript,react,redux]
---

<center>
<p>
<img src="https://upload.wikimedia.org/wikipedia/commons/5/57/React.js_logo.svg" width="150px" />
</p>
</center>

There is an excellent series of videos [here](https://egghead.io/lessons/javascript-redux-the-single-immutable-state-tree) which introduces React + Redux by building a basic Todo application.

I enjoyed these, but I wanted a way to apply the concepts to something more like a real world application. In the videos, all the source code is written in a single [jsbin](http://jsbin.com), with the important libraries included from CDNs, rather than being installed locally.

So, this post is my attempt to create the same application as a real application - i.e. with all the code in multiple files, libraries installed locally, and with a build system to compile everything for deployment.

I spent a long time trying to set this all up from scratch, adding packages and tools one at a time to build up the system. But, the current state of javascript tooling is a complete mess. So, in the end, I gave up playing javascript package Jenga, and started looking for a template project which had all the pieces wired up.

A depressing number of the projects I found didn't include a testing library, but in the end I found one that seems to have everything I want;

https://github.com/michaelcheng429/react-redux-fullstack-starter

Create our todo app;

git clone git@github.com:michaelcheng429/react-redux-fullstack-starter.git

mv react-redux-fullstack todo-app
cd todo-app
rm -rf .git
git init

npm install
npm run dev

http://localhost:8080/




I'm using the following tools/libraries;

* [NPM](https://www.npmjs.com/) because it's hard do anything Javascript-related without it
* [Babel](https://babeljs.io/) so that we can use modern ES6 syntax in our JS code
* [React](https://facebook.github.io/react/)
* [Redux](http://redux.js.org/)
* [React-Redux](https://github.com/rackt/react-redux) - a separate library that lets you tie react and redux together
* [Sass](http://sass-lang.com/) because I like it better than plain CSS
* [Webpack](https://webpack.github.io/) as the build system

You will need [NodeJS](https://nodejs.org/en/) installed (which provides the npm command).

# Set up the project

{% highlight bash %}
mkdir redux-todo-app
cd redux-todo-app
npm init
{% endhighlight %}

Just hit enter in response to all the prompts, to accept the defaults and create the `package.json` file.

# Install dependencies

{% highlight bash %}
npm install --save-dev webpack css-loader style-loader node-sass sass-loader
{% endhighlight %}

# Configure the build system

Let's start by getting a trivial "hello world" example to build.

{% highlight bash %}
mkdir -p app/src/js app/assets
{% endhighlight %}

Edit `app/index.html` and enter the following content;

{% highlight html %}
<html>
  <head></head>
  <body>
    <script src="assets/index.js"></script>
  </body>
</html>
{% endhighlight %}

We'll keep all our source code in `app/src`, and the compiled code will be in `app/assets/index.js`.

For now, all the `index.html` file does is load in the compiled javascript.

Edit `app/src/js/root.js` and enter the following content;

{% highlight javascript %}
document.write("Hello, world!")
{% endhighlight %}

Now we need to configure our build system to compile `app/src/root.js` into `app/assets/index.js`

Edit `webpack.config.js` and add the following content;

{% highlight javascript %}
module.exports = {
  entry: "./app/src/js/root.js",
  output: {
    path: __dirname + "/app/assets",
    filename: "index.js"
  },
};
{% endhighlight %}

This tells webpack that it should compile `app/src/js/root.js` and write the resulting JS code into `app/assets/index.js`

Now, we should be able to compile the code, like this;

{% highlight bash %}
./node_modules/.bin/webpack --progress --colors
{% endhighlight %}

The `--progress` and `--colors` options just make the output nicer, they're not necessary.

You should see a nice, green message saying that `app/assets/index.js` has been built.

Now, if you open `app/index.html` in your browser, you should see the "Hello, world!" message.

Rather than typing that webpack command every time, let's add a build task to npm. Edit `package.json` and update the "scripts" section, to replace this;

{% highlight javascript %}
"scripts": {
  "test": "echo \"Error: no test specified\" && exit 1"
},
{% endhighlight %}

...with this;

{% highlight javascript %}
  "scripts": {
    "build": "./node_modules/.bin/webpack --progress --profile --colors"
  },
{% endhighlight %}

Now, we can compile our project like this;

{% highlight bash %}
npm run build
{% endhighlight %}

# Use ES6

We want to use the latest ES6 syntax in our JS code, so we'll need to add a transpiler to our project.

{% highlight bash %}
npm install --save-dev babel-core babel-loader
{% endhighlight %}

Now we need to tell webpack to use the transpiler on all .js files. Edit `webpack.config.js` and add a new section below the output section, like this;

{% highlight javascript %}
module.exports = {
  entry: "./app/src/js/root.js",
  output: {
    path: __dirname + "/app/assets",
    filename: "index.js"
  },
  module: {
    loaders: [
      {
        test:      /\.js$/,
        loaders:   ['babel'],
        excludes:  /node_modules/

      }
    ]
  }
};
{% endhighlight %}

Let's check that it's working. Edit `app/src/js/root.js` and replace the contents with this;

{% highlight js %}
var obj = {
  hello() {
    document.write("Hello, ES6 world!")
  }
}

obj.hello()

{% endhighlight %}

That's ES6 function declaration syntax, so it will only work if it's being transpiled correctly.

{% highlight bash %}
npm run build
open app/index.html
{% endhighlight %}

You should see "Hello, ES6 world!" in your browser.

# Switch to React.js

Now we should be able to start using React components, so let's try that.

Webpack needs another loader, to allow it to handle React's JSX syntax

{% highlight bash %}
npm install --save-dev jsx-loader
{% endhighlight %}

We also need to install react and react-dom;

{% highlight bash %}
npm install --save-dev react react-dom
{% endhighlight %}

We need a DOM element at which to mount our React application. Edit `app/index.html` and replace the content with this;

{% highlight html %}
<html>
  <head></head>
  <body>
    <div id="root"></div>
    <script src="assets/index.js"></script>
  </body>
</html>
{% endhighlight %}

We don't need our `app/src/js/root.js` file anymore, so go ahead and delete that.

We're going to keep our react components in their own directory hierarchy;

{% highlight bash %}
mkdir -p app/src/js/react/components
{% endhighlight %}

Edit `app/src/js/react/components/root.jsx` and add the following content;

{% highlight javascript %}
var ReactDOM = require('react-dom')
var React    = require('react')

var Hello = require('./hello.jsx')

ReactDOM.render(
  <Hello greeting="Hello from React" />,
  document.getElementById('root')
)
{% endhighlight %}

This is a contrived example, just to demonstrate that we can pull in a separate react component from another file.

Edit `app/src/js/react/components/hello.jsx` and add the following content;

{% highlight javascript %}
var React = require('react')

var Hello = React.createClass({
  render() {
    return <h1>{this.props.greeting}</h1>
  }
})

module.exports = Hello
{% endhighlight %}

The entrypoint of our project is now the `root.jsx` file, not the previous `app/src/js/root.js` file (which we've deleted), so we need to update `webpack.config.js` accordingly.

We also need to tell webpack to use the correct loader for our jsx files.

So, `webpack.config.js` should now look like this;

{% highlight javascript %}
module.exports = {
  entry: "./app/src/js/react/components/root.jsx",
  output: {
    path: __dirname + "/app/assets",
    filename: "index.js"
  },
  module: {
    loaders: [
      {
        test:      /\.jsx$/,
        loaders:   ['babel', 'jsx'],
        excludes:  /node_modules/
      }
    ]
  }
};
{% endhighlight %}

Now, after you run the build, you should be able to view `app/index.html` in your browser and see "Hello from React"

The latest version of react allows us to simplify our Hello component. Because it just renders layout code based on its properties, we can replace the source of our `hello.jsx` file with this;

{% highlight javascript %}
var React = require('react')

var Hello = (props) => (<h1>{props.greeting}</h1>)

module.exports = Hello
{% endhighlight %}

Starting from scratch, we've created a project that let's us use ES6 and React.js with Webpack to build an application from individual React.js source files.

In the next post, we'll look at building the Redux TODO application.

The source code for this post is available here.


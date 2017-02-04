---
layout: post
title: "A Simple ES6 (ES2015) Javascript Project (webpack edition) - Part 1"
description: "Creating a simple project using ES2015 Javascript, with webpack"
category:
tags: [javascript]
image: "/images/webpack-logo.png"
---

This is a version of [another post][gulp-post] I wrote in 2016, but using [webpack][webpack] instead of [gulp][gulp]

In this post, I'm going to walk through creating a very simple Javascript project. The project itself is not going to do anything much, but the point (as always, with javascript) is to figure out how to get the build pipeline set up correctly. I'm going to try to use a minimum of components, and in the end I want the following;

* A static javascript application, deliverable as two files;

  * index.html
  * application.js

The application should work in all modern browsers, and should have its own stylesheet.

* When working on the site, I want to;

  * write my javascript using ES2015
  * keep my javascript classes in separate files

For the purposes of this exercise, all the application needs to do is write a message into a web page. The point is to use ES2015 to do that.

# Getting started

Let's start by setting up a fresh project;

~~~bash
$ mkdir hello-es2015
$ cd hello-es2015
$ git init
~~~

Let's add some directories

~~~bash
$ mkdir src dist
$ touch src/.gitkeep dist/.gitkeep
~~~

We're going to be adding some npm packages, but we don't want them in our git repo.

~~~bash
$ echo node_modules/ > .gitignore
~~~

Finally, we'll need an empty `package.json` file;

~~~json
{
}
~~~

Now let's add some source files;

`src/app.js`

~~~javascript
console.log("Hello from app.js")
~~~

`src/stylesheet.css`

~~~css
body {
  background-color:  black;
  font-family:       "Roboto","Helvetica Neue",Helvetica,Arial,sans-serif;
  color:             white;
  font-weight:       bold;
  margin:            20px 20px auto;
}

main {
  width: 95%;
  margin: auto;
}
~~~

`src/index.html`

~~~html
<html>
  <head>
    <meta name="viewport" content="width=500,initial-scale=1.0,user-scalable=yes">
    <title>Hello ES2015</title>
  </head>
  <body>
    <main>
      <p>This is not very interesting</p>
    </main>
  </body>
</html>
~~~

Let's commit what we've got, so far

~~~bash
$ git add .
$ git commit -m "Initial commit"
~~~

All very simple. If you open `src/index.html` in your browser, you should see an uninspiring web page with no styling and with nothing logged to the console.

# Webpack

We're going to need a build tool to take our separate javascript classes and combine them. We're also going to need to transpile the ES2015 javascript into the ES5 code supported by the majority of browsers.  So, let's create a build system to generate our `dist/` files.

We're going to use [webpack][webpack], so first we need to install it as a dependency;

~~~
$ npm install webpack --save-dev
~~~

The default configuration file for webpack is `webpack.config.js` so let's create that now;

~~~javascript
var path = require('path')

module.exports = {
  entry: './src/app.js',
  output: {
    filename: 'application.js',
    path: path.resolve(__dirname, 'dist')
  }
}
~~~

This says that `src/app.js` is the entrypoint of the source code for our application, and that we want the output bundle to be called `application.js` in the `dist/` folder. Now, when you run webpack, you should see output like this;

~~~bash
$ ./node_modules/webpack/bin/webpack.js

Hash: ea4ea2ad384024eb4abd
Version: webpack 2.2.1
Time: 66ms
         Asset     Size  Chunks             Chunk Names
application.js  2.54 kB       0  [emitted]  main
   [0] ./src/app.js 33 bytes {0} [built]
~~~

If you look in the `dist` folder, you should have an `application.js` file.

We need webpack to create the `index.html` in our dist folder. To do that, we need to install a webpack plugin;

~~~bash
npm install html-webpack-plugin --save-dev
~~~

By default, the html plugin will generate an `index.html` file from scratch, but I want to use our `src/index.html` file as a template. Change your `webpack.config.js` file to look like this;

~~~javascript
var path = require('path')
var HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: './src/app.js',
  output: {
    filename: 'application.js',
    path: path.resolve(__dirname, 'dist')
  },
  plugins: [new HtmlWebpackPlugin({ template: 'src/index.html' })]
}
~~~

Now, after you run webpack your `dist` folder should contain both an `application.js` file and an `index.html` file. If you open up the `index.html` file in a browser, you should see the web page, and some output on the javascript console.

The page doesn't have our styling, though. To fix that, we need to add a couple of webpack loaders so that webpack knows how to take our CSS file and bundle the styling into the `dist/application.js` file.

~~~bash
npm install --save-dev css-loader
npm install --save-dev style-loader
~~~

To use these, we need to add a `module` entry to our `webpack.config.js` file, like this;

~~~javascript
var path = require('path')
var HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: './src/app.js',
  output: {
    filename: 'application.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      }
    ]
  },
  plugins: [new HtmlWebpackPlugin({ template: 'src/index.html' })]
}
~~~

Webpack won't build anything we don't need, so we need to tell it that we want it to include our CSS. We can do that by modifying `src/app.js` like this;

~~~javascript
import css from './stylesheet.css'

console.log("Hello from app.js")
~~~

Now, when you run webpack, you should still have just the two files in `dist`, but webpack will have embedded the styles from `src/stylesheet.css` in the `application.js` file. Load up `dist/index.html` and it should have white text on a black background.

The source code for this blog post is available [here][source]

[webpack]: https://webpack.js.org
[gulp-post]: https://digitalronin.github.io/2016/07/06/simple-es6-project.html
[gulp]: http://gulpjs.com/
[source]: https://github.com/digitalronin/hello-es2015-webpack


---
layout: post
title: "A Simple ES6 (ES2015) Javascript Project"
description: "Creating a simple project using ES2015 Javascript, with gulp"
category:
tags: [javascript]
---

In this post, I'm going to walk through creating a very simple Javascript project. The project itself is not going to do anything much, but the point (as always, with javascript) is to figure out how to get the build and test pipelines set up correctly. I'm going to try to use a minimum of components, and in the end I want the following;

* A static javascript application, deliverable as three files;

  * index.html
  * application.js
  * stylesheet.css

The application should work in all modern browsers.

* When working on the site, I want to;

  * write my javascript using ES2015
  * keep my javascript classes in separate files
  * write and run unit tests for my classes

For the purposes of this exercise, all the application needs to do is write a message into a web page. The point is to use ES2015 to do that.

# Getting started

Let's start by setting up a fresh project (FYI, I'm using npm version 3.5.3);

~~~bash
$ mkdir hello-es2015
$ cd hello-es2015
$ git init
$ npm init
~~~

For now, just press return in response to all the prompts.

Let's add some directories

~~~bash
$ mkdir src dist
$ touch src/.gitkeep dist/.gitkeep
~~~

We're going to be adding some npm packages, but we don't want them in our git repo.

~~~bash
$ echo node_modules/ > .gitignore
~~~

Now let's add some source files;

`src/app.js`

~~~javascript
console.log("Hello from app.js");
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
    <link rel="stylesheet" href="stylesheet.css" />
  </head>
  <body>
    <main>
      <p>This is not very interesting</p>
    </main>
    <script src="application.js"></script>
  </body>
</html>
~~~

And let's commit what we've got, so far

~~~bash
$ git add .
$ git commit -m "Initial commit"
~~~

All very simple. If you open `src/index.html` in your browser, you should see an uninspiring web page.

Note that you *won't* see anything logged to the console, because we called our script `application.js` in the html tag, but our javascript source file is called `app.js` We'll fix that in the next step.

# Gulp

We're going to need a build tool to take our separate javascript classes and combine them. We're also going to need to transpile the ES2015 javascript into the ES5 code supported by the majority of browsers.  So, let's create a build system to generate our `dist/` files. For the files we've got right now, a simple `cp src/* dist/` would work. But, we're going to need something a bit more complicated pretty soon, so we'll use a proper build tool.

We're going to use [gulp.js](http://gulpjs.com/), installing it globally so that we can call `gulp` from the command-line, without having to type `./node_modules/gulp/bin/gulp.js` every time. We're also going to install it as a project dependecy, along with a couple of plugins.

~~~
$ npm install gulp-cli --global
$ npm install gulp gulp-concat del --save-dev
~~~

(For a proper introduction to gulp, check out [this article](https://markgoodyear.com/2014/01/getting-started-with-gulp/))

In order to use gulp, we need to tell it what to do via a `gulpfile.js` so create one with the following content;

~~~javascript

var gulp   = require('gulp'),
    concat = require('gulp-concat'),
    del    = require('del');

gulp.task('default', ['clean'], function() {
  gulp.start('build-js', 'copy-css', 'copy-html');
});

gulp.task('clean', function() {
  return del('dist/*');
});

gulp.task('build-js', function() {
  return gulp.src('src/**/*.js')
    .pipe(concat('application.js'))
    .pipe(gulp.dest('dist/'));
});

gulp.task('copy-css', function() {
  return gulp.src('src/**/*.css')
    .pipe(gulp.dest('dist/'));
});

gulp.task('copy-html', function() {
  return gulp.src('src/**/*.html')
    .pipe(gulp.dest('dist/'));
});

~~~

This loads our gulp plugins, then defines tasks to build our `application.js` file (`build-js`), and copy our CSS and HTML files. The `default` task is what will happen if we just type `gulp` at the command-line, and the `clean` task is listed as a dependency of the default task, so we'll always be building into a clean `dist/` directory.

Run `gulp` and you should see something like this;

~~~bash
$ gulp
[17:40:59] Using gulpfile ~/hello-es2015/gulpfile.js
[17:40:59] Starting 'clean'...
[17:40:59] Finished 'clean' after 5.78 ms
[17:40:59] Starting 'default'...
[17:40:59] Starting 'build-js'...
[17:40:59] Starting 'copy-css'...
[17:40:59] Starting 'copy-html'...
[17:40:59] Finished 'default' after 12 ms
[17:40:59] Finished 'build-js' after 30 ms
[17:40:59] Finished 'copy-html' after 20 ms
[17:40:59] Finished 'copy-css' after 22 ms
~~~

Now if you open `dist/index.html` in your browser, you should see the same web page, and this time you should also see a log message `Hello from app.js` in the console.

# ES2015

We haven't done anything using ES2015 javascript features yet. Let's fix that now.

Edit your `src/index.html` file, and remove the contents of the `main` tag, so that it's just `<main></main>`

Then replace `src/app.js` with this;

~~~javascript
import Hello from './hello'

(new Hello({
  target: document.getElementsByTagName('main')[0]
})).run();
~~~

...and create a `src/hello.js` file containing this;

~~~javascript
class Hello {

  constructor(config) {
    this.target = config.target;
  }

  run() {
    this.target.innerHTML = `
      <p>
        Hello from ES2015
      </p>
    `;
  }
}

export default Hello;
~~~

When you run `gulp` again and reload your browser, you should see nothing but a black page, with a javascript error in the console like this;

`application.js:1 Uncaught SyntaxError: Unexpected token import`

We need to modify our build pipeline to transpile our new ES2015 code to ES5. To do that, we'll use [babel](https://babeljs.io/)

~~~bash
$ npm install babel-cli babel-preset-es2015 babelify browserify vinyl-source-stream
~~~

create a `.babelrc` file containing this;

~~~javascript
{
  presets: ["es2015"]
}
~~~

Now that we have babel, we can convert our gulpfile to ES2015 as well. Rename `gulpfile.js` to `gulpfile.babel.js` and edit it to look like this;

~~~javascript
(() => {
  'use strict';
})();

import gulp from "gulp";
import browserify from "browserify";
import source from "vinyl-source-stream";
import del from "del";

gulp.task('default', ['clean'], () => {
  gulp.start('build-js', 'copy-css', 'copy-html');
});

gulp.task('clean', () => {
  return del('dist/*');
});

gulp.task('build-js', () => {
  return browserify("src/app.js")
    .transform("babelify")
    .bundle()
    .pipe(source("application.js"))
    .pipe(gulp.dest("dist"));
});


gulp.task('copy-css', () => {
  return gulp.src('src/**/*.css')
    .pipe(gulp.dest('dist/'));
});

gulp.task('copy-html', () => {
  return gulp.src('src/**/*.html')
    .pipe(gulp.dest('dist/'));
});

~~~

Run `gulp` again, and then refresh your browser, and you should see "Hello from ES2015"

# Testing

The last thing I want to do is get some tests running. We're going to use the [Mocha](https://mochajs.org) test framework, with the [Chai](http://chaijs.com/) assertion library.

First, let's create a simple test. Edit your `src/hello.js` file and add a method we can test, called `ten`;

~~~javascript
class Hello {

  constructor(config) {
    this.target = config.target;
  }

  run() {
    this.target.innerHTML = `
      <p>
        Hello from ES2015
      </p>
    `;
  }

  ten() {
    return 10;
  }
}

export default Hello;
~~~

Impressive, isn't it? But, it gives us an instance method we can target in a unit test.

Now install mocha and chai;

~~~
$ npm install mocha gulp-mocha chai --save-dev
~~~

Create a directory called `test` and then a file `test/hello_test.js`;

~~~javascript
import { expect } from 'chai';
import Hello from '../src/hello'

describe("A simple test", () => {
  let hello;

  beforeEach(() => {
    hello = new Hello({});
  });

  it("should return ten", () => {
    expect(hello.ten()).to.eq(10);
  });

});
~~~

Now add a task in our `gulpfile.babel.js` file to run the tests;

~~~javascript
...
import mocha from "gulp-mocha";   // <-- add this line
...
gulp.task('test', () => {
  return gulp.src('test/**/*_test.js', { read: false })
    .pipe(mocha({reporter: 'dot'}));
});
...
~~~

That's it. Now we can run our test with `gulp test`

Because gulp is already configured to use babel to transpile ES2015 files, there's nothing else we need to do.

# Conclusion

There's a lot more we could do with these tools, such as setting up gulp to watch for changes and run our tests, but the point of this post was to show you how to put the pieces together. I hope you found it useful.

The final source code for this post is available [here](https://github.com/digitalronin/hello-es2015)

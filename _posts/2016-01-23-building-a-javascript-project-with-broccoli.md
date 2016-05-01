---
layout: post
title: "Building a Javascript project with Broccoli"
description: ""
category:
tags: [javascript]
---

<center>
<p>
<img src="http://broccolijs.com/logo-256-1151e939db4b4d6a2947eafd283998b2.png" width="150px" />
</p>
</center>

This blog post is my latest attempt at putting together a JavaScript build pipeline to create an application using ES6 and a unit testing framework.

The idea is to create a single page application which will then consume an API. So, I want the output from my build pipeline to be a single JS file, and a single CSS file.

This all seems a very basic to me, and yet building it up from scratch, one piece at a time, has proven to be a challenge.

This time, I am using  [broccoli](http://broccolijs.com/).

### Links

The following links have been very helpful, but please be aware that the examples shown on these pages don't seem to be entirely up to date.

[http://broccolijs.com/](http://broccolijs.com/)

[https://github.com/givanse/broccoli-babel-examples](https://github.com/givanse/broccoli-babel-examples)

[https://github.com/jayphelps/broccoli-babel-boilerplate](https://github.com/jayphelps/broccoli-babel-boilerplate)

### Start

{% highlight bash %}
mkdir broccoli-test
cd broccoli-test
npm init
{% endhighlight %}

Just hit enter in response to all the prompts.

{% highlight bash %}
npm install --save-dev broccoli broccoli-cli broccoli-funnel
touch Brocfile.js
mkdir src
{% endhighlight %}

Edit `src/index.js`

{% highlight javascript %}
console.log("Hello, world!")
{% endhighlight %}

Edit `Brocfile.js`

{% highlight javascript %}
module.exports = 'src'
{% endhighlight %}

That's enough to enable us to do a very basic test and confirm that our build system is working.

The JavaScript ecosystem has an embarrassment of build tools. We could use the `package.json` file as the core of our build system, defining tasks in the `scripts` section of the file. But, the longer I spend programming, the more I appreciate the value of learning one tool well instead of many tools badly. So, I'm going to use `make` to glue all of these pieces together.

Edit `Makefile`

{% highlight make %}
run: dist/index.js
  @node dist/index.js

dist/index.js: src/index.js
  @make clean
  ./node_modules/.bin/broccoli build dist

clean:
  @rm -rf dist || true
{% endhighlight %}

(If you want to learn more about make, I highly recommend [this gist](https://gist.github.com/isaacs/62a2d1825d04437c6f08))

Now, we can run a build like this;

{% highlight bash %}
$ make
./node_modules/.bin/broccoli build dist
Hello, world!
{% endhighlight %}

Nothing too surprising, but it confirms that broccoli is building `dist/index.js` from `src/index.js`

### ES6

Now let's enable using ES6 javascript syntax. To do that, we'll have to add a transpiler to convert our ES6 javascript to ES5. I'm going to use babel.

{% highlight bash %}
npm install --save-dev broccoli-babel-transpiler
{% endhighlight %}

Now, let's convert our `index.js` file to use ES6 syntax. Edit `src/index.js`

{% highlight javascript %}
(() => {
  console.log("Hello, ES6 world!")
})()
{% endhighlight %}

Note: `node src/index.js` will still work, because node understands ES6 syntax. But, if we tried to use that javascript in a web page, it wouldn't work in some browsers. You can see details of exactly which browsers support which ES6 features [here](https://kangax.github.io/compat-table/es6/)

We need to edit the `Brocfile.js` to use the transpiler;

{% highlight javascript %}
var babel = require('broccoli-babel-transpiler')

transpiler = babel('src')

module.exports = transpiler
{% endhighlight %}

Now, run the build again;

{% highlight bash %}
$ make
./node_modules/.bin/broccoli build dist
Hello, ES6 world!
{% endhighlight %}

To prove that the transpiler is working, look at `dist/index.js`

{% highlight javascript %}
"use strict";

(function () {
    console.log("Hello, ES6 world!");
})();
{% endhighlight %}

### Multiple files

Compiling one file isn't going to get us very far, so let's extend our build system so that it combines multiple files into `dist/index.js`

To do that, we need another couple of broccoli plugins;

{% highlight bash %}
npm install --save-dev broccoli-concat broccoli-merge-trees
{% endhighlight %}

Create `src/another.js`

{% highlight javascript %}
(() => {
    console.log("Another file")
})()
{% endhighlight %}

Edit `Brocfile.js`

{% highlight javascript %}
var babel  = require('broccoli-babel-transpiler')
var funnel = require('broccoli-funnel')
var concat = require('broccoli-concat')

var appJs = babel('src')

// Concatenate all the JS files into a single file
appJs = concat(appJs, {
  inputFiles: ['*.js'],
  outputFile: 'index.js'
})

module.exports = appJs
{% endhighlight %}

<!--- '* --->

{% highlight bash %}
$ make
./node_modules/.bin/broccoli build dist
Another file
Hello, ES6 world!
{% endhighlight %}


### ES6 Polyfill

There are a lot of nice features in ES6 that are supported on the server side, but not yet on the client side, e.g. [generator functions](https://facebook.github.io/regenerator/)

If we want to use those in our code, we need to add a polyfill to translate the unsupported functions. Babel has such a polyfill, but we need to jump through a few hoops to get it to work.

First, let's add some code to `src/index.js` which uses one of these unsupported features;

{% highlight javascript %}
function* counter(start, stop) {
  for (var i = start; i < stop; i += 1) {
    yield i
  }
}

(() => {
    console.log("Hello, ES6 world!")
})()

for (let i of counter(1, 5)) {
  console.log(`count is ${i}`)
}
{% endhighlight %}

<!--- '* --->

If you try to run make now, you'll get an error like this; `ReferenceError: regeneratorRuntime is not defined`

Edit `Brocfile.js`

{% highlight javascript %}
var babel      = require('broccoli-babel-transpiler')
var funnel     = require('broccoli-funnel')
var concat     = require('broccoli-concat')
var mergeTrees = require('broccoli-merge-trees')

var appJs = babel('src')

// // Grab the polyfill file provided by the Babel library
var babelPath = 'node_modules/babel-core'

var browserPolyfill = funnel(babelPath, {
  files: ['browser-polyfill.js']
})

// Add the Babel polyfill to the tree of transpiled files
appJs = mergeTrees([browserPolyfill, appJs])

// Concatenate all the JS files into a single file
appJs = concat(appJs, {
  inputFiles: ['browser-polyfill.js', '*.js'],
  outputFile: 'index.js'
})

module.exports = appJs

{% endhighlight %}
<!--- '* --->

Now, we can run our example;

{% highlight bash %}
$ make
./node_modules/.bin/broccoli build dist
Another file
Hello, ES6 world!
count is 1
count is 2
count is 3
count is 4
{% endhighlight %}

Note: AFAICT, [this pull request](https://github.com/babel/broccoli-babel-transpiler/pull/42) should mean we can just add a second parameter to our babel call, like this; `babel('src', { browserPolyfill: true })` instead of the changes above, but it doesn't seem to work, for me.


### Use classes defined in separate files

We're going to want to put our classes into separate files, and refer to them in our code. Let's set that up, now.

{% highlight bash %}
mkdir src/classes
{% endhighlight %}

Edit `src/classes/my_class.js`;

{% highlight javascript %}
export default class MyClass {
  foo() {
    console.log("MyClass says foo!")
  }
}
{% endhighlight %}

We'll call our new class from `src/index.js` Add these lines at the bottom of the file;

{% highlight javascript %}

var mc = new MyClass()
mc.foo()

{% endhighlight %}

Now we need to tell broccoli to include the files in our new `classes` directory.

Edit `Brocfile.js` and change the `inputFiles` line;

{% highlight javascript %}
inputFiles: ['browser-polyfill.js', 'classes/*.js', '*.js'],
{% endhighlight %}

Note: We have to put the `classes/*.js` section before the section that includes `index.js` so that the combined javascript file will define `MyClass` before we try to use it.

{% highlight bash %}
$ make
Another file
Hello, ES6 world!
count is 1
count is 2
count is 3
count is 4
MyClass says foo!
{% endhighlight %}

### Testing

The last thing I want to do for now is to add a test framework. I'm going to use [mocha](https://mochajs.org/) with the [chai](http://chaijs.com/) library;

{% highlight bash %}
npm install --save-dev chai mocha
{% endhighlight %}


{% highlight bash %}
mkdir -p test/unit/classes
{% endhighlight %}

Edit `test/init.js`

{% highlight javascript %}
'use strict';

require('babel/register')({
  stage: 0
});
{% endhighlight %}

Edit `test/mocha.opts`

{% highlight javascript %}
test/unit/**/*_spec.js
{% endhighlight %}
<!--- '** --->

Let's add a method to `src/classes/my_class.js` which returns a value we can test for;

{% highlight javascript %}
export default class MyClass {
  foo() {
    console.log("MyClass says foo!")
  }

  something() {
    return "whatever"
  }
}
{% endhighlight %}

Now let's write a test in `test/unit/classes/my_class_spec.js`

{% highlight javascript %}
import { expect } from 'chai'
import MyClass from '../../../src/classes/my_class'

describe('MyClass', () => {
  it('does something', () => {
    var myclass = new MyClass()
    expect(myclass.something()).to.equal('whatever')
  })
})
{% endhighlight %}

The test framework isn't going through broccoli, so we need to tell mocha to transpile any code it sees.

Edit `Makefile` and add these lines;

{% highlight make %}
test:
  ./node_modules/.bin/mocha --compilers js:babel-core/register

.PHONY: test

{% endhighlight %}

Now, we can run our tests;

{% highlight bash %}
$ make test
./node_modules/.bin/mocha --compilers js:babel-core/register


  MyClass
    ✓ does something


  1 passing (10ms)
{% endhighlight %}

Note: In the broccoli-babel-boilerplate example I mentioned earlier, the test setup includes [jshint](http://jshint.com/), but I couldn't get this to work in my project - jshint would simply hang and never complete. So, I'm presenting this example without it. If you manage to get it working, please let me know how in the comments.

I'd like to add CSS using SASS and React.js and use this as the starting point for building a real application, but I'm going to leave this here for now. Depending on how far I get, there may be future posts on this subject.

The code for this post is available [here](https://github.com/digitalronin/broccoli-test)


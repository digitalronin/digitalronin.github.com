---
layout: post
title: "Redux Demo. App.   part 2"
description: ""
category:
tags: [react,redux]
image: "http://www.pcgamesn.com/sites/default/files/Metro-Redux-Collection-Is-Real-Full-Reveal-Coming-at-E3-2014.jpg"
---

In [part 1](https://digitalronin.github.io/2016/01/16/redux-demo-app/) we created a build system that lets us write an application using React.js components. Now let's extend that.

# Add a test framework

The first thing I want is to be able to write tests for the application, so I'm going to need a test library and a way of running the tests.

I'm going to use [Karma](

npm install --save-dev karma jasmine jasmine-core karma-webpack karma-jasmine karma-chrome-launcher


mkdir -p app/spec/js/react/components


./node_modules/.bin/karma init



I'm going to use [Jasmine](https://jasmine.github.io/)

{% highlight bash %}
npm install --save-dev jasmine-node
{% endhighlight %}

We need somewhere to put our tests;

{% highlight bash %}
mkdir spec
{% endhighlight %}

Configure npm to run our tests for us by adding a spec line to the scripts section of our `package.json` file;

{% highlight json %}
  "scripts": {
    "build": "./node_modules/.bin/webpack --progress --profile --colors",
    "spec":  "./node_modules/.bin/jasmine-node spec/"
  },
{% endhighlight %}

Edit `spec/test_spec.js` and add the following content;

{% highlight javascript %}
describe("A suite", () => (
  it("contains spec with an expectation", () => (
    expect(true).toBe(true)
  ))
))
{% endhighlight %}

Now we can run our test like this;

{% highlight bash %}
npm run spec
{% endhighlight %}

# Testing our React component

Install the react test utilities;

{% highlight bash %}
npm install --save-dev fs jasmine-core react-addons-test-utils
{% endhighlight %}

Let's write a test for our Hello component;

{% highlight bash %}
mkdir -p spec/react/components
{% endhighlight %}

Edit `spec/react/components/hello_spec.js`

{% highlight javascript %}
var React = require('react');
var Hello = require('../../../app/src/js/react/components/hello.jsx');

describe("Hello", () => (
  it("Renders a message", () => (
    expect(true).toBe(true)
  ))
))
{% endhighlight %}


If we try to run our tests now, we'll get an error `[SyntaxError: Unexpected token <]` because our test code is not being pre-processed by webpack and babel to turn JSX syntax into javascript.

We need to add a new entrypoint to `webpack.config.js` so that webpack will build our tests into something we can run;

Edit `webpack.config.js`;

{% highlight javascript %}
# CONTENT
{% endhighlight %}






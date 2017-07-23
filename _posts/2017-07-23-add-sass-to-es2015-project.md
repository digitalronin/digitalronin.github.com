---
layout: post
title: "Adding SASS to an ES6 (ES2015) Javascript Project"
description: ""
category:
tags: [javascript]
image: "/images/sass-logo.png"
---

This is a follow-up to an [earlier blog post][older-post] about setting up an ES6 project from scratch,
using [Webpack][webpack]. I would recommend reading that post first, before diving into this one.

In this post, I'm going to demonstrate how to switch to using [Sass][sass] instead of writing plain
CSS to manage the styles for your project.

First of all, let's add some styling in CSS, that we can convert to Sass later.

Open up `src/stylesheet.css` and add this at the bottom;

~~~css
.foo .bar {
  color: red;
}
~~~

Then, change `app/hello.js` to add some classes to the HTML it renders;

~~~javascript
class Hello {
  constructor(config) {
    this.target = config.target;
  }

  run() {
    this.target.innerHTML = `
      <div class="foo">
        <div class="bar">
          Hello from ES2015
        </div>
      </div>
    `;
  }
}

export default Hello
~~~

Now, after you build your project and open up `dist/index.html` in the browser, you should
see that the text "Hello from ES2015" is red.

Now, let's switch to Sass.

To do this, we're going to need some more plugins for webpack.

~~~bash
$ npm install --save-dev node-loader sass-loader
~~~

Rename `src/stylesheet.css` to `src/stylesheet.scss` and change the section we added to
SCSS syntax. I've also changed the colour to green, so that we can see a difference
when we view the final page;

~~~css
.foo {
  .bar {
    color: green;
  }
}
~~~

There's no `src/stylesheet.css` file anymore - we're going to explicitly tell webpack to
insert styles into the `dist/application.js` file instead, so remove this line from
`src/app.js`

~~~javascript
import css from './stylesheet.css'
~~~

Most of the changes we need to make are in `webpack.config.js`. Let's go through them.

There are two entry points for webpack now, so change this;

~~~javascript
entry: './src/app.js',
~~~

...to this;

~~~javascript
  entry: [
    './src/app.js',
    './src/stylesheet.scss'
  ],
~~~

In our module rules section, we need to remove the rule for `css` files, and
replace it with a new rule for `scss` files. So, remove this stanza;

~~~javascript
{
  test: /\.css$/,
  use: ['style-loader', 'css-loader']
},
~~~

...and replace it with this;

~~~javascript
{
  test: /\.scss$/,
  use: [
    'style-loader',
    'css-loader',
    'sass-loader'
  ]
},
~~~

That's it.

Now, when you build your project, you should see the text in green, so you know
your Sass is being compiled correctly.

[older-post]: https://digitalronin.github.io/2017/02/04/simple-es6-project.html
[webpack]: https://webpack.js.org
[sass]: http://sass-lang.com/

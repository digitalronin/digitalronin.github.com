---
layout: post
title: "Using React with Phoenix"
description: ""
category:
tags: []
image: "/images/phoenix_logo.png"
---

Adding [React][react] to a [Phoenix][phoenix] project should be pretty straightforward, according to the docs, but it gave me some trouble, and [I'm not the only one][mailing_list]

Things change pretty fast, especially at the intersection of Elixir and JavaScript. So, as at the end of 2016, here is how to get React working with a Phoenix application.

Start with a new Phoenix project;

~~~bash
mix phoenix.new hello_react

mix ecto.create

mix phoenix.server
~~~


Open up `web/templates/page/index.html.eex` and replace the entire contents with this;

~~~html
<div id="react-target">
  <h1>No react here</h1>
</div>
~~~

When you reload the page, you should see that message below the default Phoenix header.

Next, let's get some javascript code running, as per the [instructions][adding_js_docs] in the Phoenix documentation

Now, open up `web/static/js/app.js` and add this at the bottom of the file;

~~~javascript
export var App = {
  run: function(){
    console.log('javascript running')
  }
}
~~~


In `web/templates/layout/app.html.eex` find this line;

~~~html
<script src="<%= static_path(@conn, "/js/app.js") %>"></script>
~~~

...and add this below it;

~~~html
<script>require("web/static/js/app").App.run()</script>
~~~

Now, when you reload the page, you should see 'javascript running' logged to the console.

Now let's add a React component to the page.

First, shut down the server and install React;

~~~bash
npm install --save-dev react react-dom
~~~

Now edit `web/static/js/app.js` again, and change the section we just added to look like this;

~~~javascript
var HelloReact = React.createClass({
  render() {
    return(
      <h1>Hello from React</h1>
    )
  }
})

export var App = {
  run: function(){
    var element = document.getElementById("react-target")
    ReactDOM.render(<HelloReact />, element)
  }
}
~~~

According to the documentation, this should just work. But in my case, and perhaps yours too, I get the following error in the console when I try to run the app;

~~~bash
29 Dec 11:01:36 - error: Compiling of web/static/js/app.js failed. SyntaxError: web/static/js/app.js:Unexpected token (29:6)
  27 |   render() {
  28 |     return(
> 29 |       <h1>Hello from React</h1>
     |       ^
  30 |     )
  31 |   }
  32 | })
~~~

So, the JSX code we added, for our React component, is not being transpiled correctly. This is nothing to do with Phoenix - the error is happening during the asset build phase. You can confirm this by running;

    node_modules/.bin/brunch build

This should give you the same error (possibly with nicer syntax highlighting).

After a lot of messing around, the way I was able to fix this was as follows;

First, install the React preset for the [Babel][babel] transpiler;

    npm install --save-dev babel-preset-react

Next, add that to the babel section of the [brunch][brunch] build pipeline by editing `brunch-config.js`. Look for the `babel` section;

~~~javascript
// Configure your plugins
plugins: {
  babel: {
    // Do not use ES6 compiler in vendor code
    ignore: [/web\/static\/vendor/]
  }
},
~~~

Edit it to look like this (I don't know why we also need to add the es2015 preset, but this doesn't work without it);

~~~javascript
// Configure your plugins
plugins: {
  babel: {
    presets: ['es2015', 'react'],
    // Do not use ES6 compiler in vendor code
    ignore: [/web\/static\/vendor/]
  }
},
~~~

Now try the brunch build command again, and it should complete with no errors.

When you run your phoenix application, and reload the browser, you should see "Hello from React". You might see a quick flash of "No react here" when the original content appears, and is then replaced by javascript.

It took me a while to figure this out, so I hope this helps someone else.

[react]: https://facebook.github.io/react/
[phoenix]: http://www.phoenixframework.org/
[mailing_list]: https://groups.google.com/d/msg/phoenix-talk/WKRuHwvGnWg/UHf9QoL8AwAJ
[adding_js_docs]: http://www.phoenixframework.org/docs/static-assets
[babel]: https://babeljs.io/
[brunch]: http://brunch.io/

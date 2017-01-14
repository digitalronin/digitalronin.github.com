---
layout: post
title: "Ticket Poker API"
description: ""
category:
tags: [elixir,phoenix,react,javascript,ticket-poker]
image: "/images/poker.jpg"
---
Someone asked me about integrating [Ticket Poker][ticket-poker] with Jira.

I don't use Jira, but it got me thinking.

I want to minimise the amount of work required to get everyone to estimate a ticket, and I want to enable people
to integrate [Ticket Poker][ticket-poker] into other planning tools. So I've added a very simple API to [Ticket Poker][ticket-poker]. Here's how it works;

To create a ticket, you call the API with the UUID of your team, and the URL of the ticket you want to estimate, as a JSON document

{% highlight json %}
{
  "team_id": "uuid-of-your-team",
  "ticket_url": "url-of-the-ticket-to-estimate"
}
{% endhighlight %}

The response will be a JSON document with a single "url" key, which will be the URL of the ticket estimation page.

Share this with your team, as usual, to estimate the ticket.

{% highlight json %}
{
  "url": "http://ticket-poker.herokuapp.com/share.this.with.your.team",
}
{% endhighlight %}

Any tickets you create will inherit the current set of coders and point values from your team.

Here is an example of a bash script to create a ticket from the command-line;

{% highlight bash %}
#!/bin/bash

TEAM_ID=[UUID from your team\'s URL]

TICKET_URL=$1

curl -s -H "Accept: application/json" \
     -H "Content-Type: application/json" \
	 	 -X POST \
     -d "{\"team_id\":\"${TEAM_ID}\",\"ticket_url\":\"${TICKET_URL}\"}" \
     https://ticket-poker.herokuapp.com/api/tickets \
     | sed 's/{"url":"\(.*\)"}/\1/'
{% endhighlight %}

(The sed part at the end is just a quick and dirty way to extract the URL from the JSON response)

Save this to a file called, for example, create-ticket.sh and make it executable (be careful that the quotes are not converted to smart quotes if you copy and paste).

Don't forget to provide the correct UUID for your team, as TEAM_ID.

Then, you can create a new ticket like this;

{% highlight bash %}
./create-ticket.sh http://your-ticket-url.goes.here
{% endhighlight %}

If you use this to build any integrations with other planning tools, please let me know.

[ticket-poker]: https://digitalronin.github.io/2017/01/02/ticket-poker.html

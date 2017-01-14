---
layout: post
title: "Ticket Poker"
description: ""
category:
tags: [elixir,phoenix,react,javascript,ticket-poker]
image: "/images/poker.jpg"
---
I wrote a little web application to help teams estimate tickets (aka stories) during sprint planning.

In my current team, some people are often working remotely, so estimating is tricky. Slack or other chat tools are great, but if you estimate that way, people see each others' estimates as soon as they type them, so later choices are influenced by earlier ones.

This isn't ideal, plus I wanted an excuse to create a little hobby project, so I came up with [Ticket Poker][ticket-poker]

![Ticket Poker homepage](/images/ticket-poker1.png)

The idea is to make the process as quick, simple and painless as possible. No logins, no passwords, no account setup. Just enter the minimum possible amount of information and get on with the job.

At the same time, I wanted the application to offer particular set of features;

* Creating a new ticket should be as quick and easy as possible
* You should only need to enter your team details once
* Team and ticket URLs should be easy to share
* Teams can choose their own set of sizes
* Only team-members can estimate tickets
* Point estimates are hidden until everyone has chosen their estimate
* Realtime updates as team-members estimate the ticket

To achieve this, I've kept the app. as simple as possible. There are only two pages; team and ticket.

The homepage of the app is the team new/edit form. Here, you enter the details of your team, and you can also enter the URL of a ticket you want to estimate. When you hit submit, the next page you see will either be your team's unique page or, if you entered a ticket URL, it will be the unique page for that specific ticket.

Teams and tickets are identified by random [UUIDs][uuid], so the only way to see the page for a team or a ticket is to know its unique random ID. So, we can be confident that only people who should be viewing/updating a team/ticket are able to do so.

Whoever is going to be creating tickets to estimate should bookmark the team's URL, although the only thing you'll have to do if you forget it is to enter the team's details again.

To start estimating a ticket just paste its URL (or type a title) into the "New Ticket" field. Most distributed teams use some kind of online tool to store their tickets, so pasting the URL of a ticket was the easiest thing I could think of. For teams which use paper story cards, typing in the title of the story instead of a URL works, too.

When you create a ticket, its URL and the current set of team-members and point sizes is copied to a new ticket record, and a new page is displayed;

![Ticket page](/images/ticket-poker3.png)

The URL at the top (Ticket: http://....) is a link to the actual ticket - the one you pasted into the "New ticket" field.

The URL in the grey box is the URL of the page you're looking at, with a "copy to clipboard" icon. This is the URL you need to share with your team to enable them to estimate this ticket.

Below that is a set of estimate cards, one for each member of your team (at the time when you created the ticket).

To choose an estimate, each team-member just needs to click on the appropriate number on their row. As people choose their estimates, the page will update in realtime for everyone who is looking at it. Members' estimates are hidden until everyone has made their choice;

![Partially-estimated ticket](/images/ticket-poker4.png)

When everyone has chosen, the final estimates are revealed;

![Completed ticket](/images/ticket-poker5.png)

Estimates can be changed at any time, until consensus is reached.

I wrote this during the xmas break, so I haven't shown it to my team yet. I'm hoping they'll find it useful, and that you will, too. If you do, or if you have any feedback, I'd love to hear from you in the comments or on github, where you'll find the [source][source].

The app is [here][ticket-poker]

Happy New Year!


[uuid]: https://en.wikipedia.org/wiki/UUID
[ticket-poker]: https://ticket-poker.herokuapp.com/
[source]: https://github.com/digitalronin/ticket-poker

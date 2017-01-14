---
layout: post
title: "Scripting Pivotal Tracker"
description: ""
category:
tags: []
image: "https://www.pivotaltracker.com/marketing_assets/tracker-eba4f51a43e4837e9b9a68544c18190d925b64e103220e565c47378ae3536c53.svg"
---
We've been using [Ticket Poker][ticket-poker] for a while, in my current team, and we're pretty happy with it.

Now, after each planning session, I take the stories we create in [Pivotal Tracker][pivotal-tracker],
use a [command-line][ticket-poker-command-line] script to generate a [Ticket Poker][ticket-poker] ticket for each one,
then paste its URL back into the [Pivotal][pivotal-tracker] story.

![Pivotal Track Story](/images/pivotal-story.png)

That gets a bit repetitive, so I decided to write a script to do the work for me.

The process goes like this;

* Find all of the development stories in the [Pivotal Tracker][pivotal-tracker] project which haven't been estimated yet
* For each of those stories, check if it already has a [Ticket Poker][ticket-poker] ticket
* If it doesn't;
  * Create a new [Ticket Poker][ticket-poker] ticket via the [API][ticket-poker-api]
  * Add the URL of the new ticket to the [Pivotal Tracker][pivotal-tracker] story

In ruby, that could look something like this (assuming `project` is a class representing a [Pivotal Tracker][pivotal-tracker] project,
and `ticket_poker` is a class that exposes the [Ticket Poker API][ticket-poker-api]);

{% highlight ruby %}
  project
    .unestimated_stories(label: 'development')
    .each do |story|
      story.add_estimation_task(ticket_poker) unless story.has_estimation_task?
  end
{% endhighlight %}

The [Pivotal Tracker][pivotal-tracker] API is really easy to use.
Fetching the stories just requires GETting the [stories endpoint][stories-endpoint] of
their latest, stable REST API.

```
https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/stories
```

To filter for **unestimated** **development** stories, we just need to add a filter string as a querystring parameter;

```
label:"development" estimate:-1
```

We URL-encode that, and append it to the API URL as;

```
?filter=[encoded filter string]
```

To check if the story already has a [Ticket Poker][ticket-poker] estimation ticket,
check all the tasks belonging to the story, and see if any of them have "Ticket Poker" in their descriptions.

{% highlight ruby %}
class Story

  ...

  def has_estimation_task?
    tasks.map(&:description).grep(/ticket.poker/i).any?
  end

  ...

end
{% endhighlight %}

We can get all the tasks belonging to the story by GETting the [story tasks endpoint][story-tasks-endpoint];

```
https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/stories/$STORY_ID/tasks
```

To add a ticket estimation task to the story, we first use the [Ticket Poker API][ticket-poker-api] to create the
ticket, then POST to the Pivotal Tracker [story tasks endpoint][story-tasks-endpoint] to create the new task.

{% highlight ruby %}
class Story

  ...

  def add_estimation_task(ticket_poker)
    url = ticket_poker.create(self.url)
    @project.add_task(self, "Ticket Poker #{url}")
  end

  ...

end
{% endhighlight %}

Here, `ticket_poker` is an object that exposes the Ticket Poker API, and `@project` is a reference to a class representing
our Pivotal Tracker project.

You can see the full script on the [Ticket Poker API][ticket-poker-api] page
(click on 'Pivotal Tracker' in the list of API Integration Examples).

It should be quite straightforward to follow this same pattern to integrate with any other planning tools,
provided they have a suitable API. If you create any more integrations, please let me know and I'll add
them to the documentation.

[stories-endpoint]: https://www.pivotaltracker.com/help/api/rest/v5#Stories
[story-tasks-endpoint]: https://www.pivotaltracker.com/help/api/rest/v5#Story_Tasks
[ticket-poker]: https://digitalronin.github.io/2017/01/02/ticket-poker.html
[ticket-poker-api]: https://ticket-poker.herokuapp.com/api
[ticket-poker-command-line]: https://digitalronin.github.io/2017/01/10/ticket-poker-api.html
[pivotal-tracker]: https://www.pivotaltracker.com

---
layout: post
title: "London Bus Arrivals"
description: ""
category:
tags: [tfl-api,bus-arrivals]
image: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/London_Buses_-_Route_253.jpg/320px-London_Buses_-_Route_253.jpg"
---

Back in the dim and distant past (2011), [Transport for London][tfl] launched their Countdown API, which enabled finding out when the next buses would arrive at any given bus stop.

[James Darling][abscond] [created][james-blog-post] a fantastic, lightweight web application, bus.abscond.org, that I and many others really liked.

Sadly, that [died][shutdown-notice] in 2016.

[TFL] now have a new API, the [Transport for London Unified API][tfl-unified-api], which powers all their services.

They do expose live bus arrivals, via pages like [this one][tfl-trafalgar-square].

![TFL Bus Arrivals page](/images/tfl-page.png)

Unfortunately, they don't have anything as lightweight, elegant and usable as James' application. If you load the page
above on a mobile device it makes 66 different network requests, transferring a staggering 1.1MB of data.

Really, TFL?

Seriously, if anyone from [TFL][tfl] ever reads this, please, please, please go take a long look at the [GDS Digital Service Standard][gds-digital-service-standard]
and then go and fix your shit.

I really miss bus.abscond.org, so I decided to fork James' [TFL Live Bus][tfl-live-bus] code, and see if I could get it to work with the new API.

The result is [Bus Arrivals][bus-arrivals]

Here is the [equivalent page][bus-arrivals-trafalgar-square] to the TFL one I showed earlier. Currently, it makes 5 network requests, and transfers
11KB of data to provide the relevant information.

![Bus Arrivals page](/images/bus-arrivals-page.png)

As you might imagine, it loads faster, too - especially on a mobile device (which is the most important kind, for this sort of service).

Best of all, you get a bookmarkable URL for every stop. I tend to use the same few stops every week,
going to and from work, so that was an essential feature of bus.abscond.org which I really miss when trying to use the TFL service -
you can get bookmarkable pages out of it, but they certainly don't make it easy.

I hope people find this useful, at least until [TFL] make me shut it down.

If you want to help, the code is [here][bus-arrivals-repo].

[abscond]: http://abscond.org/
[bus-arrivals]: https://bus-arrivals.herokuapp.com/
[bus-arrivals-trafalgar-square]: https://bus-arrivals.herokuapp.com/stop/490013767A
[gds-digital-service-standard]: https://www.gov.uk/service-manual/service-standard
[james-blog-post]: http://berglondon.com/blog/2011/09/14/bringing-the-london-bus-network-home/
[shutdown-notice]: https://github.com/james/TFL-Live-Bus/issues/5
[tfl-bus-arrivals]: https://tfl.gov.uk/modes/buses/live-bus-arrivals
[tfl-live-bus]: https://github.com/james/TFL-Live-Bus
[tfl-trafalgar-square]: https://tfl.gov.uk/bus/stop/490013767A/trafalgar-sq-charing-cross-stn
[tfl-unified-api]: https://api.tfl.gov.uk/
[tfl]: https://tfl.gov.uk/
[bus-arrivals-repo]: https://github.com/digitalronin/TFL-Live-Bus

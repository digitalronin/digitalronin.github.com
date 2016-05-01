---
layout: post
title: "Docker image for s3cmd"
description: "A lightweight docker image providing s3cmd"
category:
tags: docker,s3cmd
---

I've been doing a lot of work with [docker](https://www.docker.com/), recently, and really enjoying it.

I'm trying to keep my docker hosts as minimal as possible, and to avoid installing extra packages on them. I often need to fetch assets from Amazon S3, so I searched [dockerhub.com](https://www.dockerhub.com) for a docker image that provides s3cmd. The trouble is, all the ones I could find were based on the Ubuntu or Debian docker images. I wanted something more lightweight, so I built one based on [Alpine Linux}(http://alpinelinux.org/)

You can find the digitalronin/s3cmd image on [dockerhub](https://registry.hub.docker.com/u/digitalronin/s3cmd/) and the Dockerfile etc. on [github](https://github.com/digitalronin/docker-s3cmd)

I hope you find it useful.

David


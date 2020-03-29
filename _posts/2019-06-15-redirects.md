---
layout: post
title: Web - IP Grabbing Redirects
subtitle: Evil URL Redirects!
gh-badge:
  - star
  - fork
  - follow
tags:
  - Hacking
  - Web
comments: true
published: true
date: '2019-06-15'
---

## Evil URL-Redirects Are Evil!
Have you ever wondered where your internet traffic is being re-directed to when you click on a link? 
Is it going to facebook? Is it going directly to the URL you're expecting to visit? 
Well, today you're going to find out where your traffic is being re-directed to!

A friend of mine, let's call him Ben, asked me if I could do some URL-Anaylsis and see if I could see his public IP address (while he's trying to catch mine) with a URL-Redirect. I'm just going to throw this out there now. If you're trying something like this, don't. It's stupid. You're going to get yourself caught. You'll see how easy it is to see where all my traffic is going.

So Ben gave me the url http://bensprogrammerblog.sytes.net/ to go to. The first thing I did was turn on my Burpsuite proxy to capture the traffic I was sending and where I was being re-directed to. 

![screen1.png](https://blog.spookysec.net/img/screen1.png)

So with Burpsuite at my side I was ready to visit the website.

![screen2.png](https://blog.spookysec.net/img/screen2.png)


So here we can see the public IP address of the URL given. This isn't the one we're looking for. This is just the front man, all for show.

![screen3.png](https://blog.spookysec.net/img/screen3.png)


After we forward the packet along we can see we're being redirected to https://programaddicts.github.io. This one isn't too particuarly interesting due to it being ran by github.

![screen4.png](https://blog.spookysec.net/img/screen4.png)


This one. http://programaddictsblog.sytes.net is the interesting one here, it's similar to what we were first sent, and if we resolve the URL to an IP address we get 67.248.XXX.XXX, Bens public IP address. If we forward this guy along and take a look at the response we can see we are actually being re-directed to the URL we were suppose to be visiting.

![screen5.png](https://blog.spookysec.net/img/screen5.png)


There are a lot of evil people on the internet who might try to do this, so think twice about when you click on a link. You can find out a lot of info on a persons device based on what their IP address is. You can even get a rough location. If we were to preform a trace route on this we can see that the IP addresses of the routers indicate a town name that's pretty damn close to where Ben lives. So to conclude, think twice before clicking on tiny-URL links, and, shame on you Ben, for trying to grab my public IP!

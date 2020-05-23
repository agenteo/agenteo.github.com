---
title: Reduce your network utilization on Zoom calls
layout: post
comments: true
image: /assets/article_images/reduce-your-network-utilization-on-zoom-calls/hero.png
og_description: This article explains how to reduce your Zoom network usage by tweaking its settings.
tags:
  - process
redirect_from:
  - reduce-your-bandwith-utilization-on-zoom-calls/
---

This is for folks using a PC or a Mac spending lots of time (and network utilization) on Zoom calls. Do you know how fast your Internet is? Do you know how much traffic are Zoom calls are chewing up?

What I found out today (using [Wireshark](https://www.wireshark.org)) on OSX 10.15.5 is the gallery view in Zoom (tested with 5.0.2) generates a lot more (3 times) traffic on a 12 person call.

Granted you might wanna see people on most of your call there might be situations where you want to reduce your traffic by compromising that experience.

I'll assume you use two monitor windows. If you're not following me on twitter (and missing out on all those zoom and agile retrospectives nerdy comments) this is the option you'll need to reduce your network:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">You might already know but Zoom has a dual window / dual monitor feature to allow you to split the video or the screen share from the gallery view. First pic is the speaker on window 1 and gallery on window 2. Second pic, is the shared screen on window 1 and gallery window 2. HTH <a href="https://t.co/DXTHodUcIq">pic.twitter.com/DXTHodUcIq</a></p>&mdash; 𝐸𝓃𝓇𝒾𝒸𝑜 𝒯𝑒𝑜𝓉𝓉𝒾 (@agenteo) <a href="https://twitter.com/agenteo/status/1256572194181787650?ref_src=twsrc%5Etfw">May 2, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Once you have two Zoom windows:

1. gallery view
1. speaker view

by minimizing the gallery view you will reduce Zoom's traffic and still see the active speaker on your second Zoom window.

<img src="/assets/article_images/reduce-your-network-utilization-on-zoom-calls/hero.png" />

<img src="/assets/article_images/reduce-your-network-utilization-on-zoom-calls/zoom-on-network-reduction.png" />

You might be able to achieve the same reduction with a single window and hide all gallery speakers but I did not test it. Does this trick works on Windows? Let me know!
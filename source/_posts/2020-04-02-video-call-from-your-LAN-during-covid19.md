---
title: Video call from your LAN during COVID-19
layout: post
og_description: 
tags:
  - process
---

In this short blog I explain how to have great video calls with nearby--within your wifi signal range--people. This avoids going out and back from the internet.

I found myself in my house in my Italian home town (with a shitty internet connection). Family lives in a house next to me and we share the same (shitty) wifi.

Because of covid we're trying to avoid contact and calling via internet has been tedious and really really unreliable.

So guess what you can use your local area network to video call and message. For free. And it'll take about 5 minutes to setup.

My goal was to install a simple app on phone / computer and allow the communication.

I looked in to two solutions: jitsi and linphone.

## Jitsi

Is web based, used WebRTC, really cool project BUT you need a centralized server. Great [explanation on how to set it up from skratch on Ubuntu](https://jitsi.org/news/new-tutorial-installing-jitsi-meet-on-your-own-linux-server/) they also have a [docker container](https://github.com/jitsi/docker-jitsi-meet) that is plug and play. I was able to setup and test locally the http version in minutes.

## Linphone

Kudos to Stefano Zaglio that pointed me to [linphone](http://linphone.org/). OMG it's amazing.

It has android, ios, osx, windows, linux clients and it does not require a server!

So I am almost done with the post. Install linphone on your device!

You do not need to sign up for an account. Once installed you will have a SIP address like this: `sip:enrico@192.168.1.3:5060`.

In order to start chatting you need to comunicate the sip address to your pal (or viceversa).

### Quick gotchas

>> Your device SIP address uses your local IP. In my experience wifi AP are generally keeping your IP the same (linked to your MAC address) but it's possible for it to change. In that case your pal on the other side won't be able to contact you anymore.

If you have multiple devices iphone, ipad, mac the other person has to add each SIP address to her contacts. It's a bit like having multiple extensions.

## Conclusions

I hope this helps some folks out there. I think offloading the internet of local communications makes sense. I can see SIP as a way to connect to your elderly neighbour that might not have a recent phone Let me know how your experiment goes!
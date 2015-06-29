---
layout: post
title: EC2 instance and IP geolocation
comments: true
tags:
  - cloud-computing
---

I was building a feature to redirect traffic coming from Australia to an Australian partner that given the original URL would serve different content. For example if somebody in Sydney visits `http://myapp.com/wedding-cakes` I need to redirect to `http://anotherapp.com.au/redirct-myapp?path=%2fwedding-cakes`.

In order to do that I relied on our <a href="https://support.cloudflare.com/hc/en-us/articles/200168236-What-does-CloudFlare-IP-Geolocation-do-" target="_blank">CDN geolocation</a> to set a `HTTP_CF_IPCOUNTRY` header with the request country of origin. This was done to avoid including a geolocation library in all the verticals serving portions of `http://myapp.com`.

I suggested the best and most reliable way to test this was to fly me to Australia but management did not approve -- so after TDD the feature I deployed it and tested it on a qa server trough my personal VPN in Australia, it all worked fine until somebody reported it was not working. Someone in the office suggested to test with **an EC2 instance in the Sydney region**, I was very skeptical that would be a better test then my VPN (that I use to stream ABC news while I am living in NYC). After a few minutes I had the EC2 instance with Ubuntu -- I hit a headers test page `curl http://myapp.com/__test_headers` and it returned `HTTP_CF_IPCOUNTRY` set to US -- somebody might think the feauture wasn't working.

Using `whois` I found the EC2 instance in Sydney uses an IP registered by Amazon in Seattle:

{% highlight bash %}
[...]
OrgName:        Amazon Technologies Inc.
OrgId:          AT-88-Z
Address:        410 Terry Ave N.
City:           Seattle
StateProv:      WA
PostalCode:     98109
Country:        US
RegDate:        2011-12-08
Updated:        2014-10-20
[...]
{% endhighlight %}

I tested the IP of that Sydney region instance on an online IP geolocation [http://www.iplocation.net/](http://www.iplocation.net/) and different services returned different countries: US, France, Australia.

![]({{ site.url }}/assets/article_images{{ page.url }}ec2_sydney_region.png)

Geo IP location is fragile that can't be trusted to determine locations of servers in the cloud. [This](http://stackoverflow.com/questions/274308/how-does-geographic-lookup-by-ip-work) is a very good explanation on how geo IP works.

---
layout: post
title: A successful Ruby on Rails performance analysis guideline
comments: true
tags:
  - ruby
  - ruby-on-rails
  - performance-analysis
---

In this post I describe a basic guideline I follow to raise awareness of feature performance degradation in a Ruby on Rails web application; the fundamentals apply to other programming language and frameworks.

## Be aware of the expected traffic

>> A software developer building a feature without knowing its expected load is like a civil engineer building a bridge ignoring its expected load.

![September 11, 1916: Quebec Bridge, Canada. Due to a design flaw the actual weight of the bridge was heavier than its carrying capacity, which caused it to collapse twice, first in 1907.](http://upload.wikimedia.org/wikipedia/en/9/99/Quebec_Bridge_Collapse.jpg)

When you rebuild an existing application the current traffic should be accessible from logs or analytics. Check with your product owner for an estimated traffic increase; he should know about mail campaigns, tv advertising and other marketing actions targeting your product.

If you are building a new application your product owner should have an estimated expected traffic.


## Responsible feature delivery

Deliver a feature and caching as separate steps. First ensure the core functionality works, then introduce the caching and its expiration mechanism.

**When you add or change a feature do a before and after check on response times**.

Run the Rails application in production mode and pull a production database to your workstation or point to a development server database (watch out for latency), ensure 3rd party APIs are available. 

You can use a custom gem ([TimeBandit](https://github.com/skaes/time_bandits)) to add Garbage Collection and memcache information to the log ie.

{% highlight bash %}
Completed 200 OK in 680.378ms (Views: 28.488ms, ActiveRecord: 5.111ms(2q,0h), MC: 5.382(6r,0m), GC: 120.100(1), HP: 0(2000000,546468,18682541,934967))
{% endhighlight %}

**Look at your workstation log and hit the same URLs from master and then your feature branch; *if* there are increased render times you must investigate**.

Sometimes new functionality means more computation and slower response times; that's ok. Discuss with your team and product owner if there is any possible adjustment to make the feature perform better. **This is an engineering task as much as a product liaison task**.

Examples of adjustments are:

* move the feature client side to allow the initial page render to be faster
* remove expensive parts and deliver a partial feature
* enable the feature to a subset of users to verify its value before introducing it to a wider audience

all these have repercussions and drawbacks; the best option for you is probably not in the list, your team will have to find it and agree on it.

Sometimes the code has performance bugs; look at database logs to ensure you see queries you expect. Perhaps your ORM is running multiple queries instead of a single more efficient one or maybe you haven't got indexes for this new feature. Investigate the root cause of any render taking longer then a few hundred milliseconds; be aware that Ruby on Rails startup costs make the very first hit always substantially slower.

**After you know if the change introduces slowdowns see how it performs under load.**

### Short story on caching mythology and *irresponsible* feature delivery

>> A few years ago my company hired a team of contractors, I was told they were the best Ruby developers in the country; Rails committers and Ruby heros. I noticed 3 seconds **server** response time on a product detail page they delivered and I asked for explanation. I was politely told to mind my business, that they would put some serious caching in and that would take care of it. It didn't solve the problem instead it hide the underlying cause making it harder to work out the root cause of slow response times.

When you have response times as high as 2/3 seconds on thousands of pages caching is not a solution. It's not practical to warm up the cache for all of pages and it's not realistic to expect all your traffic to be cached. When multiple pages caches expire and significant traffic hit your code you run in [cache stampedes](http://en.wikipedia.org/wiki/Cache_stampede).

>> Adding caching without understanding why your code is slow is like putting a plaster on a wound without cleaning it.


## Load test your feature

**When you add a significant feature to your backlog also add a before and after load test chore. It's not practical to have somebody else run load tests for you when you will have to work on the fix.**

### Load test 101

To create a test plan with a meaningful list of URLs, extract them from your database, scrape your website ([Scrapy](http://scrapy.org/)), record your product owner user navigation ([sproxy](http://www.joedog.org/sproxy-home/)) or use current users navigational habits from your logs.

With your test plan and an estimated load run a load test tool (my favourite is currently [vegeta](https://github.com/tsenart/vegeta)) from EC2 or a load test service (I've heard good things of [BlazeMeter](http://blazemeter.com/)).

Analyze response times on your logs or with a monitoring tool ([NewRelic](http://newrelic.com/) or if you're not on Ruby [AppDynamics](http://www.appdynamics.com/)), their results will point to code to optimize or requiring to scale up the infrastructure. 

**Always have a rollback strategy if the feature doesn't perform well or doesn't bring the expected improvements**.


### Scaling up

The increase of server resources can help resolve some performance issues; without loadtesting each feature it's hard to tell how long that will work for... or if it will work at all.

>> Increasing server resources to handle unoptimized code is like owning a Ferrari and expecting to cruise around Manhattan's financial district at 9am on a Tuesday. Owning a Ferrari or a UPS truck won't make a difference at that time, you will be stuck in traffic.

Capacity planning is not the focus of this article, if you are interested I enjoyed reading [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579) and [Web Operations: Keeping the Data on Time](http://www.amazon.com/gp/product/1449377440/ref=pd_lpo_sbs_dp_ss_1/191-1462743-7066957?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=lpo-top-stripe-1&pf_rd_r=0Y837KQJG5SV71AW0ZVS&pf_rd_t=201&pf_rd_p=1944687782&pf_rd_i=0596518579).

## Conclusion

**When developing or changing features in your Ruby on Rails code be mindful about response times and their deterioration; build a product sustaining your expected (or estimated) load.**

Do not overengineer solutions, address the needs you have today keeping your [product vision](http://www.jamesshore.com/Agile-Book/vision.html) in mind. Maintainable code can be refactored and optimized, systems can be migrated.

### Interesting links

* [Performance Testing Crash Course: Dustin Whittle](https://www.youtube.com/watch?v=Zap15XHtny4) 
* [The Future of Ruby Performance Tooling](http://goruco.com/speakers/2014/aaron-quint/)
* [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579)
* [Web Operations: Keeping the Data on Time](http://www.amazon.com/gp/product/1449377440/ref=pd_lpo_sbs_dp_ss_1/191-1462743-7066957?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=lpo-top-stripe-1&pf_rd_r=0Y837KQJG5SV71AW0ZVS&pf_rd_t=201&pf_rd_p=1944687782&pf_rd_i=0596518579)

![2009 Quebec Bridge seen from North shore of the Saint Lawrence River picture by Martin St-Amant - Wikipedia - CC-BY-SA-3.0](http://upload.wikimedia.org/wikipedia/commons/thumb/d/da/125_-_Qu%C3%A9bec_-_Pont_de_Qu%C3%A9bec_de_nuit_-_Septembre_2009.jpg/640px-125_-_Qu%C3%A9bec_-_Pont_de_Qu%C3%A9bec_de_nuit_-_Septembre_2009.jpg)

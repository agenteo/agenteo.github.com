---
layout: post
title: A successful Ruby on Rails performance analysis workflow
comments: true
tags:
  - ruby
  - ruby-on-rails
  - performance-analysis
---

Oftentimes when solutions are stated to us seem obvious, this is I think one of those times.

In this post I will describe a basic workflow I follow to raise awareness in Ruby on Rails feature performance; the fundamental concepts apply to other programming language and frameworks.

## Be aware of the expected traffic

>> A software developer delivering a feature without knowing its expected load is like a civil engineer building a bridge ignoring how much weight it's meant to support.

When rebuilding an existing app the current traffic data should be accessible from logs or analytics. Check with your product owner for an estimated traffic increase. He should know about mail campaigns, tv advertising and other marketing actions targeting your product.

If you are building a new application your product owner should still have an estimated expected traffic.


## Responsible feature delivery

Deliver features and caching as separate steps. First ensure the core functionality is working, then introduce the caching and its expiration mechanism.

When adding or changing a feature do a before and after check on response times, look at your workstation log and switch between master and your feature branch. Run the Rails application in production mode, pull a production database to your workstation or point to a development server database (watch out for latency), ensure 3rd party APIs are available. If you see an increased rendering time **you must understand why**.

Sometimes new functionality means more computation and slower response times; communicate this information to your team and product owner and discuss if there is any adjustments to make it perform better. **This is an engineering task as much as a product liaison task**.

Examples of adjustments are:

* move the feature client side to allow the initial page render to be faster
* remove expensive parts to deliver the feature partially
* enable the feature to a subset of users to verify its value before introducing it to a wider audience

all these have repercussions and drawbacks; the best option for you is probably not in the list, your team will have to find it and agree on it.

Sometimes the code has performance bugs; look at database logs to ensure you see queries you expect. Perhaps your ORM is running multiple queries instead of a single more efficient one or maybe you haven't got indexes for this new feature. Investigate the root cause of any Rails page render taking longer then a few hundred milliseconds; be aware that framework startup costs make the very first hit always substantially slower.

### Short story on caching mythology

A few years ago my company hired a team of contractors, I was told they were the best Ruby developers in the country; Rails committers and Ruby heros. I noticed 3 seconds **server** response time on a product detail page they delivered and I asked for details. I was politely told to mind my business, that they would put some serious caching in and that would take care of it. It didn't, instead it hide the underlying cause of the problem making it harder for my company team to work out the reasons of slow response times.

When you have response times so high on thousands of pages caching is not a solution. It's not practical to warm up the cache for thousands of pages, and it's not realistic to expect all your traffic to be cached. You inevitably run in [cache stampedes](http://en.wikipedia.org/wiki/Cache_stampede) where multiple pages caches expire and significant traffic will hit your (slow) code.

>> Adding caching without understanding why your code is slow is like putting a plaster on a wound without cleaning it.

After you know if the change introduces slowdowns see it performing under load.


## Load test your feature

When you work on a significant feature have an associated load test chore; expecting somebody else to run load tests isn't practical. The developer is likely to have to apply a fix anyway.

After the product owner accepts the feature load test it on qa, you should be able to temporarily match that environment with production. If that isn't feasable the tests on qa won't be representative of production but a before and after load test still highlights performance impact.

Another option is (after acceptance) to deploy to production and load test it there. You want to carefully increase traffic to exercise your new feature without bringing your site to a halt. In larger environments this might be the only viable way to have meaningful load tests; if interested a great read is [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579). 

If the delivered feature can be feature flagged deploy and activate it only on your load tests URLs to verify its performance before making it available to a wider audience.

Create a test plan extracting urls from your database, scraping your website ([Scrapy](http://scrapy.org/)]), recording your product owner user navigation ([sproxy](http://www.joedog.org/sproxy-home/)) or using current users navigational habits from your logs.

Once you have a test plan and an estimated load run a load test tool (my favourite is currently [vegeta](https://github.com/tsenart/vegeta)) or a load test service (I've heard good things of [BlazeMeter](http://blazemeter.com/)) and analyze response times on your logs or with a monitoring tool (ie [NewRelic](http://newrelic.com/) or [AppDynamics](http://www.appdynamics.com/)).

This information highlights portions of the code needing optimization or requiring to scale up your infrastructure. 

Always have a rollback strategy if the feature doesn't perform well or doesn't bring the expected improvements.


### Scaling up

Increasing server resources can help your performance issues; without loadtesting each delivered feature it's hard to tell how long that will work for.

>> Increasing server resources to handle unoptimized code is like owning a Ferrari and expecting to cruise around Manhattan's financial district at 9am on a Tuesday. Owning a Ferrari or a UPS truck won't change a thing, you will be stuck in traffic.

Now we entering the domain of capacity planning, which in my opinion is on the border of software development. It's a task where an infrastructure and developers should pair. If this topic interest you I recommend reading [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579).

## Conclusion

Building an online product requires synergy between all team members. Circulating information is critical to ensure what the development team is building will sustain what the business know is about to support.

Address what you need today having your [product vision](http://www.jamesshore.com/Agile-Book/vision.html) in mind. Maintainable code can be refactored and optimized, systems can be migrated, there is no technical solution to address an evolving product live time.


### Interesting links

* [Worst 100 bridge collapses of the last 100 years](http://content.time.com/time/photogallery/0,29307,1649646,00.html)
* 


# Bin

## Diagnose and load test existing features

When you deal with slow code that crept in production use your monitoring tool to find out more on the slow parts. That information is usually pointing to a URL segment or when using New Relic a Ruby on Rails controller action. Run a load test now, and keep the load test plan to be run 

That is often pointing out a lot of useful information like: relational database time (but not mongodb), external services, Ruby garbage collection.

Those tools won't point you to a precise part parts of your code. For that on your workstation take bits of code out and see how it affects the response time, this way you can surgically detect what and how is impacting your response times.

If the problem is buggy code fix it. If the feature is genuinely requiring more computation communicate with your team and product owner to see if there is an alternative.



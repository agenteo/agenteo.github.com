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

In this post I will describe the workflow I follow to build solid Ruby on Rails web applications; the fundamental concepts apply to other programming language and frameworks.

## Be aware of the expected traffic

>> A software developer delivering a feature without knowing its expected load is like a civil engineer building a bridge ignoring how much weight it's meant to support.

When rebuilding an existing app the current traffic data should be accessible from logs or analytics. Check with your product owner for an estimated traffic increase. He should know about mail campaigns, tv advertising and other marketing actions targeting your product.

If you are building a new application your product owner should still have an estimated expected traffic.


### Short story on caching mythology

A few years ago my company hired a team of contractors, I was told they were the best Ruby developers in the country; Rails committers and Ruby heros. I noticed 3 seconds **server** response time on a product detail page they delivered and I asked for details. I was politely told to mind my business, that they would put some serious caching in and that would take care of it. It didn't, instead it hide the underlying cause of the problem making it harder for my company team to work out the reasons of slow response times.

When you have response times so high on thousands of pages caching is not a solution. It's not practical to warm up the cache for thousands of pages, and it's not realistic to expect all your traffic to be cached. You inevitably run in [cache stampedes](http://en.wikipedia.org/wiki/Cache_stampede) where multiple pages caches expire and significant traffic will hit your (slow) code.

>> Adding caching without understanding why your code is slow is like putting a plaster on a wound without cleaning it.

## Deliver features responsibly

Always deliver features without caching and do a speed assessment on your workstation logs. Run the Rails application in production mode, pull a production database and ensure 3rd party APIs are available and performing without significant latency.

### Changes on existing features

Always do a before and after check on response times, look at your workstation log and switch between master and your feature branch. If your code change increments an existing segment rendering time **you must understand why**.

Sometimes bringing new functionality will mean more computation and slower response times; communicate this information to your product owner and discuss with **the whole team** adjustments to the feature to make it perform better. **This is an engineering task as much as a product liaison task**.

Examples of options are:

* move the feature client side to allow the initial page render to be faster
* remove expensive parts to deliver the feature partially
* enable the feature to a subset of users to verify its value before introducing it to a wider audience

all these have repercussions and drawbacks; the best one for you is probably not on the list, your team will have to find it and agree it.


### Investigate code

Sometimes you will understand the code has performance bugs; look at database logs to ensure you see queries you expect. Perhaps your ORM is running multiple queries instead of a single more efficient one or maybe you haven't got indexes for this new feature.

I always investigate the root cause of any Rails page render taking longer then a few hundred milliseconds. To give you an idea a Ruby on Rails 4.1 controller action rendering a view with static text takes around 20 milliseconds.

After you know if the feature introduces slowdowns you want to see it performing under load.

## Load test new features

When you deliver a new feature have an associated load testing chore; expecting somebody else to run load tests isn't practical because the developer would have to apply a fix anyway.

After the product owner accepts the feature load test it on qa, you should be able to temporarily match that environment with production. If that can't be done the tests on qa won't be representative but a before and after load test will still highlight problem with the feature performance.

Another option is (after acceptance) to deploy to production and load test it there. You want to increase traffic to exercise your new feature without bringing your site to a halt.

If the delivered feature can be feature flagged you could deploy and activate it on your load tests URLs only to verify its performance before making it available to a wider audience.

With the estimated load that your product owner provided create a test plan. There are many options depending on your application you can generate the plan from your database, scraping your website ([Scrapy](http://scrapy.org/)]), record your product owner user navigation ([sproxy](http://www.joedog.org/sproxy-home/)) or using current users navigational habits from your logs.

Once you have a test plan and an estimated load run a load test tool (my favourite is currently [vegeta](https://github.com/tsenart/vegeta), [siege](http://www.joedog.org/siege-home/)) and analyze response times on your logs or with a monitoring tool (ie [NewRelic](http://newrelic.com/) or [AppDynamics](http://www.appdynamics.com/)).

This information will allow you to focus on optimizing the code or scaling up your infrastructure based on product and engineering. 

Always have a rollback strategy if the feature doesn't perform well.

## Load test existing features

When you deal with slow code that crept in production use your monitoring tool to find out more on the slow parts. That information is usually pointing to a URL segment or when using New Relic a Ruby on Rails controller action.

That is often pointing out a lot of useful information like: relational database time (but not mongodb), external services, Ruby garbage collection.

Those tools won't point you to a precise part parts of your code. For that on your workstation take bits of code out and see how it affects the response time, this way you can surgically detect what and how is impacting your response times.

If the problem is buggy code fix it. If the feature is genuinely requiring more computation communicate with your team and product owner to see if there is an alternative.

### Scaling up

In some cases increasing server side resources is an option; but if doing that fails then you have to take a closer look at your code.

>> Increasing server resources to handle unoptimized code is like owning a Ferrari and expecting to cruise around Manhattan's financial district at 9am on a Tuesday. Owning a Ferrari or a UPS truck won't change a thing, you will be stuck in traffic.

I recommend reading 

## Conclusion

Building an online product requires synergy between all team members. Circulating information is critical to ensure what the development team is building will sustain what the business know is about to support.

Address what you need today having your [product vision](http://www.jamesshore.com/Agile-Book/vision.html) in mind. Maintainable code can be refactored and optimized, systems can be migrated, there is no technical solution to address an evolving product live time.


### Interesting links

* [Worst 100 bridge collapses of the last 100 years](http://content.time.com/time/photogallery/0,29307,1649646,00.html)

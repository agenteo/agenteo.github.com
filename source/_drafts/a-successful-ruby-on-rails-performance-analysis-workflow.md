---
layout: post
title: A successful Ruby on Rails performance analysis guideline
comments: true
tags:
  - ruby
  - ruby-on-rails
  - performance-analysis
---

Oftentimes when solutions are stated to us seem obvious, this is I think one of those times.

In this post I will describe a basic guideline I follow to raise awareness in Ruby on Rails feature performance; the fundamental concepts apply to other programming language and frameworks.

## Be aware of the expected traffic

>> A software developer delivering a feature without knowing its expected load is like a civil engineer building a bridge ignoring how much weight it's meant to support.

When rebuilding an existing app the current traffic data should be accessible from logs or analytics. Check with your product owner for an estimated traffic increase. He should know about mail campaigns, tv advertising and other marketing actions targeting your product.

If you are building a new application your product owner should still have an estimated expected traffic.


## Responsible feature delivery

Deliver features and caching as separate steps. First ensure the core functionality is working, then introduce the caching and its expiration mechanism.

When adding or changing a feature do a before and after check on response times. Run the Rails application in production mode and pull a production database to your workstation or point to a development server database (watch out for latency), ensure 3rd party APIs are available. 

Look at your workstation log and switch between master and your feature branch; if there are increased rendering times **you must understand why**.

Sometimes new functionality means more computation and slower response times; that's ok, communicate this information to your team and product owner and discuss if there is any adjustments to make it perform better. **This is an engineering task as much as a product liaison task**.

Examples of adjustments are:

* move the feature client side to allow the initial page render to be faster
* remove expensive parts to deliver the feature partially
* enable the feature to a subset of users to verify its value before introducing it to a wider audience

all these have repercussions and drawbacks; the best option for you is probably not in the list, your team will have to find it and agree on it.

Sometimes the code has performance bugs; look at database logs to ensure you see queries you expect. Perhaps your ORM is running multiple queries instead of a single more efficient one or maybe you haven't got indexes for this new feature. Investigate the root cause of any Rails page render taking longer then a few hundred milliseconds; be aware that framework startup costs make the very first hit always substantially slower.

After you know if the change introduces slowdowns see it performing under load.

### Short story on caching mythology

A few years ago my company hired a team of contractors, I was told they were the best Ruby developers in the country; Rails committers and Ruby heros. I noticed 3 seconds **server** response time on a product detail page they delivered and I asked for explanation. I was politely told to mind my business, that they would put some serious caching in and that would take care of it. It didn't, instead it hide the underlying cause of the problem making it harder to work out the reasons of slow response times.

When you have response times so high on thousands of pages caching is not a solution. It's not practical to warm up the cache for all of pages, and it's not realistic to expect all your traffic to be cached. When multiple pages caches expire and significant traffic hit your code you run in [cache stampedes](http://en.wikipedia.org/wiki/Cache_stampede).

>> Adding caching without understanding why your code is slow is like putting a plaster on a wound without cleaning it.


## Load test your feature

When you work on a significant feature have an associated load test chore; expecting somebody else to run load tests isn't practical. The developer is likely to have to apply a fix anyway.

After the product owner accepts the feature load test it on qa, you should be able to temporarily match that environment with production. If that isn't feasable the tests on qa won't be representative of production but a before and after load test still highlights performance impact.

Another option is (after acceptance) to deploy to production and load test it there. You want to carefully increase traffic to exercise your new feature without bringing your site to a halt. In larger environments this might be the only viable way to have meaningful load tests; if interested a great read is [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579). 

If the delivered feature can be feature flagged deploy and activate it only on your load tests URLs to verify its performance before making it available to a wider audience.

Create a test plan extracting urls from your database, scraping your website ([Scrapy](http://scrapy.org/)), recording your product owner user navigation ([sproxy](http://www.joedog.org/sproxy-home/)) or using current users navigational habits from your logs.

Once you have a test plan and an estimated load run a load test tool (my favourite is currently [vegeta](https://github.com/tsenart/vegeta)) from EC2 or a load test service (I've heard good things of [BlazeMeter](http://blazemeter.com/)) and analyze response times on your logs or with a monitoring tool (ie [NewRelic](http://newrelic.com/) or [AppDynamics](http://www.appdynamics.com/)).

This information highlights portions of the code needing optimization or requiring to scale up your infrastructure. 

**Always have a rollback strategy if the feature doesn't perform well or doesn't bring the expected improvements**.


### Scaling up

Increasing server resources can help your performance issues; without loadtesting each delivered feature it's hard to tell how long that will work for.

>> Increasing server resources to handle unoptimized code is like owning a Ferrari and expecting to cruise around Manhattan's financial district at 9am on a Tuesday. Owning a Ferrari or a UPS truck won't change a thing, you will be stuck in traffic.

Now we entering the domain of capacity planning, which in not the focus of this article. I recommend reading [The Art of Capacity Planning](http://www.amazon.com/The-Art-Capacity-Planning-Resources/dp/0596518579) and [Web Operations: Keeping the Data on Time](http://www.amazon.com/gp/product/1449377440/ref=pd_lpo_sbs_dp_ss_1/191-1462743-7066957?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=lpo-top-stripe-1&pf_rd_r=0Y837KQJG5SV71AW0ZVS&pf_rd_t=201&pf_rd_p=1944687782&pf_rd_i=0596518579).

## Conclusion

When developing or changing features be mindful about speed deterioration; build a product sustaining the expected (or estimated) load.

Do not overengineer solutions, address the needs you have today keeping your [product vision](http://www.jamesshore.com/Agile-Book/vision.html) in mind. Maintainable code can be refactored and optimized, systems can be migrated.

### Interesting links

* [Worst 100 bridge collapses of the last 100 years](http://content.time.com/time/photogallery/0,29307,1649646,00.html)
* 

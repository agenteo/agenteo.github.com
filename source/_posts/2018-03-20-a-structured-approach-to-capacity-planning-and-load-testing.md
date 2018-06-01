---
layout: post
title: Reproduce production incidents with a structured load testing plan
comments: true
published: false
tags:
  - java
  - performance-analysis
  - process
#image: /assets/article_images/a-successful-ruby-on-rails-performance-analysis-guideline/quebec_bridge.jpg
image_credit: 2009 Quebec Bridge seen from North shore of the Saint Lawrence River picture by Martin St-Amant - Wikipedia - CC-BY-SA-3.0
---

Intro22

In this article I explain how we reproduced a JSON API production incident on a performance setup using structured load testing on Elastic Beanstalk / Amazon Web Services.

A lot of this will sound like stating the obvious but I find that many don't know or think some of these .

## Get the numbers

I call legacy an application that has been delivering value at scale to its users and to the business. Because it's in production it can't just be rewritten and migrated overnight. Capacity planning can tell us around what point it'd stop delivering that value.

If you're building an application targeted to the 1 million US accountants it would be nonsensical to prepare it for the 130 millions tax return individuals.

When a new feature is added to the backlog ensure the product owner **specify the number of expected users**.

All apps have a breaking point. Could be CPU bound, memory bound, I/O bound. It would be good to know that 300K request per minute (rpm) start making the app misbehaving but it shouldn't be an immediate concern if your max expected load is between 5K and 10K rpm.

## Setup a performance environment

It's rare
Do you need to architect for that. A product owner must tell engineers that number is 10K.

Sometime production incidents was happening sporadically and hard to tes

In this post I describe the framework I've used to monitor load testing
Body


This was a JVM app running on AWS so I created a script leveraging aws-cli to ssh in to all the ec2 instances in severe state taking a memory snapshot and downloading it to the workstation for forensic analysis.

Close

In 2015 I wrote a post about load testing 
In this post I describe a basic guideline I follow to raise awareness of feature performance degradation in a Ruby on Rails web application; the fundamentals apply to other programming language and frameworks: be aware of the expected traffic, responsible feature delivery and load testing.

## Be aware of the expected traffic

>> A software developer building a feature without knowing its expected load is like a civil engineer building a bridge ignoring its expected load.

![September 11, 1916: Quebec Bridge, Canada. Due to a design flaw the actual weight of the bridge was heavier than its carrying capacity, which caused it to collapse twice, first in 1907.](http://upload.wikimedia.org/wikipedia/en/9/99/Quebec_Bridge_Collapse.jpg)


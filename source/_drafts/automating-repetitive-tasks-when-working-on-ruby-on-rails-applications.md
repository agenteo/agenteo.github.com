---
layout: post
title: Automating repetitive tasks when working on Ruby on Rails on Heroku
comments: true
tags:
  - ruby
  - ruby-on-rails
  - automation
---

Ruby on Rails speeds up development with a series of default generators and tasks. Some examples are:

{% highlight bash %}
rake db:setup
rake db:migrate
{% endhighlight %}

But while developing tasks specific to my application

Why move data between production to qa?
* facilitate user acceptance on something that is as close as possible to production
* reproducing bugs
 
If you want to fix a production bug you need to reproduce it. You must then run your application with production data by moving database and assets from production to another stage. Not moving assets will leave the application in a confusing state where some assets will be missing. Pointing to production assets might destroy or alter production information when testing on qa or workstation. A clear example here is sharing the same S3 bucket between qa and production.

I like to move the production data to qa first

-- commonly the other relevant piece are assets needing to be syncronized between S3 buckets or 3rd party systems.

move Align production with other stages

## Deployment

Aligning production data to qa and workstation is one.

When there is a bug report in production it's safe to take the production data to another stage where it can be safely debugged.

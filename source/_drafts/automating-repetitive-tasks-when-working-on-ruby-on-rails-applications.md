---
layout: post
title: Automating repetitive tasks when working on Ruby on Rails on Heroku
comments: true
tags:
  - ruby
  - ruby-on-rails
  - automation
---

Ruby on Rails has a list of default tasks helping speeding up development. Some examples are:

{% highlight bash %}
rake db:setup
rake db:migrate
{% endhighlight %}

But while developing I have other repetitive tasks, specific to my application.

Aligning production data to qa and workstation is one.

When there is a bug report in production it's safe to take the production data to another stage where it can be safely debugged.

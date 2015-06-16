---
layout: post
title: After Ruby on Rails comes Lotus the complete Ruby web framework
comments: true
tags:
  - executive
---

I was an early adopter of Ruby on Rails in 2005 and I delivered several products with it in the last 10 years. Rails is an adaptable framwork ideal for 2-3 weeks projects a web agency needs to deliver--when the application is more complex or long running you can leverage a modular approach called [component based Rails architecture](http://teotti.com/component-based-rails-architecture-primer/) to incrementally build more maintainable code but it's frustrating when the framework gets in the way of modularity instead of promoting it.

The Rails framework wasn't build or concerned with modularity but a new Ruby web framework is: Lotus. I took a peak at it after a few months and will list the main differences between the Rails way and Lotus as well as some benchmarking. I will have lots of links to Lotus excellent documentation because reading their guides is a pleasent experience where key concepts are well laid out and explained with code samples.

## General approach

The framework follows the routing + Model View Controller pattern that Ruby on Rails uses--you will find a dose of the Rails magic in Lotus but only a dose and not an overdose.

## Routing

The Lotus framework is rack compliant and its minimal routing is effective and reminiscent of Rails with helpful conventions like:

{% highlight ruby %}
# apps/web/config/routes.rb
get '/', to: "home#index" # => will route to Web::Controllers::Home::Index
{% endhighlight %}

to avoid the longer:

{% highlight ruby %}
get '/',   to: Web::Controllers::Home::Index
{% endhighlight %}

## Controller actions

The controller actions are classes as opposed to Ruby on Rails class instance methods--this will help code maintainability by reducing the responsability of an action and draw a clear boundary between framework and application domain which in Rails land was achieved services always tangled with the framework like [hexagonal architecture](https://www.agileplannerapp.com/blog/building-agile-planner/refactoring-with-hexagonal-rails) or tried to solve.

Controller action instance variables will not be handed to the view template unless [exposed](http://lotusrb.org/guides/actions/exposures/).

## Views

The framework provides a [model-view layer](http://lotusrb.org/guides/views/overview/) that could act as a presenter in simple domains or istantiate more presenters in complex cases.

What Rails developers call *views* are called [templates](http://lotusrb.org/guides/views/templates/) in Lotus and already support the popular Ruby templating like erb, haml, slim.

## View helpers

Lotus [view helpers](http://www.rubydoc.info/gems/lotus-helpers) are first class citizen and like controller actions they are classes--you can achieve that in Rails using [intention revealing helpers](http://teotti.com/building-intention-revealing-ruby-on-rails-helpers/) or gems like [cells](https://github.com/apotonick/cells) but it's good to see a framework setting that course.



---

I think because the project creator doesn't have a lot of interest in that topic Rails will never commit in that direction which at this point is just fine. 


 framework that promotes the quick and dirty way to hit the market philosophy works well for ignorance driven development.

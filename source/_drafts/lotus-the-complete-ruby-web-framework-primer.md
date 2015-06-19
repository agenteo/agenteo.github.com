---
layout: post
title: Rails vs. Lotus
comments: true
tags:
  - executive
---

I was an early adopter of Ruby on Rails in 2005 and I delivered several products with it in the last 10 years. I think Rails works at its best for mildly complex 4-8 weeks projects and for longer more complex ones I switch to a modular approach called [component based Rails architecture](http://teotti.com/component-based-rails-architecture-primer/) to incrementally build maintainable code.

If you built and maintained a Rails application for 2 or 3 years and haven't noticed any maintainability problem I think you don't need to look in to Lotus. For you Rails wins.

If you are struggling to maintain a large Rails applications and haven't used component based architecture [you should look at it first](http://teotti.com/component-based-rails-architecture-primer/) because Lotus is trying to solve the same problem--its advantage is modularity is at the framework core

Rails wasn't build with modularity at its foundation and you can feel that when working with components and applications reaching a certain dimension. With #cbra you use ingenuity to achieve something the framework wasn't built to do--you are bending rules and stop following its conventions. For you Rails wins but you might interested in knowing more about Lotus.

I will describe Lotus a new Ruby web framework is and the main differences with Rails. I will have lots of links to Lotus excellent documentation because reading their guides is a pleasent experience where key concepts are well laid out and explained with code samples.

## General approach

The framework allows to have multiple "applications" run in to a single Ruby process, similar to what 


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
 

What I find frustrating is how the framework gets in the way of modularity instead of promoting it.


there are multiple examples of this. From promoting decoration (concerns) as a way to reduce model responsabilities

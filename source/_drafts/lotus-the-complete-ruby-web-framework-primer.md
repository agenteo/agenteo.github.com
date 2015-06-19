---
layout: post
title: Rails vs. Lotus
comments: true
tags:
  - executive
---

I was an early adopter of Ruby on Rails in 2005 and I delivered several products with it in the last 10 years. I think Rails works at its best for mildly complex 4-8 weeks projects and for longer more complex ones I switch to a modular approach called [component based Rails architecture](http://teotti.com/component-based-rails-architecture-primer/).

If you built and maintained a classical Rails application for 2 or 3 years and haven't noticed any maintainability problem I think you don't need to look in to Lotus. For you Rails wins.

If you are struggling to maintain a large Rails applications and haven't used component based architecture [you should look at it](http://teotti.com/component-based-rails-architecture-primer/) because Lotus is trying to solve the same problem. The advantage of Lotus is modularity at the framework core something Rails lacks and you can feel that when working with a component based application reaching a certain dimension. Component based architecture uses ingenuity to achieve something the framework wasn't built to do, bending rules and diverging from conventions--as of June 2015 Rails still wins but you want to keep a close eye on Lotus and read on to get a primer on why that is.

## General approach

The framework modularity is well explained in the project [guides](http://lotusrb.org/guides) and [readme](https://github.com/lotus/lotus).

A Lotus application can serve multiple *applications* from the same Ruby process similar to what high level components do in **#cbra**.

Lotus sets a boundary between code dealing with the framework living inside `/apps` and code related to the persistence and domain logic living inside `/lib`. The default application is called `web` but customizable thanks to a set of generators like:

{% highlight ruby %}
lotus new shipping --application=api
{% endhighlight %}

The application structure is:

{% highlight bash %}
apps/web/
├── application.rb
├── config
├── controllers
├── public
├── templates
└── views
{% endhighlight %}

The applications are mounted via `config/environment.rb`:

{% highlight ruby %}
require 'rubygems'
require 'bundler/setup'
require 'lotus/setup'
require_relative '../lib/bookshelf'
require_relative '../apps/web/application'

Lotus::Container.configure do
  mount Web::Application, at: '/'
end
{% endhighlight %}

If you have more then one application beware that unlike in Rails mounting them on the same segment will only serve the first sets of routes.

{% highlight ruby %}
Lotus::Container.configure do
  mount Web::Application, at: '/'
  mount GameZone::Application, at: '/'
end
{% endhighlight %}

*BEWARE*: in the example above any route provided by `GameZone` will not be found forcing the mounted routes to be unique segments and leaving the greedier one at the bottom, for example:

{% highlight ruby %}
Lotus::Container.configure do
  mount GameZone::Application, at: '/zone'
  mount Web::Application, at: '/'
end
{% endhighlight %}

The framework follows the routing + View Controller pattern that Ruby on Rails uses--you will find a dose of the Rails magic in Lotus but only a dose and not an overdose.

## Application routing

The Lotus framework is rack compliant and its minimal routing is effective and reminiscent of Rails with helpful conventions like:

{% highlight ruby %}
# apps/APPLICATION_NAME/config/routes.rb
get '/', to: "home#index" # => will route to Web::Controllers::Home::Index
{% endhighlight %}

to avoid the longer:

{% highlight ruby %}
get '/',   to: Web::Controllers::Home::Index
{% endhighlight %}

## Controller actions

The [controller](https://github.com/lotus/controller) actions are classes as opposed to Ruby on Rails class instance methods--this will  responsability for an action 


and setting a boundary between framework and application domain which in Rails was achieved with services hard to decouple from the framework like [hexagonal architecture](https://www.agileplannerapp.com/blog/building-agile-planner/refactoring-with-hexagonal-rails).

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

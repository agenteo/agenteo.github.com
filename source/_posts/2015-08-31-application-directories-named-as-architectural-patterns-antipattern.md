---
title: Application directories named as architectural patterns antipattern
layout: post
draft: true
tags:
  - ruby
  - rails
---

**Regardless of the programming language grouping class files in directories using an architectural pattern name is unintuitive.**

I saw this happening in different programming languages and frameworks but I will use Ruby on Rails as an example.

I am not referring to framework specific directories--for example Rails conventional **MVC** directories: *models, views, controllers, helpers* come with the framework and developers should know what they are for.

The problem starts with a list like this:

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
├── models
├── presenters
├── services
├── serializers
├── strategies
├── utils
└── views
{% endhighlight %}

When I see **presenters, services, serializers, strategies, utils** directories I can guess someone likes patterns but I gather nothing about their boundary of operation or the application domain.

**This antipattern encourages code separation based on the class pattern taxonomy rather then its responsability**--like if a foreman would group workers by their country of origin instead of their skills--pretty stupid.

All the existing Rails applications I inherited used this antipattern--I am going to describe its problems and suggest an intention revealing alternative.

## An example

If you haven't seen this in action here's an example. This antipattern separate class files like:

{% highlight bash %}
services/reservation_quote_recalculation_service.rb # ReservationQuoteRecalculationService
strategies/quote_strategy.rb # QuoteStrategy
specifications/obsolete_quote_specification.rb # ObsoleteQuoteSpecification
{% endhighlight %}

But when updating a reservation `ReservationQuoteRecalculationService` uses `QuoteStrategy` that uses `ObsoleteQuoteSpecification`. So the classes work together within the same boundary but the directory misnaming obfuscate that.

In a real application you will have a higher number of collaborating classes and you will have to bounce between patterns directories and--understandably--lose your mind in the process.

## Group by business contexts

I use the conventional Rails `models` directory not just for *ActiveRecord* models but all the classes related to the **application domain model** regardless of their design pattern.

Inside I add directories matching a Ruby **namespace representing the boundaries**--sometime bounded contexts--where those objects act.

The example above can look like this:

{% highlight bash %}
book/reservation_quote_recalculation_service.rb # Book::ReservationQuoteRecalculationService
book/quote_strategy.rb # Book::QuoteStrategy
book/obsolete_quote_specification.rb # Book::ObsoleteQuoteSpecification
{% endhighlight %}

This is a simplified example--in a real application another namespace for the quote recalculation boundary might be necessary.

### Example 1: the memory game service

An example could be an application for memory videogames with game designers creating games, players playing them. Two very different contexts: **workshop** and **gamezone**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── workshop
│   └── gamezone
└── views
{% endhighlight %}

Whatever code concerns `workshop` will be living in that directory regardless of its pattern--inside of it all classes should be in the `Workshop`  namespace. The same applies for `gamezone`.

### Example 2: the private jet company

Another example is a private jet company that can book trips, update ongoing trip and billing. Again three very distinct contexts: **book**, **trip**, **bill**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── book
│   ├── trip
│   └── bill
└── views
{% endhighlight %}

### Example 3: editorial content management

A content management that imports content from a legacy system allowing an editorial team to update some of the content and having users viewing that. Three contexts: **legacy_import**, **editorial**, **public**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── legacy_import
│   ├── editorial
│   └── public
└── views
{% endhighlight %}

## Naming

Gathering those context from your product owner is much harder then using architectural pattern names but will improve code maintainability.

The contexts will change as the business evolves so it's natural--**and critical**--for the code to be consistent with them. It's unlikely to get the naming right at the first try. A great read on this subject is [Domain-Driven Design](http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215).

#### What happens to shared code?

As the application grows there **will be shared code** between contexts. Leaving shared items in a `models/shared` directory can be sufficient initially but stop when that becomes the application kitchen sink.

At this point an appropriate solution is introducing a dependency structure--in Ruby on Rails that is [component based Rails architecture](http://teotti.com/component-based-rails-architecture-primer/), compiled languages will have a safer dependency management but rigorous automated testing yields good results in interpreted languages.

---
layout: post
title: Component based Rails architecture primer
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

I have worked on many successful products that fit in the classical Ruby on Rails MVC paradigm. Often conventions like: decorators, presenters, service objects can be sufficient to handle some complexity **but as the project grows they don't help to understand what the whole application does**. If I have 20 or 30 controllers and a similar number of models the intention of the application is obfuscated, Ruby namespaces can add modularity but can't enforce a dependency structure and classes end up in a tangle of dependencies hard to follow. **Component based architecture is complementary to good object oriented practices and uses namespaces, test driven development and Ruby gems to gradually define application boundaries and enforce an internal dependency structure**.

## A practical example

This example is adapted from a real life application but to make it manageable I've omitted major features and only left four components: a staff only *administration area*, a *public area*, a *legacy migration* and some shared *domain logic*. The *legacy migration* was initially part of the admin component and later when its complexity increased it was extracted in a separate one--**I usually don't architect an application with components from day one instead I introduce them gradually as the complexity grows or when the scope changes** as I describe [here](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

A component is a Ruby on Rails engine or Ruby gem, its dependencies are set in its `.gemspec` file, a test suite will test it in isolation and ensure the dependency structure is solid. An engine is like a Rails app in miniature, you have models, views, controllers routes, rake tasks--you can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)

The high level components are required by the main Rails application `Gemfile`.

{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

I think it's great to see what the main application is doing without having to dig in layers of controllers and models. The `Gemfile` will look for the high level components `public_ui`, `admin_ui`, `legacy_migration` in the `components` directory of the Rails application and automatically resolve any local component dependency like the `domain_logic`--I explain how this works in [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

When a high level component provide routes they are mounted in the Rails application route file.

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}

Inside the admin engine we will keep all the controllers, models, helpers and tasks related to that area and they will all be namespaced with `AdminUi` and the same for `PublicUi`. Some of their database models and utility classes are shared and live inside a depedency `DomainLogic`.

## Handling application change

>> To have a project accelerate as development proceeds—rather than get weighed down by its own legacy—demands a design that is a pleasure to work with, inviting to change. A supple design.

When later the **legacy migration** is completed I can simply remove its component directory and its entry from the `Gemfile` without affecting the rest of the product--with a conventional approach I would have to find and delete the code hoping the tests catch any broken dependency.

If I need to add an API I can put it in a high level component (like public_ui and admin_ui) relying on domain logic--if required for performance or security reasons I can **deploy only some high level components** as I explain in [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When the project grows even more and I have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based architecture can be a stepping stone to services if and when my product needs that**--but at the beginning of a long running project with 5 full stack engeneers working on it what advantage does having two or three codebases gives me? I know developing a project that require code changes to a remote dependency needs some process adjustment as I explain in [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).



## Challenges

Component based is not a good fit for every project, when my application domain model doesn't differ much from what the data store presents there is no reason to change the conventional Rails approach. When I am on a growing conventional application I introduce components gradually as the complexity increases and the regular MVP approach isn't conducive to a good design. When I know the application is going to be under development for several months and it has complex business rules I introduce components early on to help define boundaries.

**You should absolutely not use a component based architecture without test driving each component in isolation.**

Be sure developers understand the meaning of each component--if someone adds public only code to a shared component it's gonna make it harder to extract components when needed. Pair switching or pull requests should help with that as well as keeping a README file in each component to explain its boundaries.

Some people are entrenched in using the Rails way at all costs and diverging is marked as plain wrong without deeper thought. It sounds a lot like me right after I left Italy and thought italian food was the best but never tasted other authentic cusines. 

There is a misconception that when a Rails app grows you have to break it in to services. I use service oriented architecture when it make sense for my business model and not to address code maintainability. [Always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.

## What to do next

This is an introduction to spark your interest and give you access to more technical resources. Leave a comment or ask questions in the [components in rails mailing list](https://groups.google.com/forum/#!forum/components-in-rails) or <a href="https://twitter.com/intent/tweet?button_hashtag=cbra" class="twitter-hashtag-button">Tweet #cbra</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>. 

Visit the centralized [Component Based Rails Architecture](http://cbra.info) site to view talks, blog posts and books; thanks to Stephan Hagerman for setting that up. You should read his book about [Component-based Rails Applications](https://leanpub.com/cbra/).




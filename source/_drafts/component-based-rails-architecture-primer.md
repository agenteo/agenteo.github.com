---
layout: post
title: Component based Rails architecture primer
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

I have worked on many successful products that fit in the classical MVC Ruby on Rails paradigm. When I get more features and the code grows sometimes conventions like: decorators, presenters, service objects are sufficient **but sometimes they don't help understand what the whole application does**. If I have 20 or 30 controllers and a similar number of models, Ruby namespaces can add modularity but can't enforce a dependency structure so classes create a tangle of dependencies that are hard to follow. **Component based architecture is complementary to good object oriented practices and uses namespaces, test driven development and Ruby gems to gradually define application boundaries and enforce an internal dependency structure**.

This approach differs from the conventional MVC Rails application to give visibility of what the whole application does through a dependency structure--an added bonus is I can now develop in smaller contexts without being overwhelmed by the entire application.

The components are in a `/components` directory in your application root and are either directly attached to the main application `Gemfile` or connected to another component as a dependency. A component is a Ruby on Rails engine or Ruby gem that you can generate using `rails plugin new public_ui --mountable` its dependencies are set in its `.gemspec` file, a test suite will test it in isolation and ensure the dependency structure is solid. You can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)

## A concrete example

This example is adapted from a real life application but to make it manageable I've omitted major features and only left four components: a staff only *administration area*, a *public area*, a *legacy migration* and some shared *domain logic*. The *legacy migration* was initially part of the admin component and later when its complexity increased it was extracted in a separate one--**I usually don't architect an application with components from day one instead I introduce them gradually as the complexity grows or when the scope changes**.

The high level components are required by the main Rails application `Gemfile`.

{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

This will look for the components `public_ui`, `admin_ui`, `legacy_migration` in the `components` directory in your Rails application and automatically resolve any local component dependency like the `domain_logic`--I explain how this works in [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

When a high level component provide routes they are mounted in the Rails application route file.

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}


## Handling application change

>> To have a project accelerate as development proceeds—rather than get weighed down by its own legacy—demands a design that is a pleasure to work with, inviting to change. A supple design.

When later the **legacy migration** is completed I can simply remove its component directory and its entry from the `Gemfile` without affecting the rest of your product--with a conventional approach I would have to find and delete the code hoping the tests catch any broken dependency.

If I need to add an API I can put it in a high level component (like public_ui and admin_ui) relying on domain logic--if required for performance or security reasons I can **deploy only some high level components** as I explain in [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When the project grows even more and I have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based architecture can even be a stepping stone to services if and when my product needs that**--but at the beginning of a long running project with 5 full stack engeneers working on it what advantage having two or three codebases give me? I know developing a project that require code changes to a remote dependency needs some process adjustment as I explain in [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).

Load increase doesn't mean increase in code complexity. A very complex application could have a smaller load then a very popular one that deals with a simple domain model. Addressing code maintainability doesn't solve code scalability [always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.


## Challenges

Component based is not a good fit for every project, when my application domain model doesn't differ much from what the data store presents there is no reason to change the conventional Rails approach. When I know the application is going to be under development for months and it has complex business rules I introduce components early on to help define boundaries. When I am on a growing conventional application I introduce components gradually as the complexity increases and the regular MVP approach isn't conducive to a good design.

**You should absolutely not use a component based architecture without test driving each component in isolation.**

Be sure developers understand the meaning of each component--if someone adds public only code to a domain logic component shared by admin and public it's gonna be harder to extract components when needed. Pair switching or pull requests should help with that as well as keeping a README file in each component to explain its boundaries.

## What to do next

This article is an introduction to the topic to spark your interest and point you to more technical resources. Leave a comment or ask questions in the [components in rails mailing list](https://groups.google.com/forum/#!forum/components-in-rails) or <a href="https://twitter.com/intent/tweet?button_hashtag=cbra" class="twitter-hashtag-button">Tweet #cbra</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>. Thanks to Stephan Hagemann there is a centralized resource with links to presentations, blog posts and books about [Component Based Rails Architecture](http://cbra.info). Stephan is also writing a great book with step by step details on topics that I only grasped [Component-based Rails Applications](https://leanpub.com/cbra/).

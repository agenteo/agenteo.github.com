---
layout: post
title: Component based Rails architecture primer
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

Many successful products fit in the classical Ruby on Rails paradigm: model, view, controller or MVC. When they get more features and the code grows conventions are: decorators, presenters, service objects **but sometime it's hard to understand what the whole application does**. Ruby namespaces can help that by adding modularity but can't enforce a dependency structure so classes can access any namespace and create tangled dependencies that are hard to follow. **Component based architecture is complementary to good object oriented practices and uses namespaces, test driven development and Ruby gems to define application boundaries and enforce an internal dependency structure**.

If you're unsure of what use case I am talking about this describes it in a language agnostic way:

>> When software with complex behavior lacks a good design, it becomes hard to refactor or combine elements. Duplication starts to appear as soon as a developer isn’t confident of predicting the full implications of a computation. Duplication is forced when design elements are monolithic, so that the parts cannot be recombined. Classes and methods can be broken down for better reuse, but it gets hard to keep track of what all the little parts do. When software doesn’t have a clean design, developers dread even looking at the existing mess, much less making a change that could aggravate the tangle or break something through an unforeseen dependency. In any but the smallest systems, this fragility places a ceiling on the richness of behavior it is feasible to build. It stops refactoring and iterative refinement.
>>
>> Evans, Eric. Domain-Driven Design: Tackling Complexity in the Heart of Software 

**Component based architecture doesn't mean you have to embrace all the domain driven design practices** but it diverges from a conventional MVC Rails application to give visibility of what the application does through a dependency structure and develop in smaller contexts.

by placing the code in components in a `/components` directory in your application root. High level component are attached to the main application or connected to another component via a dependency structure, 

A component is a Ruby on Rails engine or Ruby gem that you can generate using `rails plugin new public_ui --mountable` its dependencies will be set in its `.gemspec` file, a test suit will test it in isolation and ensure the dependency structure is solid. You can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)

## A concrete example

An existing application with code for an *administration area* and for a *public area* that share some *domain logic* can be sliced in three components--some *legacy migration* code could initially be part of the admin component and as it grows be extracted in a separate one. Having components from day one is unusual instead I introduce them as the complexity grows or when the scope changes.


The high level components are required by your main Rails application `Gemfile` for example:

{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

This will look for `public_ui`, `admin_ui`, `legacy_migration` inside the `components` directory in your Rails application--if they provide routes they have to be mounted in your Rails application route file:

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}

In our toy example the `domain_logic`--a dependency of `public_ui`, `admin_ui` and `legacy_migration`--is not in the `Gemfile` because it's automatically resolved as a local dependency. For more details read [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

## Handling application change

>> To have a project accelerate as development proceeds—rather than get weighed down by its own legacy—demands a design that is a pleasure to work with, inviting to change. A supple design.

When later the **legacy migration** is completed I can simply `git rm` its component directory and remove its entry from the `Gemfile` without affecting the rest of your product--if I followed a conventional approach I would have to find and delete the code hoping the tests catch any possible broken dependency.

If I need an API that could be a component (like public_ui and admin_ui) relying on domain logic--if required for performance or security reasons I can **deploy only parts of the component based architecture**. For more details read [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When the project grows even more and have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based approach can even be a stepping stone to service oriented architecture if and when your product needs that**--but at the beginning of a long running project with 5 full stack engeneers working on it what advantage does having two or three codebases brings? I know developing a project that require code changes to a remote dependency needs some process adjustment. If you are interested you can read [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).


Here's my adaptation:

Cognitive overload is the primary motivation for component based architecture. Components give people two views of the application: They can look at detail within a component without being overwhelmed by the whole, or they can look at relationships between components in views that exclude interior detail. The components should emerge as a meaningful part of the application, telling the story of the domain on a larger scale.

Solving code maintainability doesn't solve code scalability and a  monolithic app under load, [always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.


## Challenges

Component based is not a good fit for every project and it's hard to define a checklist to follow -- I think you have to work on a Rails app with 2/3 years of history to fully apreciate its benefits.

Some people are entrenched in the classic Rails approach and use arguments valid for small code bases or side projects outside their context.

If proficient and expert developers on a team are against component based do not enforce it, instead see if they would accept a limited time trial period on a specific area of the code to evaluate its benefits. I am using proficient and experts based on the [Dreyfus model of skill acquisition](http://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition).

Be sure developers understand the meaning of each component -- if someone adds public only code to a domain logic component shared by admin and public it's gonna be harder to extract components when needed. Pair switching or pull requests should help with that as well as keeping a README file in each component to explain its boundaries.

You should absolutely not use a component based architecture without test driving each component in isolation.

Many people bash a Ruby on Rails monolithic approach as not scalable but it really depends on what your product is doing. I worked on products handling 2/3K request per minute on 10 2X Dynos on Heroku delivering response times of around 80ms.

Let people know you are using or want to try *component based Rails architecture* <a href="https://twitter.com/intent/tweet?button_hashtag=cbra" class="twitter-hashtag-button">Tweet #cbra</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>. There is a central resource with links to presentations, blog posts and books at [http://cbra.info](http://cbra.info). Stephan Hagemann is writing a great book about this topic with detail step by step tutorial [Component-based Rails Applications](https://leanpub.com/cbra/) credit goes to him and Pivotal for the naming and sharing their discovering on this.


Most ruby gems have a dependency structure, what component based does is introduce that structure in a Rails application.



Many successful products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. When they get more features and the code grows Rails conventions are decorators to attach additional responsabilities to an object dynamically, presenters to convert a domain object to another representation (often for the browser), service objects to encapsulate domain operations **but sometime it's still hard to understand what the whole application does**.

Many successful products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. When they get more features and the code grows the convention is to manage it with concerns/decorators, presenters, service objects, namespaces--this is sufficient if code remains maintainable as complexity increases **but sometime it's still hard to understand what the whole application does**.

Decorators are good to attach additional responsabilities to an object dynamically, presenters are good to convert a domain object to another representation (often for the browser), service objects are encapsulating domain operations--only namespaces allow you to introduce modularity but they don't enforce a dependency structure so all the little parts can break out of a module boundary and become entangled and hard to understand. **Component based architecture is complementary to good object oriented practices and uses namespaces and Ruby gems to define application boundaries and enforce an internal dependency structure**.


If you have to interface to another system you could encapsulate that in a class. But if the logic is more complex you might need to accomodate that domain logic in more then one class meaning you need to create a namespace and the problem with namespaces is that they are accessible by any other class.

Some people are entrenched in the Rails way at all costs and diverging is marked as plain wrong without deeper thought. It sound a lot like when I left Italy and thought italian food was the best and there was no alternative but never tasted other authentic cusines. Living abroad I chance to taste foreign authentic cusines and I changed my mind. I might now have Turkish or Japanese or Indian every day but they are awesome.

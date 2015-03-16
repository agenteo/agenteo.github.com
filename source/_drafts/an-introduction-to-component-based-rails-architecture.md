---
layout: post
title: An introduction to component based Ruby on Rails architecture
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

Many successful products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. When they get more features and the code grows the convention is to manage it with concerns/decorators, presenters, service objects, namespaces--this is sufficient if code remains maintainable as complexity increases but if it's hard to understand what the application does consider another approach. **Component based architecture is complementary to Rails conventional practices and uses Ruby gems to define application boundaries and its internal dependency structure**.

Decorators are good to attach additional responsabilities to an object dynamically, presenters are good to convert a domain object to another representation (often for the browser), service objects are encapsulating domain operations but none of these help define areas of your code. Namespaces do and are a great way to introduce modularity in a Rails application but they don't enforce a dependency structure.

this extract helps clarify the conditions I am talking about:

>> When software with complex behavior lacks a good design, it becomes hard to refactor or combine elements. Duplication starts to appear as soon as a developer isn’t confident of predicting the full implications of a computation. Duplication is forced when design elements are monolithic, so that the parts cannot be recombined. Classes and methods can be broken down for better reuse, but it gets hard to keep track of what all the little parts do. When software doesn’t have a clean design, developers dread even looking at the existing mess, much less making a change that could aggravate the tangle or break something through an unforeseen dependency. In any but the smallest systems, this fragility places a ceiling on the richness of behavior it is feasible to build. It stops refactoring and iterative refinement.
>>
>> Evans, Eric. Domain-Driven Design: Tackling Complexity in the Heart of Software 

Component based architecture doesn't mean you have to embrace all the domain driven design practices, it means you keep all the parts composing your application in a formal area (the `/components` directory) using a dependency structure to describe what the application does and develop in smaller contexts.

## A concrete example

An application with code for an *administration area* and for a *public area* that share some *domain logic* might benefit from having three components--some *legacy migration* code could initially be part of the admin component and as it grows be extracted in a separate one.

This application don't need to have components from day one but as the complexity grows being aware of relevant areas and their dependencies allows to move their code in to components. I explained the process in this post.

A component is a Ruby on Rails engine or Ruby gem that you can generate using `rails plugin new public_ui --mountable`. You can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)

Those components are required by your main Rails application `Gemfile` for example:

{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

This will look inside the `components` directory in your Rails application for the `public_ui`, `admin_ui`, `legacy_migration`--if they provide routes they can be mounted in your Rails application route file:

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}

Notice `domain_logic` (a dependency of `public_ui` and `admin_ui`) is not in the `Gemfile` because it will be automatically resolved as a local dependency. For more details read [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

## Handling application change

>> To have a project accelerate as development proceeds—rather than get weighed down by its own legacy—demands a design that is a pleasure to work with, inviting to change. A supple design.

When later the **legacy migration** is completed you can simply `git rm` its component directory and remove its entry from the `Gemfile` without affecting the rest of your product--if you followed a conventional approach you would have to find and delete the code hoping your tests are catching any regression.

If you product now need an API that could be a component (like public_ui and admin_ui) relying on domain logic--if required for performance or security reasons you can **deploy only parts of your component based architecture**. For more details read [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When you grow and have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based approach can be a stepping stone to service oriented architecture if and when your product needs that** -- but at the beginning of a long running project you might only have 5 full stack engeneers working on the entire project and what advantage does having two or three codebases brings? I know developing a project that require code changes to a remote dependency needs some process adjustment. If you are interested you can read [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).


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




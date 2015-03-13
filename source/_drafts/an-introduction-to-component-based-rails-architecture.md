---
layout: post
title: An introduction to component based Ruby on Rails architecture
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

Many popular and load intensive products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. As they get more features the code will grow and the conventions to manage it are concerns/decorators, presenters, service objects, namespaces. This might be sufficient if as complexity increase your code stays maintainable and delivers business value but if you are at a point where it's hard to "keep track of what all the little parts are doing" it's time to consider another approach. **Component based architecture is complementary to Rails conventional good practices and uses Ruby gems to define application boundaries**.

I think this situation is explained well in this extract:

>> When software with complex behavior lacks a good design, it becomes hard to refactor or combine elements. Duplication starts to appear as soon as a developer isn’t confident of predicting the full implications of a computation. Duplication is forced when design elements are monolithic, so that the parts cannot be recombined. Classes and methods can be broken down for better reuse, but it gets hard to keep track of what all the little parts do. When software doesn’t have a clean design, developers dread even looking at the existing mess, much less making a change that could aggravate the tangle or break something through an unforeseen dependency. In any but the smallest systems, this fragility places a ceiling on the richness of behavior it is feasible to build. It stops refactoring and iterative refinement.
>>
>> Evans, Eric. Domain-Driven Design: Tackling Complexity in the Heart of Software 

Component based architecture doesn't mean you are going full on domain driven design, it means you move meaningful parts of your application in a formal area of your code (the `/components` directory) and set a dependency structure. This clarifies what the whole application does and allows to work on a single component without being overwhelmed by the whole.

A component is a Ruby on Rails engine or Ruby gem that you can generate using `rails plugin new public_ui --mountable`. You can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)

## A concrete example

An application with an *administration area* and a *public area* sharing *domain logic* have three components -- a task to *migrate legacy* content might initially live in the admin component but as it grows it can be extracted in a separate component.

How do you decide to use components instead of `rails_admin` for the administration area and a regular controller index and show for the public and rake task for the legacy migration? After all isn't that what makes Rails good for "agile web development"? Yes and no, and you need to ask yourself how long is this product going to be worked on for? **If this is a 1 month pilot project with 3 developers do not use component architecture!** Leverage Rails's conventions and its best practices to accomodate growth. If this is a product--or as it's fashionable to call it a *minimum viable product*-- with an aproximate release date between 3 to 6 months from now with 3 to 5 developers you are on the border line and depending on your product complexity you might fit the Rails conventional approach. If you time to market is over 6 months you should consider starting with a component structure unless your product is revolutionary simple.

The whole minimum viable product doesn't mean you have to create a minimally maintainable product, if after a few months it's hard to estimate consistently because the code is a mess you are in for a big surprise when you are successful and suddenly need to reanimate a dead body. Uncle Bob touch base on that in his awesome (Architecture the Lost Years)[http://confreaks.tv/videos/rubymidwest2011-keynote-architecture-the-lost-years]. No matter what your CTO says building big balls of mud is not

Those components are required by your main Rails application `Gemfile` for example:


{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

This will look inside the `components` directory in your Rails application for the `public_ui`, `admin_ui`, `legacy_migration` components -- if they provide routes they can be mounted in your Rails application route file:

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}

Notice that `domain_logic` is not in the `Gemfile`, it will be automatically resolved as a local dependency. For more details read [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

## Handling application change

When later the **legacy migration** is completed you can simply `git rm` its component without affecting the rest of your product -- if you followed a conventional approach you would have to find and delete the code hoping your tests are catching any regression.

If you need to add an API that could be a component relying on domain logic -- if required for performance or security reasons you can **deploy only parts of your component based architecture**. For more details read [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When you grow and have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based approach can be a stepping stone to service oriented architecture if and when your product needs that** -- but at the beginning of a long running project you might only have 5 full stack engeneers working on the entire project and what advantage does having two or three codebases brings? I know developing a project that require code changes to a remote dependency needs some process adjustment. If you are interested you can read [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).


Here's my adaptation:

>> Cognitive overload is the primary motivation for component based architecture. Components give people two views of the application: They can look at detail within a component without being overwhelmed by the whole, or they can look at relationships between components in views that exclude interior detail. The components in the domain layer should emerge as a meaningful part of the model, telling the story of the domain on a larger scale.

Solving code maintainability doesn't solve code scalability and a service oriented architecture might perform as bad as a monolithic app under load, [always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.


## Challenges

Component based is not a good fit for every project but it's hard to define a checklist to follow -- I think you have to work on a Rails app with 2/3 years of history to fully apreciate its benefits.

Some people are entrenched in the classic Rails approach and use arguments valid for small code bases or side projects outside their context.

If proficient and expert developers on a team are against component based do not enforce it, instead see if they would accept a limited time trial period on a specific area of the code to evaluate its benefits. I am using proficient and experts based on the [Dreyfus model of skill acquisition](http://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition).

Be sure developers understand the meaning of each component -- if someone adds public only code to a domain logic component shared by admin and public it's gonna be harder to extract components when needed. Pair switching or pull requests should help with that as well as keeping a README file in each component to explain its boundaries.

You should absolutely not use a component based architecture without test driving each component in isolation.

Many people bash a Ruby on Rails monolithic approach as not scalable but it really depends on what your product is doing. I worked on products handling 2/3K request per minute on 10 2X Dynos on Heroku delivering response times of around 80ms.

Let people know you are using or want to try *component based Rails architecture* <a href="https://twitter.com/intent/tweet?button_hashtag=cbra" class="twitter-hashtag-button">Tweet #cbra</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>. There is a central resource with links to presentations, blog posts and books at [http://cbra.info](http://cbra.info). Stephan Hagemann is writing a great book about this topic with detail step by step tutorial [Component-based Rails Applications](https://leanpub.com/cbra/) credit goes to him and Pivotal for the naming and sharing their discovering on this.

---
layout: post
title: An introduction to component based Ruby on Rails architecture
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

Many products fit the classical Ruby on Rails application development approach: model, view, controller -- they can be very popular and load intensive. As the product gets more features the code will grow and the convention is to use concerns (decorators), presenters, service objects, namespaces. **Component based architecture is complementary to those good practices and uses Ruby gems to define application boundaries**.

I want to stress again the conventional MVC might be sufficient if when complexity increases your code remains maintainable and delivers business value but if you are at a point where it's hard to tell what the application is doing consider the component based approach.

**The component based architecture gives structure to your product while facilitating developer life** -- you have a single codebase divided in components with significant responsibilities. A component is a Ruby on Rails engine or Ruby gem that you can generate using `rails plugin new public_ui --mountable` you can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html)


## A concrete example

An application with an *administration area* and a *public area* sharing *domain logic* have three components -- a task to *migrate legacy* content might initially live in the admin component and as it grows it can be extracted in to a separate component. Those components are required by your main Rails application `Gemfile` for example:


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


## Handling application change

When later the **legacy migration** is completed you can simply `git rm` its component without affecting the rest of your product -- if you followed a conventional approach you would have to find and delete the code hoping your tests are catching any regression.

If you need to add an API that could be a component relying on domain logic -- if required for performance or security reasons you can [deploy only parts of your component based architecture](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When you grow and have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based approach can be a stepping stone to service oriented architecture if and when your product needs that** -- but at the beginning of a long running project you might only have 5 full stack engeneers working on the entire project and what advantage does having two or three codebases brings? I know developing a project that require code changes to a remote dependency needs [some process adjustment](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).

Solving code maintainability doesn't solve code scalability and a service oriented architecture might perform as bad as a monolithic app under load, [always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.


## Downsides

Component based is not a good fit for every project but some people entrenched in the classic Rails approach use arguments valid for small code bases or side projects outside their context. If the majority of your team is against it see if they would accept a trial period otherwise do not proceed against their will. The minimum viable product doesn't mean minimum maintainable product.

Be sure developers understand the meaning of each component -- if someone adds public only code to a domain logic component shared by admin and public it's gonna be harder to extract components when needed. Pair switching or pull requests should help with that and having and add a README file in each component explaining its boundaries.

You should not use a component based architecture without test driving each component in isolation.

Many people bash a Ruby on Rails monolithic approach as not scalable but it really depends on what your product is doing.




or if you would like a step by step guide I'd recommend [Stephan Hagemann book](https://leanpub.com/cbra/).

---
layout: post
title: An introduction to component based Ruby on Rails architecture
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

Many products fit in the classical Ruby on Rails application development approach: model, view, controller -- they can be very popular and load intensive. As the product gets more features the code will grow and the convention is to use *concerns, service objects, namespaces and then move to service oriented architecture* -- the other approaches help code maintainability but I think switching to services because of code organization is a mistake. **Component based architecture is an approach leveraging Ruby gems to surface application boundaries -- this could be in an ongoing project where it's hard to tell what's going on or a new complex project that would slip out of the Rails conventional approach soon after it starts**.

I want to stress again the conventional MVC might be sufficient for you if when complexity increases you can keep your code maintainable kk

I want to stress again the conventional MVC might be sufficient for you if when complexity increases you can keep your code maintainable and steadily deliver features while your team is confident on what your code does. But if you are at a point where it's hard to tell what the application is doing you might want to consider an approach complementary to your current strategy.

**The component based architecture gives structure to your product while facilitating developer life** -- you have a single codebase divided in components with significant responsibilities. For example an application with an administration area and a public facing area sharing some domain logic are three components -- a task to migrate legacy content might initially live in the admin component and as it grows it can be extracted in to a separate component. Those components are required by your main Rails application `Gemfile` for example:


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

## What is a component

**A component is a Ruby on Rails engine or Ruby gem** and you can generate one using `rails plugin new public_ui --mountable` you can find out more about engines on [Rails guides](http://guides.rubyonrails.org/engines.html) or if you would like a step by step guide I'd recommend [Stephan Hagemann book](https://leanpub.com/cbra/)

## Handling application change

When later the **legacy migration** is completed you can simply `git rm` its component without affecting the rest of your product -- if you followed a conventional approach you would have to find and delete the code hoping your tests are catching any regression.

If you need to add an API that could be a component like public and admin relying on domain logic -- if required for performance or security reasons you can [deploy only parts of your component based architecture](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When you grow and have two teams one dedicated to admin features one to public features it would make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based approach can be a stepping stone to service oriented architecture if and when your product needs that** -- but at the beginning of a long running project you might only have 5 full stack engeneers working on the entire project and what advantage does having two or three codebases brings? I know developing a project that require code changes to a remote dependency needs [some process adjustment](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).

Solving code maintainability doesn't solve code scalability and a service oriented architecture might perform as bad as a monolithic app under load, [always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.


## Downsides

I mentioned at the beginning when I advice against component based but I worked with teamates that simply did not like switching from the classic Rails approach. If the vast majority of your team is against this approach do not proceed with it but **if you have experience with unmaintainable large codebases don't let people silence you with arguments valid for small code bases or side projects that do not apply to a long running more complex product**.

Be mindful of developers missunderstanding or ignoring the meaning of the components -- if you have a domain logic to share models and logic between your admin and public you should not add public only logic to it. When code is added to the wrong component it might take a while for someone to notice, no harm will be done but it will impact the maintainability. Pair switching or pull requests should help with that.

You should not use a component based architecture without test driving each component in isolation.

Many people bash a Ruby on Rails monolithic approach as not scalable but it really depends on what your product is doing.

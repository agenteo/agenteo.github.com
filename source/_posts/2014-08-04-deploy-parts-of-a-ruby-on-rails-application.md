---
layout: post
title: Deploy parts of a Ruby on Rails application
comments: true
tags:
  - work
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
redirect_from:
  - /feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/
  - /work/ruby/rails/engines/2014/08/04/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/
  - /work/ruby/rails/engines/2014/08/04/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines.html/
---

**This article explains how to deploy portions of a Ruby on Rails application to separate servers with the use of Ruby Gems and Rails Engines.**

In the past I used Ruby gems and Rails engines as building blocks of complex Rails applications to get better long term maintainability but this time it started for a different reason.

We were a team of 6 full stack developers and one product owner part of a larger engineering division engaged in a portal re-platforming. Our project had an administration interface for editors to manage different type of content and a public view of it.

Months in to development we were told of a company policy requiring administration interfaces to be deployed on a separate server behind a corporate VPN--another good reasons for it was very different user requests loads between the two portions.

We brainstormed and came out with 3 proposals.

## Full service oriented architecture

Split the monolithic application in three applications: admin, public, API. Admin would be reading/writing from the API, public just read.

That service oriented architecture was pushed hard by management but it felt like premature optimization since nothing else was going to use the API but we knew it would introduce problems.

The public and admin applications needed to share significant amount of user interface to allow admins content preview to look like on the public portion.

The overhead of a team of 6 committing work in three separate repositories and deploy three applications to see initial features delivered was going to slow development down. 

## Multiple apps with Engines on a private server

Split the monolithic application in two: admin, public both depending on two Rails Engines published to a private server: `shared_ui` to allow content preview and `persistence` containing the database abstraction and `ActiveRecord` models.

Similarly to the first proposal maintaining multiple repositories and dealing with local dependencies in development mode would slow down development--now even more because shared engines would have to be git submodules or subtrees as well as being published to a private gem server by multiple developers potentially multiple times per day. This was a recipe for conflict disaster that I saw happening before and wanted to avoid.

Another team used this strategy on a different project and after seeing how inefficient it was I summarized an alternative with components documented [here](http://teotti.com/rails-service-oriented-architecture-alternative-with-components/).

## One app with local Gems and Engines

We decided to go with one Ruby on Rails application turning the administration and public on and off based on a *running mode* feature flag.

In order to do this we gradually moved code from the `/app` directory in to two entry point component engines: `admin_ui` and `public_ui` each with their own dependency structure.

![]({{ site.url }}/assets/article_images{{ page.url }}dependency_structure.jpg)

The main application would mount the entry point Engines routes based on a unix environment variable like this:

{% highlight ruby %}
Rails.application.routes.draw do
case AppRunningMode.value
  when :admin
    mount AdminUi::Engine => "/admin"
  when :public
    mount PublicUi::Engine => "/"
  else
    mount AdminUi::Engine => "/admin"
    mount PublicUi::Engine => "/"
end
{% endhighlight %}

The class method `AppRunningMode.value` is just a proxy to the env variable.

So we run the application public portion with:

{% highlight bash %}
RUNNING_MODE=public rails s
{% endhighlight %}

and the administration portion with:

{% highlight bash %}
RUNNING_MODE=admin rails s
{% endhighlight %}

With this approach we could run both admin and public in development mode simply omitting that variable.

{% highlight ruby %}
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
end
{% endhighlight %}

we only needed the entry points listed in the main Rails application Gemfile thanks to the bundler `path` option with block [explained more here](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

### Details about the dependencies

Both `admin_ui` and `public_ui` depended on a `persistence` engine that encapsulated the `ActiveRecord` models and a `shared_ui` that contained the `erb` templates used to display and preview content.

As the application evolved so did the dependency structure--for example the admin had a `site_search` component gem encapsulating the logic to update the portal internal search engine when content pieces were published.

Editors were review existing content in the legacy application and mark it for migration--overnight it would be pushed to an Amazon queue and the Rails application would pull and upsert the content in the new database. We didn't want to mix that logic with the **persistence** engine but where else? We encapsulated all that behaviour in one component/engine: `legacy_migration`--after launch that engine was removed leaving no trace behind about the migration scripts. 

![]({{ site.url }}/assets/article_images{{ page.url }}dependency_structure_with_migration.jpg)

### Adequate memory usage

We were also able to reduce memory footprint creating a bundle group for the running mode to require only that portion's gems:

{% highlight ruby %}
group :public_app do
  path 'components' do
    gem 'public_ui'
  end
end

group :admin_app do
  path 'components' do
    gem 'admin_ui'
    gem 'legacy_migration'
  end
end
{% endhighlight %}

We only needed the entry point listed in the main Rails application Gemfile thanks to the bundler groups associated with the application running modes--this is [explained more here](http://teotti.com/reduce-memory-footprint-requiring-portions-of-your-component-based-rails-applications/).

I updated this in `config/application.rb`:

{% highlight ruby %}
Bundler.require(*Rails.groups + AppRunningMode.bundler_groups)
{% endhighlight %}

to require only the gems in the group we're on. When bundling for the admin server you can now skip public with:

{% highlight ruby %}
bundle --without 'public_app'
{% endhighlight %}

## Summary

You might be wondering couldn't you achieve this result without engines and gems? Partially. The core idea is a conditional statement wrapping the routes for public and admin but there is more to that. Thanks to components this design was intention revealing and ready to evolve the project to services--perhaps when the team size exceeded 10/12 developers making in process boundaries harder to maintain with team diligence.

I think this was a pragmatic approach using the design we needed to deliver business value but ready to evolve as application aged.

UPDATE: a video of a talk I gave about this at NYC.rb is available on [https://www.youtube.com/watch?v=rMOn2H7h3oY](https://www.youtube.com/watch?v=rMOn2H7h3oY)

---
layout: post
title: Feature flagging portions of your Ruby on Rails application with engines
comments: true
categories:
  - work
  - ruby
  - rails
  - engines
redirect_from:
  - /work/ruby/rails/engines/2014/08/04/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/
  - /work/ruby/rails/engines/2014/08/04/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines.html/
---

In the past I used Rails engines to create smaller components in complex Rails applications with the objective of a better long term maintainability. What that usually means is I separate out user interface engines from domain logic engines.

For the last two months I've been working on a greenfield project with a public and administration interface both living in the same application.

Recently I was asked to break up the public part from the administration part of a web application because of a company policy to lock administration interfaces behind a VPN. Other points that were brought up: to separate the load between the two portions, and to reduce admin deployments disrupting service on the public portion.

## First proposal

An initial proposal was to split it in two applications and have them talking via an API. That service oriented architecture seemed very much premature optimization since nothing else was going to use the API. Also the two portions of the app (public and admin) would have to share a significant amount of domain logic (to access the data models) and user interface (to allow staff members to preview elements as they will look on public).

## Second proposal

Another solution was to separate the shared domain logic and user interface in to Rails engines, and have the two portions (public and admin) depend on them. The downside of this was dealing with local dependencies while in development mode.

We knew our development would constantly alter the domain logic engine and the shared ui engine, meaning releasing a new gem for every admin or public update. We would also have to [update our work flow]({% post_url 2014-08-05-git-precommit-hooks-helping-local-ruby-gems-development %}) to ensure the Gemfile.lock won't be pointing to the local gems when checked in version control.

## Final proposal

Instead why not keep the application as one, and switch the admin interface and public interface on or off based on an application *running mode* feature flag?

In order to do this, both *admin_ui* and *public_ui* are Rails engines and the main application mounts them based on a unix environment variable.

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

So you can then run the application public portion with:

{% highlight bash %}
RUNNING_MODE=public rails s
{% endhighlight %}

and run the admin portion with:

{% highlight bash %}
RUNNING_MODE=admin rails s
{% endhighlight %}

One of the advantages of this approach is you can run in development mode without that variable and both portions will be mounted.

It will be likely be part of the server provisioning process to setup that ENV variable.

The main application Gemfile will still include both engines:

{% highlight ruby %}
gem 'domain_logic', path: 'engines/domain_logic'
gem 'shared_ui', path: 'engines/shared_ui'
gem 'admin_ui', path: 'engines/admin_ui'
gem 'public_ui', path: 'engines/public_ui'
{% endhighlight %}

So the engines are all there, and if you have a `raise 'boom'` in your `admin_ui/lib/admin_ui.rb` even when the app running mode is set to public *will* explode. This unrealistic example is a reminder that this is a single application. Hopefully your test suite will catch that raise.

In regards to the rails engines approach both AdminUi and PublicUi depend on a DomainLogic engine and a SharedUi engine. This facilitate a complete split of the two portions in the future without locking you in to any specific architecture today.


## Summary
I think this approach is pragmatic and delivers what we need now allowing up to adapt if in the future we will need a different architecture.

If you had to split portions of your applications on different servers I'd like to hear your approach. If you have any question feel free to use the comments.

UPDATE: a video of a talk I gave about this at NYC.rb is available on [https://www.youtube.com/watch?v=rMOn2H7h3oY](https://www.youtube.com/watch?v=rMOn2H7h3oY)

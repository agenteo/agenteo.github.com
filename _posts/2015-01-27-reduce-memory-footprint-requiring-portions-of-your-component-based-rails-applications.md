---
layout: post
title: Reduce memory footprint requiring portions of your component based Rails application with Bundler
comments: true
tags:
  - work
  - ruby
  - rails
  - engines
---

This strategy applies to Ruby on Rails applications built with a component based architecture (#cbra) and serving multiple portions.

I've explained how to serve multiple portions on [this article](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

## Usecase

The application has different audiences and different deployments servers but you don't want to go SOA and deal with separate projects or publishing multiple libraries depending on each other to share significant amount of logic as I posted [here](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).

Examples of this could be an app with a public facing portion and admin part and an API and a legacy content migration. When you run public why would you require all the other components? That's what Ruby on Rails will do by default.

## Ignoring Gemfile.lock

There is a [long article](http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/) where TaskRabbit explains how they take advantage of component based rails applications and how they manage their Gemfile to source only relevant portions of the application. I created a branch with their approach [here](https://github.com/agenteo/lab-bundler-groups/tree/boot-inquirer-approach/lab-cbra-bundler-groups).

What I don't like about it is disconnecting the application from the Gemfile.lock, here's how it works:

{% highlight ruby %}
gemspec path: "apps/shared"
BootInquirer.each_active_app do |app|
  gemspec path: "apps/#{app.gem_name}"
end
{% endhighlight %}

BootInquirer knows about running portions (via ENV variables) and running bundle would only include relevant components. **But updates to a component gemspec aren't stored in Gemfile.lock.**

You will be without a manifest to tell what version of gems your production app is running. 

For our application that relies on multiple shared company gems that would mean locking the gems on each component gemspec or bundling and ending up with the latest version when we might not want to. 

## Bundler groups to require portions of your app

I like the idea of loading requiring portions of the application using [bundler groups](http://bundler.io/v1.5/groups.html). For example an app serving public and admin:


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

where admin app also has a set of ongoing legacy migration daemons.

Now running `bundle` will still install all the gems but you can (and should) ignore the portion that isn't required. 

For example when deploying the public application:

{% highlight bash %}
bundle --without 'admin_app'
{% endhighlight %}

You will see a confirming message: `Gems in the group admin_app were not installed.` and hopefully shave off a few seconds from installing unnecessary dependencies.

You can run with an env `BUNDLE_WITHOUT` or `--without` see [bundler excellent documentation](http://bundler.io/v1.3/man/bundle-config.1.html). Heroku [supports](https://devcenter.heroku.com/articles/bundler#specifying-gems-and-groups) the env variable.

One little change you need to do is inside `config/application.rb` change `Bundler.require` to:

{% highlight ruby %}
Bundler.require(*Rails.groups + AppRunningMode.bundler_groups)
{% endhighlight %}

`AppRunningMode` is aware of the APP_RUNNING_MODE env variable and translates that in to a bundler group.

Here's an example:

{% highlight ruby %}
class AppRunningMode

  class << self

    def value
      case ENV['APP_RUNNING_MODE']
      when 'workshop'
        return :workshop
      when 'playground'
        return :playground
      else
        return :development
      end
    end

    def bundler_groups
      case value
      when :workshop
        return [:workshop_app]
      when :playground
        return [:playground_app]
      else
        return [:workshop_app, :playground_app]
      end
    end

  end

end
{% endhighlight %}


This is the same class I use to allows for components routes to be mounted programmatically in my other [post](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

I created a test example app with a component based app running two portions: playground and workshop. I've setup workshop to depend and require these gems at startup:

{% highlight ruby %}
s.add_dependency "chronic"
s.add_dependency "state_machine"
s.add_dependency "carrierwave"
s.add_dependency 'prawn'
s.add_dependency 'cinch'
s.add_dependency 'nokogiri'
{% endhighlight %}

to keep the example simple playground doesn't have any dependency.

I run a `ps` for the current ruby process in a controller like this:

{% highlight bash %}
memory_usage = `ps -o rss= -p #{Process.pid}`.to_i
render text: "Ruby process memory usage #{memory_usage} KB"
{% endhighlight %}

and rendered it out on a `/benchmark`.

Running playground portion only:

```
Ruby process memory usage 73924 KB
```

Running both playground and workshop:

``
Ruby process memory usage 83148 KB
```
 
I've uploaded a github repo [here](https://github.com/agenteo/lab-bundler-groups/tree/master/lab-cbra-bundler-groups) with this example as well as a simpler one file test outside of Rails.
 
# Conclusion

If your Ruby on Rails application holds multiple portions in a single repository requiring only the served portion will help reducing memory usage as well as enforcing your dependency structure.

I checked on the public portion of an app deployed on Heroku running a 2400 requests per minute load test from an EC2 instance with [Vegeta](https://github.com/tsenart/vegeta) before the change the 10 2X dynos memory usage on Newrelic would go from a minimum of 422 up to 674MB. After the change and applying the same load test we're starting from 377 up to 588MB. You milage might vary but I'd be surprised if you have no gain.

The `Gemfile.lock` remains the manifest of what your apps are locked to. If for some reason you need different versions of the same gems in your components I'd love to hear from you, perhaps you should revisit the single repository approach.

If you have any feedback I'd like to hear from you on the comments below or twitter [@agenteo](http://twitter.com/agenteo).

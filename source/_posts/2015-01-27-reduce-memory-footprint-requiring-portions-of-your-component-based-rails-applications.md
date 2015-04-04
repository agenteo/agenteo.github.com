---
layout: post
title: Reduce memory footprint requiring portions of your component based Rails application with Bundler
comments: true
tags:
  - work
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

A Ruby on Rails application built with [component based architecture](http://teotti.com/component-based-rails-architecture-primer/) [serving multiple portions](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/) to different audiences for example: public, admin and API will install and require them all but you can require only the necessary portion to reduce memory usage and speed up the bundling process.

I leverage [bundler groups](http://bundler.io/v1.5/groups.html) to define the portions of my application inside the `Gemfile` for example an app serving public and admin:

{% highlight ruby %}
# Gemfile
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

The admin application is deployed with some legacy migration daemons.

## Speed up deployment

Running `bundle` on your workstation installs all the gems and locks your `Gemfile.lock` with all the components but when you deploy to the admin server you can (and should) ignore the public portion that isn't required. For example deploying the public application with:

{% highlight bash %}
bundle --without 'public_app'
{% endhighlight %}

You will see a confirming message: `Gems in the group public_app were not installed.` and probably shave off a few seconds from installing unnecessary dependencies.

If you don't like the inline option you can use an environment variable `BUNDLE_WITHOUT` for more information see [bundler excellent documentation](http://bundler.io/v1.3/man/bundle-config.1.html). Heroku [supports](https://devcenter.heroku.com/articles/bundler#specifying-gems-and-groups) that environment variable.

## Decrease memory usage

Inside `config/application.rb` change `Bundler.require` to:

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

This extends the class I use to allow components routes to be mounted programmatically when [serving multiple portions](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

## Benchmarking a practical example

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

The benchmark is a simple `ps` for the current ruby process in a controller like this:

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

```
Ruby process memory usage 83148 KB
```
 
I've uploaded a github repo [here](https://github.com/agenteo/lab-bundler-groups/tree/master/lab-cbra-bundler-groups) with this example as well as a simpler one file test outside of Rails.
 
# Conclusion

If your Ruby on Rails application holds multiple portions in a single repository requiring only the served portion will help reducing memory usage as well as enforcing your dependency structure.

I checked on the public portion of an app deployed on Heroku running a 2400 requests per minute load test from an EC2 instance with [Vegeta](https://github.com/tsenart/vegeta) before the change the 10 2X dynos memory usage on Newrelic would go from a minimum of 422 up to 674MB. After the change and applying the same load test we're starting from 377 up to 588MB. You milage might vary but I'd be surprised if you have no gain.

The `Gemfile.lock` remains the manifest of what your apps are locked to. If for some reason you need different versions of the same gems in your components I'd love to hear from you, perhaps you should revisit the monolithic approach.

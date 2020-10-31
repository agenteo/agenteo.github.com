---
layout: post
title: Use of Ruby on Rails environments
comments: true
tags:
  - ruby
  - ruby-on-rails
redirect_from:
  - /work/ruby/2013/04/30/use-of-rails-environments/
  - /work/ruby/2013/04/30/use-of-rails-environments.html/
---

When you generate a Ruby on Rails application it will create three environments:
* development
* production
* test

each has a corresponding configuration file:

* config/environments/development.rb
* config/environments/production.rb
* config/environments/test.rb

The purpose of those environments is to configure the Ruby on Rails framework.
[Rails guide link](http://guides.rubyonrails.org/configuring.html#rails-environment-settings).

In development mode Rails reloads all app classes and turns off caching
to allow a faster development cycle. This is how the app runs on a development
workstation.

In production mode all caching is turned on, often pointing to a memcached
server. This is how the app runs on the live server.

The test mode is used in the tests, we have a special throw away database used
only for test, wiped out between test runs.

These are the Rails default environments.

What I've often seen are extra Rails environments such as:

* develop -- a development server used only for development tests
* staging/pre_production -- a server where stakeholders can test stories on an
  environment as similar to production as possible

rhat I usually see is those extra environments are a perfect copy of `config/environments/production.rb`.

So I started wondering what's their purpose?

I can tell you what their purpose used to be for me.

In the past I used the map each Rails environment to a server stage, and use them
to load configuration and set behaviour.

I used to think having a YAML file to load configuration was a neat solution to
setting configuration on different stages. And I am pretty sure I wasn't alone,
[here is an old Railcast about that](http://railscasts.com/episodes/85-yaml-configuration-file).

Now I'd rather put that configuration in an unix ENV variable and have the code
load it from there. This [link](http://railsapps.github.io/rails-environment-variables.html) covers this approach.

Each server stage will be provisioned with apropriate ENV variables (ie. S3BUCKET).

Look at [foreman](https://github.com/ddollar/foreman) or [dotenv](https://github.com/bkeepers/dotenv) to use the env variables approach in development mode.

Another thing I used to do what turning on some behaviour on specific stages. This
wasn't feature flagging but simply a server stage dependent behaviour.

## Turning on behaviour on specific server stages
If the separate Rails environment is only used for feature toggling (ie. display
a different header to differentiate the staging site from production site) do we
really need a separate Rails environment for that?

Why not having as part of the server provisioning a unix variale (ie. STAGE='staging')
set to the server stage?

In Rails instead of:

{% highlight ruby %}
if Rails.env.staging?
# do stuff
end
{% endhighlight %}

we will use:

{% highlight ruby %}
if ENV['STAGE'] == 'staging'
# do stuff
end
{% endhighlight %}

If you find typing that often a simple helper could be introduced:

{% highlight ruby %}
class ServerStage
   def self.current
     ENV['STAGE']
   end
   
   def self.staging?
     current == 'staging'
   end
end
{% endhighlight %}

{% highlight ruby %}
if ServerStage.staging?
# do stuff
end
{% endhighlight %}



## Conclusion
My suggestion is to run both staging and production servers using the Rails
production environment unless there are Rails configuration differences between
them.

What's your opinion? I am curious to see if I missed some useful application of
Rails environments or overlooked at downside of ENV variables.
---
layout: post
title: Gemfile hierarchy in Ruby on Rails component based architecture
comments: true
categories:
  - work
  - ruby
  - engines
redirect_from:
  - /work/ruby/engines/2014/11/19/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/
  - /work/ruby/engines/2014/11/19/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture.html/
---

When working on component based Rails applications you create a dependency hierarchy of local engines.

Let's say you have an `admin_ui` engine and a `public_ui` engine and they both depend on a `domain_logic` engine.

**TL;DR add bundler's undocumented `path 'components'` at the top of your Gemfile and it will recursively require gemspecs and you won't need to add path individually for each gem anymore.**

You would imagine that adding to the main application:

{% highlight ruby %}
gem 'admin_ui', path: 'components/admin_ui'
gem 'public_ui', path: 'components/public_ui'
{% endhighlight %}

should be sufficient. But you'd be in for a surprise, when you run bundle:

{% highlight bash %}
$ bundle
Resolving dependencies...
Could not find gem 'domain_logic (>= 0) ruby', which is required by gem 'admin_ui (>= 0) ruby', in any of the sources.
{% endhighlight %}

the reason for this error is that `admin_ui` is trying to bring in its dependency `domain_logic` but its unable to find its sources.

The solution I have been using so far is to include the `domain_logic` local path in the main application `Gemfile` like this:

{% highlight ruby %}
gem 'admin_ui', path: 'components/admin_ui'
gem 'public_ui', path: 'components/public_ui'

gem 'domain_logic', path: 'components/domain_logic'
{% endhighlight %}

When you have a more complex application this approach means you are flattening your dependency tree in the top level application. I think and it's far from intuitive or maintainable.

## In an ideal world

Bundler should offer a directive such as:

{% highlight ruby %}
path 'components'
{% endhighlight %}

and I guess Christmas came earlier this year because... it does!

By adding that path bundler will use that path to resolve dependencies:

{% highlight bash %}
Using domain_logic 0.0.1 from source at components
Using admin_ui 0.0.1 from source at components
Installing coffee-script-source 1.8.0
Installing execjs 2.2.2
Installing coffee-script 2.3.0
Installing coffee-rails 4.0.1
Installing jbuilder 2.2.5
Installing jquery-rails 3.1.2
Using public_ui 0.0.1 from source at components
{% endhighlight %}

Your main application `Gemfile` doesn't need the path on its top level dependencies now looking like this:

{% highlight ruby %}
gem 'admin_ui'
gem 'public_ui'
{% endhighlight %}

and the `admin_ui/Gemfile` doesn't even need to specify the path for `domain_logic`.

EDIT: it's better to avoid a global source that could collide with other gems present on gemservers. Instead use a block to wrap your components:

{% highlight ruby %}
path 'components' do
  gem 'admin_ui'
  gem 'public_ui'
end
{% endhighlight %}

## Components Gemfile

When you test in isolation your components bundler won't be able to find the local gem.

We can now take advantage of this `path` directive in the component `Gemfile`:

{% highlight ruby %}
path '../'
{% endhighlight %}

to avoid specifing local paths of depencies already specified in the gemspec.

## Conclusion

I run in to `path` while looking at the bundler source code to add the same feature. When talking with Terence he didn't mentioned it and it's not in Bundler documentation or site either so I'll clarify with him if it's a supported feature.

UPDATE: looks like it is supported there was an issue open to document this [https://github.com/bundler/bundler/issues/3214](https://github.com/bundler/bundler/issues/3214). I've submitted a patch to the docs.

UPDATE [19 Jan 2015]: if you are interested there is a conversation about this on [components in rails mailing list](https://groups.google.com/forum/#!topic/components-in-rails/aCGDuYcS2W0).

You can find a test app where I spiked this solution at: [https://github.com/agenteo/lab-gemfile-hierarchy](https://github.com/agenteo/lab-gemfile-hierarchy)

I hope this helps others. Ciao.

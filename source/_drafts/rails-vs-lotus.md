---
layout: post
title: Rails vs. Lotus
comments: true
tags:
  - rails
  - ruby
  - lotus
---

*Lotus* is a new but stable [rack compliant](http://rack.github.io/) Ruby web framework embracing modularity at its core to incrementally design a maintainable application.

The *conventional MVC Rails* structure fits simple use cases and when their complexity increases you can use ingenuity in the form of *[component based Rails](http://teotti.com/component-based-rails-architecture-primer/)* to achieve modularity sometime as a stepping stone to [service oriented architecture](http://teotti.com/rails-service-oriented-architecture-alternative-with-components/).

**In this article I will compare Lotus features with *regular* and *components* Rails and point to the excellent Lotus documentation for more details--I will assume you are familiar with how Ruby on Rails works.**

### Stating the obvious

Using Lotus for rapid prototyping would be a mistake--Ruby on Rails is a much better fit for that leveraging its vast pool of plugins.

Many Rails projects I worked on since 2005 had a plugin based prototype foundation unsuitable for long term custom applications and transforming development in to a daunting plugin customization.

Usually at the foundation of larger Rails plugins there are framework agnostic Ruby gems and rack middlewares like *Warden* at the core of *Devise*--you can use those smaller libraries to accelerate development in Lotus.

If are working on a production Rails application don't try to migrate it to Lotus. If you're having troubles dealing with complexity in Rails read [my primer on component based](http://teotti.com/component-based-rails-architecture-primer/).

## General approach

Lotus sets a clear boundary between code dealing with the web framework living inside `/apps` and code related to the persistence and domain logic living inside `/lib`.

>> A Lotus application can serve multiple *applications* similarly to what high level components do in **component based Rails architecture**.

The default application is called `web` but can be overridden when first running the generator:

{% highlight ruby %}
lotus new shipping --application=customer_zone
{% endhighlight %}

The directory structure at this point is:

{% highlight bash %}
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── apps
├── config
├── config.ru
├── db
├── lib
└── spec
{% endhighlight %}

Inside `apps` we find the default `web` application--let's add an `api` application responsible for a customer facing api leaving `web` focused on the web experience:

{% highlight ruby %}
lotus generate app api
{% endhighlight %}

the apps have the following directory structure:

{% highlight bash %}
├── application.rb
├── config
├── controllers
├── public
├── templates
└── views
{% endhighlight %}

Another example where this works well is an `admin` application serving staff only functionality.

## Application routing

The Lotus applications routes are mounted via `config/environment.rb`:

{% highlight ruby %}
require 'rubygems'
require 'bundler/setup'
require 'lotus/setup'
require_relative '../lib/shipping'
require_relative '../apps/api/application'

Lotus::Container.configure do
  mount Api::Application, at: '/'
end
{% endhighlight %}

>> Mounting multiple Lotus applications on the same segment doesn't work like mounting engines in Rails--only the first one will be served.

{% highlight ruby %}
Lotus::Container.configure do
  mount Web::Application, at: '/'
  mount Api::Application, at: '/'
end
{% endhighlight %}

In the example above the routes provided by `Api` will not be found. This means the mounted routes must be unique segments and you must leave the *greedier* one at the end, for example:

{% highlight ruby %}
Lotus::Container.configure do
  mount Api::Application, at: '/api'
  mount Web::Application, at: '/'
end
{% endhighlight %}

The routing syntax is reminishent of Rails and you will find a dose--not an overdose--of magic in Lotus.

{% highlight ruby %}
# apps/APPLICATION_NAME/config/routes.rb
get '/', to: "ship_routes#index" # => will route to Api::Controllers::ShipRoutes::Index
{% endhighlight %}

to avoid the longer:

{% highlight ruby %}
get '/',   to: Api::Controllers::ShipRoutes::Index
{% endhighlight %}

## Controller actions

In Lotus the [controller](https://github.com/lotus/controller) actions are classes as opposed to Ruby on Rails class instance methods. 

{% highlight ruby %}
module Api::Controllers::ShipRoutes
  include Lotus::Action

  class Index
    def call(params)
      @ships = ShipRoute.all
    end
  end
end
{% endhighlight %}

This helps defining their single responsability and prevent bloated code sharing too much logic--in Lotus you can [share controller action logic](http://lotusrb.org/guides/actions/share-code/) with a `prepare` block and callbacks.

Controller action instance variables will not be handed to the view template unless [exposed](http://lotusrb.org/guides/actions/exposures/)--the `params` and `errors` variables are exposed by default. More on this after the next section.

## Domain logic and persistence layer

Lotus is ORM agnostic but it provides [lotus models](http://lotusrb.org/guides/models/overview/) a structured persistence framework with [entities](http://lotusrb.org/guides/models/entities/) and [repositories](http://lotusrb.org/guides/models/repositories/) ideal in more complex domains where using [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html) would be unsuitable--but Lotus won't get in your way if that's what you need. Just remember the "When to use" paragraph in Patterns of Enterprise Application Architecture:

>> Active Record is a good choice for domain logic that isn't too complex, such as creates, reads, updates, and deletes. Derivations and validations based on a single record work well in this structure.

For that reason Lotus models delegate validation at the controller action level and [Luca Guidi explains why](http://lucaguidi.com/2014/10/23/introducing-lotus-validations.html).

You won't find `/models` inside the `/apps` directory--the application generator will build a properly namespaced structure in `/lib` and since Lotus **does not have autoloading** it must be required from `config/environment.rb`:

{% highlight ruby %}
require_relative '../lib/shipping'
{% endhighlight %}

Keep in mind the generators will add default require statements.

### Adding more domain logic with gems

With Ruby namespaces alone you have some modularity but you can’t enforce a dependency structure and in complex domains your classes will end up creating a tangle of dependencies hard to follow. In this example I add a `components` directory in the repository root and add the local gem to `Gemfile`:

{% highlight ruby %}
path 'components' do
  gem 'freight_calculator'
end
{% endhighlight %}

You will need to `require 'freight_calculator` in `config/environment.rb`.

If `freight_calculator` depends on a local `route_finder` it will resolve its dependencies internally without concerning the rest of the application.

## Views and templates

In Lotus the separation between a controller action and its view layer is also well defined. The framework provides a [model-view ](http://lotusrb.org/guides/views/overview/) class linked to the controller action class that can act as a presenter in simple domains or instantiate more presenters in complex cases.

The view will only have access to variables explicitly exposed from the controller action similar to calling render with `locals` from a Rails action.

What Rails calls *views* are called [templates](http://lotusrb.org/guides/views/templates/) in Lotus and support popular Ruby templating like erb, haml, slim and more.

## View helpers

In Rails you have a plethora of helpers available in your views. Lotus has a vast list of helpers added trough the optional `Lotus::Helpers` module--all are private so you must define an explicit interface in your view. For example `format_number` is a private helper method and can't be used in a template like:

{% highlight ruby %}
<%= format_number book.downloads_count %>
{% endhighlight %}

Instead it must be wrapped in a `download_counts` helper method in the view like this:

{% highlight ruby %}
# apps/web/views/books/show.rb
module Web::Views::Books
  include Web::View

  def downloads_count
    format_number book.downloads_count
  end
end
{% endhighlight %}

Then called in the template with:

{% highlight ruby %}
<%= downloads_count %>
{% endhighlight %}

The example is taken from the excellent [lotus guide about helpers](http://lotusrb.org/guides/helpers/overview/).

Lotus counterpart to Rails's custom helpers is based on plain Ruby and well explained [in its dedicated guides section](http://lotusrb.org/guides/helpers/custom-helpers/). If you have larger more complex custom helpers you can still adopt the [intention revealing helpers](http://teotti.com/building-intention-revealing-ruby-on-rails-helpers/) strategy.

## Final thoughts

Lotus and regular Rails have different use cases--understanding yours will be key to pick the right tool.

Lotus isn't an overnight hack--it's been under development for over one year, it's used in production and you can see passion and attention to detail in its modular design, automated tests, and [documentation](http://lotusrb.org/guides).

If you built and maintained a classical Rails application for 2 or 3 years and haven't noticed any maintainability problem I think you don't need to look in to Lotus. Maybe your domain is one of many fitting perfectly in the Rails use cases. Or maybe somebody else needs to look at your code.

If you used component based Rails you already hit some of the framework limits and diverged from its conventions and plugins so the question is what does Rails do that Lotus doesn't for you? I think on my next project I will do a risk assessment and decide whether to use Lotus or not.

I hope the article has sparkled interest in what Lotus has to offer. I am looking forward to hear Rails developers feedback on Lotus.

---
layout: post
title: Rails vs. Lotus
comments: true
tags:
  - rails
  - ruby
  - lotus
---

**This article introduces Lotus 0.4 features and compares them with *regular* and *component based* Rails 4.** I will assume you are familiar with the Ruby on Rails conventions.

---

*Lotus* is a modular [rack compliant](http://rack.github.io/) Ruby web framework promoting applications incremental design and separation of concerns beyond classical MVC.

The *conventional MVC Rails* structure fits simpler use cases and when their complexity increases you can use ingenuity in the form of *[component based Rails](http://teotti.com/component-based-rails-architecture-primer/)* to achieve application modularity sometime as a stepping stone to [service oriented architecture](http://teotti.com/rails-service-oriented-architecture-alternative-with-components/).


## Preamble

Using Lotus for rapid prototyping would be a mistake--Ruby on Rails is a much better fit for that leveraging its vast pool of plugins.

Many Rails projects I saw had a plugin based prototype foundation making long term development a daunting plugin customization.

Usually at the foundation of larger Rails plugins there are framework agnostic Ruby gems and rack middlewares--like *Warden* at the core of *Devise*--that can be used to accelerate development in Lotus.

## Multi application approach

Lotus helps understanding what the whole project does by supporting sub applications.

An example could be a *memory game* project where users can play games created by a team of game designers and with an API to publish leaderboards to mobile devices. This project domain can be broken up in to three applications: a `gamezone` application where users play games, a `workshop` application where game designers create games and an `api` application to publish game statistics to mobile devices. The assumption is they all share some domain logic and database connection so breaking them up in to three projects at the start will create more development overhead then benefits.

### Lotus

Lotus can serve such a project with its default [*container* architecture](http://lotusrb.org/guides/architectures/container/). When the time comes for a portion to be deployed and developed in isolation it supports single applications with its *application* architecture.

Having all the applications as one codebase speeds up project development and it's great that Lotus [architecture supports](http://lotusrb.org/guides/architectures/overview/) that at its core.

**Some people might quickly dismiss this as impossible in Ruby on Rails but that's wrong.**

### Rails

It's true that in a *conventional Rails* project this is impossible to achieve--all your code lives inside `/app` and there is no way to set more applications boundaries. In simple cases this is not a problem--you could have a gamezone controller a workshop controller and an api controller but that's rarely the case and even when it starts like that requirements will change and expand.

So for larger more complex domains--or for applications started small and grew over time--missing the boundaries makes it hard to understand what the whole project does and to migrate one of those portions to its own service.

**To solve this problem a few years ago people started leveraging Ruby gems and Rails engines in what is called *component based Rails architecture*.**

A high level component can *simulate* a Lotus application boundary in Rails--to find out more about this [read a component based primer](http://teotti.com/component-based-rails-architecture-primer/).

## Lotus directory structure

Let's generate our `memory_game` project in Lotus--the default application would be called `web` but can be overridden when first running the generator:

{% highlight ruby %}
lotus new memory_game --application=game_zone
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

Let's add a `workshop` application to allow our staff to create games leaving `game_zone` focused on the web gaming experience:

{% highlight ruby %}
lotus generate app workshop
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

All the Lotus applications share some domain logic and persistence--more about that later.

## Application routing

The Lotus applications routes are mounted via `config/environment.rb`:

{% highlight ruby %}
require 'rubygems'
require 'bundler/setup'
require 'lotus/setup'
require_relative '../lib/memory_game'
require_relative '../apps/game_zone/application'

Lotus::Container.configure do
  mount GameZone::Application, at: '/'
end
{% endhighlight %}

>> Mounting multiple Lotus applications on the same segment doesn't work like mounting engines in Rails--only the first one will be served.

{% highlight ruby %}
Lotus::Container.configure do
  mount GameZone::Application, at: '/'
  mount Workshop::Application, at: '/'
end
{% endhighlight %}

In the example above the routes provided by `Workshop` will not be found. This means the mounted routes must be unique segments and you must leave the *greedier* one at the end, for example:

{% highlight ruby %}
Lotus::Container.configure do
  mount Workshop::Application, at: '/workshop'
  mount GameZone::Application, at: '/'
end
{% endhighlight %}

The routing syntax is reminishent of Rails and you will find a dose--not an overdose--of magic in Lotus.

{% highlight ruby %}
# apps/APPLICATION_NAME/config/routes.rb
get '/', to: "games#index" # => will route to GameZone::Controllers::Games::Index
{% endhighlight %}

to avoid the longer:

{% highlight ruby %}
get '/',   to: GameZone::Controllers::Games::Index
{% endhighlight %}

## Controller actions

In Lotus the [controller actions](http://lotusrb.org/guides/actions/overview/) are classes as opposed to Ruby on Rails class instance methods. This helps defining their single responsability and prevent bloated code sharing too much logic--in Lotus you can [share controller action logic](http://lotusrb.org/guides/actions/share-code/) with a `prepare` block and callbacks.

{% highlight ruby %}
module GameZone::Controllers::Games
  class Index
    include Lotus::Action
    expose :games

    def call(params)
      @games = Game.all
    end
  end
end
{% endhighlight %}

Controller action instance variables will not be handed to the view template unless [exposed](http://lotusrb.org/guides/actions/exposures/)--the `params` and `errors` variables are exposed by default. In the example above `@games` wouldn't be available to the view without the `expose :games`.

## Domain logic and persistence layer

Lotus is ORM agnostic but it provides [lotus models](http://lotusrb.org/guides/models/overview/) a structured persistence framework with [entities](http://lotusrb.org/guides/models/entities/) and [repositories](http://lotusrb.org/guides/models/repositories/) ideal in more complex domains where using [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html) would be unsuitable--but Lotus won't get in your way if that's what you need. Just remember the "When to use" paragraph in Patterns of Enterprise Application Architecture:

>> Active Record is a good choice for domain logic that isn't too complex, such as creates, reads, updates, and deletes. Derivations and validations based on a single record work well in this structure.

For that reason Lotus models delegate validation at the controller action level--you can [read the full explanation here](http://lucaguidi.com/2014/10/23/introducing-lotus-validations.html).

You won't find `/models` inside the `/apps` directory--the application generator will build a properly namespaced structure in `/lib` and since Lotus **does not have autoloading** it must be required from `config/environment.rb`:

{% highlight ruby %}
require_relative '../lib/memory_game'
{% endhighlight %}

Keep in mind the generators will add default require statements.

### Adding more domain logic with gems

With Ruby namespaces alone you have some modularity but you can't enforce a dependency structure and in complex domains your classes will end up creating a tangle of dependencies hard to follow. You can use ruby gems to handle your dependency structure.

In this example I assume my application domain has **significant logic** related to calculating level progression using a statistical model so inside a `components` directory in the repository root I create two gems: `level_progression`, `bayesian_model`. The first depends on the latter and it will resolve that dependency internally without concerning the rest of the application. I only need to add the local gem `level_progression` to the Lotus application `Gemfile`:

{% highlight ruby %}
path 'components' do
  gem 'level_progression'
end
{% endhighlight %}

And `require 'level_progression'` in `config/environment.rb`. Now my actions can use:

{% highlight ruby %}
calculator = LevelProgression::Calculator.new(last_score, current_score, bonus)
calculator.next_level
{% endhighlight %}

**This same approach can be used in Rails and is a trait of *component based Rails architecture*.**

## Views and templates

In Lotus the separation between a controller action and its view layer is also well defined. The framework provides a [model-view ](http://lotusrb.org/guides/views/overview/) class linked to the controller action class that can act as a presenter in simple domains or instantiate more presenters in complex cases.

{% highlight ruby %}
# apps/web/views/games/index.rb
module GameZone::Views::Games
  include GameZone::View

  class Index
  end
end
{% endhighlight %}

The view will only have access to variables explicitly exposed from the controller action. There is no call to render--the framework takes care of passing from controller action to the apropriate view.

A `GameZone::Views::Games::Index` view class will expect a template `templates/games/index.[format].[engine]`. What Rails calls *views* are called [templates](http://lotusrb.org/guides/views/templates/) in Lotus and support popular Ruby templating like erb, haml, slim and more. 

## View helpers

In Rails you have a plethora of helpers available in your views. Lotus has a vast list of helpers added trough the optional `Lotus::Helpers` module--all are private so you must define an explicit interface in your view.

For example using `format_number` directly in a template like:

{% highlight ruby %}
<%= format_number game_session.current_score %>
{% endhighlight %}

will raise `NoMethodError: undefined method 'format_number'`. Instead it must be wrapped in a `current_score` helper method in the view like this:

{% highlight ruby %}
# apps/game_zone/views/game_sessions/show.rb
module GameZone::Views::GameSessions
  include GameZone::View

  class Show
    def current_score
      # I am assuming the GameZone::Controllers::GameSessions::Show
      # to expose game_session
      format_number game_session.current_score
    end
  end
end
{% endhighlight %}

Then called in the template with:

{% highlight ruby %}
<%= current_score %>
{% endhighlight %}

Lotus counterpart to Rails's custom helpers is based on plain Ruby and well explained [in its dedicated guides section](http://lotusrb.org/guides/helpers/custom-helpers/). If you have larger more complex custom helpers you can still adopt the [intention revealing helpers](http://teotti.com/building-intention-revealing-ruby-on-rails-helpers/) strategy.

## Final thoughts

Lotus isn't an overnight hack--it's been under development for over one year, its semantic versioned API is stable, people are using it in production and you can see passion and attention to detail in its modular design, automated tests, and [documentation](http://lotusrb.org/guides).

Lotus and regular Rails excel in different areas knowing what your application needs is critical.

If are working on a production Rails application before thinking to migrate it to Lotus evaluate [component based architecture](http://teotti.com/component-based-rails-architecture-primer/).

Before committing to Lotus check for outstanding [github issues](https://github.com/lotus/lotus/issues) some might be blocking you as well as missing features your might got used to from Rails. For example there is no asset management (scheduled to be included in 0.5.0).

I hope the article has sparkled interest in what Lotus has to offer. I only scratched the surface and skipped topics like [testing](http://lotusrb.org/guides/actions/testing/), [caching](http://lotusrb.org/guides/actions/http-caching/), [migrations](http://lotusrb.org/guides/migrations/overview/), [sessions](http://lotusrb.org/guides/actions/sessions/) all covered in detail in Lotus excellent guides.

I am looking forward to hear other Ruby and Rails developers feedback on Lotus.

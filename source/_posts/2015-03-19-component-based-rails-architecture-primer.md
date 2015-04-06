---
layout: post
title: A component based Rails architecture primer
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
---

I have worked on many products that fit in the classical Ruby on Rails MVC paradigm and conventions like: decorators, presenters, service objects can be sufficient to handle some complexity **but when the project is over a certain size they don't help understand what the whole application does**. If you have over 20 or 30 controllers and models can you still understand what the application is doing? Is it hard to keep track of what all the little parts do? If you use Ruby namespaces you have some modularity but you can't enforce a dependency structure and your classes are creating a tangle of dependencies hard to follow.

**Component based architecture is complementary to good object oriented practices and uses namespaces, test driven development and Ruby gems to gradually define application boundaries and enforce an internal dependency structure**.

## A practical example

This example is adapted from a real life application but to make it manageable I've omitted major features and only left four components: a staff only *administration area*, a *public area*, a *legacy migration* and some shared *domain logic*. The *legacy migration* was initially part of the admin component and later extracted in a separate one when its became more complex. **I usually don't architect an application with components from day one instead I introduce them gradually as the complexity grows or when the scope changes** as I describe [here](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

Component is the name given to a Ruby on Rails engine or Ruby gem when used as building block of the Rails application. A component dependencies are set in its `.gemspec` file, a test suite will test it in isolation and ensure the dependency structure is solid, an engine is like a Rails app in miniature, you have models, views, controllers routes, rake tasks--I will show more on this later.

### Intention revealing

The high level components are required by the main Rails application `Gemfile`.

{% highlight ruby %}
# Gemfile
path 'components' do
  gem 'public_ui'
  gem 'admin_ui'
  gem 'legacy_migration'
end
{% endhighlight %}

I think it's great to see what the main application is doing without having to dig in layers of controllers and models.

The `Gemfile` will look for the high level components `public_ui`, `admin_ui`, `legacy_migration` in the `components` directory of the Rails application and automatically resolve any local component dependency like the `domain_logic`. I explain how this works in [Gemfile hierarchy in Ruby on Rails component based architecture](http://teotti.com/gemfiles-hierarchy-in-ruby-on-rails-component-based-architecture/).

The `/components` directory has all the components.

{% highlight bash %}
$ ls -l components/
total 0
drwxr-xr-x  18 agenteo  320754065  612 Mar 19 08:42 admin_ui
drwxr-xr-x  18 agenteo  320754065  612 Mar 10 08:20 domain_logic
drwxr-xr-x  18 agenteo  320754065  612 Mar 19 08:42 public_ui
drwxr-xr-x  20 agenteo  320754065  680 Mar 10 08:20 legacy_import
{% endhighlight %}

### Cleaner routes

I worked on a large Rails applications constantly growing for 3 years and the route file was long and dreadful to change, components helps keeping that maintainable. When a high level component provides routes I mount them in the Rails application route file which stays clean.

{% highlight ruby %}
# config/routes.rb
Rails.application.routes.draw do
  mount AdminUi::Engine => "/admin"
  mount PublicUi::Engine => "/"
end
{% endhighlight %}

Be mindful of the segments you assign to the engine or you might run in to collisions.
 
### Inside a component

Inside the admin engine we compartmentalize controllers, models, helpers and tasks with a `AdminUi` namespace. The engine has a similar structure of a rails app.

{% highlight bash %}
$ ls -l components/admin_ui/
total 56
-rw-r--r--   1 agenteo  320754065   606 Feb 27 15:25 Gemfile
-rw-r--r--   1 agenteo  320754065  5955 Mar 19 08:42 Gemfile.lock
-rw-r--r--   1 agenteo  320754065    76 Feb 27 15:25 README.md
-rw-r--r--   1 agenteo  320754065   495 Feb 27 15:25 Rakefile
-rw-r--r--   1 agenteo  320754065  1666 Feb 27 15:25 admin_ui.gemspec
drwxr-xr-x   7 agenteo  320754065   238 Feb 27 15:25 app
drwxr-xr-x   3 agenteo  320754065   102 Feb 27 15:25 bin
drwxr-xr-x   5 agenteo  320754065   170 Mar 19 08:42 config
drwxr-xr-x   5 agenteo  320754065   170 Feb 27 15:25 lib
drwxr-xr-x  13 agenteo  320754065   442 Mar 19 08:55 spec
-rwxr-xr-x   1 agenteo  320754065   281 Feb 27 15:25 test.sh
{% endhighlight %}

This is a simplified version of the admin app folder to give you an idea of how a component internals look.

{% highlight bash %}
components/admin_ui/app/
├── assets
│   ├── images
│   │   └── admin_ui
│   ├── javascripts
│   │   └── admin_ui
│   └── stylesheets
│       └── admin_ui
├── controllers
│   └── admin_ui
│       ├── application_controller.rb
│       ├── content_pieces_controller.rb
│       ├── content_preview_controller.rb
│       ├── images_controller.rb
│       ├── mobile_content_preview_controller.rb
│       ├── publish_content_items_controller.rb
│       ├── slideshow_slides_controller.rb
│       ├── slug_controller.rb
│       └── taxonomy_controller.rb
├── helpers
│   └── admin_ui
│       ├── application_helper.rb
│       ├── content_helper.rb
│       ├── content_items_sortable_links_helper.rb
│       ├── content_pieces_filterable_links_helper.rb
│       ├── content_pieces_search_helper.rb
│       ├── date_formatter_helper.rb
│       ├── edit_content_piece_helper.rb
│       ├── filters
│       ├── link_to_publishing_action_helper.rb
│       ├── tag_link_helper.rb
│       └── form_helper.rb
├── models
│   ├── admin_ui
│   │   ├── content_filter.rb
│   │   ├── content_sorter.rb
│   │   ├── criteria
│   │   └── site_search_delegate.rb
└── views
    ├── admin_ui
    │   ├── content_pieces
    │   └── mobile_content_preview
    └── layouts
        └── admin_ui
{% endhighlight %}

Each class (model, controller, helper) has a specific responsibility inside the admin interface. Its models can't access the `legacy_migration` component model unless the `admin_ui` depends on it, so I can work on a component and its dependencies without having to worry about the rest. Breaking this dependency structure would pop up during your automated tests.

Inside the admin ui gemspec I have the dependency on `domain_logic` as well as other libraries and development libraries.

{% highlight ruby %}
# components/admin_ui/admin_ui.gemspec
$:.push File.expand_path("../lib", __FILE__)

require "admin_ui/version"

Gem::Specification.new do |s|
  s.name        = "admin_ui"
  s.version     = AdminUi::VERSION
  s.authors     = ["We the people"]
  s.email       = ["we@thepeople.com"]
  s.summary     = "Helpful summary"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.1"
  s.add_dependency 'jquery-rails'
  s.add_dependency 'sass'
  s.add_dependency 'nokogiri'
  s.add_dependency 'kaminari'

  # local dependencies
  s.add_dependency "domain_logic"

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rspec-rails', '3.1.0'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'launchy'

  s.add_development_dependency 'jasmine'
  s.add_development_dependency 'jasmine-phantom'
  s.add_development_dependency 'jasmine-rails'
end
{% endhighlight %}

## Automated testing is critical

I test each component in isolation because testing from the main application won't warn for an invalid dependency. Let's say `admin_ui` and `public_ui` use a `Tracking::Code` class and `admin_ui` has a dependency on the `tracking` component in its gemspec but `public_ui` doesn't--because of the missing dependency I would expect a `public_ui` endpoint to error but it won't because from the main application `tracking` got required trough `admin_ui`.

Having broken dependencies prevents you to [deploy portions of your component based application to separate hosts](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/#final-proposal) or spending time chasing and untangling dependencies later on.

I add to each component a `test.sh` bash script with the tests commands to run ie. `bundle exec rspec` sometime `bundle exec jasmine` in a client side focused component--then the main application has the following `build.sh` script that finds and runs all the components `test.sh` and checks all their status reporting back to the user.

{% highlight bash %}
#!/bin/bash

result=0

for test_script in $(find . -name test.sh); do
  pushd `dirname $test_script` > /dev/null
  source "$HOME/.rvm/scripts/rvm"
  rvm use $(cat .ruby-version)@$(cat .ruby-gemset) --create
  ./test.sh
  result+=$?
  popd > /dev/null
done

if [ $result -eq 0 ]; then
  echo "🏈  SUCCESS :-)"
else
  echo "💔  FAILURE ;-("
fi

exit $result
{% endhighlight %}

## Handling application change

When later the **legacy migration** is completed I can simply remove its component directory and its entry from the `Gemfile` without affecting the rest of the application--with a conventional approach I would have to find and delete the code hoping the tests catch any broken dependency.

If I need to add an API I can put it in a high level component (like public_ui and admin_ui) relying on domain logic--if required for performance or security reasons I can **deploy only some high level components** as I explain in [Feature flagging portions of your Ruby on Rails application with engines](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/).

When the project grows even more and I have two teams one dedicated to admin features one to public features it might make sense to extract admin and public components in two Rails applications and publish any shared component to a private gem server. **The component based architecture can be a stepping stone to services if and when my product needs that**--but at the beginning of a long running project with 5 full stack engineers what advantage does three codebases give me? I know developing a project that changes a remote dependency needs some process adjustment as I explain in [GIT precommit hooks helping local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/).



## Challenges

Component based is not a good fit for every project, when my application domain model doesn't differ much from what the data store presents there is no reason to change the conventional Rails approach. When I am on a growing conventional application I introduce components gradually as the complexity increases and the regular MVC approach isn't conducive to a good design. When I know the application is going to be under development for several months and it has complex business rules I introduce components early on to help define boundaries.

**You should absolutely not use a component based architecture without test driving each component in isolation.**

Be sure developers understand the meaning of each component--if someone adds public only code to a shared component it's gonna make it harder to extract components when needed. Pair switching or pull requests should help with that and maybe keeping a README file in the component root to explain its boundaries.

For some developers there is the Rails way or the highway--they are convinced that when the app grows you must break it in to services. **You should use service oriented architecture when it make sense for your business model and not to address code maintainability**. [Always be mindful of performance impact](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember Ruby isn't the right tool for every single project.

## What to do next

This is an introduction to spark your interest and start asking questions in the comments or in the [components in rails mailing list](https://groups.google.com/forum/#!forum/components-in-rails) or <a href="https://twitter.com/intent/tweet?button_hashtag=cbra" class="twitter-hashtag-button">Tweet #cbra</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>. Visit the centralized [Component Based Rails Architecture](http://cbra.info) site to view talks, code samples, blog posts and books; thanks to Stephan Hagerman for setting that up.




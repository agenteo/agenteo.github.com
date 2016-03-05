---
layout: post
title: Maintainable Rake tasks in a Ruby on Rails application
comments: true
tags:
  - ruby
  - rails
  - maintainability
image: /assets/article_images/create-maintainable-mongodb-queries-in-ruby-with-query-object-and-mongoid-criterias/hero.jpg
---

A greenfield Rails application has a few conventional rake tasks but it rarely stays like that--as it grows the development team adds **custom tasks** that end up mixed with the default ones and the ones added by gems and engines.

**When you print your application list of Rake tasks with `rake -T` can you distinguish between custom and default tasks?**

Can you tell the custom tasks in this list?

{% highlight bash %}
rake about                                                       # List versions of all Rails frameworks and the environment
rake assets:clean[keep]                                          # Remove old compiled assets
rake assets:clobber                                              # Remove compiled assets
rake assets:environment                                          # Load asset compile environment
rake assets:precompile                                           # Compile all the assets named in config.assets.precompile
rake cache_digests:dependencies                                  # Lookup first-level dependencies for TEMPLATE (like messages/sho...
rake cache_digests:nested_dependencies                           # Lookup nested dependencies for TEMPLATE (like messages/show or ...
rake clean                                                       # Remove any temporary products
rake clobber                                                     # Remove any generated file
rake content_deduplicator:run                                    # Delete duplicated content
rake db:drop                                                     # Drops all the collections for the database for the current Rail...
rake db:mongoid:create_indexes                                   # Create the indexes defined on your mongoid models
rake db:mongoid:drop                                             # Drops the default session
rake db:mongoid:purge                                            # Drop all collections except the system collections
rake db:mongoid:remove_indexes                                   # Remove the indexes defined on your mongoid models without quest...
rake db:mongoid:remove_undefined_indexes                         # Remove indexes that exist in the database but aren't specified ...
rake db:purge                                                    # Drop all collections except the system collections
rake db:reset                                                    # Delete data and loads the seeds
rake db:seed                                                     # Load the seed data from db/seeds.rb
rake db:setup                                                    # Create the database, and initialize with the seed data
rake deploy[portion,stage,branch]                                # Deploy the specified portion of the app to the provided stage
rake doc:app                                                     # Generate docs for the app -- also available doc:rails, doc:guid...
rake honeybadger:deploy                                          # Notify Honeybadger of a new deploy
rake honeybadger:heroku:add_deploy_notification                  # Install Heroku deploy notifications addon
rake honeybadger:test                                            # Verify your gem installation by sending a test exception to the...
rake jslint                                                      # Run JSLint check on selected Javascript files
rake jslint:copy_config                                          # Create a copy of the default JSLint config file in your config ...
rake log:clear                                                   # Truncates all *.log files in log/ to zero bytes (specify which ...
rake legacy_images_migration   # Legacy Images Migration
rake legacy_import_run                                          # Transfer articles from SQS
rake legacy_url_migration        # Legacy url migration
rake middleware                                                  # Prints out your Rack middleware stack
rake notes                                                       # Enumerate all annotations (use notes:optimize, :fixme, :todo fo...
rake notes:custom                                                # Enumerate a custom annotation, specify with ANNOTATION=CUSTOM
rake rails:template                                              # Applies the template supplied by LOCATION=(/path/to/template) o...
rake rails:update                                                # Update configs and some other initially generated files (or use...
rake routes                                                      # Print out all defined routes in match order, with names
rake reindex                                                     # Reindexes published content for site search
rake secret                                                      # Generate a cryptographically secure secret key (this is typical...
rake simplecov                                                   # Run tests
rake slideshow_into_article[source_id_strings]                   # Converts slideshow into article, takes comma separated list of ...
rake spec                                                        # Run all specs in spec directory (excluding plugin specs)
rake spec:lib                                                    # Run the code examples in spec/lib
rake spec:requests                                               # Run the code examples in spec/requests
rake spec:tasks                                                  # Run the code examples in spec/tasks
rake stats                                                       # Report code statistics (KLOCs, etc) from the application
rake taxonomy_tags                                               # Creates a CSV collection of the taxonomy terms used
rake test                                                        # Runs test:units, test:functionals, test:generators, test:integr...
rake test:all                                                    # Run tests quickly by merging all types and not resetting db
rake test:all:db                                                 # Run tests quickly, but also reset db
rake time:zones:all                                              # Displays all time zones, also available: time:zones:us, time:zo...
rake tmp:clear                                                   # Clear session, cache, and socket files from tmp/ (narrow w/ tmp...
rake tmp:create                                                  # Creates tmp directories for sessions, cache, sockets, and pids
rake transfer[source,destination]                                # Transfer source database to destination
rake transfer_images                                             # Transfers images from production Image API to local server
{% endhighlight %}

This is taken from an application less then 2 years old.

You can imagine the list growing. I've seen it so long that I wanted to cry.

Can you tell the custom tasks in the following list?

{% highlight bash %}
rake about                                                       # List versions of all Rails frameworks and the environment
rake app:db:transfer[source,destination]                         # Transfer source database to destination
rake app:db:transfer_images                                      # Transfers images from production Image API to local server
rake app:deploy[portion,stage,branch]                            # Deploy the specified portion of the app to the provided stage
rake app:domain_logic:slideshow_into_article[source_id_strings]  # Converts slideshow into article, takes comma separated list of ...
rake app:site_search:reindex                                     # Reindexes published content for site search
rake app:taxonomy_tags                                           # Creates a CSV collection of the taxonomy terms used
rake assets:clean[keep]                                          # Remove old compiled assets
rake assets:clobber                                              # Remove compiled assets
rake assets:environment                                          # Load asset compile environment
rake assets:precompile                                           # Compile all the assets named in config.assets.precompile
rake cache_digests:dependencies                                  # Lookup first-level dependencies for TEMPLATE (like messages/sho...
rake cache_digests:nested_dependencies                           # Lookup nested dependencies for TEMPLATE (like messages/show or ...
rake clean                                                       # Remove any temporary products
rake clobber                                                     # Remove any generated file
rake db:drop                                                     # Drops all the collections for the database for the current Rail...
rake db:mongoid:create_indexes                                   # Create the indexes defined on your mongoid models
rake db:mongoid:drop                                             # Drops the default session
rake db:mongoid:purge                                            # Drop all collections except the system collections
rake db:mongoid:remove_indexes                                   # Remove the indexes defined on your mongoid models without quest...
rake db:mongoid:remove_undefined_indexes                         # Remove indexes that exist in the database but aren't specified ...
rake db:purge                                                    # Drop all collections except the system collections
rake db:reset                                                    # Delete data and loads the seeds
rake db:seed                                                     # Load the seed data from db/seeds.rb
rake db:setup                                                    # Create the database, and initialize with the seed data
rake doc:app                                                     # Generate docs for the app -- also available doc:rails, doc:guid...
rake honeybadger:deploy                                          # Notify Honeybadger of a new deploy
rake honeybadger:heroku:add_deploy_notification                  # Install Heroku deploy notifications addon
rake honeybadger:test                                            # Verify your gem installation by sending a test exception to the...
rake jslint                                                      # Run JSLint check on selected Javascript files
rake jslint:copy_config                                          # Create a copy of the default JSLint config file in your config ...
rake log:clear                                                   # Truncates all *.log files in log/ to zero bytes (specify which ...
rake legacy_migration:content_deduplicator:run                   # Delete duplicated content
rake legacy_migration:find_and_replace:legacy_url_migration      # Legacy url migration
rake legacy_migration:find_and_replace:images_migration # Legacy Images Migration
rake legacy_migration:run                                        # Transfer articles from SQS
rake middleware                                                  # Prints out your Rack middleware stack
rake notes                                                       # Enumerate all annotations (use notes:optimize, :fixme, :todo fo...
rake notes:custom                                                # Enumerate a custom annotation, specify with ANNOTATION=CUSTOM
rake rails:template                                              # Applies the template supplied by LOCATION=(/path/to/template) o...
rake rails:update                                                # Update configs and some other initially generated files (or use...
rake routes                                                      # Print out all defined routes in match order, with names
rake secret                                                      # Generate a cryptographically secure secret key (this is typical...
rake simplecov                                                   # Run tests
rake spec                                                        # Run all specs in spec directory (excluding plugin specs)
rake spec:lib                                                    # Run the code examples in spec/lib
rake spec:requests                                               # Run the code examples in spec/requests
rake spec:tasks                                                  # Run the code examples in spec/tasks
rake stats                                                       # Report code statistics (KLOCs, etc) from the application
rake test                                                        # Runs test:units, test:functionals, test:generators, test:integr...
rake test:all                                                    # Run tests quickly by merging all types and not resetting db
rake test:all:db                                                 # Run tests quickly, but also reset db
rake time:zones:all                                              # Displays all time zones, also available: time:zones:us, time:zo...
rake tmp:clear                                                   # Clear session, cache, and socket files from tmp/ (narrow w/ tmp...
rake tmp:create                                                  # Creates tmp directories for sessions, cache, sockets, and pids
{% endhighlight %}

I imagine you spotted the **app** and **legacy_migration** groups.

Keeping tasks grouped in an intention reveling directory structure help reduce cognitive load and you can now filter the list with `rake -T app`:

{% highlight bash %}
rake app:db:transfer[source,destination]                         # Transfer source database to destination
rake app:db:transfer_images                                      # Transfers images from production Image API to local server
rake app:deploy[portion,stage,branch]                            # Deploy the specified portion of the app to the provided stage
rake app:domain_logic:slideshow_into_article[source_id_strings]  # Converts slideshow into article, takes comma separated list of ...
rake app:site_search:reindex                                     # Reindexes published content for site search
rake app:taxonomy_tags                                           # Creates a CSV collection of the taxonomy terms used
{% endhighlight %}

## How do you achieve this?

First create an `app` directory within the `lib/tasks` and move your custom tasks within it for example `transfer_images.rake`:

{% highlight bash %}
lib/
├── tasks
│   ├── app
│   │   └── transfer_images.rake
{% endhighlight %}

Then wrap the rake task in a rake namespace:

{% highlight ruby %}
namespace :app do
  namespace :db do
    # your task here
  end
end
{% endhighlight %}

This task was inside a `db` namespace because it was updating the local database records while transfering images from production to the workstation.

Your application custom rake tasks will be different but I'd recommend to create a second level rake namespace if you have more then one task operating in that context.

But what if you only have one custom task? Should you just put it in the `Rakefile`? I don't think so. It all starts from one custom task. Start this practice from the very beginning doesn't cost much and leads the way to a more maintainable path for the following developers.

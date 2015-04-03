---
layout: post
title: Building and maintaining a large Ruby on Rails application for 3 years
comments: true
tags:
  - work
  - ruby
  - component-based-rails-architecture
redirect_from:
  - /work/ruby/2013/07/16/using-plugins-as-components-of-a-large-ruby-on-rails2-application/
  - /work/ruby/2013/07/16/using-plugins-as-components-of-a-large-ruby-on-rails2-application.html/
  - /using-plugins-as-components-of-a-large-ruby-on-rails2-application/
---

Sometime we start building projects avoiding architecture and following framework conventions but diverging from that helped managing a Rails project growing for about 3 years.

Some Rails shortcoming have been fixed since then and I will link to the latest techniques but **recognizing when to diverge from the conventional approach is still challenging and important to prevent an unmaintainable application**. Do it too early and you will over engineer too late and the refactoring will be expensive.

The initial development went on for about 10 months with a team of two backend developers, two frontend plus designers and a project manager. After launch the application was constantly extended and maintained for the 24 months I was on the team.

## The project

We were about to rebuild a multinational brand site dedicated to pregnancy and newborn content with social interactions delegated to a forum--the new version was adding custom social functionalities within the content--the original baby name finder for example was browsing a list of name meanings but its new version was also allowing members to shortlist, vote names, share with family, generate weekly popularity graphs. 

We decided against a gradual deliver and instead **rebuild all the existing vertical areas** dedicated to specific subjects: baby names, promotions, kids activities, kids recipes each served within a unique segment: `/baby-names`, `/promotions`, `/kids-activities`, `/kids-recipes`--after that the stakeholder intended to invest in even more verticals. 

## Initial approach

Before starting development we agreed that keeping code from different verticals in the same controllers and models directory would obfuscate their boundaries and we decided to use subdirectories mapped to verticals ie. `/app/models/babynames_models`, `/app/controllers/babynames`, `/app/views/babynames` containing all code specific to baby names--this allowed us to quickly find vertical related code and reduce merge conflicts while developing in parallel.

{% highlight bash %}
$ ls -l app/models
ask_an_expert_models            contact_us                      loyalty_models                  recipe_finder_models            utils
babynames_models                kids_activities_models          membership_models               sharing
babynames_utils                 landing_page_header             promos_and_samples_models       story_models
{% endhighlight %}

{% highlight bash %}
$ ls -l app/controllers
admin                           ask_an_expert                   contact_us_controller.rb        membership                      promos_and_samples
admin_controller.rb             babynames                       kids_activities                 my_huggies                      recipe_finder
application_controller.rb       contact_us                      loyalty                         my_huggies_controller.rb        stories
{% endhighlight %}

This approach was sufficient during the initial development phase but after we went live and started adding more verticals the growing number of subdirectories made jumping between models/controllers/views time consuming--ideally I wanted to find and work on all the babynames files within a single directory. The application route file `/config/routes.rb` was a 300 lines mix from all verticals hard to understand and painful to maintain.

## A self contained approach

To address these problems I introduced the room decorator vertical as a plugin (precursors of engines) not to reuse its code but to encapsulate its models, controllers, views, helpers, routes--now only minor changes would affect a few models in the main application through decoration.

The main application routes would pick up the plugin routes from `PLUGIN/config/routes.rb` and stop growing.

We were also able to have unit tests inside the plugin.

To make verticals plugins stand out from the vendor plugins we had a naming convention to append a static string in front of plugin name.

{% highlight bash %}
$ ls -l vendor/plugins/ | grep hug
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 19:55 huggies_api
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 20:06 huggies_baby_room_gallery
drwxr-xr-x   9 agenteo  84396665  306 14 Nov 20:08 huggies_blog
drwxr-xr-x  14 agenteo  84396665  476 14 Nov 20:08 huggies_mums_tips
drwxr-xr-x   6 agenteo  84396665  204 14 Nov 20:11 huggies_voting_tool
{% endhighlight %}

## What didn't go well

Like the subdirectory structure the plugins were setting **a weak boundary** meaning classes in one vertical could depend on other verticals or the main application **creating dependencies impossible to track without reading the code**. 

>> If a developer must consider the implementation of a component in order to use it, the value of encapsulation is lost.
>>
>> Eric Evans

It was still hard to pinpoint which of the over 200 migrations belonged to a plugin and how its vertical was affecting the database schema.

I started thinking how much code should be in the main application for the plugins to use? **Back then I could only *chase* good balance but with current Rails I can achieve that by moving all the functionality away from the main application in to small engine components creating a solid dependency structure**. I explain how in [A component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/).

This plugin approach I used in 2008 was far from perfect but it reduced entropy and it was better then having all models and controllers in a fragile directory structure or even worst introducing service oriented architecture for code organization. I disagree that after a few years large applications must be rebuilt if **you build them incrementally using a supple design they can be maintained and shaped in to a new form**.

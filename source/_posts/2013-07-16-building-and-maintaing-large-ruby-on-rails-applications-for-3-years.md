---
layout: post
title: Building and managing a large Ruby on Rails application for 3 years
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

In 2008 I was working on a large Rails 2 application for about 3 years and since following framework conventions wasn't bringing the best results I switched to a plugin structure the precursor of current engines.

Sometime we deliver small size projects without thinking architecture but simply sticking to framework conventions--a good part of Rails popularity is due to those conventions but I will explain how diverging from them was beneficial to this large project.

Thanks to Ben and Red Ant to let me use the project as a use case.

## The project

The site we were about to rebuild was showing static content to users and enabling discussions on a forum--the new version was going to introduce a strong social interaction to the content. For example the original baby name finder component was browsing a list of names and their meaning but its new version was also allowing shortlisting, voting names, sharing with family, weekly popularity graphs. We had similar enhancements to several other content areas that I will refer to as verticals some examples are: promotions, kids activities, recipes finder.

I don't remember why but we decided against gradually deploying verticals and instead rebuild all the key ones to match the existing site and do a big bang release--we knew that after release the stakeholder was going to invest in even more verticals.

Somebody decided to use a pre build PHP **forum** to reduce the scope and a Rails **CMS** called Radiant to handle purely static content--the remaining verticals where part of a single Ruby on Rails application that I will call **core**--finally nginx was proxying the segments to the correct upstream.

The project rebuild went on for about 10 months with a team of two backend developers, two frontend plus designers and a project manager. From now on I will only talk about development on **core**.

## A sufficient approach

Keeping code for different verticals in the same `/app/models` or `/app/controllers` was going to become unmaintainable very quickly so we agreed to use subdirectories. This is an example of models and controllers with subdirectories roughly mapped to verticals. 

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

This approach allowed us to find vertical related code and reduce merge conflicts while developing in parallel--after we went live we started adding new verticals and a few shortcomings started to surface. 

## Some downsides

Our sub directory structure was creating a weak boundary meaning classes from one vertical could tinker with others and create tangled dependencies hard to follow--the result was large god objects primarily `user.rb` frequently changed by all verticals either directly or trough decoration causing people to step on each other toes. It was really hard to trace the over 200 migrations to a vertical making it difficult to understand the scope of a database change--similarly the route file `/config/routes.rb` was a 300 lines mix from all verticals painful to maintain and manage. We did not enforce namespaces which caused helper methods collisions

## An almost self contained approach

**I introduced the next vertical as a plugin (precursors of engines) to encapsulate its code and minimize changes to the main application**. A plugin could provide the main rails application with models, controllers, views, helpers, routes and migrations **but instead of creating the classical reusable plugin it was very specific code for the vertical**. Most of the code related to the vertical would live inside its plugin directory and only minor changes would affect the app god models with decoration--the new routes would be automatically picked up from the plugin's `config/routes.rb` and finally we had unit tests inside the plugin.

To make verticals plugins stand out from the vendor plugins we agreed to append a static string in front of plugin name but when developers did't remember (or care) about the prefix it was really hard to find them.

{% highlight bash %}
$ ls -l vendor/plugins/ | grep hug
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 19:55 huggies_api
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 20:06 huggies_baby_room_gallery
drwxr-xr-x   9 agenteo  84396665  306 14 Nov 20:08 huggies_blog
drwxr-xr-x  14 agenteo  84396665  476 14 Nov 20:08 huggies_mums_tips
drwxr-xr-x   6 agenteo  84396665  204 14 Nov 20:11 huggies_voting_tool
{% endhighlight %}

We did knot fix the growing migrations and when a vertical relied on the main application code changes would occur in both areas--**this unspoken dependency between a plugin and the main application did not help set clear boundaries**--how much should the main application take care of? In a large application ideally nothing all its logic will come from a series of small well defined components. I explain how in [A component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/).

## Conclusions

For me using plugins in 2008 was a breakthrough to [components](http://teotti.com/topics/component-based-rails-architecture/) and certainly better then having all models and controllers in a fragile sub directory structure or worst introducing service oriented architecture merely for organizational reasons. This approach helped manage the app growth and entropy--I disagree with people thinking after a few years large applications have to inevitably be rebuilt--**when you use a supple design the application can be maintained and shaped in to a new form**.

I encountered a bit of skepticism about this approach from other fossilized on Rails conventions and never looking at the whole app from a different angle. After you see conventions playing against large apps the responsible thing to do is looking for alternatives.

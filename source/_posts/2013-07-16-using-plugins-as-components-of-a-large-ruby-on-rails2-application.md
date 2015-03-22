---
layout: post
title: Using plugins as components of a large Ruby on Rails 2 application
comments: true
tags:
  - work
  - ruby
  - component-based-rails-architecture
redirect_from:
  - /work/ruby/2013/07/16/using-plugins-as-components-of-a-large-ruby-on-rails2-application/
  - /work/ruby/2013/07/16/using-plugins-as-components-of-a-large-ruby-on-rails2-application.html/
---

In 2008 I was working on a large Rails 2 application for 3 years and that's when I realized following the framework conventions wasn't bringing the best results and switched to a plugin structure--the precursor of current engines.

Thanks to Ben and Red Ant to let me use the project as a use case.

## The story

Sometime we deliver small size short time projects without much architecture and strictly follow the Ruby on Rails conventions--a good part of the framework popularity is from those type of projects **but I think Rails can handle large projects and keep them maintainable**.

The site was primarly showing static content to users and enabling discussions on a forum--the new version was going to introduce a social aspect to the content. For example the name finder component was browsing a list of names and its new version was going to allow shortlisting, voting names, sharing with family which would also vote, weekly popularity graphs. 

The project rebuild went on for about 10 months with a team of two backend developers, two frontend plus designers and a project manager.

I don't remember why but we decided against gradually deploying areas and instead rebuild all the key areas required to match the legacy:

* name finder
* promotions
* kids activities
* user registration process
* CMS
* forum

We decided to serve the **forum** from another app outside the Rails stack and the **CMS** to be a Radiant app (a separate rails app) but the remaining areas where part of a single Ruby on Rails application (called **core**). Nginx would be proxying the segments to the correct upstream.

We knew that after the release the stakeholder was going to invest in more vertical components.

Me and the other developer agreed that since **core** was going to serve multiple verticals having all the models in the `/app/models` wasn't going a sane way to work so we created model subfolders and required that inside environment.rb

{% highlight ruby %}
Dir.glob("#{RAILS_ROOT}/app/models/*[^.rb]").each{|dir| config.load_paths << dir }
{% endhighlight %}

{% highlight bash %}
$ ls -l app/models
ask_an_expert_models            contact_us                      loyalty_models                  recipe_finder_models            utils
babynames_models                kids_activities_models          membership_models               sharing
babynames_utils                 landing_page_header             promos_and_samples_models       story_models
{% endhighlight %}

Inside the controllers we also had subfolders, roughly mapping the ones defined under models:

{% highlight bash %}
$ ls -l app/controllers
admin                           ask_an_expert                   contact_us_controller.rb        membership                      promos_and_samples
admin_controller.rb             babynames                       kids_activities                 my_huggies                      recipe_finder
application_controller.rb       contact_us                      loyalty                         my_huggies_controller.rb        stories
{% endhighlight %}

This approach allowed us to identify a vertical slice of the application and create a boundary where all the files would live. Nothing was preventing classes in different boundaries to tinker with other boundaries.

After we went live we were asked to build new verticals and after a few months a few shortcomings started to surface:

* it was hard to define the boundaries of a vertical--often classes where referencing another vertical class which would create a tangled depedency hard to follow
* the migrations folder didn't have boundaries making it difficult to tell to which silo they belonged
* the routes file didn't have boundaries, we used comments to highlight the entries related to a vertical but maintaining it was a painful process
* we did not enforce namespaces which caused some helper methods to be overwritten

## Plugins to the help

After reading a book about Rails that talked about plugins I started using one to enforce structure in our application code instead of the usual drop in functionality.

A plugin (precursors of engines) is an extension to the main rails application, the plugin folder follows Rails's usual directories and make its models, controllers, views, helpers available to the main application.

That's how the vendor plugin are working, but instead of creating a reusable plugin I created a very specific one!

So it was not designed to provide a generic functionality that we would use again in other projects but instead it was holding concepts related to a specific strand of work (feature) of this particular project.

Advantages of this approach:
* most of the code related to the 'component' would belong inside its plugin directory
* only minor changes would happen in the app god models (usually using decoration)
* you could now isolate the routes of the new component in the plugin's config/routes.rb which would be picked up by the main application.
* we had unit tests inside the plugin.

Shortcomings of the approach:

* since we had plenty of vendor plugins in order to make the internal ones stand out we had to set a convention of appending the project name in front of plugin name ie.

{% highlight bash %}
$ ls -l vendor/plugins/ | grep hug
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 19:55 huggies_api
drwxr-xr-x   7 agenteo  84396665  238 14 Nov 20:06 huggies_baby_room_gallery
drwxr-xr-x   9 agenteo  84396665  306 14 Nov 20:08 huggies_blog
drwxr-xr-x  14 agenteo  84396665  476 14 Nov 20:08 huggies_mums_tips
drwxr-xr-x   6 agenteo  84396665  204 14 Nov 20:11 huggies_voting_tool
{% endhighlight %}

That convention (one more thing to do for the developer) didn't really work well,
people sometime forgot the prefix making hard to detect non vendor plugins.
* the migrations had still to be placed in the main app migration folder, so that folder kept
growing.
* we had plugins relying on the main application code, so a change to a
  plugin would require to change main application code. A better approach would
  have been to move the code in the main app in plugins. I'll describe that
  approach in a followup article.


## Conclusion
Three new components were created as plugins before I left the company.
I felt we were on the right track to keep the app under control.

Moving the initial components from the main app to their own plugin would have
helped to improve consistency.

Even considering the shortcomings I believe this way of structuring this large
project helped us.

It was certainly better then having everything in /models and /controllers keeping
using subfolders or introducing SOA merely for organizational reasons.

I encountered a bit of skepticism on this approach from other developers.
I've found many Rails developers are fossilized on the conventions Rails gives
and never look at a Rails app from a different angle.
In cases of large apps some of those conventions will simply play against you
and I think we should look in to alternative paths to follow.

Did you find yourself working on a large Ruby on Rails application? Did you
structure the code in any particular way?

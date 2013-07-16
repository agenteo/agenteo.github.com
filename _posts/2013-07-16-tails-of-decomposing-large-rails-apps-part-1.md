---
layout: default
title: Tails of decomposing a large Ruby on Rails application part 1
comments: true
categories:
  - work
  - ruby
---


# {{page.title}}

This is a short story about the creation and maintenance of a large Ruby on Rails
application, and how after initially sticking to the Rails conventions I
questioned them and used Rails plugins to structure the code of new components.


## The story
Sometime we work on a small size project.

Without much upfront design we deliver the product following the Ruby on Rails conventions,
maybe using scaffold generators, maybe dropping in a few gems.

It's critical to acknowledge those scenarios, a good part of Rails's popularity is due to those kind of projects.

But I believe Ruby on Rails can handle large projects too and this story is about those times.

I worked on new green field projects containing many concepts at the
foundation of the system, and you simply couldn't go live without all of them.

This first part goes through how I realized I had to step away from some of
Ruby on Rails's conventions in order to introduce a little bit of structure in
the large application we where working on.

The year was 2008 and the app was running on Rails 2.

Six years later I believe large Ruby on Rails apps are facing the same pitfalls. I will
discuss a more updated technical solution in a follow up article.


## The project (Huggies.com.au)
This was a rebuild of a big multinational brand, the legacy site was mostly presenting
content to the users, now we had to create a social experience around that content.

For example the name finder component in the legacy site was just browsing a list of names.
In the new build it would allow users to vote names, an improved search, creating
shortlists to share with family (which would then be allowed to vote), popularity graphs.

The project rebuild was ongoing for about 10 months.

The team was composed of two backend developers, two frontend plus designers and PMs.

We knew we had to implement what existed in the legacy site and deliver new/improved components:
* name finder
* promotions
* kids activities
* user registration process
* CMS
* forum

We decided to serve the forum from another app outside the Rails stack.
And we decided to handle the CMS as a Radiant app (a separate rails app).
Nginx would sit in front and route the URLs to the appropriate backend.

But the rest of the components where part of a single Ruby on Rails application.
* name finder
* promotions
* kids activities

And we knew that after (big bang) release the stakeholder was going to ask for
more of those vertical components.

Me and the other developer agreed that having all the
models inside the /app/models wasn't going to be a sane way to work.

We created model subfolders and required that inside environment.rb
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

Advantages of this approach:
 
* easier to identify a knowledge 'silo' then having all the files in a single controller or model folder

We successfully went live and kept developing new features, but after a few months the shortcomings started to surface:

* sometimes it was hard to define the boundaries of the knowledge 'silo'
* the migrations folder didn't have boundaries, hence difficult to tell to which silo they belonged
* similarly the routes file didn't have boundaries, we used comments blocks to highlight 'silo' blocks but maintaining it was a painful process
* we did not use namespaces which caused some helper methods to be overwritten. I think this was due to my ignorance at the time not to a Rails flaw.


## Plugins to the help
After reading a book about Rails that talked about plugins I
started looking in to using them to enforce structure in our application code
instead of the usual drop in functionality.

A plugin (in Rails 3 and above called engines) is an extension to the
main rails application, the plugin folder follows Rails's usual directories and
make its models, controllers, views, helpers available to the main application.

That's how the vendor plugin are working, but instead of creating a reusable
plugin I created a very specific one!
So it was not designed to provide a generic functionality that we would use again
in other projects but instead it was holding concepts related to a specific strand
of work (feature) of this particular project.

Advantages of this approach:
* most of the code related to the 'component' would belong inside its plugin directory
* only minor changes would happen in the app god models (usually using decoration)
* you could now isolate the routes of the new component in the plugin's config/routes.rb which would be picked up by the main application.
* we had unit tests inside the plugin.

Shortcomings of the approach:

* since we had plenty of vendor plugins in order to make the internal ones stand out we had to set a convention of appending the project name in front of plugin name ie.  {% highlight bash %}
$ ls -l vendor/plugins/ | grep hug
drwxr-xr-x   7 teottie5e  84396665  238 14 Nov 19:55 huggies_api
drwxr-xr-x   7 teottie5e  84396665  238 14 Nov 20:06 huggies_baby_room_gallery
drwxr-xr-x   9 teottie5e  84396665  306 14 Nov 20:08 huggies_blog
drwxr-xr-x  14 teottie5e  84396665  476 14 Nov 20:08 huggies_mums_tips
drwxr-xr-x   6 teottie5e  84396665  204 14 Nov 20:11 huggies_voting_tool
{% endhighlight %} That convention (one more thing to do for the developer) didn't really work well,
people sometime forgot the prefix making hard to detect non vendor plugins.
* the migrations had still to be placed in the main app migration folder, so that folder kept
growing.


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
and I think it's our duty to look in to alternative paths to follow.

Did you find yourself working on a large Ruby on Rails application? Did you
structure the code in any particular way?

In the next part I'll go trough the last application me and my team built using
engines on Rails 3.

{% if page.comments %}
  <div id="disqus_thread"></div>
  <script type="text/javascript">
      /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
      var disqus_shortname = 'enricoteotti'; // required: replace example with your forum shortname

      /* * * DON'T EDIT BELOW THIS LINE * * */
      (function() {
          var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
          dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
          (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
      })();
  </script>
  <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
  <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
{% endif %}

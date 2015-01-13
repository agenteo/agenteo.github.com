---
layout: post
title: Root level segment filter pages with Ruby on Rails route constraints
comments: true
tags:
  - work
  - ruby
  - routes
---

{{ page.title }}

Recently I was asked to implement a set of vanity URLs (static filters) to an app root level segment. I'd have a key value mapping `slug` with `filter_ids`.

The app already had a detail page served at the root, so I added a new root route with a `constraints` attribute to ensure the filter page would be used for a vanity slug only.

{ highlight ruby }
Rails.application.routes.draw do
  get '/:vanity_url' => 'articles#index',
      constraints: RouteConstraints::VanitySlug.new
  get '/:slug' => 'articles#show'
end
{ endhighlight }

The constraint return true or false to determine if this route matches our expectations.

But I also wanted to avoid parsing and extracting filter data out of the vanity slug in the controller action.

So I delegated that resposability to the route constraint (`app/models/route_constraints/vanity_slug.rb`):

{ highlight ruby }
module RouteConstraints

  class VanitySlug

    def matches?(request)
      vanity_url = request.path_parameters[:vanity_url]
      if vanity_url =~ /^filter-/
        filter_string = vanity_url.gsub(/^filter-/, '')
        filter_dictionary = FilterDictionary.new(filter_string)
        request.path_parameters[:filter_ids] = filter_dictionary.ids
        return true
      end
      false
    end
  end

end
{ endhighlight }


Assuming `/filter-best-articles-2014` to be mapped to ids `[1234, 5678]` the above would pass to my controller action a hash with `filter_ids` containing `[1234, 5678]`.

## Conclusion

You're likely to have that `filter_ids` passed to `articles#index` through other filters in your app and this approach doesn't alter that functionality and decouples the route parsing from a controller before action.

The controller action ignores where those `filter_ids` are coming from.

I drove this feature by adding a route automated tests to ensure this functionality was sound.

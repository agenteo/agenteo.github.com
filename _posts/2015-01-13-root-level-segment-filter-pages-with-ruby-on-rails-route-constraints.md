---
layout: post
title: URL segments serving filters and more with Ruby on Rails route constraints
comments: true
tags:
  - work
  - ruby
  - routes
---

Recently I was asked to implement result URL slug applying filters (ie. `/content/best-2014-articles`) to an app segment already serving other content (ie. an article `/content/ways-to-ruin-your-wedding`).

Doing this without a unique prefix or suffix differentiating filter pages from the detail pages means doing a slug lookup on every request. The cost of this operation is dependent on your application logic. A small infrequently updated dataset could be fetched once and memoized in to singleton with key (slug) value (filter information) and just occupy memory in your Ruby process. If you have a more dynamic dataset your focus should be on monitoring and optimizing that query under load.

## The direction

A route automated test is the way to start ensuring the functionality is solid:

{ highlight ruby }
assert_routing({ path: '/best-articles-2014', method: :get },
               { controller: 'articles', action: 'index', filter_ids: [12345,6789] })
{ endhighlight }

The `filter_ids` will be populated during the routing to avoid changing the `articles#index` behaviour. I wanted to leave that action (already consuming filter_ids as a search parameter) agnostic from this new feature.

We must ensure the fallback works when the slug is not vanity:

{ highlight ruby }
assert_routing({ path: '/not-a-vanity-slug', method: :get },
               { controller: 'articles', action: 'show', slug: '/not-a-vanity-slug' })
{ endhighlight }

I'd stub any I/O in those and rely on a higher lever request spec as a smoke integration test.

## The implementation

I added a new root route leveraging `constraints` attribute to ensure the filter page would only be routed for a vanity slug.

{ highlight ruby }
Rails.application.routes.draw do
  get '/:vanity_url' => 'articles#index',
      constraints: RouteConstraints::VanitySlug.new
  get '/:slug' => 'articles#show'
end
{ endhighlight }

The constraint class has a `matches?` method that return true or false to determine if this route matches our expectations.

On top of that I wanted to parse and extract filter data from the vanity slug in the controller action. Ideally the destination `controller#action` should be agnostic of handle traffic from the .

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


Assuming `/filter-best-articles-2014` is mapped to ids `[1234, 5678]` in our `FilterDictionary` the code above would pass to the `articles_controller#index` a `param[:filter_ids]` with `filter_ids` containing `[1234, 5678]`. Magic!

## Conclusion

Ruby on Rails constraints can help you if you want to handle different controller actions on the same route segment. Parsing a URL and populating params is a really powerful hidden feature.

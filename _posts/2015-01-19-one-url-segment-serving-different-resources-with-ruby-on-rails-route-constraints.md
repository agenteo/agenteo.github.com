---
layout: post
title: One URL segment serving different resources with Ruby on Rails route constraints
comments: true
tags:
  - work
  - ruby
  - rails
  - routes
---

I was asked to implement result URL slug applying filters (ie. `/content/best-2014-wedding-articles`) to a segment already serving other content (ie. an article `/content/ways-to-ruin-your-wedding`).

Doing this without a unique prefix or suffix differentiating a filter page from a detail page route means using Ruby on Rails routes constraints to do a slug lookup on every request.

The cost of this operation depends on your application logic. A small infrequently updated dataset could be fetched once and memoized in to singleton with key (slug) value (filter information) and just occupy memory in your Ruby process. A more dynamic dataset might rely on a database query and you'll have to monitor and ensure its performant under load.

## What is a Ruby on Rails route constraint?

A constraint determines if a route should be resolved or not. You can think of the route constraint as a [policy pattern](http://en.wikipedia.org/wiki/Strategy_pattern) on a route. When the policy is true the route will resolve, otherwise will move on the next one. Common examples like regular expressions on the params or filters on the subdomain are [documented here](http://guides.rubyonrails.org/routing.html#segment-constraints) technical details on its implementation [on Github](https://github.com/rails/rails/blob/77627c5aa3b9aeb68a53ad4a700f5003f2f24089/actionpack/lib/action_dispatch/routing/mapper.rb#L939).

What we will be using is referred as "advanced constraint" and it's basically a Ruby class with a `match?` method returning `truethy` or `falsey` value. More information [here](http://guides.rubyonrails.org/routing.html#advanced-constraints).

## The direction

A route automated test is the best way to start building this functionality:

{% highlight ruby %}
assert_routing({ path: '/content/best-articles-2014', method: :get },
               { controller: 'articles', action: 'index', static_result_slug: 'best-articles-2014' })
{% endhighlight %}

You will proceed by mocking the constraint setting exceptions on what it needs to do and have its `match?` method return true. Also ensure the fallback route works when the constraint doesn't match:

{% highlight ruby %}
assert_routing({ path: '/not-a-vanity-slug', method: :get },
               { controller: 'articles', action: 'show', slug: '/not-a-vanity-slug' })
{% endhighlight %}

Our routing will look like this:

{% highlight ruby %}
get '/blog' => 'articles#index'
scope path: '/blog' do
  get '/:static_result_slug' => 'articles#index', constraints: Routing::Results::Constraint.new
  get '/:slug' => 'articles#show'
end
{% endhighlight %}

I added a new segment for static result slug using `constraints` to ensure the filter page would only be routed for a vanity slug.

Integration test is critical and I used a feature test to ensure that given the result page slugs data set is populated the user lands on the correct results.

{% highlight ruby %}
module Results

  class Constraint

    def initialize
      @dictionary = Dictionary.new
    end

    def matches?(request)
      @dictionary.find(request.path)
    end

  end

end
{% endhighlight %}

Now the `controller#action` will receive a `static_result_slug` parameter and transform it to a series of filter ids to filter on. In my case I had an existing `param[:filter_ids]` attribute to use. The action will need to handle a 404 in case the filter slug is not found.

## Hack for adventurous people

The constraint is a policy class and should stay that way. What I am suggesting next substantially changes that assumption but I think it's interesting to look and to think about it.

The constraint object has full access to the current request. You *can* run the parse operation in the constraint and add a new param filter with that list of ids.

This would avoid adding that parsing logic to the `articles#index` as well as the 404 now handled by your next route.

This was taken from my spike app and assumes `filter-` is prefixing all the result pages rather then doing a dictionary lookup for the match.

{% highlight ruby %}
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
{% endhighlight %}

Assuming `/filter-best-articles-2014` is mapped to ids `[1234, 5678]` in our `FilterDictionary` the code above would pass to the `articles_controller#index` a `param[:filter_ids]` with `filter_ids` containing `[1234, 5678]`. Awesome but we're walking on thin ice.

The `assert_routing` rspec helper will not respect changes to the request for that new parameter. That and breaking the policy object stopped me from using this in a production app (instead we do the parsing in the controller action).

## Conclusion

If your search engine optimization policy is ok using a `-tips` or `-filter` suffix in your results routes I'd say go for it and save some memory / computation.

Ruby on Rails constraints help you serving the same segment for different resources and do an excellent job leaving your controllers clean.

Changing the request object by adding or removing params breaks the constraint responsibility and I feel the ideal solution would be to have a Ruby on Rails routes transform feature ie:

{% highlight ruby %}
get '/:static_result_slug' => 'articles#index',
    constraints: Routing::Results::Constraint.new,
    transformer: Routing::Results::FilterIdsTranformer.new
{% endhighlight %}

the transformer would only run when the constraints is true.

The interaction between constraints and request object should be clarified in Ruby on Rails, perhaps the code should receive a `.frozen` object to prevent hacks like mine to throw people on a buggy vs featured path. I'll follow up and update this.

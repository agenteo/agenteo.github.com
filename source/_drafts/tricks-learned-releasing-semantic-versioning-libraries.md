---
layout: post
title: Best practices releasing semantic versioned (Ruby) libraries
comments: true
tags:
  - mongodb
---


When releasing a library you are starting a contract with your clients - they can be collegues in other divisions, paying subscribers of a product, general public - but you owe them the same attention to detail. Following [semantic versioning](http://semver.org) in library release is a must to ensure clients know what to expect in the next version but architecting resilient and maintainable code is another critical point of maintaining libraries.

{% highlight bash %}
Given a version number MAJOR.MINOR.PATCH, increment the:
MAJOR version when you make incompatible API changes,
MINOR version when you add functionality in a backwards-compatible manner, and
PATCH version when you make backwards-compatible bug fixes.
{% endhighlight %}


To facilitate access to a server API we create a library wrapping it - the clients will not have to worry about the server API because it sign on a contract with our library API. Do not get confused by API (Application Programming Interface) being used in two different context: the server and confuses you

{% highlight ruby %}
# library_facade.rb
def term(id)
  response = connection.get("/term/#{id}.json")
  JSON.parse(response.body)
end
{% endhighlight %}

Just forwarding the API JSON responses can't provide default results when the API is unreachable - with a data structure wrapping the response it can instantiate objects as well as fallbacks when needed. Here's how it looks:

{% highlight ruby %}
# library_facade.rb
def term(id)
  response = connection.get("/term/#{id}.json")
  LibraryNamespace::Term.new( JSON.parse(response.body) )
end
{% endhighlight %}

We istanciate a `Term` class with the response data and will return a `Term` object to our clients rather then an arbitrary JSON hash we don't control.

[Circuit breaker](http://martinfowler.com/bliki/CircuitBreaker.html) is a pattern *"to detect failures and encapsulates logic of preventing a failure to reoccur constantly (during maintenance, temporary external system failure or unexpected system difficulties)"*. Have the library use it to manage API availability and return a fallback object when needed.


{% highlight ruby %}
# library_facade.rb
def term(id)
  if circuit_breaker.open?
    LibraryNamespace::FallbackTerm.new
  else
    response = circuit_breaker.response
    LibraryNamespace::Term.new( JSON.parse(response.body) )
  end
end
{% endhighlight %}

This gracefully handles errors providing your clients objects with the same signature for an error and success response. For example imagine an article with a term id using the API library to retirieve more term information - when the library returns a `FallbackTerm` the article page can hide the term information or just display its fallback fields knowing they are the same as `Term`.


If an API endpoint updates its response formats the library will break istantiating objects from an outdated data structure. **This is the responsability of a library wrapping an API instead of its clients breaking or concerning about changes in the API responses**. Release a major [semantic version](http://semver.org/) library change to inform your clients a backward incompatible change was introduced.

If you control the API have a versioned endpoint or a request header to prevent introducing breaking changes without a deprecation phase. Here's an example using a data structure to deprecate incoming major API changes - take the following API response is using both `taxonomy_slug` and `seo_slug` in `broader_terms` - to be consistent `taxonomy_slug` will be renamed to `seo_slug`. 
{% highlight ruby %}
{
    "id"=>"d15cf067-c4b1-4820-a837-59444208cac5",
    "name"=>"BBQ",
    "term_status"=>"Active",
    "seo_term_plural"=>"BBQ Foods",
    "seo_slug_plural"=>"bbq-foods",
    "description"=>"(cuisine)\r\nMeat that is smoked, grilled, cooked \"low and slow.\" BBQ styles change regionally and are cause for great debate.",
    "synonym"=>"barbecue, Bar-B-Q",
    "created_at"=>"2014-06-20T20:31:25.466Z",
    "updated_at"=>"2014-08-04T20:00:53.191Z",
    "seo_term_singular"=>"BBQ",
    "seo_slug_singular"=>"bbq",
    "narrower_terms"=>[
      {
        "id"=>"d15cf067-c4b1-4820-a837-59444208cac5",
        "seo_slug"=>"bbq",
        "name"=>"BBQ"
      }
    ],
      "broader_terms"=>[
        {
          "id"=>"d15cf067-c4b1-4820-a837-59444208cac5",
          "seo_slug"=>"bbq",
          "name"=>"BBQ"
        },
      {
        "id"=>"df6a96bc-e01a-4ba3-8868-0c18ef741c9b",
        "seo_slug"=>"specialty-food",
        "name"=>"Specialty"
      },
      {
        "id"=>"02d6895a-1ac2-4a0d-bfd9-d1aa13135d43",
        "taxonomy_slug"=>"cuisine",
        "name"=>"Cuisine"
      }
      ],  
    "taxonomy"=>{
      "id"=>"02d6895a-1ac2-4a0d-bfd9-d1aa13135d43", "name"=>"Cuisine"
    },
    "archived_terms"=>[]
  }
{% endhighlight %}

This would introduce a breaking change to your client using `taxonomy_slug` and a data structure can help defining a method like:

{% highlight ruby %}
# term.rb
def taxonomy_slug
  puts 'DEPRECATION WARNING: using taxonomy_slug for taxonomy entries has been deprecated switch to seo_slug'
  taxonomy_slug
end

def seo_slug
  response['seo_slug'] || response['taxonomy_slug']
end
{% endhighlight %}

this change would go out in a minor version -- the major release after that will remove the `taxonomy_slug` method.

When you are providing shared libraries you need an architecture that facilitate deprecation and changes. Providing generic data structures like an Array of arrays or Hash might prevent that. Once you expose a method returning:

{% highlight ruby %}
{ "published": true, "url": "/best-practices" }
{% endhighlight %}

and want to switch `url` to `path` your clients have to search and replace.

When the response contains an array fallback to a an empty array.



If you want to facilitate a server API usage create a library wrapping it.

{% highlight ruby %}
def term(id)
  response = connection.get("/term/#{id}.json")
  JSON.parse(response.body)
end
{% endhighlight %}

Just forwarding the API JSON responses can't provide default results when the API is unreachable - with a data structure wrapping the response it can instantiate objects as well as fallbacks when needed. Here's how it looks:

{% highlight ruby %}
def term(id)
  response = connection.get("/term/#{id}.json")
  LibraryNamespace::Term.new( JSON.parse(response.body) )
end
{% endhighlight %}

We istanciate a `Term` class with the response data and will return a `Term` object to our clients rather then an arbitrary JSON hash we don't control.

Use [circuit breaker](http://martinfowler.com/bliki/CircuitBreaker.html) to manage API availability and return a fallback object when needed.

{% highlight ruby %}
def term(id)
  if circuit_breaker.open?
    LibraryNamespace::FallbackTerm.new
  else
    response = circuit_breaker.response
    LibraryNamespace::Term.new( JSON.parse(response.body) )
  end
end
{% endhighlight %}

The `LibraryNamespace::FallbackTerm` is exposing the same fields as a `LibraryNamespace::Term` so your clients consume a timed out response in the same way of a regular response -- when the response is an array fallback to a an empty array.

If the API endpoint updates its response formats your library will break istantiating objects from an outdated data structure. This is good, release a [semantic version](http://semver.org/) major library change to inform your clients a backward incompatible change was introduced. If you control the API have a versioned endpoint or a request header to prevent introducing breaking changes without a deprecation phase.

Here's an example using a data structure to deprecate incoming major API changes. Given the following API response:

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

using both `taxonomy_slug` and `seo_slug` in its `broader_terms` and `taxonomy_slug` will be renamed to `seo_slug`. This would introduce a breaking change to your client using `taxonomy_slug` - here's how a data structure helps:

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


Create objects wrapping your data structures

{% highlight ruby %}
def term(id)
  get("/term/#{id}.json")
end

def get(path)
  response = connection.get(path)
  JSON.parse(response.body)
end
{% endhighlight %}

A library just returning API JSON responses can't provide default results when the API is unreachable - with a data structure wrapping the response it can instantiate objects as well as fallbacks when needed.

{% highlight ruby %}
def term(id)
  response = connection.get(path)
  LibraryNamespace::Term.new( JSON.parse(response.body) )
end
{% endhighlight %}

The `Term` class will fetch entries from the response.

Use [circuit breaker](http://martinfowler.com/bliki/CircuitBreaker.html) to manage API availability in the library.

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

The `LibraryNamespace::FallbackTerm` will be populated with the same fields as `LibraryNamespace::Term` - this allows your clients to consume a timed out response in the same way a regular response. The fallback class can have a `fallback` method set to true and when the response is an array it will gracefully fallback to a an empty array.

If the API endpoint updates its response formats your library will break when istantiating objects in an outdated data structure. This is good, release a [semantic version](http://semver.org/) major library change to inform your clients a backward incompatible change was introduced.

The API should have a versioned endpoint or a request header to prevent introducing breaking changes without a deprecation phase.

The library data structure facilitates the deprecation phase by notifying its clients about major changes beforehand.

For example:

{% highlight ruby %}
client.term(term_id)
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

is using `taxonomy_slug` in its `broader_terms` and you decide to be consistent and rename it to `seo_slug`.

This would be a breaking change to your client that might be currently using `taxonomy_slug`. With a data structure you can:

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

The new field is not in the current version of the API but you can start providing it.

Keep track of deprecations in your changelog for your clients.

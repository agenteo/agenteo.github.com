
Create objects wrapping your data structures


A library directly returning API JSON responses to its clients will be unable to provide fallback results when the API is unreachable. If the library has a data structure wrapping the API response, it can istanciate genuine objects with the API response as well as fallbacks when the API isn't responding. Use [circuit breaker](http://martinfowler.com/bliki/CircuitBreaker.html) to let the library manage the API availability.

If you have control of the API and it's written in the same language as the library share the data structure objects -- inevitably

If the API endpoint updates its response formats your library will break istantiating objects in an outdated data structure. This is good, release a [semantic version](http://semver.org/) major library change to inform your clients a backward incompatible change was introduced.

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

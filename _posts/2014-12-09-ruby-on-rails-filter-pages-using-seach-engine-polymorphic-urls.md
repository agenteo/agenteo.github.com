---
layout: post
title: Ruby on Rails filter pages using search engine polymorphic URLs
comments: true
tags:
  - work
  - ruby
  - SEO
redirect_from: "/2014/12/09/ruby-on-rails-filter-pages-using-seach-engine-psycotic-urls/"
---

We're all familiar with search engine friendly URLs ie. a filter on 'Mid range' would be hyphenated to `/mid-range`.

**TL;DR you can have a slug with multiple hyphenated search terms by iterating and extracting the terms in your taxonomy from the slug but you must ensure only one slug will be serving your content by automatically redirecting malformed slugs.**


## The old way

When asked to build a search page off user's UI selection filters I'd first approach it with the classic query string, ie. user clicking filter for 'mid range' and 'contemporary' would result in a result page URL with `search%5B%5D=mid range&search%5B%5D=contemporary` or perhaps with the ID of the filter term. Not very search engine friendly I've been told.

## A friendlier approach

I'd suggest a unique term separator (not occurring in any term) for example: `/mid-range_contemporary` or adding a separate segment for each term filtered on `/contemporary/mid-range/`. In the latter you'd be expected to populate `/contemporary` with relevant content, and you'd have to prevent the user from clicking 'mid range' before 'contemporary'.

## A polymorphic way

Recently I was told that a better search engine approach would be to have a single segment based on the previous user selection example: `/mid-range-contemporary`, and after clicking 'gray decks' the URL would become `/mid-range-contemporary-gray-decks`. But `/gray-decks-mid-range-contemporary` should return the same result page.

All these examples are from a real web site called zillow.com (that my SEO team used as an example). I determined these were not to be called search engine friendly (SEF) URL anymore but search engine polymorphic (SEP) URL.


>>> Polymorphism
>>>
>>> in biology occurs when two or more clearly different phenotypes exist in the same population of a species - in other words, the occurrence of more than one form or morph. In order to be classified as such, morphs must occupy the same habitat at the same time and belong to a panmictic population (one with random mating).
>>>
>>> -- <cite>Wikipedia</cite>

And here's a real example knocking at my door: zillow tag system changing their urls exactly per my SEO team request.

![zillow.com/digs](/assets/images/zillow_example.gif)

After seeing it happening before my eyes I had to find a way to do it.

## Ruby on Rails spike on polymorphic URLs

I started from a route receiving the polymorphic slug:

{% highlight ruby %}
get '/digs/:polymorphic_slug' => 'polymorphic#index'
{% endhighlight %}

and hand it over to the controller action that would delegate the lookup:

{% highlight ruby %}
lookup = PolymorphicSlugLookup.new(params[:polymorphic_slug])
terms = []
dictionary = Dictionary.new
lookup.ids.each do |id|
  terms << dictionary.term(id)
end
flash[:notice] = "You searched for : #{terms.join(' ')}"
{% endhighlight %}

The PolymorphicSlugLookup class is where given the slug, I gather every term from the slug until is empty.

{% highlight ruby %}
class PolymorphicSlugLookup

  def initialize(slug)
    @slug = slug
    @dictionary = Dictionary.new
  end

  def ids
    @ids = []
    @dictionary.ordered_terms.each do |term|
      if @slug.match(/-?#{term}-?/)
        @slug.gsub!(/-?#{term}-?/, '')
        @ids << @dictionary.id(term)
      end
      break if @slug.empty?
    end
    @ids
  end

end
{% endhighlight %}

Having ordered terms is critical to avoid shorter terms being a partial match. Which is a constraint of this system: if we have two terms 'fire' and 'fireplace' then the longer will take precedence and override the shorter.

## Resource uniqueness

You don't want to have two URLs serving the same resource ie. `/mid-range-contemporary-gray-decks` and `/gray-mid-range-contemporary-decks`. You can prevent this from your UI but users could type or start linking content to it and the curent solution would serve that content.

Assuming the lookup returns ids ordered according to your SEO value, you could redirect if the original slug doesn't match. A solution is to have a `PolymorphicSlugRedirect` that given the result of a lookup, would compare it with the requested slug. 

{% highlight ruby %}
lookup = PolymorphicSlugLookup.new(params[:polymorphic_slug])
redirect = PolymorphicSlugRedirect.new(params[:polymorphic_slug], lookup.ids)
if redirect.execute?
 redirect_to "/digs/#{redirect.destination}"
end
# render search response...
{% endhighlight %}

## How slow is this?

Well, I've benchmarked the look up:

{% highlight ruby %}
Benchmark.bm do |x|
  x.report { lookup = PolymorphicSlugLookup.new('bathrooms'); lookup.ids  }
end
{% endhighlight %}

with about 100 terms preloaded in memory:

{% highlight bash %}
$ ruby benchmark.rb
user     system      total        real
0.000000   0.000000   0.000000 (  0.002699)
{% endhighlight %}

with about 1000 terms:

{% highlight bash %}
$ ruby benchmark.rb
user     system      total        real
0.010000   0.010000   0.020000 (  0.014530)
{% endhighlight %}

with now over 10000 terms the lookup is now taking a significant 150ms:

{% highlight bash %}
$ ruby benchmark.rb
user     system      total        real
0.140000   0.010000   0.150000 (  0.149572)
{% endhighlight %}

I haven't tested this with any caching but assuming you find a suitable expiration policy you could HTTP cache those URLs.

I committed this sample app on [https://github.com/agenteo/lab-search-engine-friendly-urls](https://github.com/agenteo/lab-search-engine-friendly-urls).

## Conclusion

My inital gut feeling was this URL requirement was odd and not in touch with reality. I later realized I was wrong, and how having a mutating or polymorphic segment is indeed pretty natural.

This will help us apply our SEO requirements, I am curious if you've seen zillow search engine friendly/polymorphic like filters anywhere else.

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


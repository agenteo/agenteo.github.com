---
layout: post
title: Ruby on Rails filter pages using search engine psycotic URLs
comments: true
tags:
  - work
  - ruby
  - SEO
---

We're all familiar with search engine friendly URLs ie. a filter on 'Mid range' would be hyphenated to `/mid-range`.

**TL;DR you can have crazy slugs with multiple terms all hypenated by draining out every term in your taxonomy from the slug.**


When asked to handle multiple terms I'd usually suggest a comma separator or adding a new segment for example: `/mid-range_contemporary` or `/mid-range/contemporary`.

Recently I was told that's not good for SEO, I was told we should handle `/mid-range-contemporary`, also `/mid-range-contemporary-gray-decks` extract our terms and filter accordingly.

All these examples are from a real web site called zillow.com (that my SEO team used as an example). Having seen it was possible I started this spike, on what I determined was not to be called search engine friendly (SEF) URL anymore but search engine psycotic (SEP) URL.

>>> Psychosis
>>>
>>> Psychosis is a loss of contact with reality that usually includes: False beliefs about what is taking place or who one is (delusions) ; Seeing or hearing things that aren't there (hallucinations).
>>> -- <cite>Google</cite>

Yep. I felt those requirement for slugs lost contact with reality.

But here's reality knocking at my door: zillow tag system changing their urls exactly per my SEO team request.

![Zillow example](/assets/images/zillow_example.gif)

After seeing it happening before my eyes I had to find a way to do it.

So I started from the route will just receive the psycotic slug:

{% highlight ruby %}
get '/digs/:psycotic_slug' => 'psycotic#index'
{% endhighlight %}

and hand it over to the controller action that would delegate the lookup:

{% highlight ruby %}
lookup = PsycoticLookup.new(params[:psycotic_slug])
terms = []
dictionary = Dictionary.new
lookup.ids.each do |id|
  terms << dictionary.term(id)
end
flash[:notice] = "You searched for : #{terms.join(' ')}"
{% endhighlight %}

The PsycoticLookup class is where given the slug, I gather every term from the slug until is empty.

{% highlight ruby %}
class PsycoticLookup

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

Assuming the lookup returns ids ordered according to your SEO value, you could redirect if the original slug doesn't match. A solution is to have a `PsycoticRedirect` that given the result of a lookup, would compare it with the requested slug. 

{% highlight ruby %}
lookup = PsycoticLookup.new(params[:psycotic_slug])
redirect = PsycoticRedirect.new(params[:psycotic_slug], lookup.ids)
if redirect.execute?
 redirect_to "/digs/#{redirect.destination}"
end
# render search response...
{% endhighlight %}

## How slow is this?

Well, I've benchmarked the look up:

{% highlight ruby %}
Benchmark.bm do |x|
  x.report { lookup = PsycoticLookup.new('bathrooms'); lookup.ids  }
end
{% endhighlight %}

with about 100 terms:

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

with now over 10000 terms the lookup is taking too much:

{% highlight bash %}
$ ruby benchmark.rb
user     system      total        real
0.140000   0.010000   0.150000 (  0.149572)
{% endhighlight %}

I commited this sample app on [https://github.com/agenteo/lab-search-engine-friendly-urls](https://github.com/agenteo/lab-search-engine-friendly-urls).

## Conclusion

This might apply for our current scenario I am curious if you've seen zillow search engine friendly/psycotic like filters anywhere else and is there a better name for them? :)

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


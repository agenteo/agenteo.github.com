---
layout: post
title: Ruby on Rails filter pages using search engine psycotic URLs
comments: true
tags:
  - work
  - ruby
  - SEO
---

# {{page.title}}

We're all familiar with search engine friendly URLs.

**TL;DR you can have crazy slugs with multiple terms all hypenated by draining out every term in your taxonomy from the slug.**

For example 'Mid range' would be hyphenated to 'mid-range'.

When asked to handle multiple terms I'd usually suggest a comma separator or adding a new segment for example: `mid-range,contemporary` or `mid-range/contemporary`.

Recently I was told that's not good for SEO, I a bit surprised by that but not so much by the comma but from the extra segment. Apparently you'd have to provide pages with relevant content on `mid-range` which is not always applicable.

I was told we should handle `mid-range-contemporary`, also `mid-range-contemporary-gray-decks` extract our terms and filter accordingly.

All these examples are from a realweb site called zillow.com that my SEO team used as an example. Having seen it was possible I started this spike, on what I determined was not a search engine friendly URL anymore but a search engine psycotic URL.


>>> Psychosis
>>>
>>> Psychosis is a loss of contact with reality that usually includes: False beliefs about what is taking place or who one is (delusions) ; Seeing or hearing things that aren't there (hallucinations).
> -- <cite>Google</cite>

![Zillow example](/assets/images/zillow_example.gif)

After looking at zillow, I couldn't find any library or protocol relevant to achieve this.

So I created a Rails application, digged in the [advanced constraints](http://guides.rubyonrails.org/routing.html#advanced-constraints) which I realized wouldn't help much in this.

The route will just receive the psycotic slug:

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

Having ordered terms is critical in order to avoid shorter terms being a partial match.

In fact one constraint of this system is if we have two terms 'fire' and 'fireplace' then the longer will take precedence.

## Resource uniqueness

You don't want to have two URLs serving the same resource ie. `mid-range-contemporary-gray-decks` and `gray-mid-range-contemporary-decks`. You could try to prevent this from your UI but users could type or start linking content to it.

Assuming the lookup returns ids ordered according to your SEO value, you could redirect if the original slug doesn't match. A solution is to have a `PsycoticRedirect` that given the result of a lookup, would compare it with the requested slug. 

{% highlight ruby %}
lookup = PsycoticLookup.new(params[:psycotic_slug])
redirect = PsycoticRedirect.new(params[:psycotic_slug], lookup.ids)
if redirect.execute?
 redirect_to "/digs/#{redirect.destination}"
end
# render search response...
{% endhighlight %}

## Conclusion
Nothing is impossible. I am curious if you've seen zillow like searches before and if there is already a pattern describing them.

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


---
layout: post
title: Ignore query strings in Ruby on Rails caching with rack-cache
comments: true
tags:
  - work
  - ruby
  - ruby-on-rails
  - caching
---

{{ post.title }}

This short post assumed you are familiar with what HTTP caching is and what rack-cache does. If not read [this](http://tomayko.com/writings/things-caches-do).

I am using rack-cache 1.2 inside a Ruby on Rails 4.1 application, its default behaviour treats every URL including the query string as a separate fragment in the meta store.

That means `http://example.com/content/piece` and `http://example.com/content/piece?utm_campaign=12345` will be cached as separate entries in the rack-cache meta store but reference the same reponse from the entity store (assuming they rendered the same markup). When you purge `/piece` its query stringed version `/piece?utm_campaign=12345` will still exist in the cache and serve the stale content.

Our app triggers that cache purge when published content is updated or unpublished (we do that hitting the content URL with an HTTP DELETE). It would be impractical to purge query stringed URLs so we customized rack-cache to store fragments using only query strings we care about, for example a pagination value `page`.

In your Ruby on Rails `production.rb` (or where you initialize rack-cache if you are on another rack framework) you need to specify `rack-cache.cache_key` to a class responsible for the cache key creation:

{% highlight ruby %}
  config.action_dispatch.rack_cache = {
    :metastore => client,
    :verbose => true,
    'rack-cache.cache_key' => AppHttpCacheKey,
    :entitystore  => client
  }
{% endhighlight %}

Technically you can do that in a `lambda` but I prefer delegating the fragment creation to a class.

Our `AppHttpCacheKey` is inheriting from [https://github.com/rtomayko/rack-cache/blob/master/lib/rack/cache/key.rb](https://github.com/rtomayko/rack-cache/blob/master/lib/rack/cache/key.rb) overriding the `query_string` private method.

Here's the original code:

{% highlight ruby %}
def query_string
  return nil if @request.query_string.nil?

  @request.query_string.split(/[&;] */n).
    map { |p| unescape(p).split('=', 2) }.
    sort.
    map { |k,v| "#{escape(k)}=#{escape(v)}" }.
    join('&')
end
{% endhighlight %}

I found it hard to understand what was going on so in my code you will see some refactoring as well as adding the functionality for query string filter:

{% highlight ruby %}
require 'rack/cache/key'

class AppHttpCacheKey < Rack::Cache::Key

  ASCII_8BIT_QUERY_STRING_SEPARATOR_REGEXP = /[&;] */n
  VALID_QUERY_STRINGS_KEYS = ['page', 'search']
  private_constant :ASCII_8BIT_QUERY_STRING_SEPARATOR_REGEXP
  private_constant :VALID_QUERY_STRINGS_KEYS

  private

    # We only consider some query strings for fragment creation.
    # Build a normalized query string by alphabetizing all keys/values
    # and applying consistent escaping.
    def query_string
      return nil if @request.query_string.nil?

      sorted_query_string_elements.map do |query_string_key, query_string_value|
        escape(query_string_key) + '=' + escape(query_string_value) if keep?(query_string_key)
      end.join('&')
    end

    def keep?(query_string_key)
      VALID_QUERY_STRINGS_KEYS.include?( escape(query_string_key) )
    end

    def sorted_query_string_elements
      unescaped_sortable_query_string_elements.sort
    end

    # The split returns an array from the key value hash. I think this
    # was done to facilitate the sorting.
    #
    # @returns Array of arrays
    def unescaped_sortable_query_string_elements
      query_string_elements.map do |query_string_element|
        unescape(query_string_element).split('=', 2)
      end
    end

    def query_string_elements
      @request.query_string.split(ASCII_8BIT_QUERY_STRING_SEPARATOR_REGEXP)
    end

end
{% endhighlight %}

The bit I added is `if keep?(query_string_key)`.

## Conclusion

Overriding the cache key is not documented on the rack-cache site, it increases the potential of rack-cache and it's pretty easy to customize. I hope this post will help people dealing with this problem.

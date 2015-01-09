---
layout: post
title: Ignore query strings defining a custom HTTP rack cache key
comments: true
tags:
  - work
  - ruby
  - caching
---

{{ post.title }}

This short post assumed you are familiar with what HTTP caching is.

I am using rack-cache to do that from inside my Ruby on Rails application. By default that means every URL is cached as a separate fragment in the meta store.

That means `http://example.com/content/piece` and `http://example.com/content/piece?utm_campaign=12345` will be cached as separate pages. Both fragments will respect the TTL set in your application. The issue arises when you want to forcibly expire those resources.

We can customize rack-cache to store fragments using only some query strings, for example a pagination value `page`.

In your `production.rb` you need to specify `rack-cache.cache_key` to the class responsible for the cache key creation:

{% highlight ruby %}
  config.action_dispatch.rack_cache = {
    :metastore => client,
    :verbose => true,
    'rack-cache.cache_key' => YourAppHttpCacheKey,
    :entitystore  => client
  }
{% endhighlight %}

The rules are based on your application logic, here's what worked for me:

This is inheriting from https://github.com/rtomayko/rack-cache/blob/master/lib/rack/cache/key.rb customizing (and improving the readability) of the `query_string` method.


{% highlight ruby %}
require 'rack/cache/key'

class WedditHttpCacheKey < Rack::Cache::Key

  ASCII_8BIT_QUERY_STRING_SEPARATOR_REGEXP = /[&;] */n
  VALID_QUERY_STRINGS_KEYS = ['page', 'terms']
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

---
layout: post
title: Best practices releasing semantic versioned (Ruby) libraries
comments: true
tags:
  - ruby
  - process
#image: /assets/article_images/best-practices-releasing-semantic-versioned-ruby-libraries/hero.jpg
---


When releasing a library you are defining a contract with your clients -- they could be colleagues in other teams, paying subscribers or the general public but if you break the contract you will loose their trust.

After building libraries for multiple teams and consuming libraries from others I came up with a list of best practices to handle errors, deprecations and releasing.

Let's say to facilitate access to a server API we create a library wrapping its endpoints, for example:

{% highlight ruby %}
# library_facade.rb
def term(id)
  response = connection.get("/term/#{id}.json")
  JSON.parse(response.body)
end
{% endhighlight %}

## Gracefully handling errors

Parsing and returning a raw API response can't provide default results when the API is unreachable -- using a data structure wrapping the response allows to instantiate objects or fallbacks when needed. Here's how it looks:

{% highlight ruby %}
# library_facade.rb
def term(id)
  response = connection.get("/term/#{id}.json")
  LibraryNamespace::Term.new( JSON.parse(response.body) )
end
{% endhighlight %}

The library instantiates a `Term` class with the API response and returns it to the client -- the advantage over the arbitrary JSON hash is we now control what the client receives and we can add or deprecate fields when the API changes as well as create a fallback object when it's unreachable.

[Circuit breaker](http://martinfowler.com/bliki/CircuitBreaker.html) is a pattern to detect failures and encapsulates retry logic. Have the library use it to manage API availability and return a fallback object when needed.


{% highlight ruby %}
# library_facade.rb
def term(id)
  response = circuit_breaker("/term/#{id}.json").response
  if response
    return LibraryNamespace::Term.new( JSON.parse(response.body) )
  end
  LibraryNamespace::FallbackTerm.new
end
{% endhighlight %}

This gracefully handles errors by providing your clients with objects with the same interface for an error and a success response. Imagine an article with a term id using the API library to retrieve more term information -- when the library returns a `FallbackTerm` the article page can hide the term information or just display its fallback fields knowing they are the same as `Term`. The fallback fields could be empty or a default set of values to display -- the library has control on what the client receives.

## Handling deprecations

When an API updates its response formats the library will break instantiating objects from an outdated data structure. This is good, **this is the role of a library wrapping an API** -- catching errors instead of its clients and concerning about the server API internals. The next step is to release a major [version](http://semver.org/) to inform your clients of the backward incompatible change.

If you control the API have a versioned endpoint or a request header to prevent introducing breaking changes without a deprecation phase.

Here's an example of the library deprecating an incoming major API change renaming `seo_slug_plural` to `seo_slug`:

{% highlight ruby %}
# version 0.15
{
    "id"=>"d15cf067-c4b1-4820-a837-59444208cac5",
    "name"=>"BBQ",
    "seo_slug_plural"=>"bbq-foods",
    "description"=>"(cuisine)\r\nMeat that is smoked, grilled, cooked \"low and slow.\" BBQ styles change regionally and are cause for great debate.",
    "created_at"=>"2014-06-20T20:31:25.466Z",
    "updated_at"=>"2014-08-04T20:00:53.191Z"
}
# version 1.0
{
    "id"=>"d15cf067-c4b1-4820-a837-59444208cac5",
    "name"=>"BBQ",
    "seo_slug"=>"bbq-foods",
    "description"=>"(cuisine)\r\nMeat that is smoked, grilled, cooked \"low and slow.\" BBQ styles change regionally and are cause for great debate.",
    "created_at"=>"2014-06-20T20:31:25.466Z",
    "updated_at"=>"2014-08-04T20:00:53.191Z"
}
{% endhighlight %}

This would introduce a breaking change to your client using `seo_slug_plural` and a data structure can help defining a method like:

{% highlight ruby %}
# term.rb
def seo_slug_plural
  puts 'DEPRECATION WARNING: using seo_slug_plural has been deprecated switch to seo_slug'
  seo_slug
end

def seo_slug
  response['seo_slug'] || response['seo_slug_plural']
end
{% endhighlight %}

this change would go out in a minor version -- the major release after that will remove the `seo_slug_plural` method.

When you release libraries you need an architecture that facilitate deprecation and changes -- returning base classes like an Array or Hash prevents that. Once the library has a method returning:

{% highlight ruby %}
{ "published": true, "url": "/best-practices" }
{% endhighlight %}

switching from `url` to `path` can't be deprecated effectively and your clients will have to search and replace the change in their code.


## Release process

The release process should be as automated as possible to prevent human error -- you don't want to publish a library with the wrong version or forgetting to create and push the tag to your centralized version control. **A ruby gem has a default build task, create a release task on top of it to simplify the release work**:

{% highlight ruby %}
namespace :your_company_namespace do
  namespace :your_library do
    desc "Adds tag, builds the gem and pushes it to gem server"
    task :release => :build do
      system "git tag -a v#{YourCompany::YourLibrary::VERSION} -m 'Tagging #{YourCompany::YourLibrary::VERSION}'"
      system "git push --tags"
      system "fury push pkg/your-gem-#{YourCompany::YourLibrary::VERSION}.gem --as COMPANY"
    end
  end
end
{% endhighlight %}

**Never delete a published library version thinking nobody used it yet**, as soon as you release assume somebody is using it! If you need to make changes be mindful and release a new version.


Documenting the process and keeping it updated is another critical step -- link the process steps from the project README. Here's a release steps example:

* make sure the VERSION in `lib/your_company/your_library/version.rb` has been correctly updated
* ensure the `CHANGELOG.md` reflect all the changes in this release
* ensure the automated test are passing `./test.sh`
* commit your changes to master
* push master to origin `git push origin master`
* run `rake your_company:your_library:release`

As you deliver features make sure they are documented with code examples -- I use [yard](http://yardoc.org/) to document code and publish the generated files to the project github page.

Informing your clients about the release is very important -- define the best channels to reach your audience and send out a release note pointing to the CHANGELOG for the current version.

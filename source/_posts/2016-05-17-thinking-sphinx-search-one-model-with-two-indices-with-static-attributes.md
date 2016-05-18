---
layout: post
title: Thinking Sphinx search one model with two indices with static attributes
comments: true
tags:
  - ruby
  - rails
  - search
image: /assets/article_images/thinking-sphinx-search-one-model-with-two-indices-with-static-attributes/hero.jpg
---

In this short article I describe how to use Sphinx and Thinking Sphinx (v3) in a Ruby on Rails application to index the same ActiveRecord model with separate criterias using two indices.

**This article is not an intruduction on the open source search engine [Sphinx](http://sphinxsearch.com/) and its Ruby library [ThinkingSphinx](http://freelancing-gods.com/thinking-sphinx/) but rather how to solve a problem I faced multiple times and not very well documented online.**

**I will use a simplified example adapted from a real life application.** A company has a web portal where users can view product representatives details. The company has a mangement console where admins can update the product representatives information. Both need to search the representatives data stored in a relational database table--and loaded in a Contact ActiveRecord object--but with different criterias.

![]({{ site.url }}/assets/article_images{{ page.url }}diagram.jpg)

To make this example manageable I am defining only one criteria different between admin and user search: **A user can't see a contact that isn't active but an admin can**. You already know real life applications aren't that simple--in real life there are likely a multitude of criterias different between admin and user search and this solution works there.

{% highlight ruby %}
# /app/indices/contact_index.rb
ThinkingSphinx::Index.define :contact, :with => :active_record do
  indexes :first_name
  indexes :last_name
  indexes :phone_number

  where "active = true" # simplified condition to make the example manageable
  has "false", as: :user_view_only, type: :boolean
end
{% endhighlight %}

{% highlight ruby %}
# /app/indices/admin_contact_index.rb
ThinkingSphinx::Index.define :contact, :name => 'admin_contact', :with => :active_record do
  indexes :first_name
  indexes :last_name

  has "true", as: :admin_view_only, type: :boolean
end
{% endhighlight %}

The *admin_contact* is a separate index used for admin search only but by default searching on `Contact.search` or doing an application wide search via `ThinkingSphinx.search` would use both the `admin_contact_index.rb` and `admin_contact.rb` indexes--that is why I leverage the **admin_view_only** static attribute to ignore the user view index. For example:

{% highlight ruby %}
Contact.create!(first_name: 'Enrico', last_name: 'Teotti', active: false)
Contact.create!(first_name: 'Enrico', last_name: 'Piovani', active: true)

# reindex Sphinx on console with rake ts:index
ThinkingSphinx.search('Enrico', with: { admin_view_only: true })
# returns Contact entries for admin only, ignoring the filter on active flag
# set on regular index. Given the above data you will get both Piovani and
# Teotti back.
 
ThinkingSphinx.search('Enrico', with: { user_view_only: true })
# Only Piovani will come back because of the active filter.
{% endhighlight %}

## Conclusions

I think one disadvantage of this solution is to add an attribute to all non admin indexes to ensure they don't conflict and also a second index increasing file size and potentially indexing time.

The advantage is delegating to Sphinx the search rather then having specific search parameters set on search calls for each application portion--also this strategy can be shared by the other indices that need different search criteria between user view and admin.

The described condition alone doesn't justify the use of Sphinx or this strategy but in a real evolving application that is rarely the only condition that search runs on--this static attribute strategy has been a good fit when implementing search segregation.

---
layout: post
title: Create mainainable mongodb queries in Ruby with mongoid criterias
comments: true
tags:
  - work
  - ruby
  - mongodb
---

### Classical approach

Building a result set quering documents mongoid is straight forward. The project documentation has an example:

{% highlight ruby %}
Article.
  where(status: "published", legacy: true, title: /#{keyword}/)
{% endhighlight %}

You can create criterias inside the `Article` class to promote reusability, ie.

{% highlight ruby %}

# article.rb
def self.published
  where(status: 'published')
end

def self.imported_from_legacy
  where(legacy: true)
end

# refactored query
Article.imported_from_legacy.published.where(title: /#{keyword}/)
{% endhighlight %}

In a growing application the query conditions are likely to increase in number and complexity and probably need to be programmatically turned on or off based on user input. Following the approach above will quickly become complex and unmanageable.

{% highlight ruby %}
if filter[:published] = 'published'
  criteria = Article.published
elsif filter[:published] = 'unpublished'
  criteria = Article.unpublished
else
  criteria = Mongoid::Criteria.new(Article)
end
criteria.imported_from_legacy.where(title: /#{keyword}/)
{% endhighlight %}

That code orchestrating the filter becomes a transactional script, regardless if it lives in a Ruby on Rails controller private method or inside a Mongoid Document or even in a separate plain Ruby object.

This is a simplified example, in reality the keyword would need to match not only the title but also the article tags. But we only store the tags ids in the database, so we need to contact the tags API to translate the keyword to id. Moreover the open field keyword search could be on tags only and ignore titles.

Understanding a transactional script limits is key in order to know when to stop using it.

## Transactional script limits

In my experience increasing the number of filters and applying more checks makes the transactional script code hard to understand and extending the code becomes daunting. Test driving becomes cumbersome, you tend to have one gigantic integration test with a setup populating all the possible combinations. I've seen this approach generating knowledge silos where only one guy (kinda) knows what's going on. 

## Another approach

What I've been doing in the last couple of years (first with Active Record now with Mongoid) is breaking up the criterias in separate objects unit tested in isolation and having a query object orchestrating the filters. In web apps I place a high level integration test to ensure the user interface returns the expected results.

The query is broken up in to criteria objects, and the query object is concatenating them.

Let's start from the query object:

{% highlight ruby %}
describe ContentFilter do

  describe ".apply" do
    let(:criteria) { Mongoid::Criteria.new(Article) }
    it "should rely on keyword, published state, legacy criteria and article type" do
      expect_any_instance_of(Criteria::KeywordFilter).to receive(:value).and_return(criteria)
      expect_any_instance_of(Criteria::PublishedStateFilter).to receive(:value).and_return(criteria)
      expect_any_instance_of(Criteria::LegacyLinkFilter).to receive(:value).and_return(criteria)
      expect_any_instance_of(Criteria::PieceTypeFilter).to receive(:value).and_return(criteria)

      filter = ContentFilter.new({ irrelevant: 'to this test' })
      filter.apply
    end
  end

end
{% endhighlight %}

The test ensure that the correct attribute is passed from the query object (ContentFilter) to each criteria.

And here's the code for it:

{% highlight ruby %}
class ContentFilter

  def initialize(filter_parameters)
    @filter_parameters = filter_parameters || {}
  end

  # Generate a filter on keyword and published state.
  # @return [Mongoid::Criteria]
  def apply
    keyword_criteria.merge(legacy_link_criteria).merge(piece_type_criteria).merge(published_state_criteria)
  end


  private

    def keyword_criteria
      criteria = Criteria::KeywordFilter.new(@filter_parameters[:keyword])
      criteria.value
    end

    def published_state_criteria
      criteria = Criteria::PublishedStateFilter.new(@filter_parameters[:published])
      criteria.value
    end

    def legacy_link_criteria
      criteria = Criteria::LegacyLinkFilter.new(@filter_parameters[:legacy_links])
      criteria.value
    end

    def piece_type_criteria
      criteria = Criteria::PieceTypeFilter.new(@filter_parameters[:piece_type])
      criteria.value
    end
end
{% endhighlight %}

The logic of the query is broken in small easy to understand parts. 

The keyword has to work in two scenarios: a tag specific filter ie. "tag:'black friday'" or "tag:'superbowl'" (to find any article tagged like that) as well as: "black" to find articles with titles and tags "black". That logic will live inside the Criteria::KeywordFilter.

Now we start building the keyword criteria:

{% highlight ruby %}
it 'should generate a criteria' do
  criteria = Criteria::KeywordFilter.new(keyword)
  expect(criteria.value).to be_kind_of(Mongoid::Criteria)
end
{% endhighlight %}

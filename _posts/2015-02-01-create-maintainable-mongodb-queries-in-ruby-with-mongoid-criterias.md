---
layout: post
title: Create mainainable mongodb queries in Ruby with mongoid criterias
comments: true
tags:
  - work
  - ruby
  - mongodb
---

Building a mongodb query in mongoid is straight forward here's an example from the project documentation:

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

In a growing application the query conditions are likely to increase in number and complexity and probably need to be programmatically turned on or off based on some user input. Following the approach above:

{% highlight ruby %}
if filter[:published] = 'published'
  criteria = Article.published
elsif filter[:published] = 'unpublished'
  criteria = Article.unpublished
else
  criteria = Article.all
end
criteria.imported_from_legacy.where(title: /#{keyword}/)
{% endhighlight %}

That code deciding which filter to apply becomes a transactional script, regardless if it lives in a Ruby on Rails controller private method or in a Mongoid Document or in a separate plain Ruby object.


This is a simplified example, let's extend that with some features taken from a real application.The keyword would need to match not only the title but also the article tags. Since we only store the tags ids in the database we need to contact the tags API to translate the keyword to id. The keyword search could be on tags only and ignore titles.

Understanding a transactional script limits is key in order to know when to stop using it.

In my experience increasing the number of filters and applying more checks makes its code hard to understand and to extend. Test driving becomes cumbersome, you tend to have one long integration test with a setup populating all the possible combinations. I've seen this approach fostering a knowledge silos where there is only one guy who approximately knows what's going on. 

## Another approach

What I've been doing with dealing with larger queries in the last couple of years is breaking up the criterias in separate objects unit tested in isolation and having a query object orchestrating the filters. This approach would work with ActiveRecord but I am using Mongoid.

The query is broken up in to criteria objects, and the query object responsibility is just merging them.

When TDD this you'd have a high level integration test testing the first criteria you're adding, then add tests for the first criteria on ContentFilter, then build that criteria's test.

To save space and reader's time I added a few criterias in one go:

{% highlight ruby %}
describe ContentFilter do

    describe ".apply" do
      let(:criteria) { Mongoid::Criteria.new(Article) }
      let(:keywords) { double }
      let(:published) { double }
      let(:legacy_links) { double }
      let(:piece_type) { double }
      let(:filters) { { keyword: keywords, published: published,
                        legacy_links: legacy_links, piece_type: piece_type } }

      before do
        allow(Criteria::KeywordFilter).to receive(:new).and_return( double(value: criteria) )
        allow(Criteria::PublishedStateFilter).to receive(:new).and_return( double(value: criteria) )
        allow(Criteria::LegacyLinkFilter).to receive(:new).and_return( double(value: criteria) )
        allow(Criteria::PieceTypeFilter).to receive(:new).and_return( double(value: criteria) )
      end

      it "should trigger keyword criteria" do
        keyword_filter = double('KeywordFilter', value: criteria)
        expect(Criteria::KeywordFilter).to receive(:new).with(keywords).and_return(keyword_filter)

        filter = ContentFilter.new(filters)
        filter.apply
      end

      it "should trigger published state criteria" do
        published_filter = double('PublishedStateFilter', value: criteria)
        expect(Criteria::PublishedStateFilter).to receive(:new).with(published).and_return(published_filter)

        filter = ContentFilter.new(filters)
        filter.apply
      end

      it "should trigger legacy link criteria" do
        legacy_links_filter = double('LegacyLinkFilter', value: criteria)
        expect(Criteria::LegacyLinkFilter).to receive(:new).with(legacy_links).and_return(legacy_links_filter)

        filter = ContentFilter.new(filters)
        filter.apply
      end

      it "should trigger piece type criteria" do
        piece_type_filter = double('PieceTypeFilter', value: criteria)
        expect(Criteria::PieceTypeFilter).to receive(:new).with(piece_type).and_return(piece_type_filter)

        filter = ContentFilter.new(filters)
        filter.apply
      end
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

The keyword filter has to work in two scenarios: a tag specific filter ie. `"tag:'black friday'"` or `"tag:'superbowl'"` (to find any article tagged like that) as well as: "black" to find articles titled and tagged "black". That logic will live inside the `Criteria::KeywordFilter`.

Now we start building the keyword criteria:

{% highlight ruby %}

describe Criteria::KeywordFilter do

  context "with a keyword filter" do
    let(:keyword) { 'music' }
    let(:music) { "ed723f60-afce-11e4-ab7d-12e3f512a338"  }
    let(:ceremony_music) { "ed7241f4-afce-11e4-ab7d-12e3f512a338" }
    before do
      expect_any_instance_of(TermsApi::Searcher).to receive(:match).with(keyword).and_return([music, ceremony_music])
    end

    it 'should generate a criteria' do
      criteria = Criteria::KeywordFilter.new(keyword)
      expect(criteria.value).to be_kind_of(Mongoid::Criteria)
    end

    it 'should match headline and tags' do
      expect(Article).to receive(:or).with( [{ term_ids: { "$in" => [music, ceremony_music] } },
                                             { headline: /#{keyword}/i },
                                            ])

      criteria = Criteria::KeywordFilter.new(keyword)
      criteria.value
    end
  end


  context "with an exact keyword filter on tag" do
    let(:tag) { "Music Ceremony" }
    let(:keyword) { %Q{tag:'#{tag}'} }
    let(:music) { "ed723f60-afce-11e4-ab7d-12e3f512a338"  }
    let(:ceremony_music) { "ed7241f4-afce-11e4-ab7d-12e3f512a338" }
    before do
      expect_any_instance_of(TermsApi::Searcher).to receive(:match_exactly).with(tag).and_return([music])
    end

    it 'should match only for the exact tag' do
      expect(Article).to receive(:in).with(term_ids: [music])

      criteria = Criteria::KeywordFilter.new(keyword)
      criteria.value
    end
  end

end
{% endhighlight %}

Our unit test is ensuring that based on keyword filters the correct mongoid API are made. I once again pasted the entire spec but while TDD-ing you'd add one example at the time. Based on how critical the feature is you might start from more then one integration feature test.

And here's the code:

{% highlight ruby %}
module Criteria

  class KeywordFilter

    # Generate a filter on keyword matching headline, term or exact term.
    def initialize(keyword)
      @keyword = keyword
    end

    # @return [Mongoid::Criteria]
    def value
      if filtering_by_exact_term?
        Article.in( term_ids: find_descendants_of_term_ids )
      elsif filtering_by_keyword?
        Article.or(matching_headline_or_terms)
      else 
        Article.all
      end
    end


    private
      
      def filtering_by_exact_term?
        filtering_by_keyword? &&
        @keyword.match(/^tag:'.+'$/)
      end
      
      def find_descendants_of_term_ids
        terms_descendants = TermsApi::TermsDescendants.new(exact_term_to_ids)
        terms_descendants.compose
      end
      
      def exact_term_to_ids
        searcher = TermsApi::Searcher.new
        searcher.match_exactly(extract_exact_term_from_keyword)
      end
      
      def extract_exact_term_from_keyword
        @keyword.match(/tag:'(.+)'/)
        $1
      end
      
      def filtering_by_keyword?
        @keyword.present?
      end
      
      def matching_headline_or_terms
        [ { term_ids: { "$in" => find_term_descendants_for_keyword_or_term } },
          { headline: /#{@keyword}/i } ]
      end

      def find_term_descendants_for_keyword_or_term
        terms_descendants = TermsApi::TermsDescendants.new(term_to_ids)
        terms_descendants.compose
      end

      def term_to_ids
        searcher = TermsApi::Searcher.new
        searcher.match(@keyword)
      end

  end
end
{% endhighlight %}

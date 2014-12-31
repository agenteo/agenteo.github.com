---
layout: post
title: Ruby on Rails intention revealing helpers
comments: true
tags:
  - work
  - rails
  - ruby
---

{{post.title}}

When I am working on a Ruby on Rails application views and I see more Ruby code then markup I move that logic in to a helper.

If the helper needs to output markup you should avoid using a blob of text perhaps interpolated with variables with the results of your logic.

For example:

{% highlight ruby %}
module PublicUi
  module HeroImageTagHelper

    def hero_image_tag(content_piece, index)
      loader = '<div class="tk-loader"><div class="tk-loader-animation"></div><span class="icon icon-general-k-logo"></span></div>'

      if content_piece.has_primary_image?
        if index == 0
          image = image_tag "#{content_piece.primary_image_url}~rs_768.576.fit"
        else
          image =  image_tag "", :'data-original-image' =>  "#{content_piece.primary_image_url}~rs_768.576.fit"
        end
        return %Q{<div class="panel-image-holder tk-loader-placeholder">#{loader}#{image}</div>}.html_safe
      end

    end

  end
end
{% endhighlight %}

Code smells:

* you should pick better variable names than `index`. This is actually the `row number` where the passed piece is located.
* it's not very clear what happens when the index/row number is zero as opposed to the other cases. For the first row we display the actual images, for the following rows we display a placeholder.
* that there are a few blobs of text interpolating variables, determining markup changes in a git diff would not be fun. We want to move that to the view layer.

## But first of all

We want to write an automated test to ensure our assumptions are correct.

{% highlight ruby %}
require 'rails_helper'

module PublicUi

  describe HeroImageTagHelper do

    describe "hero_image_tag_helper(content_piece, row_number)" do
      let(:markup) { helper.hero_image_tag(content_piece, row_number) }

      context "with a piece without primary image" do
        # it should never be called
      end

      context "with a piece with primary image" do
        let(:image_url) { 'http://example.com/image/12345' }
        let(:content_piece) { double('ContentPiece', primary_image_url: image_url) }

        context "when in the first row" do
          let(:row_number) { 0 }
          it "should populate the image source" do
            expect(markup).to match(%Q{src="#{image_url}})
          end
        end

        context "when in the second (and following) row" do
          let(:row_number) { 1 }
          it "should not populate the image source" do
            expect(markup).to_not match(%Q{src="#{image_url}})
          end

          it "should render a placeholder" do
            expect(markup).to match(%Q{data-original-image="#{image_url}})
          end
        end

      end

    end

  end

end
{% endhighlight %}

By writing the test you might actually find out that some of the code is redundant, perhaps left there from a previous implementation and never removed. In our case that was the check for image presence, now taken care at a higher lever meaning this helper is only called for pieces with images.

All the tests will be green, unfortunately this is the downside of retrofitting tests to already implemented code. You might find useful to break the implemented code on purpose to see a red coming up and ensure you are not seeing false positives.

## Move markup where it belongs

In a partial view `public_ui/content_pieces/index/cards/_image.html.erb`.

{% highlight html %}
<div class="panel-image-holder tk-loader-placeholder">
  <div class="tk-loader">
    <div class="tk-loader-animation"></div>
    <span class="icon icon-general-k-logo"></span>
  </div>
  <%= image_markup %>
</div>
{% endhighlight %}

Now we will render this partial from our helper passing an `image_markup` local variable. Ignore `HeroImageTag` for now:

{% highlight ruby %}
module PublicUi
  module HeroImageTagHelper

    def hero_image_tag(content_piece, row_number)
      tag = HeroImageTag.new(content_piece, row_number)
      render(partial: 'public_ui/content_pieces/index/cards/image',
             locals: { image_markup: tag.markup } )
    end
  end
end
{% endhighlight %}

## Surface the logic using good old object oriented programming

This this a plain old Ruby object with one task. You need to use `ActionController::Base.helpers.image_tag` to access the `image_tag` helper.

{% highlight ruby %}
class HeroImageTag

  def initialize(content_piece, row_number)
    @content_piece = content_piece
    @row_number = row_number
  end

  def markup
    if visible_row?
      return actual_image
    end
    placeholder_image
  end

  private

    def visible_row?
      @row_number == 0
    end

    def actual_image
      ActionController::Base.helpers.image_tag(image_url)
    end

    def placeholder_image
      ActionController::Base.helpers.image_tag("", :'data-original-image' => image_url)
    end

    def image_url
      "#{@content_piece.primary_image_url}~rs_768.576.fit"
    end

end
{% endhighlight %}

You could try to achieve the same result by passing around instance variables in your helper module but that is not setting a clear boundary like the class does.

I usually leave the class inside the helper module.


## Conclusion

This feature has an integration test to ensure the images after the first row are loaded appropriately but that goes beyond the purpose of this article.

Helpers tend to become the kitchen sink of your app. Very long, with private methods sharing existing instance variables and setting new one. Lots of hidden logic and multi line strings with markup.

Intention revealing is the way to go, it will lead to maintainable code and you should value that. 

I am curious to see if you've used this approach before and where you're keeping your helper classes.

If you're not sold I'd like to hear what's keeping you from refactoring your helpers.

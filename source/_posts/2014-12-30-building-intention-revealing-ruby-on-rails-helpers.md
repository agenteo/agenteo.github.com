---
layout: post
title: Building intention revealing Ruby on Rails helpers
comments: true
tags:
  - work
  - ruby-on-rails
  - ruby
  - maintainability
---

{{post.title}}

{% highlight javascript %}
{
  "ruby": "2.1",
  "rails": "4.1",
  "os": "OSX 10.10"
}
{% endhighlight %}

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

## Alternatives

Intention revealing helpers is not a substitute for presenters or decorators; it complements them.

### Presenters

I don't think The hero_image_tag example I gave above would fit well in a presenter. You would still have to pass a current_row from the view to the hero_image_tag and then still render view partials to avoid keeping markup in the presenter class. It will add to the presenter 4 private methods specific to the hero image tag.

Where do you draw the boundary of a presenter? At what point do you stop adding features to it?

I think the presenters are appropriate when extending a model with simple view related properties ie:

{% highlight ruby %}
# article.rb

def page_title
"My example website #{title}"
end
{% endhighlight %}

If there is no logic there is no intention and you won't need intention revealing helpers :)

Another example where this technique helped clarifying the intent of the code is a link to a dynamic filter page controlled by query string params.

### Cells

[Cells](https://github.com/apotonick/cells) is a solid and interesting library that I follow. I avoid using libraries unless they bring unique benefits; I think intention revealing helpers achieves the same goal with the advantage of not having to learn an external dependency.

If the widget was even more complex, assuming it would make sense to have a base class and variations inherit from it I consider using cells.

## Conclusion

This feature has an integration test to ensure the images after the first row are loaded appropriately but that goes beyond the purpose of this article.

Helpers tend to become the kitchen sink of your app. Very long, with private methods sharing existing instance variables and setting new one. Lots of hidden logic and multi line strings with markup.

Intention revealing is the way to go, it will lead to maintainable code and you should value that. 

I am curious to see if you've used this approach before and where you're keeping your helper classes.

If you're not sold I'd like to hear what's keeping you from refactoring your helpers.

EDIT:
thanks to mdaubs for pointing out a bug in rails 4.0 where `config.action_controller.asset_host` won't prefix the image referenced in `image_tag` when called via `ActionController::Base.helpers`. A fix was introduced in Ruby on Rails 4.1 **asset_path ignores host configuration when called outside of view** [#10051](https://github.com/rails/rails/issues/10051).

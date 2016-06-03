---
layout: post
title: refactoring Ruby on Rails controller action
comments: true
tags:
  - ruby
  - rails
  - architecture
image: /assets/article_images/fluentlenium-with-google-chrome/hero.jpg
---

This article is an example of how to refactor a Ruby on Rails controller action containing a mix of framework specific instructions--ie. redirect, flash--and business logic. 

![](http://www.osnews.com/images/comics/wtfm.jpg)

This is not a silver bullet that will solve all your problems and suddenly increase your Ruby on Rails application code quality. It is an object oriented approach that can and should be used in combination with other patterns and in larger domains with a [component based architecture](http://teotti.com/component-based-rails-architecture-primer/).

**Evaluating if your problem domain complexity accounts for this approach is probably the hardest part**. Without experiencing the pain of maintaining a big ball of mud for more then a few months that complexity can be hard to see so instead of a toy example I will use a simplified problem adapted from a real life Ruby on Rails application.

## Our feature set

>> A regional representative (rep) access an edit/confirm page to update/confirm his profile

A few scenarios can happen in that feature:
 
1. the regional rep submits invalid data and fails to edit/confirm the profile
2. the regional rep successfuly updates the profile
3. the regional rep successfuly updates the profile and uploads a new photo
4. the regional rep used an expired notification link and can't edit/confirm the profile

The server side handles rendering the view layer--once upon a time the controller action code might have looked like this:

{% highlight ruby %}
def update
  @regional_representative = Contact.find(params[:id])
  if @regional_representative.update_attributes(params[:regional_representative])
    redirect_to rep_profile_show_url
  else
    render :edit
  end
end
{% endhighlight %}

But here's how it looks today:

{% highlight ruby %}
def update
  access_token = find_access_token
  if access_token.present? && !access_token.expired?
    form = ConfirmProfileForm.new(update_params[:regional_representative])
    if form.valid?
      if form.photo_path
        flash[:photo_update_notice] = "Your photo will be updated by the admin."
      end

      profile_updater = RegionalRepProfileUpdater.new
      profile_updater.update(access_token.regional_representative_id, form)

      redirect_to rep_profile_show_url
    else
      render :edit, locals: {rep: Contact.find(access_token.regional_representative_id), errors: form.errors.full_messages}
    end
  else
    render :template, "rep/shared/expired_token"
  end
end
{% endhighlight %}

In the 11 years I worked with Ruby and Rails I rarely saw controllers actions staying in their initial state--**they keep growing as the application evolve and it's always just another little change. Until...**

![](https://media.giphy.com/media/3R1dpjYOfnzJm/giphy.gif)

## The code is not that bad

This code is already implementing some good practices to make it more maintainable and intention revealing.

Since the validation rules for a regional representative confirming his profile are specific to that **context** the code uses a `ConfirmProfileForm`--an `ActiveModel` that handles validation of a `regional_representative` *entity* instead of creating a special validation case on the `Contact` ActiveRecord object.

The `ProfileUpdater` is a service object that encapsulate the ActiveRecord object update and emails/sms notifications to the regional representative as well as attaching an updated photo to the admin email--to make the example more manageable I've skipped the code handling service faliure.

Most developers are able to see and implement those two refactorings and sometime this is sufficient--if the leftover logic is minimal it can be left in the controller action--**but in this case there is still logic handling steps 1 to 4 in that controller action and it's not very intention revealing because it's mixed with framework code**.

## Domain logic mixed with the framework

Let's identify the controller action code that touches the framework directly:

{% highlight ruby %}
# when a photo is updated
flash[:photo_update_notice] = "Your photo will be updated by the admin."
# when profile is successfuly updated--possibly with photo update
redirect_to rep_profile_show_url
# when profile update fails
render :edit, locals: {rep: Contact.find(access_token.regional_representative_id), errors: form.errors.full_messages}
# when using an expired token
render :template, "rep/shared/expired_token"
{% endhighlight %}

Imagine encapsulating all that framework specific behaviour in a single object that delegates to the controller using Ruby's [SimpleDelegator](http://ruby-doc.org/stdlib-2.2.1/libdoc/delegate/rdoc/SimpleDelegator.html).

{% highlight ruby %}
module Rep
  class ProfileUpdateResponse < SimpleDelegator
    def profile_updated
      redirect_to rep_profile_show_url
    end

    def profile_updated_and_new_photo
      profile_updated
      flash[:photo_update_notice] = "Your photo will be updated by the admin."
    end

    def profile_update_failed(regional_representative, full_error_messages)
      render :edit, locals: {rep: regional_representative, errors: full_error_messages}
    end

    def expired_access_token
      render :template, "rep/shared/expired_token"
    end
  end
end
{% endhighlight %}
 
And pass that object to a `ProfileChange` service that encapsulate the business logic and given some user input will interact with the controller:

{% highlight ruby %}
module Rep
  class ProfileController < ApplicationController
    def update
      service = ProfileChange.new(ProfileUpdateResponse.new(self))
      service.perform(params[:token], update_params[:regional_representative])
    end
  end
end
{% endhighlight %}

Let's look at `ProfileChange` internals:

{% highlight ruby %}
module Rep
  class ProfileChange
    
    def initializer(listener)
      @listener = listener
    end

    def perform(token_value, contact_params)
      access_token = access_token(token_value)
      # not_expires is an ActiveRecord criteria on AccessToken
      if access_token.not_expired
        update_profile(contact_params, access_token)
      else
        @listener.expired_access_token
      end
    end


    private

    def access_token(token_value)
      AccessToken.where(value: token_value, permitted_action: :rep_confirm_profile)
    end

    def update_profile(contact_params, access_token)
      form = ConfirmProfileForm.new(contact_params)
      if form.valid?
        update_valid_profile(form, access_token)
      else
        @listener.profile_update_failed(Contact.find_by(id: access_token.contact_id), form.errors.full_messages)
      end
    end
    
    def update_valid_profile(form, access_token)
      profile_updater = ProfileUpdater.new
      profile_updater.update(access_token.contact_id, form)
      if form.photo_path
        @listener.profile_updated_and_new_photo
      end
      @listener.profile_updated
    end


  end
end
{% endhighlight %}

The `ProfileChange` service orchestrate the objects and based on certain conditions triggers four outcomes:  `profile_updated`, `profile_updated_and_new_photo`, `profile_update_failed`, `expired_access_token`.

---

## Conclusions

In this scenario moving code out of the controller action in to this layer of abstraction untangles framework and domain logic and makes the profile change intent explicit--in simpler cases this abstraction would get in the way and leaving the whole logic in the controller action is adeguate. If you're wondering where those concepts spawn have a look at [Ports & Adapters / Hexagonal Architecuture](http://alistair.cockburn.us/Hexagonal+architecture) by Alistair Cockburn.

### Bigger picture

Our fictional organization portal operates in three contexts:

1. a customer can view products and contact a regional representative for support
2. an administrator can manage products and regional representative
3. a regional representative can confirm and manage their profile.

This example--even after the refactor--is part of one boundary: **3**--and I've left the `Rep` module to indicate that--but as the application evolves those three boundaries will have cross boundary dependencies that this approach doesn't highlight but it's very easy to combine this approach to a [component based](http://teotti.com/component-based-rails-architecture-primer/).

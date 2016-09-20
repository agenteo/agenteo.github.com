---
layout: post
title: Untangle unmaintainable Ruby on Rails controller actions
comments: true
tags:
  - ruby
  - rails
  - rails4
  - architecture
image: /assets/article_images/untangle-unmaintainable-rails-controller-actions/hero.jpg
---

This article is an example of how to refactor a Ruby on Rails controller action containing a mix of framework specific instructions--ie. redirect, render, flash--and business logic. 

![](http://www.osnews.com/images/comics/wtfm.jpg)

This is not a silver bullet that will solve all your problems and suddenly increase your Ruby on Rails application code quality. It is an object oriented approach that can--and should--be used in combination with other patterns.

**Evaluating if your problem domain complexity accounts for this approach is probably the hardest bit** and without experiencing the pain of maintaining a big ball of mud for more then a few months that complexity can be hard to spot. To mitigate that instead of a toy example I will use **a simplified problem adapted from a real life usecase**.

In this example I assume the server to render the view layer.

## Our feature set

>> A regional representative (rep) access an edit/confirm page to update/confirm his profile

A few scenarios can happen within that feature:
 
1. the regional rep submits invalid data and fails to edit/confirm the profile
2. the regional rep successfuly updates the profile
3. the regional rep successfuly updates the profile and uploads a new photo
4. the regional rep used an expired notification link and can't edit/confirm the profile

The server side handles rendering the view layer and at some point the controller action code might have looked like this:

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

But after introducing that feature set it looks like this:

{% highlight ruby %}
def update
  access_token = find_access_token
  if access_token.present? && !access_token.expired?
    confirm_profile_form = ConfirmProfileForm.new(update_params[:regional_representative])
    if confirm_profile_form.valid?
      if confirm_profile_form.photo_path
        flash[:photo_update_notice] = "The new photo will be checked and updated by our staff within 72 hours"
      end

      profile_updater = ProfileUpdater.new
      profile_updater.update(access_token.regional_representative_id, confirm_profile_form)

      redirect_to rep_profile_show_url
    else
      render :edit, locals: {rep: Contact.find(access_token.regional_representative_id), errors: confirm_profile_form.errors.full_messages}
    end
  else
    render :template, "rep/shared/expired_token"
  end
end
{% endhighlight %}

Sine 2005 when I started working with Ruby and Rails I rarely saw controllers actions staying in their initial state--**they keep growing as the application evolves you see more actions more private methods and it's always just another little change. Until...**

![](https://media.giphy.com/media/3R1dpjYOfnzJm/giphy.gif)

## The code is not that bad

This example controller action code is already implementing some good practices to make it more maintainable and intention revealing.

### Form object handling data validation

Since the validation rules for a regional representative confirming his profile are specific to that **context** the code uses a `ConfirmProfileForm`--an `ActiveModel` that handles validation of a `regional_representative` *entity* instead of creating a special validation case on the `Contact` ActiveRecord object.

### Service encapsulating persistence layer and notifications

The `ProfileUpdater` is a service object that encapsulate the ActiveRecord object update and dispatch emails/sms notifications to the regional representative as well as attaching an updated photo to the admin email--to make the example more manageable I've skipped the code handling service faliure.

### Explicit view variables

The rendering of the view templates explicitly provide local variables instead of having instance variables that as the application grows are difficult to track and leak between partials.

Most developers are able to see and implement those refactorings and when the leftover logic is minimal it can be kept in the controller action **but in this case logic handling steps 1 to 4 is in that controller action and it's not very intention revealing because it's closely coupled with framework behaviour**.

## Domain logic mixed with the framework

Let's identify the controller action code that interacts with the Rails framework:

{% highlight ruby %}
# when a photo is updated
flash[:photo_update_notice] = "Your photo will be updated by the admin."
# when profile is successfuly updated--possibly with photo update
redirect_to rep_profile_show_url
# when profile update fails
render :edit, locals: {rep: Contact.find(access_token.regional_representative_id), errors: confirm_profile_form.errors.full_messages}
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
      render :template, "rep/expired_token"
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

    def perform(token_value, regional_rep_params)
      access_token = access_token(token_value)
      # not_expires is an ActiveRecord criteria on AccessToken
      if access_token.not_expired
        update_profile(regional_rep_params, access_token)
      else
        @listener.expired_access_token
      end
    end


    private

    def access_token(token_value)
      AccessToken.where(value: token_value, permitted_action: :rep_confirm_profile)
    end

    def update_profile(regional_rep_params, access_token)
      form = ConfirmProfileForm.new(regional_rep_params)
      if form.valid?
        update_valid_profile(form, access_token)
      else
        regional_rep = Contact.find_by(id: access_token.contact_id)
        @listener.profile_update_failed(regional_rep, form.errors.full_messages)
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

The `ProfileChange` does its job and interacts with the framework via `ProfileUpdateResponse`--when test driving `ProfileChange` in isolation the framework behaviour can easily be abstracted away to focus on the core logic. 

If framework abstraction isn't a concern this same refactor could be done in the controller via private methods except very often a single controller holds logic for multiple actions ending up with a mix of responsabilities and a tangle of private methods and shared state.

## Conclusions

In this scenario moving code out of the controller action in to this layer of abstraction untangles framework and domain logic making the profile change intent explicit--in simpler cases this abstraction could just get in the way and leaving the whole logic in the controller action is adequate. This separation concept is based on [Ports & Adapters / Hexagonal Architecuture](http://alistair.cockburn.us/Hexagonal+architecture) by Alistair Cockburn.

### Bigger picture

Our fictional organization portal operates other contexts:

1. a customer can view products and contact a regional representative for support
2. an administrator can manage products and regional representative
3. a regional representative can confirm and manage their profile

This example--even after the refactor--is part of **one boundary**--I've left the `Rep` module to indicate that--but as the application evolves those three operational contexts will have cross boundary dependencies that this approach doesn't highlight but it's easy to move this approach in a [component based](http://teotti.com/component-based-rails-architecture-primer/) with Ruby Gems and Rails engines.

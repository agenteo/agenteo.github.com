---
layout: post
title: an hexagonal approach within Ruby on Rails components
comments: true
tags:
  - ruby
  - rails
  - architecture
image: /assets/article_images/fluentlenium-with-google-chrome/hero.jpg
---

In this post I will walk trough the technical implementation of an [hexagonal architecture]() to a Rails controller using a problem adapted from real life Ruby on Rails applications--I hope that will help see the benefits of this approach more then a toy example.

The domain problem you're trying to solve should be the decider for this approach. I worked on many applications that were fine could have benefitted 

Anytime an administrator update a product representative profile he must confirm the changes. A few things can happen there:
 
* the product rep submits invalid data and fails to update the profile
* the product rep successfuly update the profile
* the product rep successfuly update the profile and uploads a new photo
* the product rep used an expired edit link and can't confirm or edit the profile

The product rep isn't a tech savvy individual so changing the profile picture requires administration action to check and possibly crop the image and do final upload. This means when the rep uploads a picture an email has to be sent to the administrator with the attached image.

Once upon a time the controller action code looked like:

{% highlight ruby %}
def update
  @contact = Contact.find(params[:id])
  if @contact.update_attributes(params[:contact])
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
    form = ConfirmContactInformationForm.new(update_params[:contact])
    if form.valid?
      if form.photo_path
        flash[:photo_update_notice] = "Your photo will be updated by the admin."
      end

      profile_updater = ContactProfileUpdater.new
      profile_updater.update(access_token.contact_id, form)

      redirect_to rep_profile_show_url
    else
      render :edit, locals: {rep: Contact.find(access_token.contact_id), errors: form.errors.full_messages}
    end
  else
    render :template, "rep/shared/expired_token"
  end
end
{% endhighlight %}

In the 11 years I worked with Ruby and Rails I saw 1% of controllers actions staying in the initial state. It's a bit like a photo of a baby boy--a snapshot in time--but the reality is the baby grew and 15 years later he's a teenager fighting pimples and--if in Italy--riding a dangerously tuned vespa without helmet.

As the application evolves and business rules are discovered the logic gets jammed in the action.

module Rep
  class ProfileUpdateResponse < SimpleDelegator
    def profile_updated
      redirect_to rep_profile_show_url
    end

    def profile_updated_and_new_photo
      profile_updated
      flash[:photo_update_notice] = "Your photo will be updated by the admin."
    end

    def profile_update_failed(contact, full_error_messages)
      render :edit, locals: {rep: contact, errors: full_error_messages}
    end

    def expired_access_token
      render :template, "rep/shared/expired_token"
    end
  end
end


Our fictional organization portal operates in three contexts: 1) a user can view products and contact a product representative for support, 2) an administrator can manage products and product representative and 3) a representative can confirm and manage their profile. This example has been simplified to avoid cognitive overload but complex enought so the reader can follow the decision process.

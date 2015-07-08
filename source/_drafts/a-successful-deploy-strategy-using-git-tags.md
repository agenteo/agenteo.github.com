---
title: A successful deploy strategy using Git tags and changelog
layout: post
draft: true
tags:
  - git
  - workflow
  - process
---

A popular git workflow is MISSING_LINK. It promotes feature branches and development, qa, production branches.

I used a stripped down version of it just using tags.

This strategy will fail when your development and product team comunication is poor. For this reason you 

## Start working on a feature

I am assuming you are already working following some agile methodologies and that your features are never bigger then 2/3 days of work.

Creating a local branch for feature development--if the work isn't completed by the end of the day it's good practice to commit to a remote server to have a backup.

Now it's time to update the `CHANGELOG.md` with the new release--if not already there--and a short description of the feature you're working on. No more then a few words and a link to your tracking system.

Once the work is complete I like to squash all the development commits in to one explaining the work done. This is a template:

{% highlight bash %}
Feature title

Explaining feature in the application context, its technical drawbacks and reasoning behing technical choice.

REF: http://link-to-tracking-system.com/feature-id
{% endhighlight %}

Before committing to `master`--**and this is critical**--you must check with the testers if they have capacity to test the new feature. This is the comunication part I referred at the beginning.

If the testers are tied up commit the feature on a feature branch--testers should clear up in a few hours. In a software project the testers shouldn't be the constraint--the development team should. A project should deliver as much as developers can deliver rather then as much as testers can test. 

Once tester have capacity you commit to `master` and deploy to your staging server.

## Release

The `CHANGELOG.md` will help the product owner creating a release mailout to stakeholders--if you are dark launching you will need a link to a dashboard indicating which features are on and to what demographic.

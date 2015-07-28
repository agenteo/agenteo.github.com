---
title: A successful deploy workflow using Git tags and a changelog
layout: post
tags:
  - git
  - workflow
---

I am describing a workflow that reduced product acceptance bottlenecks and ensured reliable deployments in a team of 5 developers and one product owner. The article is broken in to:

* working on a feature
* merging approval
* release + operations
* hotfixes

I am assuming you are already following some agile practice and your features are never bigger then 2/3 days of work.

## Working on a feature

Create a local branch off master dedicated to the feature you are about to start--this will allow work in progress (WIP) commits that facilitate incremental development and allow to detect incremental changes rather then one big commit.

Update the `CHANGELOG.md` with the next release marker--if not already added by someone else--and a short description of the feature you're working on. No more then a few words and a link to your tracking system.

{% highlight bash %}
# Changelog

Summary of release changes to Project Name

## 0.12.0 TBD
* feature short description
* feature short description

## 0.11.0 2015-03-13-12:36
* feature short description
* feature short description
* feature short description
* feature short description
* feature short description
* feature short description
* feature short description
{% endhighlight %}

When the feature is completed squash your branch changes:

{% highlight bash %}
git rev-list --count HEAD ^master
git rebase -i HEAD~THE_NUMBER_FROM_ABOVE
{% endhighlight %}
 
with a meaningful message explaining the work done, for example:
 
{% highlight bash %}
Feature title

Explaining feature in the application context, possible technical drawbacks and reasoning behing technical choice.

REF: http://link-to-tracking-system.com/feature-id
{% endhighlight %}

If the work isn't complete at the end of the day push the branch to the origin as a backup.

## Merging approval

This is something I've rarely seen in any team because as soon as developers are done with work they want to deploy which often ends up clogging the product owner acceptance pipeline.

Before bringing your changes to `master`--**and this is critical**--you must check with the testers if they have capacity to test the new feature. If the testers are tied up commit your feature branch to origin--testers should clear up in a few hours.

**In a software project the testers shouldn't be the constraint--the development team should**.

If this clogging happens often check what the development team can do to help with acceptance--I think a good balance is one tester every 2/3 developers.

Once tester have capacity merge your code in `master` and deploy to your staging server.

## Release

The `CHANGELOG.md` in `master` should have a list of all the features from the last release and will help the product owner creating a release mailout to stakeholders--when dark launching features a dashboard indicating which features are on and to what demographic would be necessary.

Make sure you update the `## 0.12.0 TBD` with an approximate date and time of the release `## 0.12.0 2015-07-13-20:36`.

If the product owner is happy with the features on the staging server he'll confirm the deploy and at this point you create a tag off master:

{% highlight bash %}
git tag -a v0.32
git push origin v0.32
{% endhighlight %}

Then the tag can be deployed to production, on Heroku that would be:

{% highlight bash %}
git push -f heroku-production v0.32^{}:master
{% endhighlight %}

What I like of this approach is developers integrates often on master but we have snapshots--the tags--of what has been deployed.

### Operations

I label the features that require a server update--database update, or a library update or running a one off task--with `operations`. When deploying to staging those operations are responsibility of whoever is delivering the feature but for a production release it's usually a single individual collecting the operations and taking care of them.

This workflow saved my team lots of gray hair from production deploys missing operational tasks.

### Hotfix

If you are dark launching you should be able to turn the feature off and avoid the hotfix deploy but when that's not the case create a branch from the latest deployed tag:

{% highlight bash %}
git checkout -b hotfix-v0.32.1 v0.32
{% endhighlight %}

work on the hotfix and when completed depending on the situation you could temporarily occupy staging or deploy directly to production.

{% highlight bash %}
git tag -a v0.32.1
git push origin v0.32.1
{% endhighlight %}

After the hotfix is deployed merge your changes back in master.

## Conclusion

Checking in with the product owner helped regaining control of the process. Great product owners are victims of their own talent and often given too many responsibilities--as developers we need to facilitate their job and I feel this workflow helped with that.

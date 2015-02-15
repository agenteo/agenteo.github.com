---
layout: post
title: Track down and deal with rspec flaky test
comments: true
tags:
  - work
  - ruby
  - testing
---

Having a suite of automated tests can be a blessing a curse. Sometime having an inconsitent suite is worst then having no tests.

Having learned this lesson the hard way I came up with a system to track down and deal with inconsistent (flaky) tests.

>> Ensure trust in a process that has undeniable upkeeping costs but ultimately helps ensuring the software is stable.

## do not commit code that breaks the build

This might sound naive but a human mistake (a quick inline commit with a syntax error) could cause the build to break. You can faciliatate that if your build is:

### easy to run

Creating a `./build` script facilitates running the build locally before committing, ensuring new developers are onboarded about the workflow via pairing or with a link to the project wiki explaining what's needed to setup the automated tests (ie. installing PhantomJS).


### take less then 10 minutes

The suite should really not run for more then 10 minutes. A longer time would start creating pockets of time inbetween delivering tasks where it's hard to be productive.

If your build takes longer then that focus on parallelizing your tests or pruning eccessive integration tests.

## Ensuring the build is green on CI

Once the build is green locally you want to ensure it's green in a shared environment accessible to all the team. After the build is green this environment can also automatically start a followup action (ie your application deploy script).

If the build fails on CI do not dismiss it as a flaky test yet.

Surely there are reasons why it worked on your workstation and not on CI. Examining the stack trace and the circumstances will help a curious motivated developer to find what went wrong.

### CI viewports smaller then workstation

Examples of this are full stack tests using different viewports between CI and workstation.

By default a CI server has a smaller viewport then an iMac (where I developed the feature).

In the squeezed CI viewport floating elements were covering buttons. This caused a consistent CI error because of not found buttons. The following Poltergeist directive forces the iMac viewport and fixed that problem:

{% highlight ruby %}
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { window_size: [1024,2573] })
end
{% endhighlight %}


Different system libraries are another reason why tests might fail on CI.

### Maintain trust in the system

You definetely do not want to leave a consistently failing test on CI. This is how people will loose trust in the system.

The worst CI consistent fail should not take an experienced developer more then 3 hours. Double that for a novice / beginner.

It's good to keep your peers updated with your efforts, in some environment though you might want to skip that step. I've seen people dismissing this errors as "it's only failing on CI so it's not worth spending time on it" and they'd rather leave the build fail or remove the test.

In my opinion that is a mistake.

>> Timeboxing some slack related to the CI build fixes is part of the upkepping cost for a tool that provide such a vital security in preventing regressions. 


## Ensuring you are seeing a flaky test

If you force the build on the test server and a previously failing test now passes you got a flaky test.

## Logging the flaky test

This empowers the team and transform the CI build from a black box showing green or red lights in to a tool you control.

### If you see something say something

Rather then asking in your chat or your collegues has anybody seen the error, use your report tool to search. I like to create github issues marked `flaky-test`

If the failing test is in your issue list comment it with the build number ie. http://yourCIserver.com/job/appName/472/

If you can't find one entry you should file one failing test per github issue, I like the title to look like: `ERRORING_FILE_NAME_AND_LINE || APPLICATION EXCEPTION` for example: `spec/features/preview/article_mobile_spec.rb:24 || Capybara::Poltergeist::TimeoutError` and mark the issue with the tag `flaky-test`.

>> We can now detect frequency of some flaky test perhaps pintpoint that to a 3rd party system having issues and focus on frequently occurring flaky tests

After confirming a flaky test add that information in jenkins with the "edit build information". A title "flaky test" and description the github issue that tracks the flaky test.

Now when looking at the build history you can quickly spot the flaky tests.


## Running a local virtual machine

Having a virtual machine matching the CI server configuration help revealing errors during TDD rather then on CI server.

An example of that is the viewport example I gave above.

Also the virtual machine has less resources and often UI intensive AJAX calls might take longer and not finish by the time the next test action runs, if your javascript code is not gracefully handling that you will get test fails. An example:

After making a category selection we need to contact the API to fetch a list of products. If your feature doesn't notify the UI about success or fail of that data retrieval your test will continue assuming that call was successful.

It is parhaps unlikely to happen in your real app but what about under load? On a vagrant virtual machine I've seen transforming CI flaky tests in consistent fails.

One way around this specific issue was to ensure no ajax calls are ongoing before moving on the next test ie:

{% highlight ruby %}
expect { no_active_ajax_calls }.to become_true

# Defined in
module AjaxCalls

  def no_active_ajax_calls
    page.evaluate_script('jQuery.active').zero?
  end

end
{% endhighlight %}

A better way would be to have the JS code changing a data attribute on the page to indicate its completion, which in turn could notify the user of this tool.

## Conclusion

Having consistent tests is difficult but important to maintain trust in the system. When you go on ebay and and look for something you trust it to be genuine

If after 1h you don't get to the root cause of something involve a collegue. After 4/5 hours declare the defeat... but post a comment here please I am already curious to hear about it.

One thing about this profession is everything happens for a reason. There is no magic. Just ignorance about topics or part of topics. Acknowledging that about 10 years ago.

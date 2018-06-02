---
title: Parallelising iOS UI tests
layout: post
comments: true
tags:
  - testing
  - ioS
image: /assets/article_images/parallelising-ios-ui-tests/hero.jpg
---

This article explains how to run iOS UI tests in parallel on a OSX host running multiple guests OSX virtual machines--the objective is to speed up a time consuming iOS UI test suite. You can find the script, its dependencies and a test project on [github](https://github.com/pivotalbeachla/parallelize-tests). **I really hope to save someone's hours of time I spent on UI testing parallelization dead ends.**

![]({{ site.url }}/assets/article_images{{ page.url }}step1.jpg)

### tldr;

Xcode8 has a `xcodebuild` option called `--only-test` to run single test files--our [proof of concept Ruby script](https://github.com/pivotalbeachla/parallelize-tests/blob/master/run.rb) collects the Xcode project test file list and runs them via ssh on multiple virtual machines--legally--running OSX. This script doesn't allow to distribute test functions across virtual machines even if that is a valid option to `--only-test`.

![]({{ site.url }}/assets/article_images{{ page.url }}step3.jpg)

Our [test project](https://github.com/pivotalbeachla/parallelize-tests) has around 15 tests--some with sleeps--and it takes around 20 minutes running on a single iMac (16GB ram, 3.5 GHz Intel Core i5 quad core). This script runs them in 7/8 minutes (with 3 virtual machines running on the same iMac). During our tests we confirmed that a shorter 2/3 minutes test suite did not benefit from this virtualization.

## The problem

As a project grows sets of diverse features over months and years its UI tests will increase and so will the suite execution time.

Apple doesn't make it easy to parallelise a test run--its xcodebuild has an option to parallelize a build but not the automated tests and its [xcode server](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/) doesn't support parallelization at the time of this writing.

At the time of this writing researching this topic online lead to **a lot** of dead ends and I felt compelled to write a blog post about our proof of concept solution. Facebook's [xctool](https://github.com/facebook/xctool) list test run [parallelization](https://github.com/facebook/xctool#parallelizing-test-runs) but during our tests that was true only for unit and **not for [Apple's UI tests](https://github.com/facebook/xctool#parallelizing-test-runs)**. Amazon's [AWS device farm](https://aws.amazon.com/device-farm/) allows to spread UI tests over a number of different devices but not to parallelize in order to reduce execution time.

Running multiple simulators on a single OSX workstation was a dead end. Running multiple physical devices connected to a OSX workstation would allow parallelization but it wasn't a suitable solution for us.

## This proof of concept stack
 
We will use a mix of open and proprietary tools:

* OSX (duh)
* OSX server ($19)
* VMware Fusion ($79.99)
* Ruby + awesome gems ($0)

**NOTE:** Oracle's Virtual Box is a free alternative to Fusion but it was giving us a hard time finding the OSX recovery partition to virtualize OSX.

The setup of the first virtual OSX box is manual--it can then be cloned to increase the size of your virtual boxes test farm. Once the VMs are setup the Ruby script `run.rb` will inspect the project on the host, find the test files, distribute them to available guests (virtual machines) and finally collect the test results and logs.

We've used a handful of awesome Ruby gems to orchestrate the parallelization:

* [sshkit](https://github.com/capistrano/sshkit) is a tool to distribute ssh commands
* [xcodeproj](https://github.com/CocoaPods/Xcodeproj) allows to detect targets and lists of test files
* [concurrent-ruby-ext](https://github.com/ruby-concurrency/concurrent-ruby) to use thread safe structures for the test list

## Installation

**[This solution](https://github.com/pivotalbeachla/parallelize-tests/) was developed during research and development as a proof of concept. It's only been tested on a [test application](https://github.com/pivotalbeachla/parallelize-tests).** Your milage may vary.

From now on we will refer to your workstation (or CI server) as the HOST.

### On the HOST:

* `git clone https://github.com/pivotalbeachla/parallelize-tests.git`
* `cd parallelize-tests` and then run `bundle`
* install OSX server from the AppStore
* install VmWare Fusion
* create a new VmWare Fusion OSX virtual machine--follow the wizard that will create the OS from the HOST recovery disk
* turn on the virtual machine (refered to as GUEST from now on) and set its name ie. (parallel-ios-tests-1)
* enable the GUEST ssh access from System Preferences -> Sharing

### Provisioning GUEST

* install xcode and necessary simulators
* enable xcode developer mode
* install git
* install SSH certificate to allow git checkout
* create a PROJECT_DIRECTORY and git clone your project--the project directory will be needed when Running the tests from the HOST

### Cloning GUEST and enlarge your virtual machines test farm
 
* turn off the GUEST
* from VmWare's menu: Virtual Machine -> Create full clone
* once the new GUEST is turned on change its name (in the script I used *parallel-ios-tests-2* and *parallel-ios-tests-3*)
* repeat this as long as you see your total test time decrease


## Running the script

You will run the `run.rb` script from the HOST. Currently all the variables have to be provided via ENV variables ie.

```
LIST_OF_VMS="parallel-ios-testbox-1.local parallel-ios-testbox-2.local parallel-ios-testbox-3.local" PROJECT_FILE=UnitTest.xcodeproj SCHEME=UnitTest VM_PROJECT_DIRECTORY="workspace/parallelize-tests" DESTINATION="platform=iOS Simulator,name=iPhone 7" ruby run.rb
```

![]({{ site.url }}/assets/article_images{{ page.url }}testsInProgress.jpg)

The test project name is UnitTest, sorry for the confusion :)

You should see green dots for a successful test and red F for a fail. In the test project you'll see all greens and one fail:

![]({{ site.url }}/assets/article_images{{ page.url }}running.jpg)

More information--including failures whole `xcodebuild` outputs--can be found inside the timestamped logs in the script's directory ie. ios-parallel-tests-20161010_1026.log.


## Conclusion

Before this I was thinking virtualizing OSX was hard and illegal but it turned out to be legal, very simple and a great way to distribute iOS UI tests.


## Credits

Tim Kersey and I paired on this during research and development time at Pivotal Labs in Santa Monica. You can find the code of the proof of concept on [GitHub](https://github.com/pivotalbeachla/parallelize-tests).

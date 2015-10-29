---
title: Manage large Ruby projects with a Gem dependency structure
layout: post
comments: true
tags:
  - maintainability
  - ruby
---

**In this post I talk about Ruby gem dependency management and how it can help manage a large codebase.**

But first I want to You might be wondering how do you get to such a large unwieldy code?

Let's start with a fairy tale:

>> Once upon a time there was a Good Software Engineer whose customers knew exactly what they wanted.
>> 
>> The Good Software Engineer worked very hard to design the Perfect System that would solve all the Customers’ problems now and for decades.
>>
>> When the Perfect System was designed, implemented, and finally deployed, the Customers were very happy indeed.
>> 
>> The Maintainer of the System had very little to do to keep the Perfect System up and running, and the Customers and the Maintainer lived happily every after.

*Taken from Object-oriented reengineering patterns Book by Serge Demeyer*

## Why isn't life like that?

Is it because we're not good engineers? Is it because we don't work hard? Or is it because we're not good enough to build a perfect system? Is it our customers fault?

In his book Demeyer points out Lehman's **law of continuing change (1974)**:

>> Any software system used in the real-world must change or become less and less useful in that environment.

and Lehman's **law of increasing complexity (1974)**:

>> As a program evolves, it becomes more complex, and extra resources are needed to preserve and simplify its structure.

In 1996 a couple of researchers backed up Lehman laws with [empirical data](http://www.researchgate.net/publication/259979752_An_Empirical_Study_of_Lehmans_Law_on_Software_Quality_Evolution) and added a few new "laws" including **the law of Declining Quality (1996)**:

>> the quality of a system will appear to be declining unless it is rigorously maintained and adapted to operational environment changes

More often then not re-engineering is a late act of desperation rather then an incremental task.

## An example

These are the files of a custom Ruby program named sfs (Super Financing Software) dealing with tasks for a financing firm. We will use Ruby gems to restructure the larger set (57 files) in a series of libraries.

{% highlight bash %}
accounting                              financing.rb                            living_trust.rb
annuity.rb                              foreclosure.rb                          loan.rb
bad_debt.rb                             franchise.rb                            money.rb
bankruptcy.rb                           freddie_mac.rb                          mortgage_backed_security.rb
borrow.rb                               future.rb                               mortgage.rb
broker.rb                               futures.rb                              mortgage_broker.rb
cash_advance.rb                         hazard_insurance.rb                     net.rb
cash_flow.rb                            hedge_fund.rb                           option.rb
check.rb                                heir.rb                                 
commodity.rb                            insurance.rb                            probate.rb
corporation.rb                          insurance_policy.rb                     real_estate.rb
credit_bureau.rb                        intellectual_property.rb                refinancing.rb
credit_card.rb                          interest_rate.rb                        retirement.rb
credit_report.rb                        invest.rb                               reverse_mortgage.rb
credit_score.rb                         investment.rb                           stock_market.rb
currency.rb                             ira.rb                                  stuff.txt
debt.rb                                 lender.rb                               tax_return.rb
equities.rb                             life_insurance_limited_liability.rb     trading.rb
equity_finance.rb                       limited_partnership.rb
financial.rb                            line_of_credit.rb
{% endhighlight %}

*there is a third column*

## Where to start from?

We look at the project backlog and see plenty of stories related to Pewterschmidt credit services. The code has no boundaries but after a bit of looking and asking around we find out that `LineOfCredit` is the entry point for interaction with Pewterschmidt credit services.

Ruby is a dynamic language so we won't have the luxurious static analysis tool you get in a compiled language.

We try a text search with `ag` and `ctags` to detect which classes are called from `LineOfCredit` and its dependencies. We're lucky enough the code wasn't built with too too much magic or metaprogramming.

Here's the list of classes only used by `LineOfCredit`:

{% highlight bash %}
bad_debt.rb
credit_bureau.rb
credit_card.rb
credit_report.rb
credit_score.rb
line_of_credit.rb
{% endhighlight %}

**but** there are others that are used somewhere else outside our **context**:

{% highlight bash %}
ira.rb
money.rb
{% endhighlight %}

we decide to only introduce one context and consciously leaving the library dependent on the larger script for now. In the automated tests we will stub or [mock](http://martinfowler.com/articles/mocksArentStubs.html) the external classes.

## Creating the library

The firm isn't just using Pewterschmidt credit services they own them so you decide to use the name in the library. Bundler provides a command to [create a gem](http://bundler.io/v1.10/man/bundle.1.html): `bundle gem pewterschmidt-credit` that will create the following namespace `Pewterschmidt::Credit` and files:

{% highlight bash %}
fang:sfs agenteo$ bundle gem pewterschmidt-credit
      create  pewterschmidt-credit/Gemfile
      create  pewterschmidt-credit/Rakefile
      create  pewterschmidt-credit/LICENSE.txt
      create  pewterschmidt-credit/README.md
      create  pewterschmidt-credit/.gitignore
      create  pewterschmidt-credit/pewterschmidt-credit.gemspec
      create  pewterschmidt-credit/lib/pewterschmidt/credit.rb
      create  pewterschmidt-credit/lib/pewterschmidt/credit/version.rb
Initializing git repo in /Users/agenteo/code/sfs/pewterschmidt-credit
{% endhighlight %}

To test our library in isolation we create a `.ruby-version` matching the wrapper script Ruby's and a dedicated `.ruby-gemset` named `sfs_pewterschmidt-credit`.

Next we add an `rspec` development dependency to `pewterschmidt-credit` and then run `bundle`:

{% highlight bash %}
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Installing rake 10.4.2
Using bundler 1.6.2
Installing diff-lcs 1.2.5

pewterschmidt-credit at /Users/agenteo/code/sfs/pewterschmidt-credit did not have a valid gemspec.
This prevents bundler from installing bins or native extensions, but that may not affect its functionality.
The validation message from Rubygems was:
  "FIXME" or "TODO" is not a description
Using pewterschmidt-credit 0.0.1 from source at .
Installing rspec-support 3.3.0
Installing rspec-core 3.3.2
Installing rspec-expectations 3.3.1
Installing rspec-mocks 3.3.2
Installing rspec 3.3.0
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endhighlight %}

Now on to installing rspec:

{% highlight bash %}
rspec --init
  create   .rspec
  create   spec/spec_helper.rb
{% endhighlight %}

And now we can move the existing tests from the main directory spec to pewterschmidt-credit and create the missing ones. Running `bundle exec rspec` inside `pewterschmidt-credit` will only run those tests so we need to update how the whole application tests are run.

We decide to add a bash script `build.sh` to locate dependencies and run the test files. You can see examples of the [build script](https://gist.github.com/agenteo/7a09eb9c8ced52fdb9ad) and of the [library test here](https://gist.github.com/agenteo/da5c986617d5ddb838d5).

### Rename files duplicating the namespace

We don't want to repeat the namespace in the class name (ie. Credit::CreditScore) so we change:

{% highlight bash %}
credit_bureau.rb
credit_card.rb
credit_report.rb
credit_score.rb
{% endhighlight %}

to be:

{% highlight bash %}
bureau.rb
card.rb
report.rb
score.rb
{% endhighlight %}

And since our intention is to split up the code in multiple libraries we create a `sfs_dependencies` directory where `pewterschmidt-credit` will live. Let's add that dependency to the `Gemfile`:

{% highlight ruby %}
gem 'pewterschmidt-credit', path: 'sfs_dependencies'
{% endhighlight %}

and bundle:

{% highlight bash %}
$ bundle
Resolving dependencies...
Using multipart-post 2.0.0
Using faraday 0.9.2
Using pewterschmidt-credit 0.0.1 from source at sfs_dependencies
Using bundler 1.6.2
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endhighlight %}

`sfs` will now install `pewterschmidt-credit` from the `sfs_dependencies` directory.

## What changed?

In the main application `Loan` and `Mortgage` class now access the `Pewterschmidt::Credit::LineOfCredit` instead of `LineOfCredit`. A challenge in Ruby is that all the `pewterschmidt-credit` library classes are public to the main application even if only one of them really is.


The next story we have to work on is on mortgages, we detect the following files with entry point `Mortgage`:

{% highlight bash %}
mortgage_backed_security.rb
mortgage.rb
mortgage_broker.rb
bankruptcy.rb
borrow.rb
{% endhighlight %}

We find out mortgages contacts the API of an agency called Jizanthapus so let's encapsulate that in another library.

{% highlight bash %}
fang:sfs agenteo$ bundle gem jizanthapus-mortgages
{% endhighlight %}

To approve a mortgages Jizanthapus need to run a credit check by Pewterschmidt credit services. So we tell our new library to depend on `pewterschmidt-credit` by adding 

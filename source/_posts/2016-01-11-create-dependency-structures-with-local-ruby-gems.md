---
layout: post
title: Create dependency structures with local Ruby Gems
comments: true
tags:
  - ruby
  - maintainability
---

Good object oriented practices can be sufficient to handle some complexity but when the project is over a certain size they don't help understand what the whole application does. **When you have to read several classes in order to visualize application dependencies you increase your cognitive load making your job harder.**

Using a local gems dependency structure is complementary to good object oriented practices and allows you to incrementally design application boundaries resulting in an intention revealing structure that reduces cognitive load and facilitates code navigation.

**There is a misconception that Ruby Gems are only for distributing libraries but they can be used locally as building blocks of a large Ruby application.**

The focus of this article is test driving the technical implementation of local Ruby Gems dependencies structure using a simplified example adapted from a real life application, you can find the code [on GitHub](https://github.com/agenteo/gem_dependency_structure).

>> As a health plan subscriber I want to see information about my plan so I know what drugs are covered

![we know more features are coming but let's focus on the first one]({{ site.url }}/assets/article_images{{ page.url }}dependencies_step_1.png)

## Ruby application

A Ruby application triggers the behaviour encapsulated in the gem dependency structure--it can be a script, rake task or web framework--it's just a proxy to the business logic encapsulated within gems.

In this example I will use a Ruby script that requires and makes calls to my health plan **entry point gem**.

To ensure your dependency structure is solid you must add *unit tests for each gem* and *integration tests at the script level*. Let's start from the latter, you will need a `Gemfile` to get our testing library *rspec*:

{% highlight ruby %}
source 'https://rubygems.org'

group :test do
  gem 'rspec'
end
{% endhighlight %}

run `bundle` and then run `rspec --init` to setup the automated tests. The full code is in [this GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/9783895ede66b8516d746dd404493ae361be7d22).

Here's our script triggering some `health_plan` class behaviour:

{% highlight ruby %}
require 'health_plan'

subscriber_id = 'ASE123456789'
aggregated_health_plan = HealthPlan::Aggregator.new(subscriber_id)
puts aggregated_health_plan.details
{% endhighlight %}

its automated test:

{% highlight ruby %}
describe 'run the script' do
  let(:script_root) { File.dirname(__FILE__) + '/../' }

  it 'should return a success code' do
    system('bundle')
    expect( system("ruby #{script_root}run.rb")).to be(true)
  end
end
{% endhighlight %}

triggers an expected error about the missing `health_plan` gem:

{% highlight bash %}
/Users/agenteo/code/lab/gem-dependency-structure/spec/../run.rb:1:in `require': cannot load such file -- health_plan (LoadError)
{% endhighlight %}

In the application root directory let's create a `local_gems` directory to store our local gems--in production pick a name that is meaningful to your team--I often use *components*.

## Building a gem

There are many ways to create a gem, I use [bundler](http://bundler.io/):

{% highlight bash %}
$ cd local_gems
$ bundle gem health_plan
  create  health_plan/Gemfile
  create  health_plan/Rakefile
  create  health_plan/LICENSE.txt
  create  health_plan/README.md
  create  health_plan/.gitignore
  create  health_plan/health_plan.gemspec
  create  health_plan/lib/health_plan.rb
  create  health_plan/lib/health_plan/version.rb
Initializing git repo in /Users/agenteo/code/lab/gem-dependency-structure/local_gems/health_plan
$ rm -Rf health_plan/.git*
{% endhighlight %}

This will create the necessary files including git files that you should remove **since the gem will be local instead of published to a separate repository**.

Let's have a look at the relevant files:

### *Gemfile*

The gem's `Gemfile` is only used for your gem's automated tests and **never by the main Ruby application**.

The generated `Gemfile` has a line with `gemspec`

{% highlight ruby %}
$ cat local_gems/health_plan/Gemfile
source 'https://rubygems.org'

# Specify your gem's dependencies in health_plan.gemspec
gemspec
{% endhighlight %}

that tells bundler to install this gem dependencies from a `.gemspec` file living in the same directory in this case `health_plan.gemspec`.
 

### *.gemspec*

This is the specification file part of Rubygems and looks like this:

{% highlight ruby %}
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'health_plan/version'

Gem::Specification.new do |spec|
  spec.name          = "health_plan"
  spec.version       = HealthPlan::VERSION
  spec.authors       = ["Enrico Teotti"]
  spec.email         = ["me@example.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
{% endhighlight %}

**You must remove TODO from summary and description or a warning will prevent you from building the gem.**

You can find details about the other fields on [rubygems.org](http://guides.rubygems.org/specification-reference/).

### *version.rb*

I never update the version number for local gems but it's good to have it there in case you will publish the gem to a private gem server and start versioning so multiple applications can use it.

## Add gem entry point to Ruby application

Now that the gem is created--you can find the code in this [GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/ee009927308602a7eaf00069d202232111fe756b)--you need to add the entry point gem to the Ruby application:

{% highlight ruby %}
path 'local_gems' do
  gem 'health_plan'
end
{% endhighlight %}

Running the test now should be green. Remember the code is just an example to exercises the dependency structure.

## Setup local gems dependencies
  
Let's add a local dependency from `health_plan` to a `drug_information` local gem that encapsulates access to drug information:

{% highlight ruby %}
# health_plan.gemspec
# within Gem::Specification.new do |spec|
spec.add_dependency "drug_information"
{% endhighlight %}

Running `bundle` within the `health_plan` local gem directory errors on `drug_information` not being found:

{% highlight bash %}
$ bundle
Fetching gem metadata from https://rubygems.org/..
Resolving dependencies...
Could not find gem 'drug_information (>= 0) ruby', which is required by gem 'health_plan (>= 0) ruby', in any of the sources.
{% endhighlight %}

That's for two reasons: first `add_dependency` doesn't yet know about local gems and second we haven't created that gem. Let's fix the second running from the local gems directory `bundle gem drug_information`.

The first problem is `health_plan` local gem failed to find `drug_information` on **rubygems.org which you must be vigilant about**. What if somebody created and published a `drug_information` gem on rubygems?

### Gotcha: Local / remote gems name collisions

I've seen this edge case happening and the result is your application uses the remote gem and your Gemfile.lock is **locked to the remote gem and prevent the local gem dependency to be picked up when created**. *If you run in to this problem the solution is to delete the Gemfile.lock and bundle again after the local gem is created*.

A safe way to prevent this problem is to have a project specific namespace wrapping the gem name ie. `ProjectName::DrugInformation`. Prefixing all your gems ie. `ProjectNameDrugInformation` works too but I find it obfuscates the gem name rather then creating proper boundaries like `ProjectName::DrugInformation` that reveals **the project** has a **drug information** boundary.

What if your gem name isn't used on rubygems.org today but somebody publishes a `drug_information` gem tomorrow? Once the Gemfile.lock is locked with the local gem this edge case isn't a problem anymore because even if the `Gemfile.lock` is deleted the local gem has higher priority over the remote one.

### Add local gems dependencies path

You must tell your local gem about its local dependencies path via the `Gemfile`:

{% highlight ruby %}
path '../'
{% endhighlight %}

that adds everything located one directory above the `health_plan` to the gems search path. That is all the gems in `local_gems`. Run bundle within `health_plan` again and you should see:

{% highlight bash %}
Using health_plan 0.0.1 from source at .
{% endhighlight %}

You can find the code in this [GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/1c47b0d2cdc865431de665428d2977eefb4d27b7).

## Use automated tests to ensure the dependencies are solid

Let's update `HealthPlan::Aggregator` to access some dummy `drug_information` code:

{% highlight ruby %}
def details
  fetched_drug_info = DrugInformation::Fetcher.new(@subscriber_id)
  { name: 'The full package plan', drugs: fetched_drug_info.details }
end
{% endhighlight %}

The dependency between `health_plan` and `drug_information` was set in the `health_plan` gem specification for its building process but **it must be explicitly required** or the code will not be found. **This is the cause of many errors especially if you're used to Ruby on Rails autoloader**.

The fix is to add a require statement, usually in the gem entrypoint file `lib/gemname.rb` in this case `lib/health_plan.rb`:

{% highlight ruby %}
require "health_plan/version"
require "health_plan/aggregator"

require "drug_information"

module HealthPlan
end
{% endhighlight %}


Automated tests are an important part of software development but they are **the only way to ensure local Ruby gems dependency structures are solid**.

### Gotcha: Flaky bugs caused by missing requirement statements

This is a problem affecting a Ruby process running in memory such as a web server or deamon. Let's say you have a gem A requiring gem C and using its code, and you have a gem B **not** requiring gem C but using its code. A and B are two high level gems that your Ruby application can call.

![visual representation]({{ site.url }}/assets/article_images{{ page.url }}flaky_bugs.png)

When your application first access gem B an error will be triggered since it uses gem C code without requiring it.

But when your application first executes gem A it requires gem C and leaves it in memory--if the application now access gem B it won't fail because gem C was previously required.

**A unit test on gem B would have caught that. And this is why you really must test all your local gems in isolation.**

For example if we run:

{% highlight ruby %}
require 'spec_helper'

describe HealthPlan::Aggregator do

  describe "#details" do
    before do
      fetcher_double = double('DrugInformation::Fetcher', details: {})
      allow(DrugInformation::Fetcher).to receive(:new).and_return(fetcher_double)
    end

    it "should not throw exceptions" do
      aggregator = HealthPlan::Aggregator.new(12345)
      expect(aggregator.details).to be_a_kind_of(Hash)
    end
  end

end
{% endhighlight %}

before requiring `drug_information` within `health_plan` the test will fail with an expected: `uninitialized constant DrugInformation::Fetcher`.

## Evolving the design of your application

An application that doesn't evolve is rarely useful and as it evolves it becomes more complex and requires extra resources to preserve and simplify its structure--these are concepts covered by Lehman's **law of continuing change** and **law of increasing complexity**.

![our evolved design]({{ site.url }}/assets/article_images{{ page.url }}dependencies_step_2.png)

The health plan requirement changed:

>> As a subscriber I want to access my health plan page with drug information and claims information

From the technical side evolving your design is really as simple as updating `add_dependency` in your *.gemspec*--what is more challenging is how to associate boundaries to gems.

**The target** is to have an intention revealing dependency structure that reduce the cognitive load. **The risk** is to split in too fine grained components creating a dependency structure that is purely technical and doesn't represent any business rule.

In the first scenario you'd be able to talk about your boundaries/libraries with your business owners. In the second scenario your libraries are so abstract that impede conversation with business owners and shouldn't have been split or perhaps be part of a shared utility library. What prevents the *shared utility gem* from becoming a kitchen sink? Team diligence.

My guideline is to use a [ubiquitous language](http://martinfowler.com/bliki/UbiquitousLanguage.html) and map business operational areas in to objects and namespaces. **When more then two or three concepts are living in a single namespace I ask the business owner if they think it's a different context or if a different team or company is operating that.**

Conway’s law help with this:

>> "organizations which design systems … are constrained to produce designs which are copies of the communication structures of these organizations"

It's hard work that can't be delegated to someone outside the development team. The boundaries can and will change as the application evolves--that's where the term evolutionary design comes from.

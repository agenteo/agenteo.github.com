---
layout: post
title: Create dependency structures with local Ruby Gems
comments: true
tags:
  - ruby
---

Good object oriented practices like the use of decorators, presenters, service objects can be sufficient to handle some complexity but when the project is over a certain size they don't help understand what the whole application does. Creating a local gems dependency structure for your application is complementary to good object oriented practices and allows you to incrementally design application boundaries.

**There is a misconception that Ruby Gems are only for distributing libraries but they can be used locally as building blocks of a large Ruby application.**

The focus of this article is test driving the technical implementation of local Ruby Gems dependencies structure using a simplified example adapted from a real life application.

>> As a health plan subscriber I want to see information about my plan so I know what drugs are covered

![visual representation]({{ site.url }}/assets/article_images{{ page.url }}dependencies_step_1.png)

## Ruby application

You're using a Ruby application to trigger the behaviour encapsulated in the gem dependency structure. The application can be a script, rake task or a web framework--it's just a proxy to the domain logic.

In this example I will use a Ruby script that requires and makes calls to my health plan **entry point** gem.

To ensure your dependency structure is solid you must add unit tests for each gem as well as integration tests at the script level. Let's start with the latter and use Rspec.

You will need a `Gemfile` to get rspec:

{% highlight ruby %}
source 'https://rubygems.org'

group :test do
  gem 'rspec'
end
{% endhighlight %}

run `bundle` and then run `rspec --init` to setup the automated tests. The full code is in [GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/9783895ede66b8516d746dd404493ae361be7d22).

{% highlight ruby %}
require 'health_plan'

subscriber_id = 'ASE123456789'
aggregated_health_plan = HealthPlan::Aggregator.new(subscriber_id)
puts aggregated_health_plan.details
{% endhighlight %}

the automated test:

{% highlight ruby %}
describe 'run the script' do
  let(:script_root) { File.dirname(__FILE__) + '/../' }

  it 'should return a success code' do
    system('bundle')
    expect( system("ruby #{script_root}run.rb")).to be(true)
  end
end
{% endhighlight %}

And the expected error it raises is about the missing `health_plan` gem:

{% highlight bash %}
/Users/agenteo/code/lab/gem-dependency-structure/spec/../run.rb:1:in `require': cannot load such file -- health_plan (LoadError)
{% endhighlight %}

In the same directory let's create a `local_gems` directory to store our local gems--in production pick a name that is meaningful to your team--I often use *components*.

## Building a gem

There are many ways to create a gem, I generally use [bundler](http://bundler.io/):

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

This will create the necessary files--you will want to remove its git repository files **because the gem will be local instead of published to a separate repository**.

Let's have a look at the relevant files:

### Gemfile

The gem's `Gemfile` is only used by your gem's automated tests and **not by the main Ruby application**. At first this can be **very confusing** and lead you to look for dependencies in the wrong place.

The generated `Gemfile` has a line with `gemspec`

{% highlight ruby %}
$ cat local_gems/health_plan/Gemfile
source 'https://rubygems.org'

# Specify your gem's dependencies in health_plan.gemspec
gemspec
{% endhighlight %}

this tells bundler to install this gem dependencies from a `.gemspec` file living in the same directory in this case `health_plan.gemspec`.
 

### .gemspec

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

### version.rb

I usually never update the version number for local gems but it's good to have it there for the unlikely case were you will publish the gem to a private gem server so multiple applications can use it. More on this later.

## Add gem entry point to Ruby application

Now that the gem is created--you can find the code in this [GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/ee009927308602a7eaf00069d202232111fe756b)--you need to add the entry point gem to the Ruby application:

{% highlight ruby %}
path 'local_gems' do
  gem 'health_plan'
end
{% endhighlight %}

Running the test now should be green. Remember the code is just an example that exercises the dependency structure.

## Setup local gems dependencies
  
Let's add a local dependency to our `health_plan` local gem `health_plan.gemspec` with `add_dependency` so this local gem is dependent on another local gem that encapsulates access to drug information:

{% highlight ruby %}
spec.add_dependency "drug_information"
{% endhighlight %}

If you run `bundle` within the `health_plan` local gem directory you will throw an error complaning `drug_information` can't be found because `add_dependency` doesn't yet know about local gems.

{% highlight bash %}
$ bundle
Fetching gem metadata from https://rubygems.org/..
Resolving dependencies...
Could not find gem 'drug_information (>= 0) ruby', which is required by gem 'health_plan (>= 0) ruby', in any of the sources.
{% endhighlight %}

There is also a second problem: we haven't created that gem. Let's fix that running from the local gems directory `bundle gem drug_information`.

Back the the real problem: `health_plan` local gem failed to find `drug_information` on rubygems.org **which you must be vigilant about**. What if somebody created and published a `drug_information` gem on rubygems?

### Local / remote gems name collisions

I've seen this edge case happening and the result is your application uses the remote gem and your Gemfile.lock is **locked to the remote gem and prevent the local gem dependency to be picked up when created**. If you run in to this problem the solution is to delete the Gemfile.lock and bundle again after the local gem is created. A fairly safe convention to prevent this problem is to have a project specific namespace wrapping the gem name ie. `ProjectName::DrugInformation`. Prefixing all your gems ie. `ProjectNameDrugInformation` works too but I find it obfuscates the gem name rather then creating proper boundaries like `ProjectName::DrugInformation` that reveals **the project** has a **drug information** boundary.

What if your gem name isn't used on rubygems.org today but somebody publishes a `drug_information` gem tomorrow? Once the Gemfile.lock is locked with the local gem this edge case is not gonna be a problem anymore because even if the `Gemfile.lock` is deleted the local gem has higher priority over the remote one.

### Specify local gem dependencies

You can tell your local gem about its local dependencies adding to the `Gemfile`:

{% highlight ruby %}
path '../'
{% endhighlight %}

that adds everything located one directory above the `health_plan` to the gems search path. That is all the gems in `local_gems`. Run bundle within `health_plan` again and you should see:

{% highlight bash %}
Using health_plan 0.0.1 from source at .
{% endhighlight %}

You can find the code in this [GitHub commit](https://github.com/agenteo/gem_dependency_structure/commit/1c47b0d2cdc865431de665428d2977eefb4d27b7).

## Use automated tests to ensure the dependencies are solid

Let's change `HealthPlan::Aggregator` code to access some dummy `drug_information` code:

{% highlight ruby %}
def details
  fetched_drug_info = DrugInformation::Fetcher.new(@subscriber_id)
  { name: 'The full package plan', drugs: fetched_drug_info.details }
end
{% endhighlight %}

remember the dependency on `drug_information` was set in the gem specification for the gem building process but **it must be explicitly required** or its code will not be found. **This is the cause of many errors especially if you're used to Ruby on Rails autoloader**.

The fix is to add a require statement, usually in the gem entrypoint file `lib/gemname.rb` in this case `lib/health_plan.rb`:

{% highlight ruby %}
require "health_plan/version"
require "health_plan/aggregator"

require "drug_information"

module HealthPlan
end
{% endhighlight %}


Automated tests are an important part of software development but they are the only way to ensure local Ruby gems dependency structures are solid.

### Flaky bugs caused by missing requirement statements

This is a problem for a Ruby process loaded and running in memory such as a web server or deamon. Let's say you have a gem A requiring C and using its code, and you have a gem B **not** requiring C but using its code. A and B are two high level gems that your Ruby script can call.

![visual representation]({{ site.url }}/assets/article_images{{ page.url }}flaky_bugs.png)

When your application first access B an error will be triggered since B doesn't require C but uses its code.

But when you first execute A it requires C and leaves it in memory, so when B runs it won't fail! 

**So you really want to test all your local gems in isolation to catch those errors.**

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

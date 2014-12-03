---
layout: post
title: GIT precommit hooks helping local Ruby GEMs development
comments: true
categories:
  - work
  - ruby
  - engines
  - git
---

# {{page.title}}

I was working on a Ruby app that depended on a few private gems, the development was not just changing the app but also those gems.

During development the `Gemfile` would look like:

{% highlight ruby %}
gem 'cargo_estimates', path: 'local_engines/cargo_estimates'
gem 'shipping_calculator', path: 'local_engines/shipping_calculator'
{% endhighlight %}

Running bundle would set the `Gemfile.lock` to those gem local version.

Committing `Gemfile.lock` in version control now could have disastrous consequences if the code is deployed.

Once the local gems updates are published you must manually change the `Gemfile` to:

{% highlight ruby %}
gem 'cargo_estimates'
gem 'shipping_calculator'
{% endhighlight %}

and run `bundle` to update the `Gemfile.lock` to use the remote gems.

This works but if your daily workflow mean multiple changes to the local gems it could get tedious to manually changing where to point those gems and to make sure `Gemfile.lock` is pointing to the right gems.


So I came up with a set of scripts to automate the development bootstrap and facilitate the workflow.

In my project folder I had a `dev_bootstrap.sh` calling a set of script located in `PROJECT_DIRECTORY/dev_bootstrap_scripts`:

{% highlight bash %}
#!/bin/bash
./dev_bootstrap_scripts/precommit_hooks.sh
./dev_bootstrap_scripts/local_engines.sh
./dev_bootstrap_scripts/set_rvmrc.sh
{% endhighlight %}

## Conditional Gemfile.lock generation

Bundler is built to have one `Gemfile.lock` so I came up with is a unix environment variable to switch the local or remote gems. The `Gemfile` now looks like:

{% highlight ruby %}
if ENV['LOCAL_ENGINES']
  gem 'cargo_estimates', path: 'local_engines/cargo_estimates'
  gem 'shipping_calculator', path: 'local_engines/shipping_calculator'
else
  gem 'cargo_estimates'
  gem 'shipping_calculator'
end
{% endhighlight %}

But you have to run `LOCAL_ENGINES=true bundle`, in the project root I had a script `lebundle.sh` to facilitate that:

{% highlight bash %}
#!/bin/bash
export LOCAL_ENGINES=true
bundle
{% endhighlight %}

An alternative is to set that env variable via rvmrc in `dev_bootstrap_scripts/set_rvmrc.sh` I had:

{% highlight bash %}
echo "rvm use $(cat .ruby-version)" > .rvmrc
echo "export LOCAL_ENGINES=true" >> .rvmrc
echo "!!!! MANUAL STEP REQUIRED !!!!"
echo "==> You need to use the correct rvm environment. Run:"
echo "source .rvmrc'"
echo "~~~~"
{% endhighlight %}

I used the `.ruby-version` to generate the `.rvmrc` which will be executed automatically when you enter the project directory and setup the `LOCAL_ENGINES` to true.

The `.rvmrc` must be in your `.gitignore` or it could override your setup when deployed.

One problem using the `.rvmrc` solution is you need to `unset LOCAL_ENGINES` when you want to bundle your application for production. I like a bit better the `lebundle` script because it's less magic and more decoupled.


## Setting up local engines

I added a script to facilitate the setup of the local engines by creating a local folder and checking out the repositories from `dev_bootstrap_scripts/local_engines.sh`:

{% highlight bash %}
#!/bin/bash
DIR=local_engines
mkdir $DIR

git clone git@github.com:worldwide_shipping/cargo_estimates.git $DIR/cargo_estimates
git clone git@github.com:worldwide_shipping/shipping_calculator.git $DIR/shipping_calculator
{% endhighlight %}


## Precommit hook to prevent commits of tainted Gemfile.lock
And here's the link up of my git precommit script `dev_bootstrap_scripts/precommit_hooks.sh`:

{% highlight bash %}
#!/bin/bash
ln -s ../../pre_commit.sh .git/hooks/pre-commit
{% endhighlight %}

Currently the `pre_commit.sh` was just calling `no_local_engines_in_gemfile_lock.sh`.

Inside `pre_commit_scripts/no_local_engines_in_gemfile_lock.sh` I use `grep` to locate the string `PATH` in my `Gemfile.lock` indicating a local gem is being used. 

{% highlight bash %}
#!/bin/bash

grep "PATH" Gemfile.lock > /dev/null
if [ $? = 0 ]; then
  echo "==> WARNING"
  echo "==  You have a PATH in your Gemfile.lock! That usually mean that some gems are local to the project!"
  echo "***"
  echo "If you are sure this is what you want you can bypass precommits with 'git commit --no-verify'"
  echo "If the local engines are there because you where developing them, you should run 'bundle' to update Gemfile.lock."
  echo "with the correct dependencies location."
  echo "***"
  exit 1
fi
{% endhighlight %}

## Summary

This worked for me cause I didn't have any local engines when the project was deployed to production. If you have a mix of local and remote gems in your project you will have to come up with a smart regular expression knowledgeable of which dependencies are allowed as a local gem.

I looked in to [git server side hooks](http://git-scm.com/book/en/Customizing-Git-Git-Hooks#Server-Side-Hooks) but hosted version control (github or bitbucket) allow you to run custom scripts.

So precommit git client side hooks require an initial manual bootstrap step but are a really great tool to facilitate development workflow. If you work with local gems I'd like to hear about your workflow in the comments.


{% if page.comments %}
  <div id="disqus_thread"></div>
  <script type="text/javascript">
      /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
      var disqus_shortname = 'enricoteotti'; // required: replace example with your forum shortname

      /* * * DON'T EDIT BELOW THIS LINE * * */
      (function() {
          var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
          dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
          (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
      })();
  </script>
  <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
  <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
{% endif %}

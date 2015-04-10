---
layout: post
title: Ruby on Rails partials are slowing you down
comments: true
tags:
  - ruby-on-rails
---

I was recently checking performance of an application and wondered if an aggressive use of erb partials to break long markup templates in shorter maintainable chunks adds overhead to response times.

Justin Weiss did some benchmarks but I want to document results on a test application using a simple in memory data model and then share the results on my real application in production mode with mongodb connections.

## A test application

I will run this test on a Rails 4.2 app running in production mode. `curl` will hit the same URL and I report the response time from Rails logs. You can find this application on [my github](https://github.com/agenteo/lab-partials-slowing-you-down). I did not involve database or caching to ensure they did not play a role in the benchmark.

As always the first call is significantly slower **549ms**

{% highlight bash %}
I, [2015-03-09T11:45:41.578125 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:45:42.126382 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.7ms)
I, [2015-03-09T11:45:42.127181 #50837]  INFO -- : Completed 200 OK in 549ms (Views: 4.4ms)
{% endhighlight %}

Second call is much faster **50ms**

{% highlight bash %}
I, [2015-03-09T11:46:34.747345 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:46:34.796360 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.3ms)
I, [2015-03-09T11:46:34.797054 #50837]  INFO -- : Completed 200 OK in 50ms (Views: 1.4ms)
{% endhighlight %}

Subsequent calls are stable around **50ms**

{% highlight bash %}
I, [2015-03-09T11:47:03.984770 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:47:04.033530 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.3ms)
I, [2015-03-09T11:47:04.033935 #50837]  INFO -- : Completed 200 OK in 49ms (Views: 0.9ms)
{% endhighlight %}

Now I introduce partials on the first call and get a similar response time **543ms**

{% highlight bash %}
I, [2015-03-09T11:47:40.174517 #50991]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:47:40 -0400
I, [2015-03-09T11:47:40.176238 #50991]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:47:40.716048 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.3ms)
I, [2015-03-09T11:47:40.716243 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716391 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716510 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716623 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716743 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716852 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.716962 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717070 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717186 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717293 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717402 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717521 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717626 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717726 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717829 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717914 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.717996 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718080 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718175 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718254 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718331 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718427 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718505 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718590 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:47:40.718652 #50991]  INFO -- :   Rendered articles/index.html.erb within layouts/application (5.7ms)
I, [2015-03-09T11:47:40.719538 #50991]  INFO -- : Completed 200 OK in 543ms (Views: 10.3ms)
{% endhighlight %}

Second call **49ms**

{% highlight bash %}
I, [2015-03-09T11:48:15.050356 #50991]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:48:15 -0400
I, [2015-03-09T11:48:15.050936 #50991]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:48:15.095831 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.095994 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096116 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096226 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096342 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096445 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096555 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096660 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096761 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096871 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.096975 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097082 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097182 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097288 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097414 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097521 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097625 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097719 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097825 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.097928 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.098036 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.098168 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.1ms)
I, [2015-03-09T11:48:15.098265 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.098355 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.098442 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:15.098513 #50991]  INFO -- :   Rendered articles/index.html.erb within layouts/application (2.8ms)
I, [2015-03-09T11:48:15.099667 #50991]  INFO -- : Completed 200 OK in 49ms (Views: 4.0ms)
{% endhighlight %}

Subsequent calls stable around **50ms**.

### With three partials

{% highlight diff %}
diff --git a/app/views/articles/_article.html.erb b/app/views/articles/_article.html.erb
index fac0108..e0fb7f3 100644
--- a/app/views/articles/_article.html.erb
+++ b/app/views/articles/_article.html.erb
@@ -1,4 +1,4 @@
 <article>
-  <h2><%= article[:title] %></h2>
-  <p><%= article[:body] %></p>
+  <%= render(partial: 'articles/article/title', locals: { title: article[:title] } ) %>
+  <%= render(partial: 'articles/article/body', locals: { body: article[:body] } ) %>
 </article>
diff --git a/app/views/articles/article/_body.html.erb b/app/views/articles/article/_body.html.erb
new file mode 100644
index 0000000..69d8bf3
--- /dev/null
+++ b/app/views/articles/article/_body.html.erb
@@ -0,0 +1 @@
+<p><%= body %></p>
diff --git a/app/views/articles/article/_title.html.erb b/app/views/articles/article/_title.html.erb
new file mode 100644
index 0000000..07c61fa
--- /dev/null
+++ b/app/views/articles/article/_title.html.erb
@@ -0,0 +1 @@
+<h2><%= title %></h2>
{% endhighlight %}

First call still around **550ms**

{% highlight bash %}
I, [2015-03-09T11:55:22.452183 #51383]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:55:22 -0400
I, [2015-03-09T11:55:22.453966 #51383]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:55:23.006269 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.3ms)
I, [2015-03-09T11:55:23.009235 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.2ms)
I, [2015-03-09T11:55:23.009322 #51383]  INFO -- :   Rendered articles/_article.html.erb (6.7ms)
I, [2015-03-09T11:55:23.009530 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.009651 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.009729 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.3ms)
I, [2015-03-09T11:55:23.009870 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.009975 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010023 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.010158 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010279 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010327 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.010481 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010586 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010633 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.010766 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010884 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.010930 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.011104 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011210 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011256 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.011395 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011509 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011556 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.011691 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011807 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.011863 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.011988 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012100 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012146 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.012279 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012363 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012416 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.012525 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012602 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012638 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.012776 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012872 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.012909 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.013033 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013114 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013150 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.013258 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013361 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013397 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.013504 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013602 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013638 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.013746 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013825 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.013860 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.013982 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014062 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014098 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.014219 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014298 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014333 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.014453 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014532 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014567 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.014672 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014767 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014802 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.014907 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.014988 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015037 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.015142 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015219 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015254 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.015372 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015454 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015489 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.015609 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015688 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:55:23.015723 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:55:23.015773 #51383]  INFO -- :   Rendered articles/index.html.erb within layouts/application (16.3ms)
I, [2015-03-09T11:55:23.016680 #51383]  INFO -- : Completed 200 OK in 563ms (Views: 21.2ms)
{% endhighlight %}

Second call:

{% highlight bash %}
I, [2015-03-09T11:56:00.645846 #51383]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:56:00 -0400
I, [2015-03-09T11:56:00.646481 #51383]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:56:00.701164 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.701391 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.701460 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.4ms)
I, [2015-03-09T11:56:00.701606 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.701732 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.701780 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.701907 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702033 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702080 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.702213 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702342 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702389 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.702532 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702640 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702687 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.702801 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702905 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.702952 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.703072 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703180 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703226 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.703365 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703466 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703516 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.703645 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703734 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.703791 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.703927 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704032 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704078 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.704195 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704295 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704343 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.704478 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704580 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704626 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.704744 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704852 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.704898 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.705013 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705154 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705201 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.705340 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705444 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705500 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.705628 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705732 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.705778 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.705913 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706015 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706060 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.706198 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706318 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706364 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.706501 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706601 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706645 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.706761 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706850 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.706895 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.707013 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707117 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707162 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.707275 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707377 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707422 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.707558 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707658 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707703 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.707838 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707939 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.707984 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.708121 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:56:00.708221 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:56:00.708266 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:56:00.708330 #51383]  INFO -- :   Rendered articles/index.html.erb within layouts/application (7.4ms)
I, [2015-03-09T11:56:00.708709 #51383]  INFO -- : Completed 200 OK in 62ms (Views: 8.0ms)
{% endhighlight %}

Subsequent calls:

{% highlight bash %}
I, [2015-03-09T11:57:19.632931 #51383]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:57:19 -0400
I, [2015-03-09T11:57:19.633552 #51383]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:57:19.689377 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.689520 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.689583 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.3ms)
I, [2015-03-09T11:57:19.689709 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.689792 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.689830 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.689948 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690031 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690068 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.690179 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690268 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690305 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.690415 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690501 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690543 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.690651 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690735 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.690790 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.690929 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691044 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691089 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.691227 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691323 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691368 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.691483 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691588 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691633 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.691766 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691864 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.691916 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.692032 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692113 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692148 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.692258 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692338 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692373 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.692487 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692565 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692600 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.692707 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692794 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.692829 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.692936 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693034 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693071 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.693176 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693253 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693288 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.693402 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693486 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693521 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.693631 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693709 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693743 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.693850 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693926 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.693961 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.694062 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694150 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694186 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.694289 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694365 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694400 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.694507 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694583 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694618 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.694724 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694803 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.694838 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.694945 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.695021 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.695056 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.695158 #51383]  INFO -- :   Rendered articles/article/_title.html.erb (0.0ms)
I, [2015-03-09T11:57:19.695240 #51383]  INFO -- :   Rendered articles/article/_body.html.erb (0.0ms)
I, [2015-03-09T11:57:19.695275 #51383]  INFO -- :   Rendered articles/_article.html.erb (0.2ms)
I, [2015-03-09T11:57:19.695323 #51383]  INFO -- :   Rendered articles/index.html.erb within layouts/application (6.2ms)
I, [2015-03-09T11:57:19.695694 #51383]  INFO -- : Completed 200 OK in 62ms (Views: 6.8ms)
{% endhighlight %}


## Impact on a real application

Taking out partials from the application is the most accurate benchmark you can run--be rigurous and run local tests before assuming the change brings any benefit if there is a significant improvement locally deploy and load test it to get a definitive answer. When testing locally account for application and database caching. I've seen garbage collection (GC) manifesting in partial rendering with response time randomly fluctuating like:

{% highlight bash %}
Rendered articles/_article.html.erb (0.2ms)
Rendered articles/_article.html.erb (0.3ms)
Rendered articles/_article.html.erb (0.2ms)
Rendered articles/_article.html.erb (0.4ms)
Rendered articles/_article.html.erb (0.175ms)
Rendered articles/_article.html.erb (0.2ms)
Rendered articles/_article.html.erb (0.3ms)
{% endhighlight %}

if each request has a spike moving around you probably have a garbage collection problem and partials rendering is just where it shows up.

I grouped 4 templates back in to one in my production application and it didn't bring any benefit, it actually made it slightly (30/40ms) slower but I've seen fluctuation like that before so I'd call it a draw.

When trying this on your app remember:

* any first call is always significantly slower because of framework startup and database query costs
* if you restart the database query you will have a slower response
* purge the disk cache: OSX `purge`, Linux `sync && echo 1 > /proc/sys/vm/drop_caches`

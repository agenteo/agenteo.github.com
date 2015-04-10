---
layout: post
title: Ruby on Rails partials are slowing you down
comments: true
tags:
  - ruby-on-rails
---

I was recently checking performance of an application and wondered if an aggressive use of erb partials to break long markup templates in shorter maintainable chunks would slow down response times. In my tests it does but its impact is negligible.

I document results on a test application using an in memory data model and will talk about the results on my real application in production mode with mongodb connections.

## A test application

I run this test on a Rails 4.2 app in production mode, `curl` hits the same URL.

{% highlight ruby %}
def index
  @articles = 25.times.collect do |i|
    { title: "Article #{i}", body: LiterateRandomizer.paragraph, published_at: Time.now }
  end
end
{% endhighlight %}

I use `curl` to hit the same URL and report the **response time** from Rails logs--I did not involve database or caching to ensure they did not play a role in the benchmark and I restarted the application after each test. You can find this application on [my github](https://github.com/agenteo/lab-partials-slowing-you-down). 

The initial test has a controller with a single view and as always the first call is significantly slower **549ms**

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

### Introduce a partial

I now introduce a single partial.

{% highlight diff %}
diff --git a/app/views/articles/_article.html.erb b/app/views/articles/_article.html.erb
new file mode 100644
index 0000000..fac0108
--- /dev/null
+++ b/app/views/articles/_article.html.erb
@@ -0,0 +1,4 @@
+<article>
+  <h2><%= article[:title] %></h2>
+  <p><%= article[:body] %></p>
+</article>
diff --git a/app/views/articles/index.html.erb b/app/views/articles/index.html.erb
index 24938da..f29b38b 100644
--- a/app/views/articles/index.html.erb
+++ b/app/views/articles/index.html.erb
@@ -1,8 +1,5 @@
 <h1>Articles#index</h1>

 <% @articles.each do |article| %>
-  <article>
-    <h2><%= article[:title] %></h2>
-    <p><%= article[:body] %></p>
-  </article>
+  <%= render(partial: 'article', locals: { article: article } ) %>
 <% end %>
{% endhighlight %}

on the first call I get a similar response time **543ms**

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

Also on the second call I get a similar response of **49ms**

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

Now I am breaking up the template in more partials.

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

Second call **62ms**

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

And the subsequent calls are stable around **62ms**.

I can see an impact when introducing 

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

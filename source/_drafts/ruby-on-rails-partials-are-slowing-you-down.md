---
---

## With the partial

First call:

```
15:13:48 web.1  | 10.0.2.2 - - [09/Mar/2015 15:13:48] "GET /content/wedding-photo-advice HTTP/1.1" 200 68274 4.8964
```

Second call:

```
15:14:12 web.1  | 10.0.2.2 - - [09/Mar/2015 15:14:12] "GET /content/wedding-photo-advice HTTP/1.1" 200 68274 1.6964
```

When restarting the db:

```
15:14:46 web.1  | 10.0.2.2 - - [09/Mar/2015 15:14:46] "GET /content/wedding-photo-advice HTTP/1.1" 200 68274 2.6280
```


## Removing a partial

```
--- a/components/public_ui/app/views/public_ui/content_pieces/index.html.erb
+++ b/components/public_ui/app/views/public_ui/content_pieces/index.html.erb
@@ -14,7 +14,11 @@
       <% row_pieces.each do |piece| %>
         <div class="col-lg-3">
           <% if piece.kind_of?(DomainLogic::Content::Piece) %>
-            <%= render partial: 'public_ui/shared/content_piece_card', locals: { content_piece: piece, content_type: piece.kind, row_number: row_number } %>
+            <% if piece.has_primary_image? %>
+              <%= render partial: 'public_ui/shared/cards/with_image', locals: { content_piece: piece, content_type: content_piece_type(piece), row_number: row_number } %>
+            <% else %>
+              <%= render partial: 'public_ui/shared/cards/without_image', locals: { content_piece: piece, content_type: content_piece_type(piece) } %>
+            <% end %>
           <% elsif piece.kind_of?(DomainLogic::ListAd) %>
             <%= render partial: 'shared_ui/ads/list_ad', locals: { ad: piece, viewport_classes: "desktop mobile" } %>
           <% end %>
diff --git a/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb b/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
index bfbe24c..e69de29 100644
--- a/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
+++ b/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
@@ -1,5 +0,0 @@
-<% if content_piece.has_primary_image? %>
-  <%= render partial: 'public_ui/shared/cards/with_image', locals: { content_piece: content_piece, content_type: content_piece_type(content_piece), row_number: row_number } %>
-<% else %>
-  <%= render partial: 'public_ui/shared/cards/without_image', locals: { content_piece: content_piece, content_type: content_piece_type(content_piece) } %>
-<% end %>
```


First call

```
15:08:21 web.1  | 10.0.2.2 - - [09/Mar/2015 15:08:21] "GET /content/wedding-photo-advice HTTP/1.1" 200 68265 4.6813
```

Second call

```
15:08:47 web.1  | 10.0.2.2 - - [09/Mar/2015 15:08:47] "GET /content/wedding-photo-advice HTTP/1.1" 200 68265 1.6679
```

calls after that are stable.

When restarting the database

```
vagrant@weddit-devbox:/app/weddit$ sudo service mongod restart
```

I get:

```
15:09:29 web.1  | 10.0.2.2 - - [09/Mar/2015 15:09:29] "GET /content/wedding-photo-advice HTTP/1.1" 200 68265 2.2997
```

and after that back to:

```
15:10:33 web.1  | 10.0.2.2 - - [09/Mar/2015 15:10:33] "GET /content/wedding-photo-advice HTTP/1.1" 200 68265 1.7394
```


## Removing two partials

```
diff --git a/components/public_ui/app/views/public_ui/content_pieces/index.html.erb b/components/public_ui/app/views/public_ui/content_pieces/index.html.erb
index f6cff8e..17e6a49 100644
--- a/components/public_ui/app/views/public_ui/content_pieces/index.html.erb
+++ b/components/public_ui/app/views/public_ui/content_pieces/index.html.erb
@@ -14,7 +14,7 @@
       <% row_pieces.each do |piece| %>
         <div class="col-lg-3">
           <% if piece.kind_of?(DomainLogic::Content::Piece) %>
-            <%= render partial: 'public_ui/shared/content_piece_card', locals: { content_piece: piece, content_type: piece.kind, row_number: row_number } %>
+            <%= render partial: 'public_ui/shared/cards/with_image', locals: { content_piece: piece, content_type: content_piece_type(piece), row_number: row_number } %>
           <% elsif piece.kind_of?(DomainLogic::ListAd) %>
             <%= render partial: 'shared_ui/ads/list_ad', locals: { ad: piece, viewport_classes: "desktop mobile" } %>
           <% end %>
diff --git a/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb b/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
index bfbe24c..e69de29 100644
--- a/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
+++ b/components/public_ui/app/views/public_ui/shared/_content_piece_card.html.erb
@@ -1,5 +0,0 @@
-<% if content_piece.has_primary_image? %>
-  <%= render partial: 'public_ui/shared/cards/with_image', locals: { content_piece: content_piece, content_type: content_piece_type(content_piece), row_number: row_number } %>
-<% else %>
-  <%= render partial: 'public_ui/shared/cards/without_image', locals: { content_piece: content_piece, content_type: content_piece_type(content_piece) } %>
-<% end %>
diff --git a/components/public_ui/app/views/public_ui/shared/cards/_with_image.html.erb b/components/public_ui/app/views/public_ui/shared/cards/_with_image.html.erb
index b2888c9..86511cf 100644
--- a/components/public_ui/app/views/public_ui/shared/cards/_with_image.html.erb
+++ b/components/public_ui/app/views/public_ui/shared/cards/_with_image.html.erb
@@ -1,15 +1,22 @@
 <div
-  class="photo-card article"
+class="photo-card article <%= content_piece.has_primary_image? ? '' : 'content-without-image' %>"
   data-terms="<%= content_piece.grouped_terms.to_json() %>"
   data-modified-date="<%= content_piece.updated_at %>"
   data-published-date="<%= content_piece.created_at %>"
   data-content-type="<%= raw content_type %>"
   data-author="<%= content_piece.author %>">
+  <% if content_piece.has_primary_image? %>
+  <div class="panel-heading">
+    <h2 class="js-headline"><%= content_piece.page_headline %></h2>
+  </div>
+  <% else %>
   <div class="panel-image">
     <%= hero_image_tag(content_piece, row_number) %>
   </div>
   <div class="panel-heading">
-    <h2 class="js-headline"><%= content_piece.page_headline %></h2>
+    <h2 class="js-headline"><%= sanitize content_piece.page_headline, tags: %w(a) %></h2>
   </div>
+  <p class="read-more"><a href="#">Read More</a></p>
+  <% end %>
   <a class="article-link js-photo-card-link" href="<%= content_piece_path(content_piece.slug) %>"></a>
 </div>
```

First call

```
16:06:04 web.1  | 10.0.2.2 - - [09/Mar/2015 16:06:04] "GET /content/wedding-photo-advice HTTP/1.1" 200 65907 8.0120
```

Second call

```
16:06:13 web.1  | 10.0.2.2 - - [09/Mar/2015 16:06:13] "GET /content/wedding-photo-advice HTTP/1.1" 200 65907 1.7242
```

Third call

```
16:09:51 web.1  | 10.0.2.2 - - [09/Mar/2015 16:09:51] "GET /content/wedding-photo-advice HTTP/1.1" 200 65907 2.2233
```


## A test application

I did not involve database to ensure it did not play a role in this benchmark.

First call:

```
Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:36:46 -0400
Processing by ArticlesController#index as */*
  Rendered articles/index.html.erb within layouts/application (1.6ms)
Completed 200 OK in 607ms (Views: 55.8ms)
```

Second call:

```
Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:37:20 -0400
Processing by ArticlesController#index as */*
  Rendered articles/index.html.erb within layouts/application (0.4ms)
Completed 200 OK in 73ms (Views: 25.8ms)
```

Now rendering a partial:

```
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
```

First call:

```
Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:33:34 -0400
Processing by ArticlesController#index as */*
  Rendered articles/_article.html.erb (0.2ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/index.html.erb within layouts/application (49.2ms)
Completed 200 OK in 605ms (Views: 99.3ms)
```


```
Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:34:21 -0400
Processing by ArticlesController#index as */*
  Rendered articles/_article.html.erb (0.1ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/_article.html.erb (0.0ms)
  Rendered articles/index.html.erb within layouts/application (46.9ms)
Completed 200 OK in 126ms (Views: 73.2ms)
```


## Running in production mode

### No partials

First call

```
I, [2015-03-09T11:45:41.578125 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:45:42.126382 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.7ms)
I, [2015-03-09T11:45:42.127181 #50837]  INFO -- : Completed 200 OK in 549ms (Views: 4.4ms)
```

Second call

```
I, [2015-03-09T11:46:34.747345 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:46:34.796360 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.3ms)
I, [2015-03-09T11:46:34.797054 #50837]  INFO -- : Completed 200 OK in 50ms (Views: 1.4ms)
```

Subsequent calls

```
I, [2015-03-09T11:47:03.984770 #50837]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:47:04.033530 #50837]  INFO -- :   Rendered articles/index.html.erb within layouts/application (0.3ms)
I, [2015-03-09T11:47:04.033935 #50837]  INFO -- : Completed 200 OK in 49ms (Views: 0.9ms)
```


### With partials

First call

```
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
```

Second call

```
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
```

Subsequent calls:


```
I, [2015-03-09T11:48:43.744899 #50991]  INFO -- : Started GET "/articles/index" for 127.0.0.1 at 2015-03-09 11:48:43 -0400
I, [2015-03-09T11:48:43.745491 #50991]  INFO -- : Processing by ArticlesController#index as */*
I, [2015-03-09T11:48:43.796669 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.796796 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.796891 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.796984 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797071 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797154 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797243 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797328 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797410 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797493 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797583 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797682 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797761 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797843 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.797935 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798018 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798098 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798182 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798267 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798344 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798425 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798513 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798591 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798673 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798764 #50991]  INFO -- :   Rendered articles/_article.html.erb (0.0ms)
I, [2015-03-09T11:48:43.798815 #50991]  INFO -- :   Rendered articles/index.html.erb within layouts/application (2.3ms)
I, [2015-03-09T11:48:43.799199 #50991]  INFO -- : Completed 200 OK in 54ms (Views: 3.0ms)
```


### With three partials


```
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
```

First call:


```

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
```



```
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
```

Subsequent calls:

```


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
```


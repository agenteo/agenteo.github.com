---
layout: post
title: Mongo command line client brackets highlighter
comments: true
tags:
  - mongodb
---

Using `mongo` command line client has a portability advantage that no GUI has -- but when creating a long query unmatched parentheses or curly bracket can be hard to find and break your query. If you are using OSX and iTerm you might be missing `mongo` default [bracket highlighting](https://jira.mongodb.org/browse/SERVER-2767).

![]({{ site.url }}assets/article_images/{{ page.url }}no-syntax-highlighting.png)

To make sure it's working open *iTerm -> Preferences* and click on Text tab and **uncheck** the `Draw bold text in bold font` and `Draw bold text in bright colors`:

![iTerm settings]({{ site.url }}assets/article_images/{{ page.url }}i-term-settings.png)

your `mongo` console will now highlight matching parentheses and curly bracket:

![]({{ site.url }}assets/article_images{{ page.url }}mongo-syntax-highlight.gif)

Hovering an extra **curly bracket** will hint at the upcoming syntax error by highlighting an **opening parentheses**:

![]({{ site.url }}assets/article_images{{ page.url }}mongo-syntax-highlight-extra-curly-bracket.gif)

This is not a full syntax highlighter but helps navigating long queries.

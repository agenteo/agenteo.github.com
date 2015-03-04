---
layout: post
title: Mongo command line client highlighter
comments: true
tags:
  - mongodb
---

Using `mongo` command line client has a portability advantage that no GUI has -- but when creating a long query unmatched parentheses or curly bracket can be hard to find and will break yor query. If you are on OSX and using iTerm and solarized you might be missing `mongo` default [bracket highlighting](https://jira.mongodb.org/browse/SERVER-2767).

![]({{ site.url }}assets/article_images/{{ page.url }}no-syntax-highlighting.png)

Open *iTerm -> Preferences* and click on Text tab and uncheck the `Draw bold text in bold font` and `Draw bold text in bright colors`:

![iTerm settings]({{ site.url }}assets/article_images/{{ page.url }}i-term-settings.png)

and your `mongo` console will now have the default highligther:

![when your hovering perentheses or curly bracket it will highlight its match]({{ site.url }}assets/article_images{{ page.url }}mongo-syntax-highlight.gif)

Hovering an extra curly bracket will hint at the upcoming syntax error by highlighting an opening parentheses:

![]({{ site.url }}assets/article_images{{ page.url }}mongo-syntax-highlight-extra-curly-bracket.gif)

This is far from a 
If you are ok leaving the command line [Robomongo](http://robomongo.org/) has a complete syntax highlighter.

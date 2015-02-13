---
layout: page
title: Topics I write about
permalink: /topics/
---

I started blogging about work related topics a couple of years ago, here is a list:
 
<ul>
{% for tag in site.tags %}
  {% assign t = tag | first %}
  <li><a href="/topics/{{ t | downcase }}">{{ t }}</a></li>
{% endfor %}
</ul>

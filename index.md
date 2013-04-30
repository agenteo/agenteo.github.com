---
layout: default
---

<ul class="bxslider">
  <li><img src="/images/code.jpg" title="Ruby source code." /></li>
  <li><img src="/images/books.jpg" title="Some books I've read" /></li>
</ul>

## My work
I am a computer programmer and my objective is to craft maintainable software that delivers business value.

I've been working with a programming language called Ruby and a web framework Ruby on Rails since 2005 creating web applications and services around them.

You can find my full profile on [linked in](http://au.linkedin.com/in/agenteo).
I try to improve my work by reading books about agile, software development, Ruby, web interfaces. I also enjoy taking a peak in to server operations and management to better understand other parts of the industry.

You can see a list of [the books I've read](/work/reading).

## My blog posts
<ul class="posts">
{% for post in site.posts limit: 5 %}
  <div class="post_info">
    <li>
            <a href="{{ post.url }}">{{ post.title }}</a>
            <span>({{ post.date | date:"%Y-%m-%d" }})</span>
    </li>
    </br> <em>{{ post.excerpt }} </em>
    </div>
  {% endfor %}
</ul>

## My hobbies
After work I cook italian food, following house recipes, and sometimes making up my own.  I am a decent pizza maker.

During the weeekend I play lots of beach volleyball.
I am far from being a professional athlete, but I am always after competitive 2 aside games.

When I feel inspired I make short movies about relevant (or invented) events of my live.

<ul class="bxslider">
  <li><img src="/images/pizza.jpg" title="My homemade pizza" /></li>
  <li><img src="/images/beachvolley.jpg" title="Setting up the net" /></li>
</ul>

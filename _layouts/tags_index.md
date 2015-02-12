<!DOCTYPE html>
<html>

  {% include head.html %}

  <body>

    {% include header.html %}

    <!-- content start -->

    <div class="page-content">
      <div class="wrapper">
        {{ content }}
      </div>
    </div>

    {% assign posts = site.tags[page.tag] %}
    {% for post in posts %}
      <article class="post" itemscope itemtype="http://schema.org/BlogPosting" role="article">
        <div class="article-item">
          <header class="post-header">
            <h2 class="post-title" itemprop="name"><a href="{{ post.url }}" itemprop="url">{{ post.title }}</a></h2>
          </header>
          <div class="post-meta">
            <time datetime="{{ post.date | date_to_long_string }}">{{ post.date | date_to_long_string }}</time>
<!--            <span class="post-tags-set">on {{#foreach tags}}<span class="post-tag-{{slug}}">{{#if @first}}{{else}}, {{/if}}<a href="/tag/{{slug}}">{{name}}</a></span>{{/foreach}}</span>-->
          </div>
        <div>
      </article>
    {% endfor %}

    <!-- content end -->

    {% include footer.html %}
    {% include javascripts.html %}

  </body>

</html>


---
---
<!DOCTYPE html>
<html>
  {% include head.html %}
  <body itemscope itemtype="http://schema.org/Article">
    {% include posts/addthis.html %}
    {% include header.html %}
    <main class="content" role="main">
      <article class="post">
        {% if page.image %}
        <div class="article-image">
          <div class="post-image-image" style="background-image: url({% if page.image %}{{ page.image }} {% endif %})" {% if page.image_credit %} data-credit={{ page.image_credit }} {% endif %}>
            Article Image
          </div>
          <div class="post-meta">
            <h1 class="post-title">{{ page.title }}</h1>
            <div class="cf post-meta-text">
              <div class="author-image" style="background-image: url({{ site.author_image }})">Blog Logo</div>
              <h4 class="author-name" itemprop="author" itemscope itemtype="http://schema.org/Person">{{ site.author }}</h4>
              on
              <time datetime="{{ page.date | date: "%F %R" }}">{{ page.date | date_to_string }}</time>
              , tagged on {% for tag in page.tags %} <span class="post-tag-{{tag}}"><a href="/topics/{{tag}}">{{tag}}</a></span>{% endfor %}
            </div>
            <div style="text-align:center">
              <a href="#topofpage" class="topofpage"><i class="fa fa-angle-down"></i></a>
            </div>
          </div>
        </div>
        {% else %}
        <div class="noarticleimage">
          <div class="post-meta">
            <h1 class="post-title">{{ page.title }}</h1>
            <div class="cf post-meta-text">
              <div class="author-image" style="background-image: url({{ site.author_image }})">Blog Logo</div>
              <h4 class="author-name" itemprop="author" itemscope itemtype="http://schema.org/Person">{{ page.author }}</h4>
              on
              <time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date_to_string }}</time>
              , tagged on {% for tag in page.tags %} <span class="post-tag-{{tag}}"><a href="/topics/{{tag}}">{{tag}}</a></span>{% endfor %}
            </div>
          </div>
        </div>
        <br>
        <br>
        <br>
        {% endif %}
        <section class="post-content">
          <div class="post-reading">
            <span class="post-reading-time"></span> read
          </div>
          <a name="topofpage"></a>
          {{content}}
        </section>
        <footer class="post-footer">
          <section class="share">
            <a href="https://twitter.com/share" class="twitter-share-button" data-via="agenteo" data-size="large" data-count="none" data-dnt="true">Tweet</a>
            <a href="https://twitter.com/agenteo" class="twitter-follow-button" data-show-count="false" data-size="large" data-dnt="true">Follow @agenteo</a>
            <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
          </section>
        </footer>
        
        <div class="page-content">
          {% if page.previous %}
          <h3>Next up:</h3>
          <div class="wrapper">
            <main class="content" role="main">
              <header class="post-header">
                <div class="article-item">
                  <h2 class="post-title" itemprop="name"><a href="{{ page.previous.url }}" itemprop="url">{{ page.previous.title }}</a></h2>
                </div>
              </header>
            </main>
          </div>
          {% endif %}
          <h3>More reads about {% for tag in page.tags %} <a href="/topics/{{tag}}">{{tag}}</a>, {% endfor %} <a href="/topics">other topics</a></h3>
      </div>
        {% include posts/comments.html %}        
      </article>
    </main>
    <div class="bottom-closer">
      <div class="background-closer-image" {%if site.cover %} style="background-image: url({{ site.cover }})"{% endif %}>
        Image
      </div>
      <div class="inner">
        <h1 class="blog-title">{{ site.author }}</h1>
        <h2 class="blog-description">{{ site.description }}</h2>
        <a href="https://enricoteotti.com" class="btn">Work with me</a>
        <a href="/" class="btn">Back to Overview</a>
      </div>
    </div>
    {% include javascripts.html %}
  </body>
</html>

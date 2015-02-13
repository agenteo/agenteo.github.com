<!DOCTYPE html>
<html>

  {% include head.html %}

  <body>

    {% include header.html %}

    <!-- content start -->
    
    <header class="blog-header">
      <h1 class="blog-title">Posts about {{ page.tag }}</h1>
    </header>

    <div class="page-content">
      <div class="wrapper">
        <main class="content" role="main">
          {% assign posts = site.tags[page.tag] %}
          {% for post in posts %}
            {% include article.html %}
          {% endfor %}
        <h3><a href="/topics">View other topics</a></h3>
        </main>
      </div>
    </div>


    <!-- content end -->

    {% include footer.html %}
    {% include javascripts.html %}

  </body>

</html>


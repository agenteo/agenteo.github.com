<!DOCTYPE html>
<html>

  {% include head.html %}

  <body>

    {% include header.html %}

    <!-- content start -->

    <div class="page-content">
      <div class="wrapper">
        <main class="content" role="main">
          {% assign posts = site.tags[page.tag] %}
          {% for post in posts %}
            {% include article.html %}
          {% endfor %}
        </main>
      </div>
    </div>


    <!-- content end -->

    {% include footer.html %}
    {% include javascripts.html %}

  </body>

</html>


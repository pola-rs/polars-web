{% extends "base.tpl" %}

{% block main %}
<article>
  <div class="container">

    {% for post in posts %}
    <section class="post" onclick="window.location='{{ post.post_href }}';">
    
      <a href="{{ post.post_href }}"><h2>{{ post.title }}</h2></a>
    
      {% if post.auth_href is defined %}
      <p>by <a href="{{ post.auth_href }}">{{ post.authors }}</a></p>
      {% else %}
      <p>by {{ post.authors }}</p>
      {% endif %}
    
      {% if post.tldr is defined %}
      <p>{{ post.tldr }}</p>
      {% endif %}
    
    </section>
    {% endfor %}

  </div>
</article>
{% endblock %}

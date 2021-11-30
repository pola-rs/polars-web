{% extends "base.tpl" %}

{% block main %}
<article class="padded pure-g">
  <div class="pure-u-1 pure-u-lg-1-5"></div>
  <div class="pure-u-1 pure-u-lg-3-5">

    {% for post in posts %}
    <section class="padded-v post" onclick="window.location='{{ post.post_href }}';">
    
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
  <div class="pure-u-1 pure-u-md-1-5 pure-u-lg-1-5"></div>
</article>
{% endblock %}

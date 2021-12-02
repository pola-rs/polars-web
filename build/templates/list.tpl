{% extends "base.tpl" %}

{% block main %}
<article>
  <div class="container">

    {% for year, items in posts.items() %}
    <p class="pl-year">{{ year }}</p>

    {% for item in items %}
    <section class="pl-excerpt" onclick="window.location='{{ item.post_href }}';">
      <div>
    
        <a href="{{ item.post_href }}"><h2>{{ item.title }}</h2></a>
     
        {% if item.auth_href is defined %}
        <p>by <a href="{{ item.auth_href }}">{{ item.authors }}</a></p>
        {% else %}
        <p>by {{ item.authors }}</p>
        {% endif %}
     
        {% if item.tldr is defined %}
        <p>{{ item.tldr }}</p>
        {% endif %}
    
      </div>
    </section>
    {% endfor %}
    {% endfor %}

  </div>
</article>
{% endblock %}

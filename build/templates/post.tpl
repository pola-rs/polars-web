{% extends "base.tpl" %}

{% block head %}
<link rel="stylesheet" href="/style-post.css" />
{% endblock %}

{% block main %}
<article>
  <div class="container">
    <div class="pl-post">{{ post }}</div>
  </div>
</article>
{% endblock %}

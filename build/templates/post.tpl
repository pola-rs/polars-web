{% extends "base.tpl" %}

{% block head %}
<link rel="stylesheet" href="/style-markdown.css" />
<link rel="stylesheet" href="/style-mermaid.css" />
<link rel="stylesheet" href="style.css" />
{% endblock %}

{% block main %}
<article>
  <div class="container">
    <div class="pl-post">{{ post }}</div>
  </div>
</article>
{% endblock %}

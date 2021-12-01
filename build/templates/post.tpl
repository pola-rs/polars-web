{% extends "base.tpl" %}

{% block head %}
<link rel="stylesheet" href="/style-markdown.css" />
<link rel="stylesheet" href="/style-mermaid.css" />
<link rel="stylesheet" href="style.css" />
{% endblock %}

{% block main %}
<article>
  <div class="container">{{ post }}</div>
</article>
{% endblock %}

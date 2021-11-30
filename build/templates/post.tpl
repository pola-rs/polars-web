{% extends "base.tpl" %}

{% block head %}
<link rel="stylesheet" href="style.css" />
{% endblock %}

{% block main %}
<article class="padded pure-g">
  <div class="pure-u-1 pure-u-lg-1-5"></div>
  <div class="pure-u-1 pure-u-lg-3-5">{{ post }}</div>
  <div class="pure-u-1 pure-u-lg-1-5"></div>
</article>
{% endblock %}

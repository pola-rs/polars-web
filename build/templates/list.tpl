{% extends "base.tpl" %}

{% block main %}
<article>
  <div class="container">

    {% for year, items in posts.items() %}
    <p class="pl-year">{{ year }}</p>

    {% for item in items %}
    <section class="pl-excerpt">
      <div>
        <div>
          <a href="{{ item.post_href }}"><h2>{{ item.title }}</h2></a>

          <p>
          {%- if item.auth_href is defined -%}
          by <a href="{{ item.auth_href }}">{{ item.authors }}</a>
          {%- else -%}
          by {{ item.authors }}
          {%- endif -%}
          &nbsp;
          {%- if item.date is not none -%}
          on {{ item.date.m }}. {{ item.date.d }}
          {%- endif -%}
          </p>
         
          {% if item.tldr is defined %}
          <p>{{ item.tldr }}</p>
          {% endif %}
    
        </div>

        {% if item.thumbnail is not none %}
        <div>
          <a href="{{ item.post_href }}"><img src="{{ item.thumbnail }}" /></a>
        </div>
        {% endif %}
      </div>
    </section>
    {% endfor %}
    {% endfor %}

  </div>
</article>
{% endblock %}

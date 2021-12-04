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
          <a href="{{ item.url_post }}"><h2>{{ item.title }}</h2></a>

          <p>
          {%- if item.url_auth is not none -%}
          by <a href="{{ item.ur_auth }}">{{ item.authors }}</a>
          {%- else -%}
          by {{ item.authors }}
          {%- endif -%}
          &nbsp;
          {%- if item.date is not none -%}
          on {{ item.date.m }}. {{ item.date.d }}
          {%- endif -%}
          </p>
         
          {% if item.blurb is defined %}
          <p>{{ item.blurb }}</p>
          {% endif %}
    
        </div>

        {% if item.img is not none %}
        <div>
          <a href="{{ item.url_post }}"><img src="{{ item.img }}" /></a>
        </div>
        {% endif %}
      </div>
    </section>
    {% endfor %}
    {% endfor %}

  </div>
</article>
{% endblock %}

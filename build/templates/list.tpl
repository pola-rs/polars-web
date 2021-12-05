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
          <a href="{{ item.endpoint }}"><h2>{{ item.title }}</h2></a>

          <p>
          {%- if item.authurl is not none -%}
          by <a href="{{ item.ur_auth }}">{{ item.authors }}</a>
          {%- else -%}
          by {{ item.authors }}
          {%- endif -%}
          &nbsp;
          {%- if item.date is not none -%}
          on {{ item.date.month }}. {{ item.date.day }}
          {%- endif -%}
          </p>
         
          <p>{{ item.blurb }}</p>
    
        </div>

        {% if item.image is not none %}
        <div>
          <a href="{{ item.endpoint }}"><img src="{{ item.image }}" /></a>
        </div>
        {% endif %}
      </div>
    </section>
    {% endfor %}
    {% endfor %}

  </div>
</article>
{% endblock %}

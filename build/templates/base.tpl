<!DOCTYPE html>
<html lang="en">

  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    {% include "meta.tpl" %}
    <title>Polars</title>
    {% if canonical is not none %}
    <link rel="canonical" href="{{ canonical }}" />
    {% endif %}
    {% if theme is undefined or theme is none %}
    <script>
      function setTheme(name) {
        localStorage.setItem("theme", name);
        document.documentElement.className = name;
      }

      function toggleTheme() {
        if (localStorage.getItem("theme") === "light") {
          setTheme("dark_dimmed");
        } else {
          setTheme("light");
        }
      }

      if (
        localStorage.getItem("theme") === "dark_dimmed" ||
        (!("theme" in localStorage) &&
          window.matchMedia("(prefers-color-scheme: dark)").matches)
      ) {
        setTheme("dark_dimmed");
      } else {
        setTheme("light");
      }
    </script>
    {% else %}
    <script>
      localStorage.setItem("theme", {{ theme }});
      document.documentElement.className = {{ theme }};
    </script>
    {% endif %}
    <script src="https://cdnjs.cloudflare.com/ajax/libs/axios/0.21.4/axios.min.js"></script>
    <script
      defer
      src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.3.1/highlight.min.js"
      onload="hljs.highlightAll();"
    ></script>
    <script
      defer
      src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.15.0/katex.min.js"
    ></script>
    <script
      defer
      src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.15.0/contrib/auto-render.min.js"
      onload="renderMathInElement(
        document.body, {
          delimiters: [
            {left: '$$', right: '$$', display: true},
            {left: '$', right: '$', display: false},
          ]
        }
      );"
    ></script>
    <script
      defer
      src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/8.13.3/mermaid.min.js"
      onload="mermaid.initialize();"
    ></script>
    <link rel="icon" type="image/png" href="/favicon.png" />
    <link rel="stylesheet" href="/style.css" />
    {% block head %}{% endblock %}
  </head>

  <body>

    <nav>
      <div class="container">

        <div class="menu">

          <img
            class="pl-logo"
            onclick="window.location='/';"
            src="https://raw.githubusercontent.com/carnarez/polars-static/master/logos/polars-logo-dimmed.svg"
          />

          <div class="pl-buttons">
            <ul>

              <li class="text" onclick="this.classList.toggle('selected');">
                <a>API</a>
                <ul>
                  <li class="text">
                    <a href="https://pola-rs.github.io/polars/polars/">Rust</a>
                  </li>
                  <li class="text">
                    <a
                      href="https://pola-rs.github.io/polars/py-polars/html/reference/"
                    >Python</a>
                  </li>
                </ul>
              </li>

              <li class="text">
                <a href="https://pola-rs.github.io/polars-book/user-guide/">User Guide</a>
              </li>
            <li class="text">
                <a href="/benchmarks.html">TPCH Benchmarks</a>
            </li>

              <li class="text"><a href="/posts">Posts</a></li>

              <li class="icon">
                <a
                  href="https://github.com/pola-rs/polars/"
                  title="GitHub"
                ><i class="fab fa-github"></i></a>
              </li>

              <li class="icon">
                <a
                  href="https://discord.com/invite/4UfP5cfBE7"
                  title="Discord"
                ><i class="fab fa-discord"></i></a>
              </li>

              <li class="icon">
                <a
                  href="https://twitter.com/DataPolars"
                  title="Twitter"
                ><i class="fab fa-twitter"></i></a>
              </li>

              {% if theme is undefined or theme is none %}
              <li class="icon">
                <a
                  class="theme-switcher" onclick="toggleTheme()"
                  title="Dark/Light Theme"
                ><i class="fas fa-adjust"></i></a>
              </li>
              {% else %}
              <li class="icon"><a><i class="far fa-circle"></i></a></li>
              {% endif %}

            </ul>
          </div>

        </div>

      </div>
    </nav>

    {% block header %}{% endblock %}

    <main>
      {% block main required %}{% endblock %}
    </main>

    <footer>
      <div class="container">

        <div class="pl-links">
          Visit the <a href="https://github.com/pola-rs">Pola-rs GitHub Organization</a>
        </div>

      </div>
    </footer>

  </body>
</html>

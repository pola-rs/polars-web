{% extends "base.tpl" %}

{% block header %}
<header>
  <div class="pl-splash">

    <h1>Pola<span class="rust-color">rs</span></h1>

    <h2>Lightning-fast DataFrame library for Rust and Python</h2>

    <div>
      <div class="github-button">
        <a href="https://github.com/pola-rs/polars/"><i class="far fa-star"></i>Star</a>
        <a
          href="https://github.com/pola-rs/polars/stargazers/"
          id="stargazers"
          ><i class="fas fa-sync"></i
        ></a>
      </div>
      <div class="github-button">
        <a href="https://github.com/pola-rs/polars/fork"><i class="fas fa-code-branch"></i>Fork</a>
        <a href="https://github.com/pola-rs/polars/fork" id="forks"><i class="fas fa-sync"></i></a>
      </div>
    </div>

  </div>

  <script>
    let s = document.getElementById("stargazers"),
        f = document.getElementById("forks");

    axios
      .get("https://api.github.com/repos/pola-rs/polars")
      .then((resp) => {
        s.innerHTML =
          (resp.data.stargazers_count / 1000).toFixed(1) + "k";
        f.innerHTML = resp.data.forks_count;
      });
  </script>

</header>
{% endblock %}

{% block main %}
<section>
  <div class="container">
    <div class="columns">

      <div class="pl-details">
        <div>
          <h3><i class="fab fa-python"></i>Familiar from the start</h3>
          <p>
            Knowing of data wrangling habits, Polars exposes a complete Python
            API, including the full set of features to manipulate DataFrames
            using an expression language that will empower you to create
            readable and performant code.
          </p>
        </div>
        <div>
          <div>
            <img
              height="80px"
              src="https://raw.githubusercontent.com/pola-rs/polars-static/master/web/polars-logo-python.svg"
            />
          </div>
          <div>
            <a href="https://pola-rs.github.io/polars-book/user-guide/">User Guide</a>
            &amp;
            <a
              href="https://pola-rs.github.io/polars/py-polars/html/reference/"
            >API Reference</a>
          </div>
        </div>
      </div>

      <div class="pl-details">
        <div>
          <h3><i class="fab fa-rust"></i>DataFrames to the Rust ecosystem</h3>
          <p>
            Polars is written in Rust, uncompromising in its choices to
            provide a feature-complete DataFrame API to the Rust ecosystem.
            Use it as a DataFrame library or as query engine backend for your
            data models.
          </p>
        </div>
        <div>
          <div>
            <img
              height="80px"
              src="https://raw.githubusercontent.com/pola-rs/polars-static/master/web/polars-logo-rust.svg"
            />
          </div>
          <div>
            <a href="https://pola-rs.github.io/polars-book/user-guide/">User Guide</a>
            &amp;
            <a href="https://docs.rs/polars/latest/polars/">API Reference</a>
          </div>
        </div>
      </div>

      <div class="pl-details">
        <div>
          <h3><i class="fas fa-award"></i>On the shoulders of a giant</h3>
          <p>
            Polars is built upon the
            <a
              href="https://github.com/jorgecarleitao/arrow2"
            >safe Arrow2 implementation</a>
            of the
            <a
              href="https://arrow.apache.org/docs/format/Columnar.html"
            >Apache Arrow specification</a>,
            enabling efficient resource use and processing performance. By
            doing so it also integrates seamlessly with other tools in the
            Arrow ecosystem.
          </p>
        </div>
        <div>
          <div>
            <img
              height="80px"
              src="https://raw.githubusercontent.com/pola-rs/polars-static/master/web/arrow-logo.svg"
            />
          </div>
          <div>
            <a href="https://arrow.apache.org/">Official website</a>
          </div>
        </div>
      </div>

    </div>
  </div>
</section>

<section class="ribbon">
  <div class="container">

    <div class="pl-intro">
      <h2>Welcome to fast data wrangling</h2>
      <p>
        Polars is a lightning fast DataFrame library/in-memory query engine.
        Its embarrassingly parallel execution, cache efficient algorithms
        and expressive API makes it perfect for efficient data wrangling,
        data pipelines, snappy APIs and so much more.
      </p>

      <p>
        Polars is about as fast as it gets, see the results in the H2O.ai
        <a href="https://h2oai.github.io/db-benchmark/">benchmark</a>.
      </p>
    </div>

  </div>
</section>

<section>
  <div class="container">

    <div class="columns">

      <div class="pl-code">
        <h3><i class="fab fa-rust"></i>Rust</h3>
        <p>Below a quick demonstration of Polars API in Rust.</p>
        <pre><code class="language-rust">use polars::prelude::*;

fn example() -&gt; Result&lt;DataFrame, PolarsError&gt; {
    LazyCsvReader::new("foo.csv")
        .has_header(true)
        .finish()?
        .filter(col("bar").gt(lit(100)))
        .groupby(vec![col("ham")])
        .agg(vec![col("spam").sum(), col("ham").sort(false).first()])
        .collect()
}</code></pre>
      </div>

      <div class="pl-code">
        <h3><i class="fab fa-python"></i>Python</h3>
        <p>Below a quick demonstration of Polars API in Python.</p>
        <pre><code class="language-python">import polars as pl

q = (
    pl.scan_csv("iris.csv")
    .filter(pl.col("sepal_length") &gt; 5)
    .groupby("species")
    .agg(pl.all().sum())
)

df = q.collect()</code></pre>
      </div>

    </div>

  </div>
</section>

<section>
  <div class="container">
    <div class="columns">

      <div class="pl-contribs">
        <h3><i class="fas fa-user-astronaut"></i>Contributors</h3>
        <div id="contributors"></div>
        <a href="https://github.com/pola-rs/polars/graphs/contributors">and more...</>
      </div>

      <div class="pl-sponsors">
        <h3><i class="fas fa-life-ring"></i>Sponsors</h3>
        <p>
          <a
            href="https://www.xomnia.com/"
          ><img
            src="https://raw.githubusercontent.com/pola-rs/polars-static/master/sponsors/xomnia.png"
            title="Xomnia"
          /></a>
          <a
            href="https://ponte.energy"
          ><img
            src="https://raw.githubusercontent.com/pola-rs/polars-static/master/sponsors/ponte_energy_partners.png"
            title="Ponte Energy Partners"
          /></a>
          <a
            href="https://databento.com/"
          ><img
            src="https://raw.githubusercontent.com/pola-rs/polars-static/master/sponsors/databento-sponsorship-logo.png"
            title="databento"
          /></a>
        </p>
      </div>

    </div>
  </div>

  <script>
    let e = document.getElementById("contributors");

    axios
      .get(
        "https://api.github.com/repos/pola-rs/polars/contributors?per_page=40"
      )
      .then((resp) => {
        resp.data.forEach((c) => {
          e.innerHTML +=
            '<a href="' +
            c.html_url +
            '" title="' +
            c.login +
            '"><img src="' +
            c.avatar_url +
            '&s=80" /></a>';
        });
      });
  </script>

</section>
{% endblock %}

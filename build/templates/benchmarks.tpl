{% extends "base.tpl" %}

{% block head %}
    <link rel="stylesheet" href="style.css"/>
    <link rel="stylesheet" href="style-benchmark.css"/>
{% endblock %}

{% block main %}

    <section class="ribbon">
        <div class="container">

            <div class="pl-intro">
                <h2>TPCH Benchmark</h2>
                <p>
                    Polars was benchmarked against several other solutions on the TPCH benchmark scale factor 10.
                    All queries are open source and up open for PR's <a href="https://github.com/pola-rs/tpch">here</a>.
                    The benchmarks ran on a <a
                        href="https://cloud.google.com/compute/docs/general-purpose-machines#n2-high-mem">GCP
                    n2-highmem-16</a>.

                    This is still a work in progress and more questions will be coming soon.
                </p>

            </div>
            <div class="result-container">
                <h2>Results including reading parquet (lower is better)</h2>
                <img src="https://raw.githubusercontent.com/pola-rs/polars-static/master/benchmarks/tpch/sf_10_and_io.png"
                     alt="tpch sf 10 and IO" class="center">
            </div>

            <div class="result-container">
                <h2>Results starting from in-memory data (lower is better)</h2>
                <img src="https://raw.githubusercontent.com/pola-rs/polars-static/master/benchmarks/tpch/sf_10.png"
                     alt="tpch sf 10" class="center">
            </div>
        </div>
    </section>

{% endblock %}

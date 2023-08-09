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

                    This is still a work in progress and more queries will be coming soon.
                </p>

                <h2>Rules</h2>
                <p>
                The original TPCH benchmark is intended for SQL databases and doesn't allow any modification on the SQL
                of that question. We are trying to benchmark of SQL front-ends and DataFrame front-ends, so the original
                rules have to be modified a little.

                We believe that the SQL queries should be translated semantically to the idiomatic query of the host tool.
                To do this we adhere to the following rules:
                <ul>
                    <li>
                        Operations (like joins, projections and filters) may not be reordered.
                    </li>
                    <li>
                        It is not allowed to insert new operations, e.g. no pruning a table before a join.
                    </li>
                    <li>
                        Every solution must provide 1 query per question independent of the data source.
                    </li>
                    <li>
                        Every solution must provide 1 query per question independent of the data source.
                    </li>
                    <li>
                        The solution must call its own API.
                    </li>
                    <li>
                        It is allowed to declare the type of join as this fits semantical reasoning in DataFrame API's
                    </li>
                    <li>
                        A solution must choose a single engine/mode for all the queries.
                        It is allowed to propose different solutions of the same vendor, e.g. polars-sql, polars-default, polars-streaming.
                        However these solutions should run all the queries, showing their strengths and weaknesses, no cherry picking.
                    </li>
                </ul>

                </p>

                <h2>Notes</h2>
                <p>
                    Note that vaex was not able to finish all queries due to internal errors or unsupported functionality
                    (e.g. joining on multiple columns).
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

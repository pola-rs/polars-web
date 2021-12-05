{%- set default_title = "Polars, lightning-fast DataFrame library" -%}
{%- set default_blurb = "Polars is a blazingly fast DataFrame library completely written in Rust, using the Apache Arrow memory model. It exposes bindings for the popular Python and soon JavaScript languages. Polars supports a full lazy execution API allowing query optimization." -%}
{%- set default_url = "https://www.pola.rs/" -%}
{%- set default_img = "https://raw.githubusercontent.com/pola-rs/polars-static/master/web/splash.png" -%}

<meta name="description" content="{{ blurb or default_blurb }}" />
<meta name="title" content="{{ title or default_title }}" />

<meta property="og:description" content="{{ blurb or default_blurb }}" />
<meta property="og:image" content="{{ img or default_img }}" />
<meta property="og:title" content="{{ title or default_title }}" />
<meta property="og:type" content="website" />
<meta property="og:url" content="{{ url or default_url }}" />

<meta property="twitter:card" content="summary_large_image" />
<meta property="twitter:description" content="{{ blurb or default_blurb }}" />
<meta property="twitter:image" content="{{ img or default_img }}" />
<meta property="twitter:title" content="{{ title or default_title }}" />
<meta property="twitter:url" content="{{ url or default_url }}" />

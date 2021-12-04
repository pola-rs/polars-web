---
title: Talk @ Bristech Bytesize Conference
tldr: Bristech Bytesize #17: Polars, the fastest DataFrame library you never heard of...
      Panel with Joris van den Bossche (software engineer at Voltron Data) & Jorge C.
      Leitão (co-founder and data scientist at Munin Data).
authors: ritchie46
link: https://github.com/ritchie46
thumbnail: bristech.png
---

# Polars DataFrame library built on Apache Arrow

<iframe
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
  allowfullscreen
  frameborder="0"
  height="315"
  src="https://www.youtube-nocookie.com/embed/XAU3dUjaX38"
  width="560"
>
</iframe>

Polars, the fastest DataFrame library you never heard of...

This talk will introduce Polars, a blazingly fast DataFrame library written in Rust on
top of Apache Arrow. Its a DataFrame library that brings exploratory data analysis
closer to the lessons learned in database research.

CPU's today's come with many cores and with their superscalar designs and SIMD
registers allow for even more parallelism. Polars is written from the ground up to
fully utilize the CPU's of this generation.

Besides blazingly fast algorithms, cache efficient memory layout and multi-threading,
it consists of a lazy query engine, allowing Polars to do several optimizations that
may improve query time and memory usage.

_Talk organized by [Bristech](https://bris.tech/) as part of their monthly
[Meetup](https://www.meetup.com/bristech/events/279653542/) sessions._

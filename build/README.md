# Module `render`

Template script to render Markdown to HTML. Fanciness included.

**Functions:**

* [`render_all_posts()`](#renderrender_all_posts): Render each post using the associated template.
* [`render_post_list()`](#renderrender_post_list): Render the list of posts using the associated template.
* [`render_homepage()`](#renderrender_homepage): Render the landing page using the associated template.

## Functions

### `render.render_all_posts`

```python
render_all_posts(path: str, tmpl_name: str):
```

Render each post using the associated template.

Each Markdown file will be converted to HTML; named identically, different
extension. On the way fills in the `meta` list (describing each post).

**Parameters:**

* `path` [`str`]: Root folder to [recursively] fetch the files to process from. Defaults to `.`.
* `tmpl_name` [`str`]: Name of the template to use. Defaults to `post.html`.

**Notes:**

This is a stateful function!

### `render.render_post_list`

```python
render_post_list(path: str, tmpl_name: str):
```

Render the list of posts using the associated template.

**Parameters:**

* `path` [`str`]: Target path the list will be rendered and outputted to. Defaults to
    `posts/index.html`.
* `tmpl_name` [`str`]: Name of the template to use. Defaults to `post.html`.

**Notes:**

This is a stateful function!

### `render.render_homepage`

```python
render_homepage(path: str, tmpl_name: str):
```

Render the landing page using the associated template.

**Parameters:**

* `path` [`str`]: Target path the landing page will be rendered and outputted to. Defaults to
    `index.html`.
* `tmpl_name` [`str`]: Name of the template to use. Defaults to `home.html`.

**Notes:**

This is a stateful function!

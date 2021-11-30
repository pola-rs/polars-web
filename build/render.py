"""Template script to render Markdown to HTML. Fanciness included."""

import glob
import re
import sys
import typing

from jinja2 import Environment, FileSystemLoader

from markdown import Markdown
from markdown.extensions import Extension
from markdown.extensions.footnotes import FootnoteExtension
from markdown.extensions.md_in_html import MarkdownInHtmlExtension
from markdown.extensions.meta import MetaExtension
from markdown.extensions.tables import TableExtension
from markdown.extensions.toc import TocExtension
from pymdownx.caret import InsertSupExtension
from pymdownx.highlight import HighlightExtension
from pymdownx.superfences import SuperFencesCodeExtension, fence_div_format
from pymdownx.tilde import DeleteSubExtension

exts: typing.List[Extension] = [
    DeleteSubExtension(),
    FootnoteExtension(),
    HighlightExtension(use_pygments=False),
    InsertSupExtension(),
    MarkdownInHtmlExtension(),
    MetaExtension(),
    SuperFencesCodeExtension(
        custom_fences=[
            {"name": "mermaid", "class": "mermaid", "format": fence_div_format}
        ]
    ),
    TableExtension(),
    TocExtension(),
]

jenv: Environment = Environment(
    loader=FileSystemLoader("templates" if len(sys.argv) < 3 else sys.argv[2])
)

meta: typing.List[typing.Dict[str, str]] = []


def render_all_posts(path: str = ".", tmpl_name: str = "post.html"):
    """Render each post using the associated template.

    Each Markdown file will be converted to HTML; named identically, different
    extension. On the way fills in the `meta` list (describing each post).

    Parameters
    ----------
    path : str
        Root folder to [recursively] fetch the files to process from. Defaults to `.`.
    tmpl_name : str
        Name of the template to use. Defaults to `post.html`.

    Notes
    -----
    This is a stateful function!
    """
    mdwn = Markdown(extensions=exts)
    tmpl = jenv.get_template(tmpl_name)

    for p in sorted(glob.glob(f"{path}/**/*.md", recursive=True)):
        sys.stderr.write(f"{p}\n")

        with open(p) as f:
            post = mdwn.convert(f.read())

        with open(re.sub(".md$", ".html", p), "w") as f:
            f.write(tmpl.render(extra_css_allowed=True, post=post, theme="light"))

        if mdwn.Meta.get("listed", [""])[0].lower() not in ["false", "off", "no"]:
            meta.append(
                {
                    "authors": ", ".join(mdwn.Meta["authors"]),
                    "auth_href": mdwn.Meta.get("link", [""])[0],
                    "post_href": "/".join(p.replace(path, "").split("/")[:-1]),
                    "title": " ".join(mdwn.Meta["title"]),
                    "tldr": " ".join(mdwn.Meta.get("tldr", [""])),
                }
            )


def render_post_list(path: str = "posts/index.html", tmpl_name: str = "list.html"):
    """Render the list of posts using the associated template.

    Parameters
    ----------
    path : str
        Target path the list will be rendered and outputted to. Defaults to
        `posts/index.html`.
    tmpl_name : str
        Name of the template to use. Defaults to `post.html`.

    Notes
    -----
    This is a stateful function!
    """
    tmpl = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(tmpl.render(posts=meta))


def render_homepage(path: str = "index.html", tmpl_name: str = "home.html"):
    """Render the landing page using the associated template.

    Parameters
    ----------
    path : str
        Target path the landing page will be rendered and outputted to. Defaults to
        `index.html`.
    tmpl_name : str
        Name of the template to use. Defaults to `home.html`.

    Notes
    -----
    This is a stateful function!
    """
    tmpl = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(tmpl.render(posts=meta))


if __name__ == "__main__":
    render_all_posts(sys.argv[1])
    render_post_list(f"{sys.argv[1]}/posts/index.html")
    render_homepage(f"{sys.argv[1]}/index.html")
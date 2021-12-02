"""Script to render the Polars landing page(s). Limited fanciness included."""

import glob
import re
import sys
import typing

from jinja2 import Environment, FileSystemLoader, Template

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

meta: typing.Dict[str, typing.List[typing.Dict[str, str]]] = {}


def render_all_posts(path: str = ".", tmpl_name: str = "post.tpl"):
    """Render each post using the associated template.

    Each Markdown file will be converted to HTML; named identically, different
    extension. On the way fills in the `meta` object describing the post.

    The 

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
    tmpl: Template = jenv.get_template(tmpl_name)
    when: typing.List[str] = []

    for p in sorted(glob.glob(f"{path}/**/*.md", recursive=True)):
        mdwn = Markdown(extensions=exts)
        newp = re.sub(".md$", ".html", p)

        try:
            year = str(int(p.replace(f"{path}/posts/", "").split("/")[0][:4]))
        except ValueError:
            year = "misc"

        if year not in meta:
            if year != "misc":
                when.append(year)
            meta[year] = []

        with open(p) as f:
            post = mdwn.convert(f.read())

        with open(newp, "w") as f:
            f.write(tmpl.render(post=post, theme="light"))

        # nasty one-liner
        if mdwn.Meta.get("rendered", [""])[0].lower() not in [
            "false",
            "off",
            "no",
        ] and p.endswith("index.md"):
            meta[year].append(
                {
                    "authors": ", ".join(mdwn.Meta["authors"]),
                    "auth_href": mdwn.Meta.get("link", [""])[0],
                    "post_href": "/".join(p.replace(path, "").split("/")[:-1]),
                    "title": " ".join(mdwn.Meta["title"]),
                    "tldr": " ".join(mdwn.Meta.get("tldr", [""])),
                }
            )

        sys.stderr.write(f"{newp}\n")

    # most recent first
    for year in sorted(when, reverse=True) + ["misc"]:
        l = meta.pop(year)
        meta[year] = l[::-1]


def render_post_list(path: str = "posts/index.html", tmpl_name: str = "list.tpl"):
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

    sys.stderr.write(f"{path}\n")


def render_game_page(path: str = "game.html", tmpl_name: str = "game.tpl"):
    """Render the little stupid game using the associated template.

    Parameters
    ----------
    path : str
        Target path the game page will be rendered and outputted to. Defaults to
        `game.html`.
    tmpl_name : str
        Name of the template to use. Defaults to `game.html`.

    Notes
    -----
    This is a stateful function!
    """
    tmpl = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(tmpl.render())

    sys.stderr.write(f"{path}\n")


def render_home_page(path: str = "index.html", tmpl_name: str = "home.tpl"):
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

    sys.stderr.write(f"{path}\n")


if __name__ == "__main__":
    render_all_posts(sys.argv[1])
    render_game_page(f"{sys.argv[1]}/game.html")
    render_home_page(f"{sys.argv[1]}/index.html")
    render_post_list(f"{sys.argv[1]}/posts/index.html")

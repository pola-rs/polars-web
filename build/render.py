"""Script to render the Polars landing page(s). Limited fanciness included."""

import glob
import os
import re
import sys
import typing

from datetime import datetime
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

meta: typing.Dict[typing.Union[int, str], typing.List[typing.Dict[str, str]]] = {}


def render_all_posts(path: str = ".", tmpl_name: str = "post.tpl"):
    """Render each post using the associated template.

    Each Markdown file will be converted to HTML; named identically, different
    extension. Symbolic links will be created between date-coined folders and
    corresponding title-coined ones, allowing posts to be reached according to
    whichever convention. On the way fills in the `meta` object describing the post.

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
    wd: str = os.getcwd()

    tmpl: Template = jenv.get_template(tmpl_name)
    when: typing.List[str] = []
    tags: typing.Dict[str, str] = {}

    for p in sorted(glob.glob(f"{path}/**/*.md", recursive=True)):

        # dirname
        dirn = "/".join(p.replace(f"{path}/posts/", "").split("/")[:-1])
        tags["url"] = f"https://www.pola.rs/posts/{dirn}"

        # convert the markdown content
        md = Markdown(extensions=exts)
        with open(p) as f:
            post = md.convert(f.read())

        # NECESSARY

        # organize per date of publication
        try:
            date = datetime.strptime(dirn.split("/")[0], "%Y%m%d")
            year = date.year
        except ValueError:
            date = None
            year = "misc"

        # parse the mandatory front matter
        try:
            auth = ", ".join(md.Meta["authors"])
            titl = " ".join(md.Meta["title"])
            tldr = " ".join(md.Meta["tldr"])

            # date <-> title
            syml = re.sub(r"\W+", "-", f"{dirn}-{titl}").lower()
            if date is None:
                url_post = f"/posts/{dirn}"
            else:
                url_post = f"/posts/{syml}"

            tags["desc"] = tldr
            tags["title"] = titl
            tags["url"] = f"https://www.pola.rs{url_post}"

            listed = True
        except KeyError:
            listed = False

        # OPTIONAL

        # parse the config key
        theme = None
        if "config" in md.Meta:
            config = " ".join(md.Meta["config"])

            if "not-listed" in config:
                listed = False

            if "dark-theme" in config:
                theme = "dark"
            if "light-theme" in config:
                theme = "light"
            if "dark-theme" in config and "light-theme" in config:
                theme = None

        # link to authors' content
        url_auth = None
        if "link" in md.Meta:
            url_auth = md.Meta["link"][0]

        # thumbnail
        thmb = None
        if "thumbnail" in md.Meta:
            thmb = md.Meta["thumbnail"][0]
            tags["img"] = thmb
            if not thmb.startswith("https://"):
                thmb = f"/posts/{dirn}/{thmb}"
                tags["img"] = f"https://www.pola.rs{thmb}"

        # add entry to the meta object
        if listed and p.endswith("index.md"):

            if year not in meta:
                meta[year] = []
                if year != "misc":
                    when.append(year)

            meta[year].append(
                {
                    "authors": auth,
                    "date": None if date is None else {
                        "y": date.year,
                        "m": datetime.strftime(date, "%b"),
                        "d": date.day,
                    },
                    "img": thmb,
                    "url_auth": url_auth,
                    "url_post": url_post,
                    "title": titl,
                    "blurb": tldr,
                }
            )

        # write the new file
        newp = re.sub(".md$", ".html", p)
        with open(newp, "w") as f:
            f.write(tmpl.render(post=post, theme=theme, **tags))

        # create soft link
        # might sound hacky, but quick and simple solution
        # no broken links either
        if year != "misc":
            os.chdir(f"{path}/posts")
            os.symlink(dirn, syml, target_is_directory=True)
            os.chdir(wd)

        sys.stderr.write(f"{newp}\n")

    # re-order the posts, most recent first
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

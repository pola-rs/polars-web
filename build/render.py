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

meta: typing.Dict[typing.Union[int, str], typing.List[typing.Any]] = {}


def _date(dirname: str) -> typing.Tuple[datetime, str]:
    """Fetch publication date from dirname."""
    try:
        date = datetime.strptime(dirname.split("/")[0], "%Y%m%d")
        year = date.year
    except ValueError:
        date = None
        year = "misc"

    return date, year


def _symlink(title: str, titles: typing.List[str] = []) -> str:
    """Generate the endpoint used for a post from its title."""
    symlink = re.sub(r"\W+", "-", title).lower()

    if symlink in titles:
        symlink = f"{symlink}-{urls.count(symlink) + 1}"

    return symlink


def _config(value: typing.List[str]) -> typing.Dict[str, str]:
    """Parse the content of the config key, if provided. To be extended to more keys."""
    listed = True
    theme = None

    if value is not None:

        # render but skip the listing
        if "not-listed" in config:
            listed = False

        # force a specific theme
        if "dark-theme" in config:
            theme = "dark"
        if "light-theme" in config:
            theme = "light"
        if "dark-theme" in config and "light-theme" in config:
            theme = None

    return {"listed": listed, "theme": theme}


def _link(value: typing.List[str]) -> str:
    """Process the link provided for the author(s)."""
    if value is not None:
        return value[0]


def _image(value: typing.List[str], root: str) -> str:
    """Process the thumbnail image."""
    root = root.rstrip("/")

    if value is not None:
        image = value[0]

        if not image.startswith("https://"):
            image = f"{root}/{image}"

        return image


def render_all_posts(path: str = ".", tmpl_name: str = "post.tpl"):
    """Render each post using the associated template.

    Each Markdown file will be converted to HTML; named identically, different
    extension. Symbolic links will be created between date-coined folders and
    corresponding title-coined ones, allowing posts to be reached according to
    whichever convention.

    On the way fills in the `meta` object describing the post.

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

    template: Template = jenv.get_template(tmpl_name)
    timeline: typing.List[str] = []
    metatags: typing.Dict[str, str] = {}
    titles: typing.List[str] = []

    for p in sorted(glob.glob(f"{path}/**/*.md", recursive=True)):
        dirname = p.replace(f"{path}/posts/", "").rsplit("/", 1)[0]

        # fetch date of publication
        date, year = _date(dirname)

        # convert the markdown content
        md = Markdown(extensions=exts)
        with open(p) as f:
            html = md.convert(f.read())

        # parse the mandatory front matter
        try:
            auths = ", ".join(md.Meta["authors"])
            title = " ".join(md.Meta["title"])
            blurb = " ".join(md.Meta["summary"])

            # sanitised title
            if year != "misc":
                symlink = _symlink(title, titles)
                titles.append(symlink)

            listed = True

        except KeyError:
            symlink = None

            listed = False

        # endpoint
        if year == "misc" or symlink is None:
            endpoint = f"/posts/{dirname}/"
        else:
            endpoint = f"/posts/{symlink}/"

        # parse the optional front matter
        config = _config(md.Meta.get("config", None))
        authurl = _link(md.Meta.get("link", None))
        image = _image(md.Meta.get("image", None), endpoint)

        # update meta tags
        metatags["title"] = title
        metatags["blurb"] = blurb
        metatags["img"] = None if image is None else f"https://www.pola.rs{image}"
        metatags["url"] = f"https://www.pola.rs{endpoint}"

        # add entry to the meta object
        if listed*config.pop("listed") and p.endswith("index.md"):

            if year not in meta:
                meta[year] = []
                if year != "misc":
                    timeline.append(year)

            meta[year].append(
                {
                    "authors": auths,
                    "authurl": authurl,
                    "blurb": blurb,
                    "date": None if date is None else {
                        "year": date.year,
                        "month": datetime.strftime(date, "%b"),
                        "day": date.day,
                    },
                    "endpoint": endpoint,
                    "image": image,
                    "title": title,
                }
            )

        # write the new file
        newp = re.sub(".md$", ".html", p)
        with open(newp, "w") as f:
            f.write(template.render(post=html, **config, **metatags))

        # create soft link date <-> title
        # might sound hacky, but quick and simple solution without creating new folders
        # (effectively keeping github repo structure) and move all extra content
        if year != "misc" and symlink is not None:
            os.chdir(f"{path}/posts")
            os.symlink(dirname, symlink, target_is_directory=True)
            os.chdir(wd)

        sys.stderr.write(f"{newp}\n")

    # re-order the posts, most recent first
    for year in sorted(timeline, reverse=True) + ["misc"]:
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
    wd: str = os.getcwd()

    template: Template = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(template.render(posts=meta))

    sys.stderr.write(f"{path}\n")


def render_game_page(
    path: str = "game.html",
    html_error_codes: typing.List[int] = [],
    tmpl_name: str = "game.tpl",
):
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
    template: Template = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(template.render())

    sys.stderr.write(f"{path}\n")

    # render template for each html error code provided
    dirname, filename = path.rsplit("/", 1)
    for error in html_error_codes:
        path = f"{dirname}/{error}.html"

        with open(path, "w") as f:
            f.write(template.render(error=error))

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
    template: Template = jenv.get_template(tmpl_name)

    with open(path, "w") as f:
        f.write(template.render(posts=meta))

    sys.stderr.write(f"{path}\n")


if __name__ == "__main__":
    render_all_posts(sys.argv[1])
    render_post_list(f"{sys.argv[1]}/posts/index.html")
    render_home_page(f"{sys.argv[1]}/index.html")
    render_game_page(f"{sys.argv[1]}/game.html", [404])

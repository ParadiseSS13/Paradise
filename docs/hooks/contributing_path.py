"""Upper-case path rewriter.

While it is not mandatory for the files "CONTRIBUTING" and "CODE_OF_CONDUCT" to
be in uppercase, this promotes visibility within the repo.

However, if mkdocs has a root file named CONTRIBUTING.md, and a nav section
named "contributing", and the site is built on a case-insensitive filesystem,
these will resolve to the same path, i.e.:

- CONTRIBUTING.md -> "/contributing/index.html"
- contributing/getting_started.md -> "/contributing/getting_started/index.html"

When URL links are generated, the original filename is used, so any links to
CONTRIBUTING.md will resolve to "/CONTRIBUTING/index.html". This will break when
published to a webserver, as that directory won't exist.

This tiny script replaces references to the upper-case file path to a lower-case
file path, to resolve this issue.

For consistency's sake, we do this for CODE_OF_CONDUCT, despite no worry about
collisions in this case, because the URL looks nicer.
"""

import re

transforms = {
    "CONTRIBUTING": "contributing",
    "CODE_OF_CONDUCT": "code_of_conduct",
}


def on_page_markdown(markdown, *, page, config, files):
    for old, new in transforms.items():
        if page.file.name == old:
            page.file.name = new
            page.file.url = page.file.url.replace(old, new)
            page.file.dest_uri = page.file.dest_uri.replace(old, new)
            page.file.abs_dest_path = page.file.abs_dest_path.replace(old, new)

        # Can't just replace filename and keep extension,
        # mkdocs will get upset it can't find a file with
        # that exact name. So we just give it a URL and it
        # complains, but ignores it and chugs along.
        markdown = re.sub(f"\.+/{old}.md", f"/{new}/", markdown)

    return markdown

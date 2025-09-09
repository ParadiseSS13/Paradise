# Contributing Guidelines

This is the contribution guide for Paradise Station. These guidelines apply to
both new issues and new pull requests. If you are making a pull request, please
refer to the [Pull request](#pull-requests) section, and if you are making an
issue report, please refer to the [Issue Report](#issues) section.

## Commenting

If you comment on an active pull request or issue report, make sure your comment
is concise and to the point. Comments on issue reports or pull requests should
be relevant and friendly, not attacks on the author or adages about something
minimally relevant. If you believe an issue report is not a "bug", please point
out specifically and concisely your reasoning in a comment on the issue itself.

Comments on Pull Requests and Issues should remain relevant to the subject in
question and not derail discussions.

Under no circumstances are users to be attacked for their ideas or
contributions. All participants on a given PR or issue are expected to be civil.
Failure to do so will result in disciplinary action.

For more details, see the [Code of Conduct](./CODE_OF_CONDUCT.md).

## Issues

The Issues section is not a place to request features, or ask for things to be
changed because you think they should be that way. The Issues section is
specifically for reporting bugs in the code.

Issue reports should be as detailed as possible, and if applicable, should
include instructions on how to reproduce the bug.

## Pull Requests

Players are welcome to participate in the development of this fork and submit
their own pull requests. If the work you are submitting is a new feature, or
affects balance, it is strongly recommended you get approval/traction for it
from our forums before starting the actual development.

It is expected that all code contributors read and understand the
[Guide to Quality PRs](./contributing/quality_prs.md).

Keep your pull requests atomic. Each pull request should strive to address one
primary goal, and should not include fixes or changes that aren't related to the
main purpose of the pull request. Unrelated changes should be applied in new
pull requests. In case of mapping PRs that add features - consult a member of
the development team on whether it would be appropriate to split up the PR to
add the feature to multiple maps individually.

Document and explain your pull requests thoroughly. Failure to do so will delay
a PR as we question why changes were made. This is especially important if
you're porting a PR from another codebase (i.e. /tg/station) and divert from the
original. Explaining with single comment on why you've made changes will help us
review the PR faster and understand your decision making process.

Any pull request must have a changelog. This is to allow us to know when a PR is
deployed on the live server. Inline changelogs are supported through the format
described [here](#using-the-changelog).

Pull requests should not have any merge commits except in the case of fixing
merge conflicts for an existing pull request. New pull requests should not have
any merge commits. Use `git rebase` or `git reset` to update your branches, not
`git pull`.

Please explain why you are submitting the pull request, and how you think your
change will be beneficial to the game. Failure to do so will be grounds for
rejecting the PR.

If your pull request is not finished, make sure it is at least testable in a
live environment. Pull requests that do not at least meet this requirement may
be closed at maintainer discretion. You may request a maintainer reopen the pull
request when you're ready, or make a new one.

While we have no issue helping contributors (and especially new contributors)
bring reasonably sized contributions up to standards via the pull request review
process, larger contributions are expected to pass a higher bar of completeness
and code quality _before_ you open a pull request. Maintainers may close such
pull requests that are deemed to be substantially flawed. You should take some
time to discuss with maintainers or other contributors on how to improve the
changes.

By ticking or leaving ticked the option "Allow edits and access to secrets by
maintainers", either when making a PR or at any time thereafter, you give
permission for repository maintainers to push changes to your branch without
explicit permission. Repository maintainers will avoid doing this unless
necessary, and generally should only use it to apply a merge upstream/master,
rebuild TGUI, deconflict maps, or other minor changes required shortly before a
PR is to be merged. More extensive changes such as force-pushes to your branch
require explicit permission from the PR author each time such a change needs to
be made.

### Using The Changelog

- The tags able to be used in the changelog are: `add/soundadd/imageadd`,
  `del/sounddel/imagedel`, `tweak`, `fix`, `wip`, `spellcheck`, and
  `experiment`.
- Without specifying a name it will default to using your GitHub name. Some
  examples include:

```txt
    :cl:
    add: The ability to change the color of wires
    del: Deleted depreciated wire merging now handled in parent
    fix: Moving wires now follows the user input instead of moving the stack
    /:cl:
```

```txt
    :cl: UsernameHere
    spellcheck: Fixes some misspelled words under Using Changelog
    /:cl:
```

### PR Status

Status of your pull request will be communicated via PR labels. This includes:

- `Status: Awaiting type assignment` - This will be displayed when your PR is
  awaiting an internal type assignment (for Fix, Balance, Tweak, etc)
- `Status: Awaiting approval` - This will be displayed if your PR is waiting for
  approval from the specific party, be it Balance or Design. Fixes & Refactors
  should never have this label
- `Status: Awaiting review` - This will be displayed when your PR has passed the
  design vote and is now waiting for someone in the review team to approve it
- `Status: Awaiting merge` - Your PR is done and is waiting for a maintainer to merge it

  **Note: Your PR may be delayed if it is pending
  testmerge or in the mapping queue**

### Mapping Standards

All PRs which modify maps are expected to follow all of our
[mapping requirements](./mapping/requirements.md).

## Modifying Rust Code

Some parts of Paradise are written in [Rust][] for performance or reliability
reasons:

- Our atmos engine, MILLA, is in the `rust/src/milla/` directory.
- The `mapmanip` library, an Aurora Station module used for automating DMM
  modification, is in the `rust/src/mapmanip` library.

The Rust parts of our codebase are compiled into a single library,
separate from the rest of the code. If you're on Windows, you get a pre-built
copy by default. If you're on Linux, you built one already to run the server.

If you make changes to the Rust library, you'll want to rebuild. This will be
very similar to [rust-g][]. The only difference is that you run `cargo` from the
`rust/` directory, and don't need to specify `--all-features` (though it doesn't
hurt).

The server will automatically detect that you have a local build, and use that
over the default Windows one.

When you're ready to make a PR, please DO NOT modify `rustlibs.dll` or
`tools/ci/librustlibs_ci.so`. Leave "Allow edits and access to secrets by
maintainers" enabled, and post a comment on your PR saying `!build_rust`. A bot
will automatically build them for you and update your branch.

[Rust]: https://www.rust-lang.org/
[rust-g]: https://github.com/ParadiseSS13/rust-g

## Other Notes

- Bloated code may be necessary to add a certain feature, which means there has
  to be a judgement over whether the feature is worth having or not. You can
  help make this decision easier by making sure your code is modular.

- You are expected to help maintain the code that you add, meaning that if there
  is a problem then you are likely to be approached in order to fix any issues,
  runtimes, or bugs.

- If you used regex to replace code during development of your code, post the
  regex in your PR for the benefit of future developers and downstream users.

- All new var/proc names should use the American English spelling of words. This
  is for consistency with BYOND.

- All mentions of the company "Nanotrasen" should be written as such -
  'Nanotrasen'. Use of CamelCase (NanoTrasen) is no longer proper.

- If you are making a PR that adds a config option to change existing behaviour,
  said config option must default to as close to as current behaviour as
  possible.

## GitHub Staff

There are three roles on the GitHub:

- Headcoder
- Maintainer
- Review Team

Each role inherits the lower role's responsibilities
(IE: Headcoders are also maintainers, and maintainers are also part of the review team)

`Headcoders` are the overarching "administrators" of the repository. People
included in this role are:

- [Burzah](https://github.com/Burzah)
- [Contrabang](https://github.com/Contrabang)
- [Warriorstar](https://github.com/warriorstar-orion)

---

`Maintainers` have write access to the repository and can merge your
PRs. People included in this role are:

- [AffectedArc07](https://github.com/AffectedArc07)
- [Charliminator](https://github.com/hal9000PR)
- [Chuga](https://github.com/chuga-git)
- [DGamerL](https://github.com/DGamerL)
- [FunnyMan3595](https://github.com/FunnyMan3595)
- [lewcc](https://github.com/lewcc)
- [PollardTheDragon](https://github.com/PollardTheDragon)
- [S34N](https://github.com/S34NW)
- [SteelSlayer](https://github.com/SteelSlayer)
- [Warriorstar](https://github.com/warriorstar-orion)

---

`Review Team` members are people who are denoted as having reviews which can
affect mergeability status. People included in this role are:

- [Charliminator](https://github.com/hal9000PR)
- [Chuga](https://github.com/chuga-git)
- [DGamerL](https://github.com/DGamerL)
- [FunnyMan3595](https://github.com/FunnyMan3595)
- [lewcc](https://github.com/lewcc)
- [PollardTheDragon](https://github.com/PollardTheDragon)
- [S34N](https://github.com/S34NW)
- [Sirryan2002](https://github.com/Sirryan2002)
- [SteelSlayer](https://github.com/SteelSlayer)
- [Warriorstar](https://github.com/warriorstar-orion)
- [Wilkson](https://github.com/BiancaWilkson)

---

Full information on the GitHub contribution workflow & policy can be found at
<https://www.paradisestation.org/dev/policy/>.

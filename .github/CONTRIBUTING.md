# CONTRIBUTING

## Introduction
This is the contribution guide for Paradise Station. These guidelines apply to
both new issues and new pull requests. If you are making a pull request, please refer to
the [Pull request](#pull-requests) section, and if you are making an issue report, please
refer to the [Issue Report](#issues) section, as well as the
[Issue Report Template](ISSUE_TEMPLATE.md).

## Commenting
If you comment on an active pull request, or issue report, make sure your comment is
concise and to the point. Comments on issue reports or pull requests should be relevant
and friendly, not attacks on the author or adages about something minimally relevant.
If you believe an issue report is not a "bug", please report it to the Maintainers, or
point out specifically and concisely your reasoning in a comment on the issue report.

## Issues
The Issues section is not a place to request features, or ask for things to be changed
because you think they should be that way; The Issues section is specifically for
reporting bugs in the code. Refer to ISSUE_TEMPLATE for the exact format that your Issue
should be in.

#### Guidelines:
 - Issue reports should be as detailed as possible, and if applicable, should include
 instructions on how to reproduce the bug.

## Pull requests
Players are welcome to participate in the development of this fork and submit their own
pull requests. If the work you are submitting is a new feature, or affects balance, it is
strongly recommended you get approval/traction for it from our forums before starting the
actual development.

#### Guidelines:
 - Pull requests should be atomic; Make one commit for each distinct change, so if a part
 of a pull request needs to be removed/changed, you may simply modify that single commit.
 Due to limitations of the engine, this may not always be possible; but do try your best.
 - Document and explain your pull requests thoroughly. Detail what each commit changes,
 and why it changes it. We do not want to have to read all of you commit names to figure
 out what your pull request is about.
 - Any pull request that is not solely composed of fixes or non gameplay-affecting
 refactors must have a changelog. Inline changelogs are supported through the format
 described [here](https://github.com/ParadiseSS13/Paradise/pull/3291#issuecomment-172950466)
 and should be used rather than manually edited .yml file changelogs.
 - Pull requests should not have any merge commits except in the case of fixing merge
 conflicts for an existing pull request. New pull requests should not have any merge
 commits. Use `git rebase` or `git reset` to update your branches, not `git pull`.

#### BYOND Specific Guidelines:
 - Any `type` or `proc` paths **must** use absolute pathing unless the file you are
 working in primarily utilizes relative pathing.
 - Paths must begin with `/`. It should be `/obj/machinery/fancy_robot`,
 not `obj/machinery/fancy_robot`.
 - New bases of datum must begin with `/datum/`. `/datum/arbitrary_datum`,
 not `/arbitrary_datum`.
 - Don't use strings in combination with `text2path()` unless the paths are being
  dynamically created. Variables can contain normal paths just fine.
 - Don't duplicate code. If you have identical code in two places, it should probably
  be a  new proc that they both can use.
 - No magic numbers/strings. If you have a number or text that is important and used in
  your code, make a `#DEFINE` statement with a name that clearly indicates it's use.
 - `if(condition)` must be used over `if (condition)` or any other variation.
  - The same applies for `while` and `for` loops, they must have no space between the
  keyword and condition brackets. `while(condition)`, `for(condition)`
 - If you want to output a message to a player's chat
  (this includes text sent to `world`), use `to_chat(mob/client/world, "message")`.
  Do not use `mob/client/world << "message"`.
 - Do not use one-line control statements (if, else, for, while, etc). The space saved
  is not worth the decreased readability.
 - Control statements comparing a variable to a constant should be formatted `variable`,
  `operator`, `constant`. This means `if(count <= 10)` is preferred over
  `if(10 >= count)`.
 - **Never** use a colon `:` operator to bypass type safety checks, unless you are doing
 something where the tiny performance increase is incredibly noticeable (eg, a loop for
   a huge list). You should properly typecast everything and use the period `.`
   operator.
 - Use early returns, and avoid far-indented if blocks. This means that you should not
  do this:
  ```
  /datum/datum1/proc/proc1()
    if (thing1)
        if (!thing2)
            if (thing3 == 30)
                do stuff
  ```
  Instead, you should do this:
  ```
  /datum/datum1/proc/proc1()
    if (!thing1)
        return
    if (thing2)
        return
    if (thing3 != 30)
        return
    do stuff
  ```
 - Any pull requests that affect map files must use the map-merge tools. Pull requests
 that do not follow this guideline will be automatically declined, unless explicit
 permission was given.
 - The following examples of code are present in the code, but are no longer acceptable:
  - To display messages to all mobs that can view `src`, you should use
  `visible_message()`.
     - Bad:
     ```
     for (var/mob/M in viewers(src))
             M.show_message("<span class='warning'>Arbitrary text</span>")
     ```
     - Good:
     ```
     visible_message("<span class='warning'>Arbitrary text</span>")
     ```
  - You should not use color macros (`\red, \blue, \green, \black`) to color text,
  instead, you should use span classes. `<span class='warning'>red text</span>`,
  `<span class='notice'>blue text</span>`.
    - Bad:
    ```
    usr << "\red Red Text \black black text"
    ```
    - Good:
    ```
    usr << "<span class='warning'>Red Text</span>black text"
    ```
  - To use variables in strings, you should **never** use the `text()` operator, use
   embedded expressions directly in the string.
     - Bad:
     ```
     usr << text("\The [] is leaking []!", src.name, src.liquid_type)
     ```
     - Good:
     ```
     usr << "\The [src] is leaking [liquid_type]"
     ```
  - To reference a variable/proc on the src object, you should **not** use
   `src.var`/`src.proc()`. The `src.` in these cases is implied, so you should just use
   `var`/`proc()`.
     - Bad:
     ```
     var/user = src.interactor
     src.fillReserves(user)
     ```
     - Good:
     ```
     var/user = interactor
     fillReserves(user)
     ```


## Maintainers
The only current official role for GitHub staff are the `Maintainers`. There are up to
three  `Maintainers` at once, and they share equal power. The `Maintainers` are
responsible for properly tagging new pull requests and issues, moderating comments in
pull requests/issues, and merging/closing pull requests.

### Maintainer List
 - [MarkvA](https://github.com/Markolie)
 - [Fox P McCloud](https://github.com/Fox-McCloud)
 - [TheDZD](https://github.com/TheDZD)

### Maintainer instructions
 - Do not `self-merge`; this refers to the practice of opening a pull request, then
  merging it yourself. A different maintainer must review and merge your pull request, no
  matter how trivial. This is to ensure quality.
  - A subset of this instruction: Do not push directly to the repository, always make a
  pull request.
 - Wait for the Travis CI build to complete. If it fails, the pull request may only be
 merged if there is a very good reason (example: fixing the Travis configuration).
 - Pull requests labeled as bugfixes and refactors may be merged as soon as they are
 reviewed.
 - The shortest waiting period for -any- feature or balancing altering pull request is 24
 hours, to allow other coders and the community time to discuss the proposed changes.
 - If the discussion is active, or the change is controversial, the pull request is to be
 put on hold until a consensus is reached.
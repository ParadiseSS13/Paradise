# CONTRIBUTING

## Introduction

This is the contribution guide for Paradise Station. These guidelines apply to
both new issues and new pull requests. If you are making a pull request, please refer to
the [Pull request](#pull-requests) section, and if you are making an issue report, please
refer to the [Issue Report](#issues) section, as well as the
[Issue Report Template](ISSUE_TEMPLATE.md).

## Commenting

If you comment on an active pull request or issue report, make sure your comment is
concise and to the point. Comments on issue reports or pull requests should be relevant
and friendly, not attacks on the author or adages about something minimally relevant.
If you believe an issue report is not a "bug", please point out specifically and concisely your reasoning in a comment on the issue itself.

### Comment Guidelines

* Comments on Pull Requests and Issues should remain relevant to the subject in question and not derail discussions.
* Under no circumstances are users to be attacked for their ideas or contributions. All participants on a given PR or issue are expected to be civil. Failure to do so will result in disciplinary action.
* For more details, see the [Code of Conduct](../CODE_OF_CONDUCT.md).

## Issues

The Issues section is not a place to request features, or ask for things to be changed
because you think they should be that way; The Issues section is specifically for
reporting bugs in the code.

### Issue Guidelines

* Issue reports should be as detailed as possible, and if applicable, should include instructions on how to reproduce the bug.

## Pull requests

Players are welcome to participate in the development of this fork and submit their own
pull requests. If the work you are submitting is a new feature, or affects balance, it is
strongly recommended you get approval/traction for it from our forums before starting the
actual development.

### Pull Request Guidelines

* Pull requests should be atomic; Make one commit for each distinct change, so if a part of a pull request needs to be removed/changed, you may simply modify that single commit. Due to limitations of the engine, this may not always be possible; but do try your best.

* Keep your pull requests small and reviewable whenever possible. Do not bundle unrelated fixes even if not bundling them generates more pull requests. In case of mapping PRs that add features - consult a member of the development team on whether it would be appropriate to split up the PR to add the feature to multiple maps individually.

* Document and explain your pull requests thoroughly. Failure to do so will delay a PR as we question why changes were made. This is especially important if you're porting a PR from another codebase (i.e. TG) and divert from the original. Explaining with single comment on why you've made changes will help us review the PR faster and understand your decision making process.

* Any pull request must have a changelog, this is to allow us to know when a PR is deployed on the live server. Inline changelogs are supported through the format described [here](https://github.com/ParadiseSS13/Paradise/pull/3291#issuecomment-172950466) and should be used rather than manually edited .yml file changelogs.

* Pull requests should not have any merge commits except in the case of fixing merge conflicts for an existing pull request. New pull requests should not have any merge commits. Use `git rebase` or `git reset` to update your branches, not `git pull`.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

* If your pull request is not finished make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement may be closed at maintainer discretion. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

* By ticking or leaving ticked the option "Allow edits and access to secrets by maintainers", either when making a PR or at any time thereafter, you give permission for repository maintainers to push changes to your branch without explicit permission. Repository maintainers will avoid doing this unless necessary, and generally should only use it to apply a merge upstream/master, rebuild TGUI, deconflict maps, or other minor changes required shortly before a PR is to be merged. More extensive changes such as force-pushes to your branch require explicit permission from the PR author each time such a change needs to be made.

#### Using The Changelog

* The tags able to be used in the changelog are: `add/soundadd/imageadd`, `del/sounddel/imagedel`, `tweak`, `fix`, `wip`, `spellcheck`, and `experiment`.
* Without specifying a name it will default to using your GitHub name. Some examples include:

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

## Specifications

As mentioned before, you are expected to follow these specifications in order to make everyone's lives easier. It'll save both your time and ours, by making
sure you don't have to make any changes and we don't have to ask you to. Thank you for reading this section!

### Object Oriented Code

As BYOND's Dream Maker (henceforth "DM") is an object-oriented language, code must be object-oriented when possible in order to be more flexible when adding
content to it. If you don't know what "object-oriented" means, we highly recommend you do some light research to grasp the basics.

### All BYOND paths must contain the full path

(i.e. absolute pathing)

DM will allow you nest almost any type keyword into a block, such as:

```dm
datum
  datum1
    var
      varname1 = 1
      varname2
      static
        varname3
        varname4
    proc
      proc1()
        code
      proc2()
        code

    datum2
      varname1 = 0
      proc
        proc3()
          code
      proc2()
        ..()
        code
```

The use of this format is **not** allowed in this project, as it makes finding definitions via full text searching next to impossible. The only exception is the variables of an object may be nested to the object, but must not nest further.

The previous code made compliant:

```dm
/datum/datum1
    var/varname1 = 1
    var/varname2
    var/static/varname3
    var/static/varname4

/datum/datum1/proc/proc1()
    code

/datum/datum1/proc/proc2()
    code

/datum/datum1/datum2
    varname1 = 0

/datum/datum1/datum2/proc/proc3()
    code

/datum/datum1/datum2/proc2()
    ..()
    code
```

### User Interfaces

All new user interfaces in the game must be created using the TGUI framework. Documentation can be found inside the [`tgui/docs`](../tgui/docs) folder, and the [`README.md`](../tgui/README.md) file. This is to ensure all ingame UIs are snappy and respond well. An exception is made for user interfaces which are purely for OOC actions (Such as character creation, or anything admin related)

### No overriding type safety checks

The use of the `:` operator to override type safety checks is not allowed. You must cast the variable to the proper type.

### Type paths must begin with a /

eg: `/datum/thing`, not `datum/thing`

### Datum type paths must began with "datum"

In DM, this is optional, but omitting it makes finding definitions harder. To be specific, you can declare the path `/arbitrary`, but it
will still be, in actuality, `/datum/arbitrary`. Write your code to reflect this.

### Do not use text/string based type paths

It is rarely allowed to put type paths in a text format, as there are no compile errors if the type path no longer exists. Here is an example:

```dm
//Bad
var/path_type = "/obj/item/baseball_bat"

//Good
var/path_type = /obj/item/baseball_bat
```

### Do not use `\The`

The `\The` macro doesn't actually do anything when used in the format `\The [atom reference]`. Directly referencing an atom in an embedded string
will automatically prefix `The` or `the` to it as appropriate. As an extension, when referencing an atom, don't use `[atom.name]`, use `[atom]`.
The only exception to this rule is when dealing with items "belonging" to a mob, in which case you should use `[mob]'s [atom.name]` to avoid `The`
ever forming.

```dm
//Bad
var/atom/A
"\The [A]"

//Good
var/atom/A
"[A]"
```

### Use the pronoun library instead of `\his` macros

We have a system in [`code/__HELPERS/pronouns.dm`](../code/__HELPERS/pronouns.dm) for addressing all forms of pronouns. This is useful in a number of ways;

* BYOND's `\his` macro can be unpredictable on what object it references. Take this example: `"[user] waves \his [user.weapon] around, hitting \his opponents!"`. This will end up referencing the user's gender in the first occurence, but what about the second? It'll actually print the gender set on the weapon he's carrying, which is unintended - and there's no way around this.
* It always prints the real `gender` variable of the atom it's referencing. This can lead to exposing a mob's gender even when their face is covered, which would normally prevent it's gender from being printed.

The way to avoid these problems is to use the pronoun system. Instead of `"[user] waves \his arms."`, you can do `"[user] waves [user.p_their()] arms."`

```dm
//Bad
"[H] waves \his hands!"
"[user] waves \his [user.weapon] around, hitting \his opponents!"

//Good
"[H] waves [H.p_their()] hands!"
"[user] waves [H.p_their()] [user.weapon] around, hitting [H.p_their()] opponents!"`
```

### Use `[A.UID()]` over `\ref[A]`

BYOND has a system to pass "soft references" to datums, using the format `"\ref[datum]"` inside a string. This allows you to find the object just based
off of a text string, which is especially useful when dealing with the bridge between BYOND code and HTML/JS in UIs. It's resolved back into an object
reference by using `locate("\ref[datum]")` when the code comes back to BYOND. The issue with this is that locate() can return a unexpected datum
if the original datum has been deleted - BYOND recycles the references.

UID's are actually unique; they work off of a global counter and are not recycled. Each datum has one assigned to it when it's created, which can be
accessed by `[datum.UID()]`. You can use this as a snap-in replacement for `\ref` by changing any `locate(ref)` calls in your code to `locateUID(ref)`.
Usage of this system is mandatory for any `Topic()` calls, and will produce errors in Dream Daemon if it's not used.

```dm
//Bad
"<a href='?src=\ref[src];'>Link!</a>"

//Good
"<a href='?src=[UID()];'>Link!</a>"
```

### Use `var/name` format when declaring variables

While DM allows other ways of declaring variables, this one should be used for consistency.

### Tabs, not spaces

You must use tabs to indent your code, NOT SPACES.

(You may use spaces to align something, but you should tab to the block level first, then add the remaining spaces.)

### No hacky code

Hacky code, such as adding specific checks (ex: `istype(src, /obj/whatever)`), is highly discouraged and only allowed when there is ***no*** other option. (Protip: 'I couldn't immediately think of a proper way so thus there must be no other option' is not gonna cut it here! If you can't think of anything else, say that outright and admit that you need help with it. Maintainers, PR Reviewers, and other contributors who can help you exist for exactly that reason.)

You can avoid hacky code by using object-oriented methodologies, such as overriding a function (called "procs" in DM) or sectioning code into functions and
then overriding them as required.

The same also applies to bugfixes - If an invalid value is being passed into a proc from something that shouldn't have that value, don't fix it on the proc itself, fix it at its origin! (Where feasible)

### No duplicated code

Copying code from one place to another may be suitable for small, short-time projects, but Paradise is a long-term project and highly discourages this.

Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

### Startup/Runtime tradeoffs with lists and the "hidden" init proc

First, read the comments in [this BYOND thread](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), starting where the link takes you.

There are two key points here:

1) Defining a list in the variable's definition calls a hidden proc - init. If you have to define a list at startup, do so in `New()` (or preferably `Initialize()`) and avoid the overhead of a second call (`init()` and then `New()`)

2) It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this tradeoff makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

### Prefer `Initialize()` over `New()` for atoms

Our game controller is pretty good at handling long operations and lag, but it can't control what happens when the map is loaded, which calls `New()` for all atoms on the map. If you're creating a new atom, use the `Initialize()` proc to do what you would normally do in `New()`. This cuts down on the number of proc calls needed when the world is loaded.

While we normally encourage (and in some cases, even require) bringing out of date code up to date when you make unrelated changes near the out of date code, that is not the case for `New()` -> `Initialize()` conversions. These systems are generally more dependent on parent and children procs, so unrelated random conversions of existing things can cause bugs that take months to figure out.

### No implicit `var/`

When you declare a parameter in a proc, the `var/` is implicit. Do not include any implicit `var/` when declaring a variable.

```dm
//Bad
/obj/item/proc1(var/mob/input1, var/input2)
    code

//Good
/obj/item/proc1(mob/input1, input2)
    code
```

### No magic numbers or strings

This means stuff like having a "mode" variable for an object set to "1" or "2" with no clear indicator of what that means. Make these #defines with a name that more clearly states what it's for. For instance:

```dm
//Bad
/datum/proc/do_the_thing(thing_to_do)
    switch(thing_to_do)
        if(1)
            do_stuff()
        if(2)
            do_other_stuff()
```

There's no indication of what "1" and "2" mean! Instead, you should do something like this:

```dm
//Good
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2

/datum/proc/do_the_thing(thing_to_do)
    switch(thing_to_do)
        if(DO_THE_THING_REALLY_HARD)
            do_stuff()
        if(DO_THE_THING_EFFICIENTLY)
            do_other_stuff()
```

This is clearer and enhances readability of your code! Get used to doing it!

### Control statements

(if, while, for, etc)

* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse
  (eg: `if(count <= 10)` not `if(10 >= count)`)
* All control statements must be spaced as `if()`, with the brackets touching the keyword.
* All control statements must not contain code on the same line as the statement.

  ```DM
  //Bad
  if(x) return

  //Good
  if(x)
      return
  ```

### Player Output

Due to the use of "Goonchat", Paradise requires a special syntax for outputting text messages to players. Instead of `mob << "message"`, you must use `to_chat(mob, "message")`. Failure to do so will lead to your code not working.

### Use early returns

Do not enclose a proc in an if-block when returning on a condition is more feasible.

This is bad:

```dm
/datum/datum1/proc/proc1()
    if(thing1)
        if(!thing2)
            if(thing3 == 30)
                do stuff
```

This is good:

```dm
/datum/datum1/proc/proc1()
    if(!thing1)
        return
    if(thing2)
        return
    if(thing3 != 30)
        return
    do stuff
```

This prevents nesting levels from getting deeper then they need to be.

### Use `addtimer()` instead of `sleep()` or `spawn()`

If you need to call a proc after a set amount of time, use `addtimer()` instead of `spawn()` / `sleep()` where feasible.
Though more complex, this method has greater performance. Additionally, unlike `spawn()` or `sleep()`, it can be cancelled.
For more details, see [https://github.com/tgstation/tgstation/pull/22933](https://github.com/tgstation/tgstation/pull/22933).

Look for code examples on how to properly use it.

```dm
//Bad
/datum/datum1/proc/proc1(target)
    spawn(5 SECONDS)
    target.dothing(arg1, arg2, arg3)

//Good
/datum/datum1/proc/proc1(target)
    addtimer(CALLBACK(target, PROC_REF(dothing), arg1, arg2, arg3), 5 SECONDS)
```

### Operators

#### Spacing of operators

* Operators that should be separated by spaces:
  * Boolean and logic operators like `&&`, `||` `<`, `>`, `==`, etc. (But not `!`)
  * Bitwise AND `&` and OR `|`.
  * Argument separator operators like `,`. (and `;` when used in a forloop)
  * Assignment operators like `=` or `+=` or the like.
  * Math operators like `+`, `-`, `/`, or `*`.
* Operators that should NOT be separated by spaces:
  * Access operators like `.` and `:`.
  * Parentheses `()`.
  * Logical not `!`.

#### Use of operators

* Bitwise AND `&`
  * Should be written as `bitfield & bitflag` NEVER `bitflag & bitfield`, both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string

```DM
    //Bad
    list(a = "b")

    //Good
    list("a" = "b")
```

#### Bitflags

* We prefer using bitshift operators instead of directly typing out the value. I.E:

```dm
    #define MACRO_ONE (1<<0)
    #define MACRO_TWO (1<<1)
    #define MACRO_THREE (1<<2)
```

Is preferable to:

```dm
    #define MACRO_ONE 1
    #define MACRO_TWO 2
    #define MACRO_THREE 4
```

While it may initially look intimidating, `(1<<x)` is actually very simple and, as the name implies, shifts the bits of a given binary number over by one digit.

```dm
    000100 (4, or (1<<2))
    <<
    001000 (8, or (1<<3))
```

Using this system makes the code more readable and less prone to error.

### Legacy Code

SS13 has a lot of legacy code that's never been updated. Here are some examples of common legacy trends which are no longer acceptable:

* To display messages to all mobs that can view `user`, you should use `visible_message()`.

```dm
    //Bad
    for(var/mob/M in viewers(user))
        M.show_message("<span class='warning'>Arbitrary text</span>")

    //Good
    user.visible_message("<span class='warning'>Arbitrary text</span>")
```

* You should not use color macros (`\red, \blue, \green, \black`) to color text, instead, you should use span classes. `<span class='warning'>Red text</span>`, `<span class='notice'>Blue text</span>`.

```dm
    //Bad
    to_chat(user, "\red Red text \black Black text")

    //Good
    to_chat(user, "<span class='warning'>Red text</span>Black text")
```

* To use variables in strings, you should **never** use the `text()` operator, use embedded expressions directly in the string.

```dm
    //Bad
    to_chat(user, text("[] is leaking []!", name, liquid_type))

    //Good
    to_chat(user, "[name] is leaking [liquid_type]!")
```

* To reference a variable/proc on the src object, you should **not** use `src.var`/`src.proc()`. The `src.` in these cases is implied, so you should just use `var`/`proc()`.

```dm
   //Bad
   var/user = src.interactor
   src.fill_reserves(user)

   //Good
   var/user = interactor
   fill_reserves(user)
```

### Develop Secure Code

* Player input must always be escaped safely, we recommend you use `stripped_input()` in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind.

* Calls to the database must be escaped properly - use proper parameters (values starting with a :). You can then replace these with a list of parameters, and these will be properly escaped during the query, and prevent any SQL injection.

```dm
  //Bad
  var/datum/db_query/query_watch = SSdbcore.NewQuery("SELECT reason FROM [format_table_name("watch")] WHERE ckey='[target_ckey]'")

  //Good
  var/datum/db_query/query_watch = SSdbcore.NewQuery("SELECT reason FROM [format_table_name("watch")] WHERE ckey=:target_ckey", list(
    "target_ckey" = target_ckey
  )) // Note the use of parameters on the above line and :target_ckey in the query.
```

* All calls to topics must be checked for correctness. Topic href calls can be easily faked by clients, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls, because it won't.

* Information that players could use to metagame (that is, to identify round information and/or antagonist type via information that would not be available to them in character) should be kept as administrator only.

* Where you have code that can cause large-scale modification and *FUN*, make sure you start it out locked behind one of the default admin roles - use common sense to determine which role fits the level of damage a function could do.

### Files

* Because runtime errors do not give the full path, try to avoid having files with the same name across folders.

* File names should not be mixed case, or contain spaces or any character that would require escaping in a uri.

* Files and path accessed and referenced by code above simply being #included should be strictly lowercase to avoid issues on filesystems where case matters.

### SQL

* Do not use the shorthand sql insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

* Use parameters for queries, as mentioned above in [Develop Secure Code](#develop-secure-code).

* Always check your queries for success with `if(!query.warn_execute())`. By using this standard format, you can ensure the correct log messages are used.

* Always `qdel()` your queries after you are done with them, this cleans up the results and helps things run smoother.

* All changes to the database's layout (schema) must be specified in the database changelog in SQL, as well as reflected in the schema file.

* Any time the schema is changed the `SQL_VERSION` defines must be incremented, as well as the example config, with an appropriate conversion kit placed
in the SQL/updates folder.

* Queries must never specify the database, be it in code, or in text files in the repo.

### Mapping Standards

* For map edit PRs, we do not accept 'change for the sake of change' remaps, unless you have very good reasoning to do so. Maintainers reserve the right to close your PR if we disagree with your reasoning.

* Map Merge
  * The following guideline for map merging applies to **ALL** mapping contributers.
    * Before committing a map change, you **MUST** run mapmerge2 to normalise your changes. You can do this manually before every commit with `"\tools\mapmerge2\Run Before Committing.bat"` or automatically by installing the hooks at `"\tools\hooks\Install.bat"`.
    * Failure to run Map Merge on a map after editing greatly increases the risk of the map's key dictionary becoming corrupted by future edits after running map merge. Resolving the corruption issue involves rebuilding the map's key dictionary;

* StrongDMM
  * [We strongly encourage use of StrongDMM version 2 or greater, available here.](https://github.com/SpaiR/StrongDMM/releases)
  * When using StrongDMM, the following options must be enabled. They can be found under `File > Preferences`.
    * Sanitize Variables - Removes variables that are declared on the map, but are the same as initial. (For example: A standard floor turf that has `dir = 2` declared on the map will have that variable deleted as it is redundant.)
    * Save format - `TGM`.
    * Nudge mode - pixel_x/pixel_y

* Variable Editing (Var-edits)
  * While var-editing an item within the editor is fine, it is preferred that when you are changing the base behavior of an item (how it functions) that you make a new subtype of that item within the code, especially if you plan to use the item in multiple locations on the same map, or across multiple maps. This makes it easier to make corrections as needed to all instances of the item at one time, as opposed to having to find each instance of it and change them all individually.
    * Subtypes only intended to be used on ruin maps should be contained within an .dm file with a name corresponding to that map within `code\modules\ruins`. This is so in the event that the map is removed, that subtype will be removed at the same time as well to minimize leftover/unused data within the repo.
  * When not using StrongDMM (which handles the following automatically) please attempt to clean out any dirty variables that may be contained within items you alter through var-editing. For example changing the `pixel_x` variable from 23 to 0 will leave a dirty record in the map's code of `pixel_x = 0`.
  * Areas should **never** be var-edited on a map. All areas of a single type, altered instance or not, are considered the same area within the code, and editing their variables on a map can lead to issues with powernets and event subsystems which are difficult to debug.
  * Unless they require custom placement, when placing the following items use the relevant "[direction] bump" instance, as it has predefined pixel offsets and directions that are standardised: APC, Air alarm, Fire alarm, station intercom, newscaster, extinguisher cabient, light switches.

* If you are making non-minor edits to an area or room, (non-minor being anything more than moving a few objects or fixing small bugs) then you should ensure the entire area/room is updated to meet these standards.

* When making a change to an area or room, follow these guidelines:
  * Unless absolutely necessary, do not run pipes (including disposals) under wall turfs.
  * **NEVER** run cables under wall turfs.
  * Keep floor turf variations to a minimum. Generally, more than 3 floor turf types in one room is bad design.
  * Run air pipes together where possible. The first example below is to be avoided, the second is optimal:

    ![image](https://user-images.githubusercontent.com/12197162/120011088-d22c7400-bfd5-11eb-867f-7b137ac5b1b2.png) ![image](https://user-images.githubusercontent.com/12197162/120011126-dfe1f980-bfd5-11eb-96b2-c83238a9cdcf.png)
  * Pipe layouts should be logical and predictable, easy to understand at a glance. Always avoid complex layouts like in this example:

    ![image](https://user-images.githubusercontent.com/12197162/120619480-ecda6f00-c453-11eb-9d9f-abf0d1a99c34.png)

  * Decals are to be used sparingly. Good map design does not require warning tape around everything. Decal overuse contributes to maptick slowdown.
  * Every **area** should contain only one APC and air alarm.
    * Critical infrastructure rooms (such as the engine, arrivals, and medbay areas) should be given an APC with a larger power cell.
  * Every **room** should contain at least one fire alarm, air vent and scrubber, light switch, station intercom, and security camera.
    * Intercoms should be set to frequency 145.9, and be speaker ON Microphone OFF. This is so radio signals can reach people even without headsets on. Larger room will require more than one at a time.
    * Exceptions can be made to security camera placement for certain rooms, such as the execution room. Larger rooms may require more than one security camera. All security cameras should have a descriptive name that makes it easy to find on a camera console.
      * A good example would be the template [Department name] - [Area], so Brig - Cell 1, or Medbay - Treatment Center. Consistency is key to good camera naming.
    * Fire alarms should not be placed next to expected heat sources.
    * Use the following "on" subtype of vents and scrubbers as opposed to var-editing: `/obj/machinery/atmospherics/unary/vent_scrubber/on` and `/obj/machinery/atmospherics/unary/vent_pump/on`
  * Head of staff offices should contain a requests console.
  * Electrochromic windows (`/obj/structure/window/reinforced/polarized`) and doors/windoors (using the `/obj/effect/mapping_helpers/airlock/polarized` helper) are preferred over shutters as the method of restricting view to a room through windows. Shutters are sill appropriate in industrial/hazardous areas of the station (engine rooms, HoP line, science test chamber, etc.).
    * Electrochromic window/windoor/door sets require a unique ID var, and a window tint button (`/obj/machinery/button/windowtint`) with a matching ID var. The default `range` of the button is 7 tiles but can be amended with a var edit.
  * Tiny fans (`/obj/structure/fans/tiny`) can be used to block airflow into problematic areas, but are not a substitute for proper door and firelock combinations. They are useful under blast doors that lead to space when opened.
  * Firelocks should be used at area boundaries over doors and windoors, but not windows. Firelocks can also be used to break up hallways at reasonable intervals.
    * Double firelocks are not permitted.
    * Maintenance access doors should never have firelocks placed over them.
  * Windows to secure areas or external areas should be reinforced. Windows in engine areas should be reinforced plasma glass.
    * Windows in high security areas, such as the brig, bridge, and head of staff offices, should be electrified by placing a wire node under the window.
  * Lights are to be used sparingly, they draw a significant amount of power.
  * Ensure door and windoor access is correctly set, this is now done by using access helpers.
    * Multiple accesses can be added to a door by placing multiple access helpers on the same tile. Be sure to pay attention so as to avoid mixing up `all` and `any` subtypes.
    * Old doors that use var edited access should be updated to use the correct access helper, and the var edit on the door should be cleaned.
      * See [`code\modules\mapping\access_helpers.dm`](../code/modules/mapping/access_helpers.dm) for a list of all access helpers.
    * Subtypes of `/obj/effect/mapping_helpers/airlock/access/any` lets anyone with ONE OF THE LISTED ACCESSES open the door.
    * Subtypes of `/obj/effect/mapping_helpers/airlock/access/all` requires ALL ACCESSES present to open the door.

  * Departments should be connected to maintenance through a back or side door. This lets players escape and allows antags to break in.
    * If this is not possible, departments should have extra entry and exit points.
  * Engine areas, or areas with a high probability of receiving explosions, should use reinforced flooring if appropriate.
  * External areas, or areas where depressurisation is expected and normal, should use airless turf variants to prevent additional atmospherics load.
  * Edits in mapping tools should almost always be possible to replicate in-game. For this reason, avoid stacking multiple structures on the same tile (i.e. placing a light and an APC on the same wall.)

### Other Notes

* Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the `tools.dm` file)
* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

* If you used regex to replace code during development of your code, post the regex in your PR for the benefit of future developers and downstream users.

* All new var/proc names should use the American English spelling of words. This is for consistency with BYOND.

* All mentions of the company "Nanotrasen" should be written as such - 'Nanotrasen'. Use of CamelCase (NanoTrasen) is no longer proper.

* If you are making a PR that adds a config option to change existing behaviour, said config option must default to as close to as current behaviour as possible.

### Dream Maker Quirks/Tricks

Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these:

#### In-To for-loops

`for(var/i = 1, i <= some_value, i++)` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but DM's `for(var/i in 1 to some_value)` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (Note, the `to` keyword is inclusive, so it automatically defaults to replacing `<=`; if you want `<` then you should write it as `1 to some_value-1`).

HOWEVER, if either `some_value` or `i` changes within the body of the for (underneath the `for(...)` header) or if you are looping over a list AND changing the length of the list then you can NOT use this type of for-loop!

### `for(var/A in list)` VS `for(var/i in 1 to length(list))`

The former is faster than the latter, as shown by the following profile results: [https://file.house/zy7H.png](https://file.house/zy7H.png)

Code used for the test in a readable format: [https://pastebin.com/w50uERkG](https://pastebin.com/w50uERkG)

#### Istypeless for loops

A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:

```dm
var/list/bag_of_items = list(sword1, apple, coinpouch, sword2, sword3)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
    if(!best_sword || S.damage > best_sword.damage)
        best_sword = S
```

The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using `istype()` (or some internal-magic similar to `istype()` - this is BYOND, after all). This is fine in its current state for `bag_of_items`, but if `bag_of_items` contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:

```dm
var/list/bag_of_swords = list(sword1, sword2, sword3, sword4)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
    if(!best_sword || S.damage > best_sword.damage)
      best_sword = S
```

The above code specifies a type for DM to filter by.

With the previous example that's perfectly fine, we only want swords, but if the bag only contains swords? Is DM still going to try to filter because we gave it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body, you can circumvent DM's filtering and automatic `istype()` checks by writing the loop as such:

```dm
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
    var/obj/item/sword/S = s
    if(!best_sword || S.damage > best_sword.damage)
      best_sword = S
```

Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the
specified type, even if it isn't really that type, causing runtime errors (AKA your shit won't work if this happens).

#### Dot variable

Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance. eg:

```dm
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```

However, DM also has a dot *variable*, accessed just as `.` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the `return` statement) at the end of a proc, provided the proc does not already manually return (`return count` for example.) Why is this special?

With `.` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the `.` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the `.` operator is compatible with a few operators that look weird but work perfectly fine, such as: `.++` for incrementing `.'s` value, or `.[1]` for accessing the first element of `.`, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```dm
/mob
    var/global/thing = TRUE
```

This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

### Global Vars

All new global vars must use the defines in [`code/__DEFINES/_globals.dm`](../code/__DEFINES/_globals.dm). Basic usage is as follows:

To declare a global var:

```dm
GLOBAL_VAR(my_global_here)
```

To access it:

```dm
GLOB.my_global_here = X
```

There are a few other defines that do other things. `GLOBAL_REAL` shouldn't be used unless you know exactly what you're doing.
`GLOBAL_VAR_INIT` allows you to set an initial value on the var, like `GLOBAL_VAR_INIT(number_one, 1)`.
`GLOBAL_LIST_INIT` allows you to define a list global var with an initial value. Etc.

### GitHub Staff

There are 3 roles on the GitHub, these are:

* Headcoder
* Commit Access
* Review Team

Each role inherits the lower role's responsibilities (IE: Headcoders also have commit access, and members of commit access are also part of the review team)

`Headcoders` are the overarching "administrators" of the repository. People included in this role are:

* [farie82](https://github.com/farie82)
* [Fox P McCloud](https://github.com/Fox-McCloud)
* [SteelSlayer](https://github.com/SteelSlayer)

---

`Commit Access` members have write access to the repository and can merge your PRs. People included in this role are:


* [AffectedArc07](https://github.com/AffectedArc07)
* [Charliminator](https://github.com/hal9000PR)
* [lewcc](https://github.com/lewcc)
* [S34N](https://github.com/S34NW)

---

`Review Team` members are people who are denoted as having reviews which can affect mergeability status. People included in this role are:

* [lewcc](https://github.com/lewcc)
* [S34N](https://github.com/S34NW)
* [Sirryan2002](https://github.com/Sirryan2002)
* [Contrabang](https://github.com/Contrabang)
* [Burzah](https://github.com/Burzah)
* [DGamerL](https://github.com/DGamerL)

---

Full information on the GitHub contribution workflow & policy can be found at [https://www.paradisestation.org/dev/policy/](https://www.paradisestation.org/dev/policy/)

### PR Status

Status of your pull request will be communicated via PR labels. This includes:

* `Status: Awaiting type assignment` - This will be displayed when your PR is awaiting an internal type assignment (for Fix, Balance, Tweak, etc)
* `Status: Awaiting approval` - This will be displayed if your PR is waiting for approval from the specific party, be it Balance or Design. Fixes & Refactors should never have this label
* `Status: Awaiting review` - This will be displayed when your PR has passed the design vote and is now waiting for someone in the review team to approve it
* `Status: Awaiting merge` - Your PR is done and is waiting for someone with commit access to merge it. **Note: Your PR may be delayed if it is pending testmerge or in the mapping queue**

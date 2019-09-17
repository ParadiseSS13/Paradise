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
 * Issue reports should be as detailed as possible, and if applicable, should include
 instructions on how to reproduce the bug.

## Pull requests
Players are welcome to participate in the development of this fork and submit their own
pull requests. If the work you are submitting is a new feature, or affects balance, it is
strongly recommended you get approval/traction for it from our forums before starting the
actual development.

#### Guidelines:
 * Pull requests should be atomic; Make one commit for each distinct change, so if a part
 of a pull request needs to be removed/changed, you may simply modify that single commit.
 Due to limitations of the engine, this may not always be possible; but do try your best.
 * Document and explain your pull requests thoroughly. Detail what each commit changes,
 and why it changes it. We do not want to have to read all of you commit names to figure
 out what your pull request is about.
 * Any pull request must have a changelog, this is to allow us to know when a PR is deployed 
 on the live server. Inline changelogs are supported through the format described 
 [here](https://github.com/ParadiseSS13/Paradise/pull/3291#issuecomment-172950466)
 and should be used rather than manually edited .yml file changelogs.
 * Pull requests should not have any merge commits except in the case of fixing merge
 conflicts for an existing pull request. New pull requests should not have any merge
 commits. Use `git rebase` or `git reset` to update your branches, not `git pull`.

#### Using Changelog
 * Tags used in changelog include add/rscadd, del/rscdel, fix/fixes, typo/spellcheck. 
 * Without specifying a name it will default to using your GitHub name. 
 Some examples
```
:cl:
add: The ability to change the color of wires
del: Deleted depreciated wire merging now handled in parent
fix: Moving wires now follows the user input instead of moving the stack
/:cl:
```
```
:cl: N3X15
typo: Fixes some misspelled words under Using Changelog
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

```DM
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

The use of this is not allowed in this project *unless the majority of the file is already relatively pathed* as it makes finding definitions via full text 
searching next to impossible. The only exception is the variables of an object may be nested to the object, but must not nest further.

The previous code made compliant:

```DM
/datum/datum1
  var/varname1
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

### No overriding type safety checks
The use of the : operator to override type safety checks is not allowed. You must cast the variable to the proper type.

### Type paths must begin with a /
eg: `/datum/thing`, not `datum/thing`

### Datum type paths must began with "datum"
In DM, this is optional, but omitting it makes finding definitions harder. To be specific, you can declare the path `/arbitrary`, but it
will still be, in actuality, `/datum/arbitrary`. Write your code to reflect this.

### Do not use text/string based type paths
It is rarely allowed to put type paths in a text format, as there are no compile errors if the type path no longer exists. Here is an example:

```DM
//Good
var/path_type = /obj/item/baseball_bat

//Bad
var/path_type = "/obj/item/baseball_bat"
```

### Do not use `\The`.
The `\The` macro doesn't actually do anything when used in the format `\The [atom reference]`. Directly referencing an atom in an embedded string
will automatically prefix `The` or `the` to it as appropriate. As an extension, when referencing an atom, don't use `[atom.name]`, use `[atom]`.
The only exception to this rule is when dealing with items "belonging" to a mob, in which case you should use `[mob]'s [atom.name]` to avoid `The`
ever forming.

```DM
//Good
var/atom/A 
"[A]"

//Bad
"\The [A]"
```

### Use the pronoun library instead of `\his` macros.
We have a system in code/\_\_HELPERS/pronouns.dm for addressing all forms of pronouns. This is useful in a number of ways;
 * BYOND's \his macro can be unpredictable on what object it references.
   Take this example: `"[user] waves \his [user.weapon] around, hitting \his opponents!"`. 
   This will end up referencing the user's gender in the first occurence, but what about the second?
   It'll actually print the gender set on the weapon he's carrying, which is unintended - and there's no way around this.
 * It always prints the real `gender` variable of the atom it's referencing. This can lead to exposing a mob's gender even when their face is covered,
   which would normally prevent it's gender from being printed.

The way to avoid these problems is to use the pronoun system. Instead of `"[user] waves \his arms."`, you can do `"[user] waves [user.p_their()] arms."`

```
//Good
"[H] waves [H.p_their()] hands!"
"[user] waves [H.p_their()] [user.weapon] around, hitting [H.p_their()] opponents!"`

//Bad
"[H] waves \his hands!"
"[user] waves \his [user.weapon] around, hitting \his opponents!"
```

### Use `[A.UID()]` over `\ref[A]`
BYOND has a system to pass "soft references" to datums, using the format `"\ref[datum]"` inside a string. This allows you to find the object just based
off of a text string, which is especially useful when dealing with the bridge between BYOND code and HTML/JS in UIs. It's resolved back into an object
reference by using `locate("\ref[datum]")` when the code comes back to BYOND. The issue with this is that locate() can return a unexpected datum
if the original datum has been deleted - BYOND recycles the references.

UID's are actually unique; they work off of a global counter and are not recycled. Each datum has one assigned to it when it's created, which can be
accessed by `[datum.UID()]`. You can use this as a snap-in replacement for `\ref` by changing any `locate(ref)` calls in your code to `locateUID(ref)`.
Usage of this system is mandatory for any /Topic( calls, and will produce errors in Dream Daemon if it's not used. `<a href='?src=[UID()];'>`, not `<a href='?src=\ref[src];'`.

### Use var/name format when declaring variables
While DM allows other ways of declaring variables, this one should be used for consistency.

### Tabs, not spaces
You must use tabs to indent your code, NOT SPACES.

(You may use spaces to align something, but you should tab to the block level first, then add the remaining spaces)

### No hacky code
Hacky code, such as adding specific checks (ex: `istype(src, /obj/whatever)`), is highly discouraged and only allowed when there is ***no*** other option. (
Protip: 'I couldn't immediately think of a proper way so thus there must be no other option' is not gonna cut it here! If you can't think of anything else, say that outright and admit that you need help with it. Maintainers exist for exactly that reason.)

You can avoid hacky code by using object-oriented methodologies, such as overriding a function (called "procs" in DM) or sectioning code into functions and 
then overriding them as required.

### No duplicated code
Copying code from one place to another may be suitable for small, short-time projects, but Paradise is a long-term project and highly discourages this.

Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

### Startup/Runtime tradeoffs with lists and the "hidden" init proc
First, read the comments in [this BYOND thread](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), starting where the link takes you.

There are two key points here:

1) Defining a list in the variable's definition calls a hidden proc - init. If you have to define a list at startup, do so in New() (or preferably Initialize()) and avoid the overhead of a second call (Init() and then New())

2) It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this tradeoff makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

### No magic numbers or strings
This means stuff like having a "mode" variable for an object set to "1" or "2" with no clear indicator of what that means. Make these #defines with a name that 
more clearly states what it's for. For instance:
````DM
/datum/proc/do_the_thing(thing_to_do)
  switch(thing_to_do)
    if(1)
      (...)
    if(2)
      (...)
````
There's no indication of what "1" and "2" mean! Instead, you should do something like this:
````DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
  switch(thing_to_do)
    if(DO_THE_THING_REALLY_HARD)
      (...)
    if(DO_THE_THING_EFFICIENTLY)
      (...)
````
This is clearer and enhances readability of your code! Get used to doing it!

### Control statements
(if, while, for, etc)

* All control statements must not contain code on the same line as the statement (`if(condition) return`)
* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse 
  (eg: `if(count <= 10)` not `if(10 >= count)`)
* All control statements must be spaced as `if()`, with the brackets touching the keyword. 
* Do not use one-line control statements. 
  Instead of doing
  ```
  if(x) return
  ```
  You should do
  ```
  if(x)
    return
  ```

### Player Output
Due to the use of "Goonchat", Paradise requires a special syntax for outputting text messages to players. Instead of `mob/client/world << "message"`,
you must use `to_chat(mob/client/world, "message")`. Failure to do so will lead to your code not working.

### Use early return
Do not enclose a proc in an if-block when returning on a condition is more feasible.
 
This is bad:
````DM
/datum/datum1/proc/proc1()
  if(thing1)
    if(!thing2)
      if(thing3 == 30)
        do stuff
````
This is good:
````DM
/datum/datum1/proc/proc1()
  if(!thing1)
    return
  if(thing2)
    return
  if(thing3 != 30)
    return
  do stuff
````
This prevents nesting levels from getting deeper then they need to be.

### Operators
#### Spacing
* Operators that should be separated by spaces
  * Boolean and logic operators like &&, || <, >, ==, etc (but not !)
  * Bitwise AND &
  * Argument separator operators like , (and ; when used in a forloop)
  * Assignment operators like = or += or the like
  * Math operators like +, -, /, or \*
* Operators that should not be separated by spaces
  * Bitwise OR |
  * Access operators like . and :
  * Parentheses ()
  * logical not !

#### Use
* Bitwise AND - '&'
  * Should be written as ```bitfield & bitflag``` NEVER ```bitflag & bitfield```, both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string
  * WRONG: list(a = "b")
  * RIGHT: list("a" = "b")

### Legacy Code
SS13 has a lot of legacy code that's never been updated. Here are some examples of common legacy trends which are no longer acceptable:
  * To display messages to all mobs that can view `src`, you should use
  `visible_message()`.
    * Bad:
     ```
     for(var/mob/M in viewers(src))
             M.show_message("<span class='warning'>Arbitrary text</span>")
     ```
    * Good:
     ```
     visible_message("<span class='warning'>Arbitrary text</span>")
     ```
  * You should not use color macros (`\red, \blue, \green, \black`) to color text,
  instead, you should use span classes. `<span class='warning'>red text</span>`,
  `<span class='notice'>blue text</span>`.
    * Bad:
    ```
    to_chat("\red Red Text \black black text")
    ```
    * Good:
    ```
    to_chat("<span class='warning'>Red Text</span>black text")
    ```
  * To use variables in strings, you should **never** use the `text()` operator, use
   embedded expressions directly in the string.
     * Bad:
     ```
     to_chat(text("[] is leaking []!", src.name, src.liquid_type))
     ```
     * Good:
     ```
     to_chat("[src] is leaking [liquid_type]")
     ```
 * To reference a variable/proc on the src object, you should **not** use
   `src.var`/`src.proc()`. The `src.` in these cases is implied, so you should just use
   `var`/`proc()`.
    * Bad:
     ```
     var/user = src.interactor
     src.fillReserves(user)
     ```
    * Good:
     ```
     var/user = interactor
     fillReserves(user)
     ```


### Develop Secure Code

* Player input must always be escaped safely, we recommend you use stripped_input in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind

* Calls to the database must be escaped properly - use sanitizeSQL to escape text based database entries from players or admins, and isnum() for number based database entries from players or admins.

* All calls to topics must be checked for correctness. Topic href calls can be easily faked by clients, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls, because it won't.

* Information that players could use to metagame (that is, to identify round information and/or antagonist type via information that would not be available to them in character) should be kept as administrator only.

* Where you have code that can cause large-scale modification and *FUN*, make sure you start it out locked behind one of the default admin roles - use common sense to determine which role fits the level of damage a function could do.

### Files
* Because runtime errors do not give the full path, try to avoid having files with the same name across folders.

* File names should not be mixed case, or contain spaces or any character that would require escaping in a uri.

* Files and path accessed and referenced by code above simply being #included should be strictly lowercase to avoid issues on filesystems where case matters.

### SQL
* Do not use the shorthand sql insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

* All changes to the database's layout(schema) must be specified in the database changelog in SQL, as well as reflected in the schema files

* Any time the schema is changed the `DB_MAJOR_VERSION` defines must be incremented, as well as the example config, with an appropriate conversion kit placed 
in the SQL/updates folder.

* Queries must never specify the database, be it in code, or in text files in the repo.

### Mapping Standards
* Map Merge
  * You MUST run Map Merge prior to opening your PR when updating existing maps to minimize the change differences (even when using third party mapping programs such as FastDMM.)
    * Failure to run Map Merge on a map after using third party mapping programs (such as FastDMM) greatly increases the risk of the map's key dictionary 
    becoming corrupted by future edits after running map merge. Resolving the corruption issue involves rebuilding the map's key dictionary;

* Variable Editing (Var-edits)
  * While var-editing an item within the editor is perfectly fine, it is preferred that when you are changing the base behavior of an item (how it functions) that you make a new subtype of that item within the code, especially if you plan to use the item in multiple locations on the same map, or across multiple maps. This makes it easier to make corrections as needed to all instances of the item at one time as opposed to having to find each instance of it and change them all individually.
    * Subtypes only intended to be used on away mission or ruin maps should be contained within an .dm file with a name corresponding to that map within `code\modules\awaymissions` or `code\modules\ruins` respectively. This is so in the event that the map is removed, that subtype will be removed at the same time as well to minimize leftover/unused data within the repo.
  * Please attempt to clean out any dirty variables that may be contained within items you alter through var-editing. For example, due to how DM functions, changing the `pixel_x` variable from 23 to 0 will leave a dirty record in the map's code of `pixel_x = 0`. Likewise this can happen when changing an item's icon to something else and then back. This can lead to some issues where an item's icon has changed within the code, but becomes broken on the map due to it still attempting to use the old entry.
  * Areas should not be var-edited on a map to change it's name or attributes. All areas of a single type and it's altered instances are considered the same area within the code, and editing their variables on a map can lead to issues with powernets and event subsystems which are difficult to debug.

### Other Notes
* Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the "tools.dm" file)

* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

* Do not divide when you can easily convert it to multiplication. (ie `4/2` should be done as `4*0.5`)

* If you used regex to replace code during development of your code, post the regex in your PR for the benefit of future developers and downstream users.

* All new var/proc names should use the American English spelling of words. This is for consistency with BYOND.

### Dream Maker Quirks/Tricks
Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

#### In-To for-loops
```for(var/i = 1, i <= some_value, i++)``` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but 
DM's ```for(var/i in 1 to some_value)``` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (
Note, the ```to``` keyword is inclusive, so it automatically defaults to replacing ```<=```; if you want ```<``` then you should write it as ```1 to 
some_value-1```).

HOWEVER, if either ```some_value``` or ```i``` changes within the body of the for (underneath the ```for(...)``` header) or if you are looping over a list AND 
changing the length of the list then you can NOT use this type of for-loop!

### for(var/A in list) VS for(var/i in 1 to list.len)
The former is faster than the latter, as shown by the following profile results:
https://file.house/zy7H.png
Code used for the test in a readable format:
https://pastebin.com/w50uERkG

#### Istypeless for loops
A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:
```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
  if(!best_sword || S.damage > best_sword.damage)
    best_sword = S
```
The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a 
for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using ```istype()``` (or 
some internal-magic similar to ```istype()``` - this is BYOND, after all). This is fine in its current state for ```bag_of_items```, but if ```bag_of_items``` 
contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
  if(!best_sword || S.damage > best_sword.damage)
    best_sword = S
```
specifies a type for DM to filter by. 

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave 
it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing 
their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic ```istype()``` checks by writing the loop as such:
```DM
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
Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:
```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```
However, DM also has a dot variable, accessed just as `.` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the `return` statement) at the end of a proc, provided the proc does not already manually return (`return count` for example.) Why is this special?

With `.` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the `.` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the `.` operator is compatible with a few operators that look weird but work perfectly fine, such as: `.++` for incrementing `.'s` value, or `.[1]` for accessing the first element of `.`, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
/mob
  var/global/thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing? 

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

### Global Vars

All new global vars must use the defines in code/\_\_DEFINES/\_globals.dm. Basic usage is as follows:

To declare a global var:
```DM
GLOBAL_VAR(my_global_here)
```
To access it:
```
GLOB.my_global_here = X
```

There are a few other defines that do other things. `GLOBAL_REAL` shouldn't be used unless you know exactly what you're doing. 
`GLOBAL_VAR_INIT` allows you to set an initial value on the var, like `GLOBAL_VAR_INIT(number_one, 1)`.
`GLOBAL_LIST_INIT` allows you to define a list global var with an initial value. Etc.

## Maintainers
The only current official role for GitHub staff are the `Maintainers`. They share equal power. The `Maintainers` are
responsible for properly tagging new pull requests and issues, moderating comments in
pull requests/issues, and merging/closing pull requests.

### Maintainer List
* [Fox P McCloud](https://github.com/Fox-McCloud)
* [Crazy Lemon](https://github.com/Crazylemon64)
* [Ansari](https://github.com/variableundefined)

### Maintainer instructions
* Do not `self-merge`; this refers to the practice of opening a pull request, then
  merging it yourself. A different maintainer must review and merge your pull request, no
  matter how trivial. This is to ensure quality.
  * A subset of this instruction: Do not push directly to the repository, always make a
  pull request.
* Wait for the Travis CI build to complete. If it fails, the pull request may only be
 merged if there is a very good reason (example: fixing the Travis configuration).
* Pull requests labeled as bugfixes and refactors may be merged as soon as they are
 reviewed.
* The shortest waiting period for -any- feature or balancing altering pull request is 24
 hours, to allow other coders and the community time to discuss the proposed changes.
* If the discussion is active, or the change is controversial, the pull request is to be
 put on hold until a consensus is reached.

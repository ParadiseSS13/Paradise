Below is a glossary of common used terms along with their meanings relating to
the coding side of SS13. If you notice any missing terms of discrepancies in
descriptions, feel free to contribute to the list! Feel free to ask any
questions in `#coding-chat` on the discord. Non-coding related Glossary can be
found on the [wiki][]. More in depth information can be found at BYOND's
official [documentation][].

[wiki]: https://paradisestation.org/wiki/index.php?title=Glossary
[documentation]: https://secure.byond.com/docs/ref/#/DM/

## .DM
DreamMaker code files, or .dm files are the file format for BYOND source code.
These files must be "ticked" in the .dme file for them to be included in the
game.

## .DMB
"DreamMaker Build" or DMB files are compiled DME files and are
used with Dream Daemon to run the server.

## .DME
"DreamMaker Environment" or DME files are what BYOND uses to compile the game.
It is a list of all .dm files used in the game, if you add a new file you will
need to "Tick" it or add it to this file manually.

## .DMI
DreamMaker images or DMI files is how BYOND stores images (also known as icons),
these can be edited with BYOND's tools or external tools.

## .DMM
DreamMaker maps or DMM files is how BYOND stores maps. These can be edited with
BYOND's tools or something like [StrongDMM](#strongdmm)

## Area
From the [BYOND documentation](https://secure.byond.com/docs/ref/#/area/):

> "Areas are derived from /area. Regions on the map may be assigned to an area
by painting it onto the map. Areas off the map serve as rooms that objects may
enter and exit. For each area type defined, one area object is created at
runtime. So for areas on the map, all squares with the same area type belong to
the same instance of the area."

In SS13, this is often used to delineate station departments and station systems
such as power and atmospherics networks.

## Atmos
The atmospherics system in SS13, which is very often old and confusing and/or
broken code.

## Atom
From the [BYOND documentation](https://secure.byond.com/docs/ref/#/atom/):

> "The /atom object type is the ancestor of all mappable
objects in the game. The types /area, /turf, /obj, and /mob are all
derived from /atom. You should not create instances of /atom directly
but should use /area, /turf, /obj, and /mob for actual objects. The
/atom object type exists for the purpose of defining variables or
procedures that are shared by all of the other 'physical' objects.
These are also the only objects for which verbs may be accessible to the
user. /atom is derived from /datum, so it inherits the basic properties that
are shared by all DM objects."

## Baseturf
An SS13 variable that saves the data of what is underneath if that that is
removed. For example, under station floors there would be a space turf and under
Lavaland turfs there would be lava.

## Bitflag
A single variable made of individual TRUE/FALSE values. See
[Bitflags](./bitflags.md) for an introduction on how to use bitflags.

## Buff
A buff is a change to a gameplay mechanic that makes it more powerful or more
useful. Generally the opposite of a [nerf](#nerf).

## Commit
A record of files changed and how they were changed, they are each assigned a
special ID called a hash that specifies the changes it makes.

## Config
The config.toml file for changing things about your local server. You will need
to copy this from the config/example folder if you haven't already.

## Datum
From the [BYOND documentation](https://secure.byond.com/docs/ref/#/datum/):

> "The datum object is the ancestor of all other data types in DM. (The only
exceptions are currently `/world`, `/client`, `/list`, and `/savefile`, but
those will be brought into conformance soon.) That means that the variables and
procedures of /datum are inherited by all other types of objects."

Datums are useful to represent abstractions that don't physically exist in the
game world, such as information about a spell or a Syndicate uplink item. They
are also useful for vars or procs that all other data-types use.

## Define
A way of declaring variable either global (across the whole game) or in a whole
file using DM's `#DEFINE` macro syntax. They should always be found at the
beginning of a file. Defines should always be capitalized (LIKE_THIS) and if not
global should undefined at the end of a file.

## Fastmos
Fast atmos, usually featuring explosive decomposition and lots of in game death.
Fastmos is not used on Paradise.

## Garbage
The garbage collector handles items being deleted and allows them to clean up
references, this allows objects to delete much more efficiently.

## Head Admin
Head of the admin team and overseeing overall changes and the direction for the
entire Paradise codebase and server. Contact them or the Balance team about
large changes or balance changes before making a PR, including map additions,
new roles, new antagonists, and other similar things.

## Icondiffbot
A tool on GitHub that renders before and after images of BYOND icons. It can be
viewed on any PR by scrolling down to the checks section and clicking details
next to it.

## LGTM
"Looks Good To Me", used during code reviews.

## Local
Your copy of your remote repository on your local machine or computer. Commits
need to be published to your remote repo before they can be pushed to the
upstream repo for a pull request.

## Maintainer
A no longer used title, previously used for people who made sure code is
quality. Maintainers were split up into the Balance Team, Design Team, and several
other groups. Check [PR #18000](https://github.com/ParadiseSS13/Paradise/pull/18000/) for more
information.

## Map merge
Tools that automatically attempt to merge maps when merging master or
committing. Map merge is a work in progress and may require manual editing too.

## Mapdiffbot
A tool on GitHub that renders before and after images of BYOND maps. It can be
viewed on any PR by scrolling down to the checks section and clicking details
next to it.

## Master Controller
The Master Controller controls all subsystems of
the game, such as the [garbage collector](#garbage).

## MC
Short for Short for [Master Controller](#master-controller).

## Merge Master
The process of merging master into your PR's branch, often to update it.

## Mob
Mobs are "mobile objects", these include players and animals. This does not
include stuff like conveyors.

## Nerf
Nerfs are changes to a gameplay mechanic that make it less powerful or decreases
its utility, typically done for the sake of improving game balance and
enjoyability. Generally the opposite of a [buff](#buff).

## NPFC
"No Player-Facing Changes", used in the changelog of a PR, most often in
refractors and exploit fixes.

## Object
Objects are things you can interact with in game, including things that do not
move. This includes weapons, items, machinery (consoles and machines), and
several other things.

## Origin
Typically another name for your [remote repo](#remote).

## PR
Short for [Pull Request](#pull-request).

## Proc
Procs or Procedures are block of code that only runs when it is called. These
are similar to something like functions in other languages.

## Publish
Uploading your code from your local machine.

## Pull Request
A request to the Paradise Github Repository for certain
changes to be made to the code of the game. This includes maps and sprites.

## Pulling code
Pulling is transferring commits from the main repo to your remote repo, or from
your remote repository to your local repository.

## Pushing code
Pushing is how you transfer commits from your repository to the Upstream repo.

## qdel
A function, `qdel()`, which tells the [garbage collector](#garbage) to handle
destruction of an object. This should always be used over `del()`.

## QDEL_NULL
A [qdel](#qdel) function which first nulls out a variable before telling the
garbage collector to handle it.

## Remote
Your forked copy of the upstream repo that you have complete access over. your
clean copy of master and any published branches you've made can be found here.

## Repo
Short for [repository](#repository).

## Repository
A collection of code which tracks the commits and changes to it. There are three
main types you will find the upstream repository, your remote repository, and
your local repository.

## Runechat Chat
Chat messages which appear above player's characters, a feature added by
[#14141](https://github.com/ParadiseSS13/Paradise/pull/14141/). Often a joke
about players now missing important things in the chat window since they no
longer have to look there for reading messages from people.

## Runtime
Runtimes most often refer to runtime errors, which are errors that happen after
compiling and happen in game.

## StrongDMM
A [robust mapping tool](https://github.com/SpaiR/StrongDMM/) that is highly
recommended over BYOND's DMM editor, as it is much quicker and has much more
options. Using any version below 2.0 makes your PR very unlikely to be accepted
as it messes with variables.

## TGUI
A JavaScript based format for displaying an interface. It is
used for our user interfaces (except OOC stuff like admin panels), or
are planned to be converted to TGUI. TGUI uses React. More information can be
found at the [TGUI Tutorial][].

[TGUI Tutorial]: https://github.com/ParadiseSS13/Paradise/blob/master/tgui/docs/tutorial-and-examples.md

## Turf
Turfs are floors, stuff like space, floors, carpets, or lava, or walls. This
does not include windows, as they are objects.

## Upstream
The original repo that you have forked your remote repository from. For us, it
is [ParadiseSS13/Paradise](https://github.com/ParadiseSS13/Paradise/).

## Var
A variable, used for temporarily storing data. For more
permanent data, check out [defines](#define).

## Verb
A special type of proc, which is only available to mobs.

## View Variables
An admin tool that can be used in game to view the variables of anything, giving
you more information about them. Very useful for debugging.

## VSC
Short for [Visual Studio Code](https://code.visualstudio.com/).

## VV
Short for [View Variables](#view-variables).

## WYCI
"When You Code It", a joking response to someone asking when something will be
added to the game.

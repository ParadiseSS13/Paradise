# Mapping Quickstart

The purpose of this guide is to provide basic instructions on how to start
mapping for Paradise Station and the tools needed to do so.

## Tooling

Once you have set up your [development environment][env], you will need several
other tools to edit maps and publish your changes for Pull Requests.

### Mapmerge

If you have a map change published as a PR, and someone else makes a change to
that map which is merged before yours, it is likely that there will be a merge
conflict. Because of the way map files are formatted, using git to resolve these
merge conflicts directly will result in a broken map.

To deal with this, a separate tool, *Mapmerge*, is integrated into git. Mapmerge
has the ability to look at the changes between two maps, merge them together
correctly, and provide markers on the map where it requires a contributor to
make a manual change.

To install Mapmerge, run `\tools\hooks\Install.bat`.

Further documentation on Mapmerge is forthcoming.

<div class="warning">

Unless you know how to use git effectively, install Mapmerge **before** having
to deal with a map merge conflict.

</div>

[env]: ../contributing/getting_started.md

### StrongDMM

[StrongDMM][] is the recommended tool for editing maps by a wide margin. It is
fast, provides easy searching for both objects on maps and objects in the
codebase, an intuitive varediting system, the ability to hide categories of
objects on the map while editing, and more.

When using StrongDMM, the following options must be enabled. They can be found
under _File -> Preferences_:

  - "Sanitize Variables" must be checked. This removes variables that are
    declared on the map, but are the same as their initial value.. (For example:
    A standard floor turf that has `dir = 2` declared on the map will have that
    variable deleted as it is redundant.)
  - "Save Format" must be set to "TGM".
  - "Nudge Mode" must be set to "pixel_x/pixel_y".

[StrongDMM]: https://github.com/SpaiR/StrongDMM/releases

### UpdatePaths

_UpdatePaths_ is a utility which make it easier for mappers to share simple
large-scale changes across maps. It does this by allowing mappers to write
scripts which describe those changes, which are then applied to maps. For
example, when migrating pixel-pushed ATMs to their directional helpers, this
script was written:

```
/obj/machinery/economy/atm{pixel_x=-32} : /obj/machinery/economy/atm/directional/west
/obj/machinery/economy/atm{pixel_x=32} : /obj/machinery/economy/atm/directional/east
/obj/machinery/economy/atm{pixel_y=-32} : /obj/machinery/economy/atm/directional/south
/obj/machinery/economy/atm{pixel_y=32} : /obj/machinery/economy/atm/directional/north
```

This takes each object found on a map with the specified `pixel_x`/`y` varedits,
and replaces them with the object on the right side of the line.

More information on UpdatePaths and how to use it is available in the
[UpdatePaths documentation][upd].

[upd]: https://github.com/ParadiseSS13/Paradise/blob/master/tools/UpdatePaths/readme.md

## Mapping Tutorial

Until a more specific guide is written for Paradise Station, /tg/station's
[Guide to Mapping](https://hackmd.io/@tgstation/SyVma0dS5#san7890s-A-Z-Guide-to-Mapping)
written by san7890 is a recommended resource for use SDMM, test mapping changes,
and reconcile map merge conflicts.

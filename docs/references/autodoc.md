# dmdoc

[dmdoc] is a documentation generator for DreamMaker, the scripting language of
the [BYOND] game engine. It produces simple static HTML files based on
documented files, macros, types, procs, and vars.

We use **dmdoc** to generate [documentation] for our code, and that
documentation is automatically generated and built on every new commit to the
master branch

This gives new developers a clickable reference [documentation] they can browse
to better help gain understanding of the Paradise codebase structure and api
reference.

[documentation]: https://codedocs.paradisestation.org/
[BYOND]: https://secure.byond.com/
[dmdoc]: https://github.com/SpaceManiac/SpacemanDMM/tree/master/crates/dmdoc

## Documenting Code On Paradise
We use block comments to document procs and types, and we use `///` line
comments when documenting individual variables.

Documentation is not required at Paradise, but it is highly recommended that all
new code be covered with DMdoc code, according to the
[Specifications](#specification).

We also recommend that when you touch older code, you document the procs that you
have touched in the process of updating that code

### Specification
A type *should* always be auto-documented, and all public procs *should* be
documented.

All type level defined variables *should* be documented.

Internal procs *can* be documented, but may not be.

A public proc is any function that a developer might reasonably call while using
or interacting with your object. Internal procs are helper functions that your
public procs rely on to implement logic.

### Documenting a proc
When documenting a proc, we give a short one line description (as this is shown
next to the proc definition in the list of all procs for a type or global
namespace), then a longer paragraph which will be shown when the user clicks on
the proc to jump to its definition

```dm
/**
  * Short description of the proc
  *
  * Longer detailed paragraph about the proc
  * including any relevant detail
  * Arguments:
  * * arg1 - Relevance of this argument
  * * arg2 - Relevance of this argument
  */
```

### Documenting types
We first give the name of the type as a header, this can be omitted if the name
is just going to be the typepath of the type, as dmdoc uses that by default.
Then we give a short one-line description of the type. Finally we give a longer
multi paragraph description of the type and its details.

```dm
/**
  * # type name (Can be omitted if it's just going to be the typepath)
  *
  * The short overview
  *
  * A longer
  * paragraph of functionality about the type
  * including any assumptions/special cases
  *
  */
```

### Documenting a variable/define
Give a short explanation of what the variable, in the context of the type, or define is.

```dm
/// Typepath of item to go in suit slot
var/suit = null
```

## Module level description of code
Modules are the best way to describe the structure/intent of a package of code
where you don't want to be tied to the formal layout of the type structure.

On Paradise we do this by adding markdown files inside the `code` directory
that will also be rendered and added to the modules tree. The structure for
these is deliberately not defined, so you can be as freeform and as wheeling as
you would like.

## Special variables
You can use certain special template variables in DM DOC comments and they will
be expanded.

- `[DEFINE_NAME]` expands to a link to the define definition if documented.
- `[/mob]` expands to a link to the docs for the /mob type.
- `[/mob/proc/Dizzy]` expands to a link that will take you to the /mob type and
  anchor you to the dizzy proc docs.
- `[/mob/var/stat]` expands to a link that will take you to the /mob type and
  anchor you to the stat var docs

You can customise the link name by using `[link name][link shorthand]`.

e.g. `[see more about dizzy here][/mob/proc/Dizzy]`

This is very useful to quickly link to other parts of the autodoc code to expand
upon a comment made, or reasoning about code.

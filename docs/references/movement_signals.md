# Movement Signals

## Background

Traditionally, BYOND games rely on several native procs to respond to certain
kinds of in-game movement:

- If one atom attempts to overlap another one, [`/atom/proc/Cross`][cross] is called,
  allowing the overlapped atom to either return `TRUE` to allow the cross, or
  `FALSE` to prevent it. When `Move()` is called and an atom overlaps another
  one, [`/atom/proc/Crossed`][crossed] is called, allowing the overlapped atom to react
  to the cross.
- Similarly, when an atom attempts to stop overlapping another,
  [`/atom/proc/Uncross`][uncross] is called to permit or deny it, then
  [`/atom/proc/Uncrossed`][uncrossed] is called to allow the atom to react to it.
- When a movable attempts to enter a turf, [`/turf/proc/Enter`][enter] is called,
  allowing the turf to return `TRUE` to permit the entry, or `FALSE` to deny it.
  When a movable succeeds in entering a turf, [`/turf/proc/Entered`][entered] is
  called, allowing the turf to react to the entry.
- Similarly, when an atom attempts to exit a turf, [`/turf/proc/Exit`][exit] is
  called to permit or deny it, then [`/turf/proc/Exited`][exited] is called to allow
  the turf to react to the exit.
- When an atom attempts to enter the contents of another one,
  [`/atom/proc/Enter`][atom_enter] is called, allowing the containing atom to
  either return `TRUE` to allow the entry, or `FALSE` to prevent it. When an
  atom successfully enters the contents of another one,
  [`/atom/proc/Entered`][atom_entered] is called.
- Similarly, when an atom attempts to exit another atom's contents,
  [`/atom/proc/Exit`][atom_exit] is called to permit or deny it, then
  [`/atom/proc/Exited`][atom_exited] is called to allow the turf to react to the
  exit.

As one can imagine, with a lot of objects moving around in the game world,
calling all of these procs can be expensive, especially if we don't care about
what happens most of the time.

In order to avoid making all of these calls, and provide more fine-grained
control over what happens on atom/turf interactions, we implement our own
version of the native `/atom/movable/Move`, and use signal handlers and
components to process the interactions we care about.

[cross]: https://secure.byond.com/docs/ref/#/atom/proc/Cross
[crossed]: https://secure.byond.com/docs/ref/#/atom/proc/Crossed
[uncross]: https://secure.byond.com/docs/ref/#/atom/proc/Uncross
[uncrossed]: https://secure.byond.com/docs/ref/#/atom/proc/Uncrossed
[enter]: https://secure.byond.com/docs/ref/#/turf/proc/Enter
[entered]: https://secure.byond.com/docs/ref/#/turf/proc/Entered
[exit]: https://secure.byond.com/docs/ref/#/turf/proc/Exit
[exited]: https://secure.byond.com/docs/ref/#/turf/proc/Exited
[atom_enter]: https://secure.byond.com/docs/ref/#/atom/proc/Enter
[atom_entered]: https://secure.byond.com/docs/ref/#/atom/proc/Entered
[atom_exit]: https://secure.byond.com/docs/ref/#/atom/proc/Exit
[atom_exited]: https://secure.byond.com/docs/ref/#/atom/proc/Exited

## Signal Handlers

There are several signal handlers used to replicate the native BYOND atom
crossover/entry behavior:

- [`COMSIG_MOVABLE_PRE_MOVE`][pre_move] is sent when trying to determine if an
  atom can enter a new turf. Any subscribed handler can return
  `COMPONENT_MOVABLE_BLOCK_PRE_MOVE` to prevent the move.
- [`COMSIG_MOVABLE_MOVED`][moved] is sent after a successful move.
- [`COMSIG_MOVABLE_CHECK_CROSS`][cross] is sent when trying to determine if an
  atom can cross over another one. Any subscribed handler can return
  `COMPONENT_BLOCK_CROSS` to prevent the cross.
- Similarly, [`COMSIG_MOVABLE_CHECK_CROSS_OVER`][crossover] is sent if an atom
  will allow another one to cross over it--the reverse of
  `COMSIG_MOVABLE_CHECK_CROSS`. Again, any subscribed handler can return
  `COMPONENT_BLOCK_CROSS` to prevent it.
- [`COMSIG_ATOM_ENTERED`][entered] is sent if an atom enters this atom's
  contents. Similarly, [`COMSIG_ATOM_EXITED`][exited] is sent if an atom exits
  this atom's contents.

[pre_move]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_MOVABLE_PRE_MOVE
[moved]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_MOVABLE_MOVED
[cross]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_MOVABLE_CHECK_CROSS
[crossover]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_MOVABLE_CHECK_CROSS_OVER
[entered]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_ATOM_ENTERED
[exited]: https://codedocs.paradisestation.org/code/__DEFINES/dcs/movable_signals.html#define/COMSIG_ATOM_EXITED

## The `connect_loc` Element

The above signals are not appropriate for all cases. For example, it may seem
like beartraps should listen to `COMSIG_MOVABLE_MOVED` to see if they should
activate. However, this will fire every time a movement crossing occurs, even if
it wouldn't normally trigger the trap, such as if the trap is being thrown and
intersects abstract lighting objects. Instead, we use `COMSIG_ATOM_ENTERED` with
the `connect_loc` element. As a refresher, `COMSIG_ATOM_ENTERED` fires when an
atom enters the contents of another. By using the `connect_loc` element, we can
have the beartrap listen for signals on the turf it's located on. Then, if the
turf has a `COMSIG_ATOM_ENTERED` signal fire, we can have the beartrap respond.

Before:

```dm
/obj/item/restraints/legcuffs/beartrap/proc/Crossed(mob/living/crossed)
	if(istype(crossed))
		spring_trap()
```

After:

```dm
/obj/item/restraints/legcuffs/beartrap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/restraints/legcuffs/beartrap/proc/on_atom_entered(datum/source, mob/living/entered)
	if(istype(entered))
		spring_trap()
```

Note that the list of connections is `static` so that a new element instance isn't
created for every new beartrap.

## Summary

The procs `/atom/movable/Cross`, `/atom/movable/Crossed`,
`/atom/movable/Uncross`, and `/atom/movable/Uncrossed`, should not be used for
new code.

If you care about every time a movable attempts to overlap you, listen to
`COMSIG_MOVABLE_PRE_MOVE`, and return `COMPONENT_MOVABLE_BLOCK_PRE_MOVE` to
prevent it from happening.

If you want to prevent a movable from crossing you, listen to
`COMSIG_MOVABLE_CHECK_CROSS` and return `COMPONENT_BLOCK_CROSS` to prevent it. If you
want to prevent a movable from being crossed by you, listen to
`COMSIG_MOVABLE_CHECK_CROSS_OVER` and return `COMPONENT_BLOCK_CROSS` to prevent it.

If you care about an atom entering or exiting your contents, listen to
`COMSIG_ATOM_ENTERED` or `COMSIG_ATOM_EXITED`.

If you care about an atom entering or exiting your location, or any other signal
firing on your location, create a `static` list of signals mapped to procs and
add a `/datum/element/connect_loc` to yourself.

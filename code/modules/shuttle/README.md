<!-- TOC depth:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Shuttle system](#shuttle-system)
	- [Introduction](#introduction)
	- [Docking ports](#docking-ports)
		- [/obj/docking_port](#obj-docking_port)
			- [Variables](#variables)
		- [/obj/docking_port/mobile](#objdockingportmobile)
		- [/obj/docking_port/mobile](#objdockingportmobile)
	- [Modifications](#modifications)
		- [Shuttle Controller](#shuttle-controller)
		- [Airlocks](#airlocks)
		- [Initialization](#initialization)
<!-- /TOC -->

 # Important note:
The following readme was last updated during Late 2015. The changes between Paradise & TG's shuttle system has diverged greatly since then. Do not take the documentation here's description of differences between tg & paradise seriously without double checking. 

# Shuttle system
## Introduction
This folder belongs to the "shuttle" system. The shuttle system is used to control the
"Shuttles" on the map, which are, at their core, a rectangular area of turfs that "move".

The shuttle system is comprised of two primary files.
[`shuttle.dm`](http://github.com/ParadiseSS13/Paradise/blob/master/code/modules/shuttle/shuttle.dm),
which contains the primary code, and
[`shuttles.dm`](http://github.com/ParadiseSS13/Paradise/blob/master/code/controllers/Process/shuttles.dm)
which contains the back-end controller system.
There are a few other files, but it isn't worth noting on.

Shuttles are used for many purposes, including the end of rounds, so it's important to
understand them.

## Docking ports
### obj docking_port
The `/obj/docking_port` type is the primary component of the shuttle system. Almost all of
the shuttle system is controlled by the docking ports, the only thing that isn't, really,
is the shuttle manager, which manages, you guessed it, the docking ports.

Docking ports are split into two main types: `/obj/docking_port/stationary`, and
`/obj/docking_port/mobile`, but they share a few variables and procs defined at the
`/obj/docking_port` level.

#### Variables
`id`: This variable is used for any plain-text references to the docking port. It should
always be lowercase.

`width`, `height`: The width and height variables are **absolute** value variables which
define the bounding box of the docking port. It is very important to note that these are
different from the `dwidth` and `dheight` in terms of how they are counted. As they are
absolute representations of the size of the bounding box, they need to be equal to the
amount of turfs on the side of the bounding box. An easy way to think of it is, if you
start at the very corner piece, you would start the count at `1` from that corner piece,
IE, you move 1 turf in any direction, it would be `2`.

A crude ASCII example:
```
||D|||
```
Would be classed by the values `width` = 6, `height` = 1.

It is important to note that bounding boxes are *always* rectangular. However, shuttles
are allowed to be any shape they so wish, as anything that matches the `turf_type` of
stationary docking ports will not be moved with the shuttle- by default, this is equal to
`/turf/space`.
Another quick example of this:
```
  |||
  |||
  |||
 |||||
||||||D
|||||||
||| |||
```
This, even though it is not exactly a rectangle, would be classified by the values
`width` = `7`, `height` = `7`.


`dwidth`, `dheight`: The relative offset of the docking port to the bounding box. These
values are calculated **relative** to the bounding box. The values are counted from the
bottom left corner of the bounding box, **relative** to the direction of the docking port.
The "bottom left corner" changes depending on the direction of the docking port object.
so a docking port **facing north** that looks something like this:

```
|||  
|||  
|||D|  
|||||
```

Would have a `dwidth` value of `3`, and a `dheight` value of `1`.
A docking port **facing south** that looks like this:

```
||||||
|||D||
 ||||
```

Would have a `dwidth` value of `2`, and a `dheight` value of `1`


### /obj/docking_port/mobile
`/obj/docking_port/mobile`, or, "Mobile" docking ports are used to define and control the
movement of the shuttle chunks. The "Mobile" docking port moves with the shuttle, and is
essentially attached to it. A "Mobile" docking port only moves to predefined positions
on the map, referred to as "Stationary" docking ports.

### /obj/docking_port/mobile
`/obj/docking_port/stationary`, or "Stationary" docking ports are used as predefined
references for where "Mobile" docking ports may move. "Stationary" docking ports do not
move unless something has gone horribly wrong. They are essentially static points in
space. Going into details, whenever a "Mobile" docking port "moves", it registers with the
stationary docking port that it was requested to move to, and moves itself to it. It is
important to note that docking ports will switch direction on the fly, and a "Stationary"
docking port not matching the initial direction of the "Mobile" docking port will cause
the entire shuttle to be rotated in order for the "Mobile" docking port to face the same
direction as the "Stationary" docking port.


## Modifications
There are three main differences between -tg-station13's shuttle system and the one in
use on Paradise, and none are very complex.

### Airlocks
The biggest modification comes in the form of how docking ports interact with airlocks.
With -tg-station13's base code, any door on the shuttle will be closed, and any door
directly next to the mobile docking port will be closed off of the shuttle.

In Paradise, however, when a mobile docking port undocks from the stationary docking port,
it will look for any door in the machine list who's `id_tag` variable matches the
stationary docking port's `id` variable. When it finds these doors, it will close *and*
bolt the doors shut. Any airlocks on the shuttle will be closed as per usual, but any
airlocks within the shuttle with the `id_tag` of `s_docking_airlock` will also be bolted,
and will stay bolted until the shuttle has exited transit space.

### Initialization
In -tg-station13's shuttle system, all docking ports register with the shuttle controller
on `New()`. However, as Paradise uses a different system for the shuttle controller, it is
not yet created when `New()` is called.

To fix this issue, all docking ports will not initialize automatically on `New()`.
Instead, they are manually initialized by the shuttle controller when it is created, via
a proc called `initialize()`.

//MISC EFFECTS

//This file is for effects that are less than 20 lines and don't fit very well in any other category.

/*CURRENT CONTENTS
	Strange Present
	Mark
	Beam
	Laser
	Begin
	Stop
	Projection
	Shut_controller
	Showcase
	Spawner
	List_container
*/

//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		anchored = 1
		layer = 99
		plane = HUD_PLANE
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		unacidable = 1//Just to be sure.

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0

/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0
	unacidable = 1

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

/obj/effect/spawner
	name = "object spawner"

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )


/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and vicerea. You swear you can see it moving..."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_g"
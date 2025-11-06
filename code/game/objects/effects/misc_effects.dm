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
	density = TRUE
	anchored = FALSE

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		layer = 99
		plane = HUD_PLANE
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/beam
	name = "beam"
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list()

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE

/obj/effect/spawner
	name = "object spawner"

/**
 * Used when we want to pass vars from a spawner to a spawned object
 *
 * a - The spawned object we want to pass a var to
 */
/obj/effect/spawner/proc/synchronize_variables(atom/a)
	return

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list()


/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and vicera. You swear you can see it moving..."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_mess"


//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = null // null iconstate is white by default
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	blend_mode = BLEND_ADD


/obj/effect/dummy/lighting_obj
	name = "lighting fx obj"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/dummy/lighting_obj/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	set_light(_range ? _range : light_range, _power ? _power : light_power, _color ? _color : light_color)
	if(_duration)
		QDEL_IN(src, _duration)

/obj/effect/dummy/lighting_obj/moblight
	name = "mob lighting fx"

/obj/effect/dummy/lighting_obj/moblight/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/dusting_anim
	icon = 'icons/effects/filters.dmi'
	icon_state = "nothing"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOOR_PLANE

/obj/effect/dusting_anim/Initialize(mapload, id)
	. = ..()
	icon_state = "snap3"
	render_target = "*snap[id]"

/obj/effect/frosty_breath
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/effect/frosty_breath/Initialize(mapload, mob/living/carbon/C)
	. = ..()
	dir = C.dir
	if(C.buckled)
		pixel_y = (C.buckled.buckle_offset + 10)
	if(dir == NORTH)
		layer = BELOW_MOB_LAYER
	flick("breath_[C.lying_prev]", src)
	QDEL_IN(src, 2 SECONDS)

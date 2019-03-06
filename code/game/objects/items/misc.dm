//MISC items
//These items don't belong anywhere else, so they have this file.

//Current contents:
/*
	mouse_drag_pointer
	Beach Ball
*/

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = WEIGHT_CLASS_TINY
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT
	
/obj/item/choice_beacon/proc/generate_display_names() // return the list that will be used in the choice selection. entries should be in (type.name = type) fashion. see choice_beacon/hero for how this is done.
	return list()

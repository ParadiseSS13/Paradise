/datum/component/spraycan_paintable
	var/current_paint

/datum/component/spraycan_paintable/Initialize()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/Repaint)

/datum/component/spraycan_paintable/Destroy()
	RemoveCurrentCoat()
	return ..()

/datum/component/spraycan_paintable/proc/RemoveCurrentCoat()
	var/atom/A = parent
	A.remove_atom_colour(FIXED_COLOUR_PRIORITY, current_paint)

/datum/component/spraycan_paintable/proc/Repaint(datum/source, obj/item/toy/crayon/spraycan/spraycan, mob/living/user)
	if(!istype(spraycan) || user.a_intent == INTENT_HARM)
		return
	. = COMPONENT_NO_AFTERATTACK
	if(spraycan.capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return
	if(spraycan.uses < 2)
		to_chat(user, "<span class ='warning'>There is not enough paint in the can!")
		return
	RemoveCurrentCoat()
	var/colour = spraycan.colour
	current_paint = colour
	var/atom/A = parent
	A.add_atom_colour(colour, FIXED_COLOUR_PRIORITY)
	playsound(spraycan, 'sound/effects/spray.ogg', 5, 1, 5)
	to_chat(user, "<span class='notice'>You spray [spraycan] on [A], painting it.</span>")

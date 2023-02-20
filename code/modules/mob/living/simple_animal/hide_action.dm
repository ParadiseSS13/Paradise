/datum/action/innate/animal_hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off. While hiding you can fit under unbolted airlocks."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "mouse_gray_sleep"

/datum/action/innate/animal_hide/Activate()
	var/mob/living/simple_animal/simplemob = owner

	if(simplemob.layer != TURF_LAYER + 0.2)
		simplemob.layer = TURF_LAYER + 0.2
		simplemob.visible_message("<B>[src] scurries to the ground!</B>", "<span class=notice'>You are now hiding.</span>")
		if(simplemob.pass_door_while_hidden)
			simplemob.pass_flags |= PASSDOOR
		return

	simplemob.layer = MOB_LAYER
	simplemob.visible_message("[src] slowly peeks up from the ground...", "<span class=notice'>You have stopped hiding.</span>")
	if(simplemob.pass_door_while_hidden)
		simplemob.pass_flags &= ~PASSDOOR

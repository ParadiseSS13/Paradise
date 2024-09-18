/datum/action/innate/hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off. While hiding you can fit under unbolted airlocks."
	var/layer_to_change_from = MOB_LAYER
	var/layer_to_change_to = TURF_LAYER + 0.2
	check_flags = AB_CHECK_CONSCIOUS
	button_overlay_icon_state = "mouse_gray_sleep"

/datum/action/innate/hide/Activate()
	var/mob/living/simple_animal/simplemob = owner

	if(owner.layer != layer_to_change_to)
		owner.layer = layer_to_change_to
		owner.visible_message("<span class='notice'><b>[owner] scurries to the ground!</b></span>", "<span class='notice'>You are now hiding.</span>")
		if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
			simplemob.pass_flags |= PASSDOOR
		return

	simplemob.layer = layer_to_change_from
	owner.visible_message("<span class='notice'>[owner] slowly peeks up from the ground...</span>", "<span class='notice'>You have stopped hiding.</span>")
	if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
		simplemob.pass_flags &= ~PASSDOOR

/datum/action/innate/hide/alien_larva_hide
	desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	button_background_icon_state = "bg_alien"
	button_overlay_icon_state = "alien_hide"
	layer_to_change_to = ABOVE_NORMAL_TURF_LAYER
	layer_to_change_from = MOB_LAYER

/datum/action/innate/hide/drone_hide
	button_overlay_icon_state = "repairbot"

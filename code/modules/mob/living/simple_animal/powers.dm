/datum/action/innate/hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	var/layer_to_change_from = MOB_LAYER
	var/layer_to_change_to = TURF_LAYER + 0.2
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "mouse_gray_sleep"


/datum/action/innate/hide/Grant(mob/user)
	. = ..()
	if(!.)
		return

	if(isanimal(owner))
		var/mob/living/simple_animal/animal = owner
		if(animal.pass_door_while_hidden)
			desc = "[desc] While hiding you can fit under unbolted airlocks."


/datum/action/innate/hide/Activate()
	var/mob/living/simple_animal/simplemob = owner

	if(owner.layer != layer_to_change_to)
		owner.layer = layer_to_change_to
		owner.visible_message(span_notice("<b>[owner] scurries to the ground!</b>"), span_notice("You are now hiding."))
		if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
			simplemob.pass_flags |= PASSDOOR
		return

	simplemob.layer = layer_to_change_from
	owner.visible_message(span_notice("[owner] slowly peeks up from the ground..."), span_notice("You have stopped hiding."))
	if(istype(simplemob) && simplemob.pass_door_while_hidden || isdrone(simplemob))
		simplemob.pass_flags &= ~PASSDOOR


/datum/action/innate/hide/drone
	desc = "Allows to hide beneath tables or certain items. Toggled on or off. While hiding you can fit under unbolted airlocks."
	button_icon_state = "repairbot"


/datum/action/innate/hide/drone/cogscarab
	layer_to_change_to = LOW_OBJ_LAYER


/datum/action/innate/hide/alien_larva
	desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	background_icon_state = "bg_alien"
	button_icon_state = "alien_hide"
	layer_to_change_to = ABOVE_NORMAL_TURF_LAYER


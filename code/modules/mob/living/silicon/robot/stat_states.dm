/mob/living/silicon/robot/WakeUp()
	. = ..()
	if(. && updating)
		update_canmove()
		update_headlamp()
		if(is_component_functioning("radio"))
			radio.on = 1

/mob/living/silicon/robot/KnockOut()
	. = ..()
	if(. && updating)
		update_canmove()
		update_headlamp()
		radio.on = 0
		uneq_all()

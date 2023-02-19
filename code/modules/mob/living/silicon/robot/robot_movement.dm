/mob/living/silicon/robot/Process_Spacemove(var/movement_dir = 0)
	if(ionpulse())
		return 1
	if(..())
		return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_delay()
	. = ..()
	. += speed
	if(module_active && istype(module_active,/obj/item/borg/destroyer/mobility))
		. -= 2
	. += config.robot_delay

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()

/mob/living/silicon/robot/get_pull_push_speed_modifier(current_delay)
	if(canmove)
		for(var/obj/item/borg/upgrade/u in upgrades)
			if(istype(u, /obj/item/borg/upgrade/vtec/))
				return pull_push_speed_modifier
	return pull_push_speed_modifier * 1.2

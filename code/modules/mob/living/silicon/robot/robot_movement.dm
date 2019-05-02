/mob/living/silicon/robot/Process_Spacemove(var/movement_dir = 0)
	if(ionpulse())
		return 1
	if(..())
		return 1
	return 0

/mob/living/silicon/robot/movement_delay()
	. = ..()

	. += speed

	if(module)
		. += module.movespeed_delay

	if(module_active && istype(module_active, /obj/item/borg/combat/mobility))
		var/obj/item/borg/combat/mobility/C = module_active
		. += C.movement_delay

	. += config.robot_delay

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
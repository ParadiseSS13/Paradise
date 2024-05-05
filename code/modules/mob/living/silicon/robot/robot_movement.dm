/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	if(ionpulse())
		return TRUE
	if(..())
		return TRUE
	return FALSE

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_delay()
	. = ..()
	. += speed
	// Counteract magboot slow in 0G.
	if(!has_gravity(src) && HAS_TRAIT(src, TRAIT_MAGPULSE))
		. -= 2	// The slowdown value on the borg magpulse.
	if(module_active && istype(module_active,/obj/item/borg/destroyer/mobility))
		. -= 3
	. += GLOB.configuration.movement.robot_delay

/mob/living/silicon/robot/mob_negates_gravity()
	return HAS_TRAIT(src, TRAIT_MAGPULSE)

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!HAS_TRAIT(src, TRAIT_MAGPULSE))
		return ..()

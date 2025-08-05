/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(ionpulse())
		return TRUE
	if(..())
		return TRUE
	return FALSE

/mob/living/silicon/robot/movement_delay()
	. = ..()
	. += GLOB.configuration.movement.robot_delay
	. += speed
	. += get_total_component_slowdown()
	. += get_stamina_slowdown()
	// Counteract magboot slow in 0G.
	if(!has_gravity(src) && HAS_TRAIT(src, TRAIT_MAGPULSE))
		. -= 2	// The slowdown value on the borg magpulse.
	if(selected_item && istype(selected_item, /obj/item/borg/destroyer/mobility))
		. -= 3
	. = min(., slowdown_cap)

/mob/living/silicon/robot/mob_negates_gravity()
	return HAS_TRAIT(src, TRAIT_MAGPULSE)

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(flow_x, flow_y)
	if(HAS_TRAIT(src, TRAIT_MAGPULSE))
		return
	..()

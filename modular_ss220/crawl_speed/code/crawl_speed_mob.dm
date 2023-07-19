/mob/living/carbon/set_body_position(new_value)
	. = ..()
	if(!.)
		return
	if(new_value == LYING_DOWN)
		ADD_TRAIT(src, TRAIT_FORCE_WALK_SPEED, CRAWL_SPEED_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_FORCE_WALK_SPEED, CRAWL_SPEED_TRAIT)

/mob/living/carbon/movement_delay(ignorewalk)
	. = ..()
	if(m_intent != MOVE_INTENT_WALK && HAS_TRAIT(src, TRAIT_FORCE_WALK_SPEED))
		. += GLOB.configuration.movement.base_walk_speed - GLOB.configuration.movement.base_run_speed

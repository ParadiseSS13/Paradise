/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/try_possess_pawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/basic_mob = new_pawn

	update_speed(basic_mob)
	RegisterSignal(basic_mob, COMSIG_MOB_ATE, PROC_REF(on_mob_eat))
	return ..()

/datum/ai_controller/basic_controller/proc/update_speed(mob/living/basic_mob)
	movement_delay = basic_mob.movement_delay()

/datum/ai_controller/basic_controller/proc/on_mob_eat()
	SIGNAL_HANDLER
	var/food_cooldown = blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
	set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)

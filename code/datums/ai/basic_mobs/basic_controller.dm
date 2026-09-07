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

/datum/ai_controller/basic_controller/on_stat_changed(mob/living/source, new_stat)
	. = ..()
	update_able_to_run()

/datum/ai_controller/basic_controller/setup_able_to_run()
	. = ..()
	if(ai_traits & AI_FLAG_PAUSE_DURING_DO_AFTER)
		RegisterSignals(pawn, list(COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_able_to_run))

/datum/ai_controller/basic_controller/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))
	return ..()

/datum/ai_controller/basic_controller/get_able_to_run()
	. = ..()
	if(. & AI_UNABLE_TO_RUN)
		return .
	var/mob/living/living_pawn = pawn
	if(ai_traits & AI_FLAG_PAUSE_DURING_DO_AFTER && LAZYLEN(living_pawn.do_afters))
		return AI_UNABLE_TO_RUN | AI_PREVENT_CANCEL_ACTIONS // dont erase targets post a do_after

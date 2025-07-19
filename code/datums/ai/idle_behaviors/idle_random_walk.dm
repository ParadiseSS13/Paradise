/// Randomly choose a direction to walk in.
/datum/idle_behavior/idle_random_walk
	/// Chance that the mob random walks per second
	var/walk_chance = 25

/datum/idle_behavior/idle_random_walk/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/actual_chance = controller.blackboard[BB_BASIC_MOB_IDLE_WALK_CHANCE] || walk_chance
	if(SPT_PROB(actual_chance, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		var/turf/destination_turf = get_step(living_pawn, move_dir)
		if(!destination_turf?.can_cross_safely(living_pawn))
			return FALSE
		living_pawn.Move(destination_turf, move_dir)
	return TRUE

/datum/idle_behavior/idle_random_walk/less_walking
	walk_chance = 10

/// Hunts down a specific atom type.
/datum/ai_behavior/hunt_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	/// How long do we have to wait after a successful hunt?
	var/hunt_cooldown = 5 SECONDS
	/// Do we reset the target after attacking something, so we can check for status changes.
	var/always_reset_target = FALSE

/datum/ai_behavior/hunt_target/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/atom/hunt_target = controller.blackboard[hunting_target_key]
	if(isnull(hunt_target))
		return FALSE
	set_movement_target(controller, hunt_target)

/datum/ai_behavior/hunt_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	var/mob/living/hunter = controller.pawn
	var/atom/hunted = controller.blackboard[hunting_target_key]

	if(QDELETED(hunted))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	target_caught(hunter, hunted)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/hunt_target/proc/target_caught(mob/living/hunter, atom/hunted)
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/living_target = hunted
		hunter.manual_emote("chomps [living_target]!")
		living_target.investigate_log("has been killed by [key_name(hunter)].", INVESTIGATE_DEATHS)
		add_attack_logs(hunter, hunted, "AI controller killed", ATKLOG_ALL)
		living_target.death()

	else if(isfood(hunted))
		hunted.attack_animal(hunter)

	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		hunter.manual_emote("chomps [hunted]!")
		qdel(hunted)

/datum/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	if(succeeded && hunting_cooldown_key)
		controller.set_blackboard_key(hunting_cooldown_key, world.time + hunt_cooldown)
	else if(hunting_target_key)
		controller.clear_blackboard_key(hunting_target_key)
	if(always_reset_target && hunting_target_key)
		controller.clear_blackboard_key(hunting_target_key)

/datum/ai_behavior/hunt_target/interact_with_target
	/// Which intent should we use to interact with
	var/behavior_intent = INTENT_HARM

/datum/ai_behavior/hunt_target/interact_with_target/target_caught(mob/living/hunter, atom/hunted)
	var/datum/ai_controller/controller = hunter.ai_controller
	controller.ai_interact(target = hunted, intent = behavior_intent)

/datum/ai_behavior/hunt_target/interact_with_target/hunt_ores
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/interact_with_target/consume_ores/minebot
	always_reset_target = TRUE
	hunt_cooldown = 2 SECONDS
	behavior_intent = INTENT_HELP

/datum/ai_behavior/hunt_target/interact_with_target/clean
	always_reset_target = TRUE
	hunt_cooldown = 2 SECONDS
	behavior_intent = INTENT_HELP

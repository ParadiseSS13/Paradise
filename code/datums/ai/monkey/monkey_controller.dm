/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
/// OOK OOK OOK

/datum/ai_controller/monkey
	ai_movement = /datum/ai_movement/jps
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/monkey_shenanigans,
	)

	ai_traits = AI_FLAG_PAUSE_DURING_DO_AFTER

	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/monkey,
		BB_MONKEY_AGGRESSIVE = FALSE,
		BB_MONKEY_BEST_FORCE_FOUND = 0,
		BB_MONKEY_ENEMIES = list(),
		BB_MONKEY_BLACKLISTITEMS = list(),
		BB_MONKEY_PICKPOCKETING = FALSE,
		BB_MONKEY_DISPOSING = FALSE,
		BB_MONKEY_GUN_NEURONS_ACTIVATED = FALSE,
		BB_RESISTING = FALSE,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey
	/// Is this mob tripping things?
	var/tripping = FALSE

/datum/targeting_strategy/basic/monkey

/datum/targeting_strategy/basic/monkey/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(controller.blackboard[BB_MONKEY_ENEMIES][the_target])
		return FALSE
	return ..()

/datum/ai_controller/monkey/process(seconds_per_tick)
	var/mob/living/living_pawn = src.pawn
	movement_delay = living_pawn.movement_delay() // Circumstances change. Update speed frequently.

	if(!length(living_pawn.do_afters) && living_pawn.ai_controller.blackboard[BB_RESISTING])
		living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, FALSE)

	if(living_pawn.ai_controller.blackboard[BB_RESISTING])
		return

	if(living_pawn.IsWeakened() || living_pawn.IsStunned()) // We're stunned - what are we gonna do?
		cancel_actions()
		return

	. = ..()

/datum/ai_controller/monkey/pun_pun
	movement_delay = 7 DECISECONDS // pun pun moves slower so the bartender can keep track of them
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/punpun_shenanigans,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey/pun_pun

/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/try_possess_pawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	pawn = new_pawn
	set_blackboard_key(BB_MONKEY_AGGRESSIVE, TRUE) // Angry monke
	set_trip_mode(mode = FALSE)

/datum/ai_controller/monkey/try_possess_pawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	var/mob/living/living_pawn = new_pawn
	if(!HAS_TRAIT(living_pawn, TRAIT_RELAYING_ATTACKER))
		living_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_ATOM_PULLED, PROC_REF(on_startpulling))
	RegisterSignals(new_pawn, list(COMSIG_LIVING_TRY_SYRINGE_INJECT, COMSIG_LIVING_TRY_SYRINGE_WITHDRAW), PROC_REF(on_try_syringe))
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_attempt_cuff))
	RegisterSignal(new_pawn, COMSIG_LIVING_MOB_BUMP, PROC_REF(on_mob_bump))
	return ..() // Run parent at end

/datum/ai_controller/monkey/unpossess_pawn(destroy)
	UnregisterSignal(pawn, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_ATOM_PULLED,
		COMSIG_LIVING_TRY_SYRINGE_INJECT,
		COMSIG_LIVING_TRY_SYRINGE_WITHDRAW,
		COMSIG_CARBON_CUFF_ATTEMPTED,
		COMSIG_LIVING_MOB_BUMP
	))

	return ..() // Run parent at end

/datum/ai_controller/monkey/on_sentience_lost()
	. = ..()
	set_trip_mode(mode = TRUE)

/datum/ai_controller/monkey/get_able_to_run()
	var/mob/living/living_pawn = pawn

	if(living_pawn.stat || living_pawn.incapacitated())
		return AI_UNABLE_TO_RUN

	if(living_pawn.ckey || living_pawn.client)
		return AI_UNABLE_TO_RUN
	return ..()

/datum/ai_controller/monkey/proc/set_trip_mode(mode = TRUE)
	if(!ismonkeybasic(pawn)) // In case the monkey was humanized.
		tripping = FALSE
		return
	tripping = mode

/// re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()
	var/mob/living/living_pawn = pawn

	if(!living_pawn.held_items())
		set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, 0)

	if(blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && is_type_in_list(/obj/item/gun, living_pawn.held_items()))
		// We have a gun, what could we possibly want?
		return FALSE

	var/obj/item/weapon
	var/list/nearby_items = list()
	for(var/obj/item/item in oview(2, living_pawn))
		if(item.force < 2)
			continue
		nearby_items += item

	for(var/obj/item/item in living_pawn.held_items()) // If we've got some garbage in our hands that's going to stop us from effectively attacking, we should get rid of it.
		if(item.force < 2)
			living_pawn.drop_item_to_ground(item)

	weapon = GetBestWeapon(src, nearby_items, living_pawn.held_items())

	var/pickpocket = FALSE
	for(var/mob/living/carbon/human/human in oview(5, living_pawn))
		var/obj/item/held_weapon = GetBestWeapon(src, human.held_items() + weapon, living_pawn.held_items())
		if(held_weapon == weapon) // It's just the same one, not a held one
			continue
		pickpocket = TRUE
		weapon = held_weapon

	if(!weapon || (weapon in living_pawn.held_items()))
		return FALSE

	if(weapon.force < 2) // our bite does 2 damage on average, no point in settling for anything less
		return FALSE

	set_blackboard_key(BB_MONKEY_PICKUPTARGET, weapon)
	if(pickpocket)
		queue_behavior(/datum/ai_behavior/monkey_equip/pickpocket, BB_MONKEY_PICKUPTARGET)
	else
		queue_behavior(/datum/ai_behavior/monkey_equip/ground, BB_MONKEY_PICKUPTARGET)
	return TRUE

/// Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/living_mob)
	// just to be safe
	if(QDELETED(living_mob))
		return

	add_blackboard_key_assoc(BB_MONKEY_ENEMIES, living_mob, MONKEY_HATRED_AMOUNT)

/datum/ai_controller/monkey/proc/on_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if(prob(MONKEY_RETALIATE_PROB))
		retaliate(attacker)

/datum/ai_controller/monkey/proc/on_startpulling(datum/source, atom/movable/puller, state, force)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(living_pawn.stat && prob(MONKEY_PULL_AGGRO_PROB)) // nuh uh you don't pull me!
		retaliate(living_pawn.pulledby)
		return TRUE

/datum/ai_controller/monkey/proc/on_try_syringe(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_SYRINGE_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_CUFF_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/on_mob_bump(mob/source, mob/living/crossing_mob)
	SIGNAL_HANDLER
	if(!tripping)
		return
	crossing_mob.KnockDown(4 SECONDS)

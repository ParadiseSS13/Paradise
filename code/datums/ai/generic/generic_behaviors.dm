/datum/ai_behavior/perform_emote

/datum/ai_behavior/perform_emote/perform(seconds_per_tick, datum/ai_controller/controller, emote, speech_sound)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return AI_BEHAVIOR_INSTANT
	if(emote in GLOB.emote_list)
		living_pawn.emote(emote)
	else
		living_pawn.custom_emote(EMOTE_VISIBLE, emote)
	if(speech_sound) // Only audible emotes will pass in a sound
		playsound(living_pawn, speech_sound, 80, vary = TRUE, pressure_affected =TRUE, ignore_walls = FALSE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/perform_speech

/datum/ai_behavior/perform_speech/perform(seconds_per_tick, datum/ai_controller/controller, speech, speech_sound, speech_verb)
	. = ..()

	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return AI_BEHAVIOR_INSTANT
	living_pawn.say(speech, speech_verb)
	if(speech_sound)
		playsound(living_pawn, speech_sound, 80, vary = TRUE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/resist

/datum/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, TRUE)
	living_pawn.run_resist()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/battle_screech
	/// List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	controller.set_blackboard_key(BB_BATTLE_CRY_COOLDOWN, world.time + MONKEY_BATTLE_CRY_COOLDOWN)
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(screeches))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Use in hand the currently held item
/datum/ai_behavior/use_in_hand
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/use_in_hand/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held = pawn.get_active_hand()
	if(!held)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pawn.activate_hand()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Use the currently held item, or unarmed, on a weakref to an object in the world
/datum/ai_behavior/use_on_object
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/use_on_object/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/use_on_object/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_item_by_slot(pawn.get_active_hand())
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(held_item)
		held_item.melee_attack_chain(pawn, target)
	else
		controller.ai_interact(target, INTENT_HELP)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/**
 * Drops items in hands, very important for future behaviors that require the pawn to grab stuff
 */
/datum/ai_behavior/drop_item

/datum/ai_behavior/drop_item/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/list/my_held_items = living_pawn.held_items() - GetBestWeapon(controller, null, living_pawn.held_items())
	if(!length(my_held_items))
		return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY
	living_pawn.drop_item_to_ground(pick(my_held_items))
	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY

/datum/ai_behavior/consume
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 2 SECONDS

/datum/ai_behavior/consume/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/consume/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hunger_timer_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!(target in living_pawn.held_items()))
		if(!living_pawn.get_empty_held_indexes() || !living_pawn.put_in_hands(target))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	target.melee_attack_chain(living_pawn, living_pawn)

	if(QDELETED(target) || prob(10)) // Even if we don't finish it all we can randomly decide to be done
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/find_nearby

/datum/ai_behavior/find_nearby/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/list/possible_targets = list()
	for(var/atom/thing in view(2, controller.pawn))
		if(!thing.mouse_opacity)
			continue
		if(thing.IsObscured())
			continue
		if(isitem(thing))
			var/obj/item/item = thing
			if(item.flags & ABSTRACT)
				continue
		possible_targets += thing
	if(!length(possible_targets))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, pick(possible_targets))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/give
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/give/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/give/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_active_hand()
	var/atom/target = controller.blackboard[target_key]

	if(!held_item) // if held_item is null, we pretend that action was successful
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!target || !isliving(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_target = target
	var/perform_flags = try_to_give_item(controller, living_target, held_item)
	if(perform_flags & AI_BEHAVIOR_FAILED)
		return perform_flags
	controller.pause_ai(1.5 SECONDS)
	living_target.visible_message(
		"<span class='notice'>[pawn] starts trying to give [held_item] to [living_target]!</span>",
		"<span class='warning'>[pawn] tries to give you [held_item]!</span>"
	)
	if(!do_after(pawn, 1 SECONDS, living_target))
		return AI_BEHAVIOR_DELAY | perform_flags

	perform_flags |= try_to_give_item(controller, living_target, held_item, actually_give = TRUE)
	return AI_BEHAVIOR_DELAY | perform_flags

/datum/ai_behavior/give/proc/try_to_give_item(datum/ai_controller/controller, mob/living/carbon/target, obj/item/held_item, actually_give)
	if(QDELETED(held_item) || QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!iscarbon(controller.pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!iscarbon(target))
		controller.clear_blackboard_key(BB_MONKEY_CURRENT_GIVE_TARGET)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) || target.r_hand && target.l_hand)
		controller.clear_blackboard_key(BB_MONKEY_CURRENT_GIVE_TARGET)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/carbon/C = controller.pawn
	C.drop_item_to_ground(held_item)
	target.put_in_hands(held_item)
	held_item.add_fingerprint(target)
	held_item.on_give(C, target)
	held_item.pickup(target)
	controller.clear_blackboard_key(BB_MONKEY_CURRENT_GIVE_TARGET)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

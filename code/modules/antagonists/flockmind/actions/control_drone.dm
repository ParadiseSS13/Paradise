/datum/action/cooldown/flock/control_drone
	name = "Control Drone"
	desc = "Direct a drone to perform an action."
	button_icon_state = "ping"
	click_to_activate = TRUE
	unset_after_click = FALSE
	click_cd_override = 0

	var/mob/living/basic/flock/drone/selected_bird

/datum/action/cooldown/flock/control_drone/Remove(mob/removed_from)
	. = ..()
	free_drone()

/datum/action/cooldown/flock/control_drone/is_valid_target(atom/cast_on)
	. = ..()
	if(selected_bird)
		return get_turf(cast_on)

	if(!isflockdrone(cast_on))
		return FALSE

	var/mob/living/basic/flock/drone/bird = cast_on
	if(HAS_TRAIT_FROM(bird, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE))
		return FALSE

	if(bird.controlled_by)
		return FALSE
	return TRUE

/datum/action/cooldown/flock/control_drone/Activate(atom/target)
	. = ..()
	if(isnull(selected_bird))
		bind_drone(target)
		return TRUE

	selected_bird.ai_controller.cancel_actions()

	// Move to turf/structure, or convert turf.
	if(isturf(target) || istype(target, /obj/structure/flock))
		if(istype(target, /obj/structure/flock/tealprint))
			if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_deposit_target, target))
				return FALSE

			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE

		var/turf/T = get_turf(target)
		if(isflockturf(T))
			if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/rally, target))
				return FALSE

			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE

		if(T.can_flock_convert())
			if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_conversion_target, target))
				return FALSE

			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE


	// Harvest items
	else if(isitem(target))
		if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_harvest_target, target))
			return FALSE

		pointer_helper(selected_bird, target, 2 SECONDS)
		unset_click_ability(owner, performing_task = TRUE)
		return TRUE

	// Attack or convert enemies.
	else if(ismob(target) && selected_bird.flock.is_mob_enemy(target))
		var/mob/living/L = target
		if(L.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE) || L.IsKnockedDown())
			if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_capture_target, target))
				return FALSE

			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE

		else if(selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/attack_target, target))
			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE

		return FALSE

	else if(isflockmob(target))
		if(istype(target, /mob/living/basic/flock/bit))
			to_chat(owner, SPAN_WARNING("Flockbits are too simple to be remotely controlled."))
			return FALSE

		var/mob/living/basic/flock/other_bird = target
		if(other_bird.flock == selected_bird.flock)
			if(!selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_heal_target, target))
				return FALSE

			pointer_helper(selected_bird, target, 2 SECONDS)
			unset_click_ability(owner, performing_task = TRUE)
			return TRUE


/datum/action/cooldown/flock/control_drone/unset_click_ability(mob/on_who, refund_cooldown, performing_task = TRUE)
	. = ..()
	free_drone(performing_task)

/datum/action/cooldown/flock/control_drone/proc/pointer_helper(atom/from, atom/towards, duration)
	var/mob/camera/flock/overmind/ghost_bird = owner
	var/image/pointer = pointer_image_to(from, towards)

	animate(pointer, time = 2 SECONDS, alpha = 0)
	ghost_bird.flock.add_ping_image(ghost_bird.client, pointer, 2 SECONDS)

/datum/action/cooldown/flock/control_drone/proc/bind_drone(mob/living/basic/flock/drone/bird)
	selected_bird = bird
	RegisterSignal(bird, COMSIG_PARENT_QDELETING, PROC_REF(drone_gone))
	ADD_TRAIT(bird, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE)
	bird.ai_controller.cancel_actions()
	bird.say("suspending automated subroutines pending sentient-level instruction", forced = TRUE)
	bird.AddComponent(/datum/component/flock_ping/selected)

/datum/action/cooldown/flock/control_drone/proc/free_drone(performing_task = TRUE)
	if(!selected_bird)
		return

	if(!QDELETED(selected_bird) && !performing_task)
		spawn(-1)
			selected_bird.say("Sentient-level instruction suspended, resuming automated subroutines.", forced = TRUE)

	UnregisterSignal(selected_bird, COMSIG_PARENT_QDELETING)
	REMOVE_TRAIT(selected_bird, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE)

	qdel(selected_bird.GetComponent(/datum/component/flock_ping/selected))
	selected_bird = null
	unset_click_ability(owner)

/datum/action/cooldown/flock/control_drone/proc/drone_gone(datum/source)
	SIGNAL_HANDLER

	free_drone()



/datum/action/cooldown/flock/control_drone
	name = "Control Drone"
	button_icon_state = "ping"
	cooldown_time = 0
	click_to_activate = TRUE
	unset_after_click = FALSE
	click_cd_override = 0

	var/mob/living/basic/flock/drone/selected_bird

/datum/action/cooldown/flock/control_drone/Remove(mob/removed_from)
	. = ..()
	free_drone()

/datum/action/cooldown/flock/control_drone/is_valid_target(atom/cast_on)
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
	var/mob/camera/flock/overmind/ghost_bird = owner

	if(isturf(target))
		selected_bird.ai_controller.queue_behavior(/datum/ai_behavior/flock/find_conversion_target, target)
		var/image/pointer = flock_pointer(selected_bird, target)

		animate(pointer, time = 2 SECONDS, alpha = 0)
		ghost_bird.flock.add_ping_image(ghost_bird.client, pointer, 2 SECONDS)

/datum/action/cooldown/flock/control_drone/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	free_drone()

/datum/action/cooldown/flock/control_drone/proc/bind_drone(mob/living/basic/flock/drone/bird)
	selected_bird = bird
	RegisterSignal(bird, COMSIG_PARENT_QDELETING, PROC_REF(drone_gone))
	ADD_TRAIT(bird, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE)
	bird.ai_controller.cancel_actions()
	bird.say("Suspending automated subroutines pending sentient level instruction.", forced = TRUE)

/datum/action/cooldown/flock/control_drone/proc/free_drone()
	if(!selected_bird)
		return

	if(!QDELETED(selected_bird))
		spawn(-1)
			selected_bird.say("Sentient level instruction suspended, resuming automated subroutines.", forced = TRUE)
	UnregisterSignal(selected_bird, COMSIG_PARENT_QDELETING)
	REMOVE_TRAIT(selected_bird, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE)
	selected_bird = null
	unset_click_ability(owner)

/datum/action/cooldown/flock/control_drone/proc/drone_gone(datum/source)
	SIGNAL_HANDLER

	free_drone()

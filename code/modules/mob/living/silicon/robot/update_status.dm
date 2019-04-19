// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_lying = FALSE)
	if(stat || lockcharge || weakened || stunned || paralysis || !is_component_functioning("actuator"))
		return TRUE

/mob/living/silicon/robot/has_vision(information_only = FALSE)
	return ..(information_only) && ((stat == DEAD && information_only) || is_component_functioning("camera"))

/mob/living/silicon/robot/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
			return
		if(!is_component_functioning("actuator") || !is_component_functioning("power cell") || paralysis || sleeping || resting || stunned || weakened || getOxyLoss() > maxHealth * 0.5)
			if(stat == CONSCIOUS)
				KnockOut()
				create_debug_log("fell unconscious, trigger reason: [reason]")
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")
	else
		if(health > 0)
			update_revive()
			var/mob/dead/observer/ghost = get_ghost()
			if(ghost)
				to_chat(ghost, "<span class='ghostalert'>Your cyborg shell has been repaired, re-enter if you want to continue!</span> (Verbs -> Ghost -> Re-enter corpse)")
				ghost << sound('sound/effects/genetics.ogg')
			create_attack_log("revived, trigger reason: [reason]")
	// diag_hud_set_status()
	// diag_hud_set_health()
	// update_health_hud()

/mob/living/silicon/robot/SetStunned(amount, updating = 1, force = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	. = STATUS_UPDATE_CANMOVE
	if((!!amount) == (!!stunned)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE

	if(status_flags & CANSTUN || force)
		stunned = max(amount, 0)
		if(updating)
			update_stat()
	else
		return STATUS_UPDATE_NONE

/mob/living/silicon/robot/SetWeakened(amount, updating = 1, force = 0)
	. = STATUS_UPDATE_CANMOVE
	if((!!amount) == (!!weakened)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	if(status_flags & CANWEAKEN || force)
		weakened = max(amount, 0)
		if(updating)
			update_stat()
	else
		return STATUS_UPDATE_NONE

/mob/living/silicon/robot/update_revive(updating = TRUE)
	. = ..(updating)
	if(.)
		update_icons()

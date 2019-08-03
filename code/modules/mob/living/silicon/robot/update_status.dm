// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	if(stat || lockcharge || IsKnockdown() || IsParalyzed() || IsStun() || IsUnconscious() || !is_component_functioning("actuator"))
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
		if(!is_component_functioning("actuator") || !is_component_functioning("power cell") || IsUnconscious() || IsSleeping() || resting || IsStun() || IsKnockdown() || getOxyLoss() > maxHealth * 0.5)
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

/mob/living/silicon/robot/update_revive(updating = TRUE)
	. = ..(updating)
	if(.)
		update_icons()

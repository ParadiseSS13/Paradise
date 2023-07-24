// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_lying = FALSE)
	if(stat || lockcharge || IsWeakened() || IsStunned() || IsParalyzed() || !is_component_functioning("actuator"))
		return TRUE

/mob/living/silicon/robot/has_vision(information_only = FALSE)
	return ..(information_only) && ((stat == DEAD && information_only) || is_component_functioning("camera"))

/mob/living/silicon/robot/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		..()
		update_headlamp()
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			return
		if(!is_component_functioning("actuator") || !is_component_functioning("power cell") || IsParalyzed() || IsSleeping() || IsStunned() || IsWeakened() || getOxyLoss() > maxHealth * 0.5)
			if(stat == CONSCIOUS)
				KnockOut()
				update_headlamp()
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
				update_headlamp()
	else
		if(health > 0)
			update_revive()
			var/mob/dead/observer/ghost = get_ghost()
			if(ghost)
				to_chat(ghost, "<span class='ghostalert'>Your cyborg shell has been repaired, re-enter if you want to continue!</span> (Verbs -> Ghost -> Re-enter corpse)")
				ghost << sound('sound/effects/genetics.ogg')
			add_misc_logs(src, "revived, trigger reason: [reason]")
	..()

/mob/living/silicon/robot/update_revive(updating = TRUE, defib_revive = FALSE)
	. = ..(updating)
	if(.)
		update_icons()

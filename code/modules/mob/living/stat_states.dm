// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = TRUE, anesthetized = FALSE)
	if(stat == DEAD)
		log_runtime(EXCEPTION("KnockOut called on a dead mob."), src)
		return FALSE
	else if(stat == (UNCONSCIOUS | ANESTHETIZED))
		return FALSE

	if(anesthetized)
		stat = ANESTHETIZED
		create_attack_log("<font color='red'>Anesthetized at [atom_loc_line(get_turf(src))]</font>")
		add_attack_logs(src, null, "Anesthetized", ATKLOG_ALL)
		log_game("[key_name(src)] was anesthetized at [atom_loc_line(get_turf(src))]")
	else
		stat = UNCONSCIOUS
		create_attack_log("<font color='red'>Fallen unconscious at [atom_loc_line(get_turf(src))]</font>")
		add_attack_logs(src, null, "Fallen unconscious", ATKLOG_ALL)
		log_game("[key_name(src)] fell unconscious at [atom_loc_line(get_turf(src))]")

	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
		set_typing_indicator(FALSE)

	return TRUE

/mob/living/proc/WakeUp(updating = TRUE)
	if(stat == DEAD)
		log_runtime(EXCEPTION("WakeUp called on a dead mob."), src)
		return FALSE
	else if(stat == CONSCIOUS || isLivingSSD(src))
		return FALSE
	stat = CONSCIOUS
		create_attack_log("<font color='red'>Woken up at [atom_loc_line(get_turf(src))]</font>")
		add_attack_logs(src, null, "Woken up", ATKLOG_ALL)
		log_game("[key_name(src)] woke up at [atom_loc_line(get_turf(src))]")
	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
	return TRUE

/mob/living/proc/can_be_revived()
	. = TRUE
	// if(health <= min_health)
	if(health <= HEALTH_THRESHOLD_DEAD)
		return FALSE

// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE)
	if(stat != DEAD)
		return 0
	if(!can_be_revived())
		return 0
	create_attack_log("<font color='red'>Came back to life at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Came back to life", ATKLOG_ALL)
	log_game("[key_name(src)] came back to life at [atom_loc_line(get_turf(src))]")
	stat = CONSCIOUS
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list += src
	if(mind)
		GLOB.respawnable_list -= src
	timeofdeath = null
	if(updating)
		update_canmove()
		update_blind_effects()
		update_sight()
		updatehealth("update revive")
		hud_used?.reload_fullscreen()

	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, updating)

	if(mind)
		for(var/S in mind.spell_list)
			var/obj/effect/proc_holder/spell/spell = S
			spell.updateButtonIcon()

	return 1

/mob/living/proc/check_death_method()
	return TRUE

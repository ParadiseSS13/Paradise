// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = TRUE)
	if(stat == DEAD)
		stack_trace("KnockOut called on a dead mob.")
		return FALSE

	else if(stat == UNCONSCIOUS)
		return FALSE

	create_attack_log("<font color='red'>Fallen unconscious at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Fallen unconscious", ATKLOG_ALL)
	log_game("[key_name(src)] fell unconscious at [atom_loc_line(get_turf(src))]")
	set_stat(UNCONSCIOUS)
	ADD_TRAIT(src, TRAIT_DEAF, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT)

	if(updating)
		update_sight()
		update_blind_effects(TRUE)
		set_typing_indicator(FALSE)
		if(hud_used && client)
			hud_used.show_hud(HUD_STYLE_ACTIONHUD)

	return TRUE

/mob/living/proc/WakeUp(updating = TRUE)
	if(stat == DEAD)
		stack_trace("WakeUp called on a dead mob.")
		return FALSE

	else if(stat == CONSCIOUS)
		return FALSE

	create_attack_log("<font color='red'>Woken up at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Woken up", ATKLOG_ALL)
	log_game("[key_name(src)] woke up at [atom_loc_line(get_turf(src))]")
	set_stat(CONSCIOUS)
	REMOVE_TRAITS_IN(src, STAT_TRAIT)

	if(updating)
		update_sight()
		update_blind_effects(force_clear_sleeping = TRUE)
		if(hud_used && client)
			hud_used.show_hud(HUD_STYLE_STANDARD)

	return TRUE

// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE)
	if(stat != DEAD)
		return FALSE

	create_attack_log("<font color='red'>Came back to life at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Came back to life", ATKLOG_ALL)
	log_game("[key_name(src)] came back to life at [atom_loc_line(get_turf(src))]")
	set_stat(UNCONSCIOUS) // this is done as `WakeUp` early returns if they are `stat = DEAD`
	WakeUp()

	if(suiciding)
		message_admins("[key_name(src)] was revived after having committed suicide. This is likely a bug.")

	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list |= src
	REMOVE_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)

	last_words = null
	timeofdeath = null

	if(updating)
		update_blind_effects()
		update_sight()
		updatehealth("update revive")
		reload_fullscreen()

	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, updating)

	if(mind)
		for(var/S in mind.spell_list)
			var/datum/spell/spell = S
			spell.build_all_button_icons()

	return TRUE

/mob/living/proc/check_death_method()
	return TRUE

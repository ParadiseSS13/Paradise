// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("KnockOut called on a dead mob."), src)
		return 0
	else if(stat == UNCONSCIOUS)
		return 0
	create_attack_log("<font color='red'>Fallen unconscious at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Fallen unconscious")
	log_game("[key_name(src)] fell unconscious at [atom_loc_line(get_turf(src))]")
	stat = UNCONSCIOUS
	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
	return 1

/mob/living/proc/WakeUp(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("WakeUp called on a dead mob."), src)
		return 0
	else if(stat == CONSCIOUS)
		return 0
	create_attack_log("<font color='red'>Woken up at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Woken up")
	log_game("[key_name(src)] woke up at [atom_loc_line(get_turf(src))]")
	stat = CONSCIOUS
	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
	return 1

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
	add_attack_logs(src, null, "Came back to life")
	log_game("[key_name(src)] came back to life at [atom_loc_line(get_turf(src))]")
	stat = CONSCIOUS
	GLOB.dead_mob_list -= src
	GLOB.living_mob_list += src
	if(mind)
		GLOB.respawnable_list -= src
	timeofdeath = null
	if(updating)
		update_canmove()
		update_blind_effects()
		update_sight()
		updatehealth("update revive")

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerRevives(src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerRevives(src)

	if(mind)
		for(var/S in mind.spell_list)
			var/obj/effect/proc_holder/spell/spell = S
			spell.updateButtonIcon()

	return 1

/mob/living/proc/check_death_method()
	return TRUE
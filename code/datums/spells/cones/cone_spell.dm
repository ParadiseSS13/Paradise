/datum/spell/cone
	create_attack_logs = FALSE
	create_custom_logs = TRUE
	var/cone_levels = 3
	var/respect_density = TRUE

/datum/spell/cone/create_new_targeting()
	var/datum/spell_targeting/cone/C = new()
	C.cone_levels = cone_levels
	C.respect_density = respect_density
	return C

// Normally, cone spells will generate an attack log for every turf they loop over, while searching for targets.
// With this override, all /aoe type spells will only generate 1 log, saying that the user has cast the spell.
/datum/spell/cone/write_custom_logs(list/targets, mob/user)
	add_attack_logs(user, null, "Cast the cone spell [name]", ATKLOG_ALL)

/datum/spell/cone/cast(list/targets, mob/user)
	var/level_counter = 1
	for(var/list/turf_list in targets)
		do_cone_effects(turf_list, user, level_counter)
		level_counter++

/datum/spell/cone/proc/do_cone_effects(list/targets, mob/user, level)
	for(var/turf/target_turf as anything in targets)
		if(QDELETED(target_turf)) //if turf is no longer there
			continue

		do_turf_cone_effect(target_turf, user, level)
		if(iswallturf(target_turf))
			continue

		for(var/atom/movable/movable_content as anything in target_turf)
			if(isobj(movable_content))
				do_obj_cone_effect(movable_content, user, level)
			else if(isliving(movable_content))
				do_mob_cone_effect(movable_content, user, level)

/datum/spell/cone/proc/do_turf_cone_effect(turf/target_turf, mob/caster, level)
	return

/datum/spell/cone/proc/do_obj_cone_effect(obj/target_obj, mob/caster, level)
	return

/datum/spell/cone/proc/do_mob_cone_effect(mob/target_mob, mob/caster, level)
	return

/datum/spell/cone/staggered
	/// The delay between each cone level triggering.
	var/delay_between_level = 0.2 SECONDS

/datum/spell/cone/staggered/cast(list/targets, mob/user)
	var/level_counter = 0
	for(var/list/turf_list in targets)
		level_counter++
		addtimer(CALLBACK(src, PROC_REF(do_cone_effects), turf_list, user, level_counter), delay_between_level * level_counter)

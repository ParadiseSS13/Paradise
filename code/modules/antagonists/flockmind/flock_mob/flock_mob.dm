/mob/living/basic/flock
	name = "flockdrone"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "drone"
	icon_living = "drone"
	icon_dead = "drone-dead"

	pass_flags_self = parent_type::pass_flags_self | PASSFLOCK

	light_color = "#26ffe6"
	light_power = 0.2
	light_range = 2

	faction = list(FACTION_FLOCK)
	ai_controller = /datum/ai_controller/flock

	initial_language_holder = /datum/language_holder/flock

	minbodytemp = 0
	maxbodytemp = 1000
	atmos_requirements = list(
		"min_oxy" = 0,
		"max_oxy" = 0,
		"min_plas" = 0,
		"max_plas" = 0,
		"min_co2" = 0,
		"max_co2" = 0,
		"min_n2" = 0,
		"max_n2" = 0
	)


	stop_automated_movement = TRUE
	movement_type = FLOATING

	var/list/actions_to_grant = list(
		/datum/action/cooldown/flock/convert,
	)

	var/icon_dormant = "drone-dormant"

	/// Flock datum. Can be null.
	var/tmp/datum/flock/flock

	/// Physical resources for constructing structures or flockrunning.
	var/tmp/datum/point_holder/substrate
	/// Type of point holder to use
	var/point_holder_type = /datum/point_holder

	/// Flock ID nametag
	var/tmp/obj/effect/abstract/info_tag/flock/name_tag
	/// Tag for the mob's current AI task.
	var/tmp/obj/effect/abstract/info_tag/flock/info/task_tag

	var/bandwidth_provided = 0

	/// If, while part of an active flock, a flockmob leaves the station, they become dormant.
	var/tmp/dormant = FALSE

/mob/living/basic/flock/Initialize(mapload, join_flock)
	. = ..()
	RegisterSignal(ai_controller, COMSIG_AI_STATUS_CHANGE, PROC_REF(on_ai_status_change))

	for(var/action_path in actions_to_grant)
		var/datum/action/action = new action_path
		action.Grant(src)

	set_combat_mode(TRUE)

	ADD_TRAIT(src, TRAIT_FREE_FLOAT_MOVEMENT, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

	flock = join_flock || get_default_flock()
	flock?.add_unit(src)

	substrate = new point_holder_type

	name_tag = new()
	name_tag.set_parent(src)

	task_tag = new()
	task_tag.set_parent(src)

	update_health_notice()
	update_light_state()

/mob/living/basic/flock/Destroy()
	flock?.free_unit(src)
	flock = null
	QDEL_NULL(name_tag)
	QDEL_NULL(task_tag)
	return ..()

/mob/living/basic/flock/create_mood()
	return // THEY DO NOT FEEEEEEEEEEEEEEEL

/mob/living/basic/flock/set_stat(new_stat)
	. = ..()
	switch(stat)
		if(CONSCIOUS)
			ADD_TRAIT(src, TRAIT_MOVE_FLOATING, STAT_TRAIT)
			REMOVE_TRAIT(src, TRAIT_NO_FLOATING_ANIM, STAT_TRAIT)
		else
			REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, STAT_TRAIT)
			ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, STAT_TRAIT)

/mob/living/basic/flock/update_name(updates)
	. = ..()
	name_tag?.set_text(real_name)

/mob/living/basic/flock/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, range)
	. = ..()
	if(!.)
		return

	language = GET_LANGUAGE_DATUM(language) || get_selected_language()
	if(flock && istype(language, /datum/language/flock))
		flock_talk(src, message, flock, forced)

// changing the default arg value here
/mob/living/basic/flock/treat_message(message, correct_grammar = FALSE)
	. = ..()

/mob/living/basic/flock/update_icon_state()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		if(dormant)
			icon_state = icon_dormant
		else
			icon_state = icon_living
	return ..()

/mob/living/basic/flock/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(flock && new_turf && !flock.is_on_safe_z(new_turf))
		dormantize()

/mob/living/basic/flock/updatehealth(cause_of_death)
	. = ..()
	update_health_notice()

/mob/living/basic/flock/death(gibbed, cause_of_death)
	flock?.remove_notice(src, FLOCK_NOTICE_HEALTH)
	flock?.free_unit(src)
	flock?.stat_deaths++
	return ..()

/mob/living/basic/flock/get_flock_id()
	return real_name

/mob/living/basic/flock/proc/update_health_notice()
	if(!flock)
		return

	var/datum/atom_hud/alternate_appearance/basic/flock/notice = get_alt_appearance(FLOCK_NOTICE_HEALTH)
	if(!notice)
		notice = flock.add_notice(src, FLOCK_NOTICE_HEALTH)

	var/image/I = notice.image
	I.icon_state = "hp-[round(getHealthPercent(), 10)]"

/mob/living/basic/flock/proc/get_flock_data()
	var/list/data = list()
	data["name"] = real_name
	data["health"] = getHealthPercent()
	data["resources"] = substrate.has_points()
	data["area"] = get_area_name(src, TRUE) || "???"
	data["ref"] = REF(src)
	return data

/// Become dormant. A husk. A shell.
/mob/living/basic/flock/proc/dormantize()
	if(dormant)
		return

	dormant = TRUE

	cancel_do_afters()
	ai_controller.set_ai_status(AI_STATUS_OFF)
	flock?.free_unit(src)
	update_light_state()

	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/flock/proc/rally(turf/location)
	if(!isturf(location))
		return

	if(ai_controller.ai_status == AI_STATUS_OFF || ckey)
		return

	ai_controller.CancelActions()
	ai_controller.queue_behavior(/datum/ai_behavior/flock/rally, location)

/// Helper for keeping consistency across tesk name sets.
/mob/living/basic/flock/proc/set_task_desc(text)
	task_tag?.set_text("Task: [text || "idling"]")

/// Turn the light on or off, based on if the mob is doing shit or not.
/mob/living/basic/flock/proc/update_light_state()
	if(stat == DEAD || dormant)
		set_light_on(FALSE)
		return

	if(ai_controller.ai_status == AI_ON || ckey)
		set_light_on(TRUE)
		return

	set_light_on(FALSE)

/mob/living/basic/flock/proc/on_ai_status_change(datum/ai_controller/source, ai_status)
	SIGNAL_HANDLER
	update_light_state()

/mob/living/basic/flock/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, bandwidth_provided))
			flock?.bandwidth.adjust_points(-bandwidth_provided)
			..()
			flock?.bandwidth.adjust_points(bandwidth_provided)
			return TRUE

	return ..()

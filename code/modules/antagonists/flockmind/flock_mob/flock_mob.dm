/mob/living/basic/flock
	name = "flockdrone"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "drone"
	icon_living = "drone"
	icon_dead = "drone-dead"

	pass_flags_self = PASSTABLE | PASSFLOCK

	light_color = "#26ffe6"
	light_power = 0.2
	light_range = 2

	faction = list("flockmind")
	ai_controller = /datum/ai_controller/flock

	sentience_type = SENTIENCE_OTHER

	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1.5, BURN = 0.2, TOX = 0.2, CLONE = 0, STAMINA = 0, OXY = 0)

	initial_traits = list(TRAIT_FLYING, TRAIT_FLOCK_THING)

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

	flock = join_flock || get_default_flock()
	flock?.add_unit(src)
	flock.add_notice(src, FLOCK_NOTICE_HEALTH)

	substrate = new point_holder_type

	name_tag = new()
	name_tag.set_parent(src)

	task_tag = new()
	task_tag.set_parent(src)

	add_language("Symphonic")
	set_default_language(GLOB.all_languages["Symphonic"])

/mob/living/basic/flock/Destroy()
	flock?.free_unit(src)
	flock = null
	QDEL_NULL(name_tag)
	QDEL_NULL(task_tag)
	return ..()

/mob/living/basic/flock/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/flock/set_stat(new_stat)
	. = ..()
	if(stat != DEAD)
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)

/mob/living/basic/flock/update_name(updates)
	. = ..()
	name_tag?.set_text(real_name)

/mob/living/basic/flock/update_icon_state()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		if(dormant)
			icon_state = icon_dormant
		else
			icon_state = icon_living
	return ..()

/mob/living/basic/flock/updatehealth(cause_of_death)
	. = ..()
	update_health_notice()

/mob/living/basic/flock/proc/update_health_notice()
	if(!flock)
		return

	var/datum/alternate_appearance/notice = get_alt_appearance(FLOCK_NOTICE_HEALTH)
	if(!notice)
		notice = flock.add_notice(src, FLOCK_NOTICE_HEALTH)

	var/image/I = notice.img
	I.icon_state = "hp-[round(get_damage_percent(), 10)]"

/mob/living/basic/flock/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(flock && new_turf && !flock.is_on_safe_z(new_turf))
		dormantize()

/mob/living/basic/flock/death(gibbed, cause_of_death)
	flock?.remove_notice(src, FLOCK_NOTICE_HEALTH)
	flock?.free_unit(src)
	flock?.stat_deaths++
	return ..()

/mob/living/basic/flock/get_flock_id()
	return real_name

/mob/living/basic/flock/proc/get_flock_data()
	var/list/data = list()
	data["name"] = real_name
	data["health"] = get_damage_percent()
	data["resources"] = substrate.has_points()
	data["area"] = get_area_name(src, TRUE) || "???"
	data["ref"] = ref(src)
	return data

/// Become dormant. A husk. A shell.
/mob/living/basic/flock/proc/dormantize()
	if(dormant)
		return

	dormant = TRUE

	ai_controller.set_ai_status(AI_STATUS_OFF)
	flock?.free_unit(src)
	update_light_state()

	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/flock/proc/rally(turf/location)
	if(!isturf(location))
		return

	if(ai_controller.ai_status == AI_STATUS_OFF || ckey)
		return

	ai_controller.cancel_actions()
	ai_controller.queue_behavior(/datum/ai_behavior/flock/rally, location)

/// Helper for keeping consistency across tesk name sets.
/mob/living/basic/flock/proc/set_task_desc(text)
	task_tag?.set_text("Task: [text || "idling"]")

/// Turn the light on or off, based on if the mob is doing shit or not.
/mob/living/basic/flock/proc/update_light_state()
	if(stat == DEAD || dormant)
		set_light(0, 0, light_color)
		return

	if(ai_controller.ai_status == AI_ON || ckey)
		set_light(2, 0.2, light_color)
		return

	set_light(0, 0, light_color)

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

/mob/living/basic/flock/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/projectile/energy/flock_bolt))
		return TRUE

	return ..()

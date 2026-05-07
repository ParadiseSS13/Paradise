/mob/living/basic/flock/drone
	name = "flockdrone"
	desc = "The physical partitions of the flockmind, forever enacting its will until its job is complete."
	hud_type = /datum/hud/flockdrone
	ai_controller = /datum/ai_controller/flock/drone

	move_force = MOVE_FORCE_WEAK

	actions_to_grant = list(
		/datum/action/cooldown/flock/release_control,
		/datum/action/cooldown/flock/convert,
		/datum/action/cooldown/flock/deconstruct,
		/datum/action/cooldown/flock/flock_heal,
		/datum/action/cooldown/flock/cage_mob,
		/datum/action/cooldown/flock/nest,
		/datum/action/cooldown/flock/deposit,
	)

	bandwidth_provided = FLOCK_COMPUTE_COST_DRONE

	initial_traits = list(TRAIT_FLYING, TRAIT_FLOCK_THING, TRAIT_IMPORTANT_SPEAKER)

	/// A mob possessing this mob.
	var/tmp/mob/camera/flock/controlled_by

	var/list/datum/flockdrone_part/parts = list()
	/// Active flockdrone part.
	var/datum/flockdrone_part/active_part

/mob/living/basic/flock/drone/Initialize(mapload, join_flock)
	create_parts()
	set_active_part(parts[1])
	. = ..()
	flock?.stat_drones_made++

	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	real_name = flock_realname(FLOCK_TYPE_DRONE)
	name = flock_name(FLOCK_TYPE_DRONE)

	if(stat == CONSCIOUS)
		INVOKE_ASYNC(src, PROC_REF(say), pick(GLOB.flockdrone_created_phrases))

/mob/living/basic/flock/drone/Destroy()
	release_control()
	QDEL_NULL(substrate)
	QDEL_LIST_CONTENTS(parts)
	active_part = null // whatever was here was qdeleted by qdel_list(parts)
	return ..()

/mob/living/basic/flock/drone/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	var/cognition = "TORPID"
	if(stat == DEAD)
		cognition = "DEAD"
	else if(controlled_by || ckey)
		cognition = "SAPIENT"
	else if(dormant)
		cognition = "ABSENT"
	else if(HAS_TRAIT(src, TRAIT_AI_PAUSED))
		cognition = "HIBERNATING"

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		controlled_by ? SPAN_FLOCKSAY("<b>ID:</b> [controlled_by.real_name] (controlling [real_name])") : SPAN_FLOCKSAY("<b>ID:</b> [real_name]"),
		SPAN_FLOCKSAY("<b>Flock:</b> [flock?.name || "N/A"]"),
		SPAN_FLOCKSAY("<b>Substrate: [substrate.has_points()]</b>"),
		SPAN_FLOCKSAY("<b>System Integrity: [round(health / maxHealth, 0.1) * 100]</b>"),
		SPAN_FLOCKSAY("<b>Cognition:</b> [cognition]"),
	)

	if(cognition == "TORPID" && length(ai_controller?.current_behaviors))
		var/datum/ai_behavior/flock/flock_behavior = locate() in ai_controller.current_behaviors
		if(istype(flock_behavior))
			. += SPAN_FLOCKSAY("<b>Task: [flock_behavior.name]")

	. += SPAN_FLOCKSAY("<b>###=-</b>")

/mob/living/basic/flock/drone/death(gibbed, cause_of_death)
	stop_flockphase(TRUE)
	release_control()
	say(pick(GLOB.flockdrone_death_phrases))
	if(flock)
		flock_talk(null, "Connection to drone [real_name] lost.", flock, involuntary = TRUE)

	var/datum/flockdrone_part/absorber/absorber = locate() in parts
	absorber.try_drop_item()
	return ..()

/mob/living/basic/flock/drone/Life(seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_FLOCKPHASE))
		if(avoid_stop_flockphase())
			flockphase_tax()
		else
			stop_flockphase()

/mob/living/basic/flock/drone/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	// Stop existing flockphasing if we can't flockphase, also update the oldloc if it was a flock floor.
	if(HAS_TRAIT(src, TRAIT_FLOCKPHASE))
		if(istype(old_loc, /turf/simulated/floor/flock))
			var/turf/simulated/floor/flock/flockfloor = old_loc
			LAZYREMOVE(flockfloor.flockrunning_mobs, src)
			flockfloor.update_power()

	// Mob can't flockphase.
	if(!isflockturf(loc) || !can_flockphase())
		stop_flockphase(TRUE)
		return

	// Being in a wall forces flockphase if able.
	if(istype(loc, /turf/simulated/wall/flock))
		if(flockphase_tax())
			start_flockphase()
			return
		return

	// Either the client wants to flockphase, of if uncliented, already flockphasing.
	var/wants_to_flockphase = client ? client.keys_held["Shift"] : HAS_TRAIT(src, TRAIT_FLOCKPHASE)
	if(!wants_to_flockphase)
		stop_flockphase()
		return

	if(istype(loc, /turf/simulated/floor/flock))
		var/turf/simulated/floor/flock/flockfloor = loc
		// Also incapable of flockphasing.
		if(flockfloor.broken)
			stop_flockphase(TRUE)
			return

		if(flockphase_tax())
			start_flockphase()
			LAZYADD(flockfloor.flockrunning_mobs, src)
			flockfloor.update_power()
			return
		return

/mob/living/basic/flock/drone/get_status_tab_items()
	. = ..()
	. += "Substrate: [substrate.has_points()]"

/mob/living/basic/flock/drone/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(M != user || !istype(user, /mob/camera/flock))
		return

	var/mob/camera/flock/ghost_bird = user
	if(istype(user) && ghost_bird.flock == flock)
		take_control(user)

/mob/living/basic/flock/drone/Click(location, control, params)
	. = ..()
	var/mob/camera/flock/ghost_bird = usr
	if(!istype(ghost_bird))
		return

	var/list/modifiers = params2list(params)
	if(!modifiers?[RIGHT_CLICK])
		return

	var/list/choices = list()
	var/image/I = image('icons/hud/radial.dmi', "radial_use")
	choices["order"] = I

	I = image('icons/hud/radial.dmi', "radial_control")
	choices["control"] = I

	var/result = show_radial_menu(usr, get_turf(src), choices, "[ref(usr)]_flock_click")
	switch(result)
		if("control")
			take_control(ghost_bird)

		if("order")
			var/datum/action/cooldown/flock/control_drone/order_action = locate() in ghost_bird.actions
			if(order_action)
				if(order_action.selected_bird)
					order_action.unset_click_ability(usr)
				else
					order_action.set_click_ability(usr)
					order_action.Trigger(target = src)

/mob/living/basic/flock/drone/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(modifiers?[RIGHT_CLICK])
		active_part?.right_click_on(attack_target, TRUE)
	else
		active_part?.left_click_on(attack_target, TRUE)

/mob/living/basic/flock/drone/RangedAttack(atom/A, modifiers)
	. = ..()
	if(.)
		return

	if(modifiers?[RIGHT_CLICK])
		active_part?.right_click_on(A, FALSE)
	else
		active_part?.left_click_on(A, FALSE)

/mob/living/basic/flock/update_health_hud()
	var/severity = 0
	var/healthpercent = ceil((health/maxHealth) * 100)
	if(healthdoll) // to really put you in the boots of a basic mob
		var/atom/movable/screen/flockdrone_health/healthdoll = healthdoll
		switch(healthpercent)
			if(100 to INFINITY)
				severity = 0
			if(81 to 99)
				severity = 1
			if(65 to 80)
				severity = 2
			if(49 to 64)
				severity = 3
			if(33 to 48)
				severity = 4
			if(17 to 32)
				severity = 5
			if(1 to 16)
				severity = 6
			else
				severity = 7

		healthdoll.icon_state = "health[severity]"



/mob/living/basic/flock/drone/harvest(mob/living/user)
	var/list/loot = list(
		/obj/item/stack/sheet/gnesis = 1,
		/obj/item/shard/gnesis_glass = 1,
	)

	for(var/i in 3 to 6)
		var/path = pickweight(loot)
		new path(drop_location())

	playsound(src, 'sound/effects/pylon_shatter.ogg', 30, TRUE, SILENCED_SOUND_EXTRARANGE)

	// Spawn flock organs here
	qdel(src)

/mob/living/basic/flock/drone/get_flock_data()
	var/list/data = ..()
	var/current_behavior_name

	if(controlled_by)
		data["task"] = "controlled"
		data["controller_ref"] = ref(controlled_by)

	else if((ai_controller.ai_status == AI_ON) && length(ai_controller.current_behaviors))
		var/datum/ai_behavior/flock/current_task = ai_controller.current_behaviors[1]
		if(istype(current_task))
			current_behavior_name = current_task.name

	data["task"] = current_behavior_name || "hibernating"
	return data

/mob/living/basic/flock/drone/on_ai_status_change(datum/ai_controller/source, ai_status)
	. = ..()
	if(ai_status == AI_STATUS_OFF && controlled_by)
		task_tag.set_text("Controlled By: [controlled_by.real_name]")

/mob/living/basic/flock/drone/dormantize()
	if(!flock)
		return ..()

	if(controlled_by)
		release_control(FALSE)
		flock_talk(null, "Connection to drone [real_name] lost.", flock, involuntary = TRUE)

	spawn(-1)
		say("error: out of signal range, disconnecting")
	return ..()

/// Sets the active flockdrone part.
/mob/living/basic/flock/drone/proc/set_active_part(datum/flockdrone_part/new_part)
	var/datum/flockdrone_part/old_part = active_part
	active_part = new_part

	active_part.screen_obj?.update_appearance()
	old_part?.screen_obj?.update_appearance()

/// Create all of the part datums for this mob.
/mob/living/basic/flock/drone/proc/create_parts()
	parts += new /datum/flockdrone_part/converter(src)
	parts += new /datum/flockdrone_part/incapacitator(src)
	parts += new /datum/flockdrone_part/absorber(src)

/mob/living/basic/flock/drone/proc/start_flockphase()
	if(HAS_TRAIT(src, TRAIT_FLOCKPHASE))
		return FALSE

	playsound(src, 'sound/goonstation/flockmind/flockdrone_floorrun.ogg', 30, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	ADD_TRAIT(src, TRAIT_FLOCKPHASE, INNATE_TRAIT)
	pass_flags_self |= LETPASSTHROW | PASSFLOCK

	mob_size = 0

	set_density(FALSE)
	for(var/obj/item/hand_item/grab/G in contents)
		qdel(G)
	move_speed -= 0.4

	var/list/color_matrix = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/shrink = matrix().Scale(0)
	animate(src, color = color_matrix, transform = shrink, time = 0.5 SECONDS, easing = SINE_EASING)
	return TRUE

/mob/living/basic/flock/drone/proc/stop_flockphase(force)
	if(!HAS_TRAIT(src, TRAIT_FLOCKPHASE))
		return FALSE

	if(!force && avoid_stop_flockphase())
		return FALSE

	playsound(src, 'sound/goonstation/flockmind/flockdrone_floorrun.ogg', 30, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	REMOVE_TRAIT(src, TRAIT_FLOCKPHASE, INNATE_TRAIT)
	pass_flags_self &= ~(LETPASSTHROW | PASSFLOCK)
	mob_size = initial(mob_size)
	set_density(TRUE)
	move_speed += 0.4

	animate(src, color = null, transform = null, time = 0.5 SECONDS, easing = SINE_EASING)

	if(!isturf(loc))
		return

	if(istype(loc, /turf/simulated/floor/flock))
		var/turf/simulated/floor/flock/flockfloor = loc
		LAZYREMOVE(flockfloor.flockrunning_mobs, src)
		flockfloor.update_power()

	var/turf/turfloc = loc
	if(turfloc.can_flock_occupy(src))
		return

	for(var/turf/T in get_adjacent_open_turfs(src))
		if(!T.can_flock_occupy(src))
			forceMove(T)
			break

/// Called in stop_flockphase() to attempt stopping flockphase due to being in a wall or something.
/mob/living/basic/flock/drone/proc/avoid_stop_flockphase()
	if(!can_flockphase())
		return FALSE
	var/turf/T = loc

	if(T.density)
		return TRUE

	if(client?.keys_held["Shift"])
		return TRUE

/// Returns TRUE if the drone can flockphase.
/mob/living/basic/flock/drone/proc/can_flockphase()
	if(stat != CONSCIOUS)
		return FALSE

	if(length(grabbed_by))
		return FALSE

	if(!substrate.has_points())
		return FALSE

	return TRUE

/// Deducts the substrate tax for flockphasing, ending flockphase if the drone ran out of points.
/mob/living/basic/flock/drone/proc/flockphase_tax()
	substrate.remove_points(1)
	if(!substrate.has_points())
		stop_flockphase(TRUE)
		return FALSE
	return TRUE

/mob/living/basic/flock/drone/proc/take_control(mob/camera/flock/master_bird)
	if(HAS_TRAIT_FROM(src, TRAIT_AI_DISABLE_PLANNING, FLOCK_CONTROLLED_BY_OVERMIND_SOURCE))
		to_chat(master_bird, SPAN_ALERT("This drone is recieving a sentient-level instruction."))
		return FALSE

	if(controlled_by)
		to_chat(master_bird, SPAN_ALERT("This drone is already under another partition's command."))
		return FALSE

	stop_flockphase()

	controlled_by = master_bird
	controlled_by.controlling_bird = src

	if(controlled_by.mind)
		controlled_by.mind.transfer_to(src)

	if(isflocktrace(controlled_by))
		flock.add_notice(src, FLOCK_NOTICE_FLOCKTRACE_CONTROL)
	else
		flock.add_notice(src, FLOCK_NOTICE_FLOCKMIND_CONTROL)

	to_chat(src, SPAN_FLOCKSAY("<b>\[SYSTEM: Control of drone [real_name] established.\]</b>"))
	return TRUE

/mob/living/basic/flock/drone/proc/release_control(go_dormant = FALSE)
	if(isnull(controlled_by))
		return

	task_tag.set_text("")

	var/dest_was_safe = TRUE
	var/turf/destination = get_turf(src)
	if(!flock.is_on_safe_z(destination))
		dest_was_safe = FALSE
		destination = get_turf(pick(flock.drones)) || get_safe_random_station_turf()

	var/mob/camera/flock/master_bird = controlled_by
	controlled_by = null

	if(flock)
		flock.remove_notice(src, FLOCK_NOTICE_FLOCKMIND_CONTROL)
		flock.remove_notice(src, FLOCK_NOTICE_FLOCKTRACE_CONTROL)

	if(isnull(master_bird) && ckey)
		if(flock)
			master_bird = new /mob/camera/flock/trace(destination, flock)
		else
			ghostize(FALSE)

	if(!master_bird)
		return

	master_bird.forceMove(destination)
	if(mind)
		mind.transfer_to(master_bird)

	flock_talk(null, "Control of [real_name] surrendered.", flock, involuntary = TRUE)
	if(!dest_was_safe)
		to_chat(master_bird, SPAN_WARNING("You feel your consciousness weaking as you are ripped further from your rift, and you retreat back to safety."))

	if(!flock && go_dormant)
		dormantize()

/mob/living/basic/flock/drone/proc/split_into_bits()
	ai_controller.pause_ai(3 SECONDS)
	say("\[System notification: drone diffracting.\]")
	emote("scream")
	flock?.free_unit(src)

	var/turf/T = get_turf(src)
	for(var/i in 1 to 3)
		var/mob/living/basic/flock/bit/bitty_bird = new(T, flock)
		bitty_bird.i_just_split(T)

	var/list/new_color = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	color = null
	animate(src, color=new_color, alpha = 0, time = 0.5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(finish_splitting)), 0.5 SECONDS)

/mob/living/basic/flock/drone/proc/finish_splitting()
	qdel(src)

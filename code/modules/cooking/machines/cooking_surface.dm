RESTRICT_TYPE(/datum/cooking_surface)

/**
 * Cooking surfaces are representations of the available "slots" on a cooking machine
 * that can hold a cooking container.
 */
/datum/cooking_surface
	var/surface_name = "surface"
	var/cooker_id
	var/obj/machinery/cooking/parent
	var/temperature = J_LO
	var/timer = 0
	var/cooktime
	var/obj/item/reagent_containers/cooking/container
	var/on = FALSE
	var/prob_quality_decrease = 0
	var/allow_temp_change = TRUE
	VAR_PRIVATE/burn_callback
	VAR_PRIVATE/fire_callback
	VAR_PRIVATE/alarm_callback

/datum/cooking_surface/New(obj/machinery/cooking/parent_)
	. = ..()
	parent = parent_

/datum/cooking_surface/proc/container_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE
	examine_list += "<span class='notice'>[examine_text()]</span>"
	if(timer)
		examine_list += "<span class='notice'>Its alarm is configured for [timer / (1 SECONDS)] seconds.</span>"

/datum/cooking_surface/proc/examine_text()
	return "This [surface_name] will cook at [temperature] temperature."

/datum/cooking_surface/proc/handle_cooking(mob/user)
	if(container)
		if(isnull(container.get_cooker_time(cooker_id, temperature)))
			reset_cooktime()

		#ifdef PCWJ_DEBUG
		log_debug("timer=[timer] cooktime=[cooktime] stopwatch=[stop_watch(cooktime)]")
		#endif

		container.set_cooker_data(src, stop_watch(cooktime) SECONDS)
		var/process_result = container.process_item(user, parent)
		if(process_result == PCWJ_COMPLETE)
			SEND_SIGNAL(container, COMSIG_COOK_MACHINE_STEP_COMPLETE, src)

/datum/cooking_surface/proc/handle_switch(mob/user)
	playsound(parent, 'sound/items/lighter.ogg', 100, TRUE, 0)
	if(on)
		turn_off()
	else
		turn_on()

	parent.update_appearance(UPDATE_ICON)
	return on

/datum/cooking_surface/proc/set_burn_ignite_callbacks()
	if(container)
		var/burn_time = PCWJ_BURN_TIME_LOW
		var/fire_time = PCWJ_IGNITE_TIME_LOW
		switch(temperature)
			if(J_MED)
				burn_time = PCWJ_BURN_TIME_MEDIUM
				fire_time = PCWJ_IGNITE_TIME_MEDIUM
			if(J_HI)
				burn_time = PCWJ_BURN_TIME_HIGH
				fire_time = PCWJ_IGNITE_TIME_HIGH

		burn_callback = addtimer(CALLBACK(src, PROC_REF(handle_burn)), burn_time, TIMER_STOPPABLE)
		fire_callback = addtimer(CALLBACK(src, PROC_REF(handle_fire)), fire_time, TIMER_STOPPABLE)

/datum/cooking_surface/proc/turn_on(mob/user)
	on = TRUE
	set_burn_ignite_callbacks()
	restart_timer()
	reset_cooktime()

/datum/cooking_surface/proc/restart_timer()
	if(alarm_callback)
		deltimer(alarm_callback)
	if(timer)
		alarm_callback = addtimer(CALLBACK(src, PROC_REF(handle_alarm)), timer, TIMER_STOPPABLE)

/datum/cooking_surface/proc/turn_off(mob/user)
	playsound(parent, 'sound/items/lighter.ogg', 100, TRUE, 0)
	on = FALSE
	unset_callbacks()
	deltimer(alarm_callback)
	cooktime = -1
	parent.update_appearance(UPDATE_ICON)

/datum/cooking_surface/proc/handle_burn()
	if(istype(container))
		container.handle_burning()

/datum/cooking_surface/proc/handle_fire()
	if(istype(container) && container.handle_ignition())
		parent.ignite()

/datum/cooking_surface/proc/handle_alarm()
	parent.atom_emote("dings.")
	playsound(parent.loc, 'sound/machines/bell.ogg', 50, FALSE)

/datum/cooking_surface/proc/unset_callbacks()
	deltimer(burn_callback)
	deltimer(fire_callback)

/datum/cooking_surface/proc/handle_timer(mob/user)
	var/old_time = timer ? timer / (1 SECONDS) : 1
	var/timer_input = tgui_input_number(
		user,
		message = "Enter an alarm for the burner in seconds. Enter zero to disable alarm.",
		title = "Set Alarm",
		default = old_time,
		max_value = 60)
	if(!isnull(timer_input))
		timer = timer_input SECONDS
		if(on)
			restart_timer()

	parent.update_appearance(UPDATE_ICON)

/datum/cooking_surface/proc/handle_temperature(mob/user)
	var/old_temp = temperature
	var/choice = tgui_input_list(
		user,
		"Select a heat setting for the burner.\nCurrent temp: [old_temp]",
		"Select Temperature",
		items = list(J_HI, J_MED, J_LO, "Cancel"),
		default = old_temp
	)
	if(choice && choice != "Cancel" && choice != old_temp)
		temperature = choice
		if(on)
			reset_cooktime()
			handle_cooking(user)

/datum/cooking_surface/proc/reset_cooktime()
	cooktime = start_watch()
	#ifdef PCWJ_DEBUG
	log_debug("reset_cooktime")
	#endif

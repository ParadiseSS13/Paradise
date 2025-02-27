RESTRICT_TYPE(/datum/cooking_surface)

/**
 * Cooking surfaces are representations of the available "slots" on a cooking machine
 * that can hold a cooking container.
 */
/datum/cooking_surface
	var/cooker_id
	var/obj/machinery/cooking/parent
	var/temperature = J_LO
	var/timer = 0
	COOLDOWN_DECLARE(cooktime_cd)
	var/cooking_ticks_handled = 0
	var/obj/placed_item
	var/on = FALSE
	var/prob_quality_decrease = 0
	VAR_PRIVATE/burn_callback
	VAR_PRIVATE/fire_callback

/datum/cooking_surface/New(obj/machinery/cooking/parent_)
	. = ..()
	parent = parent_

/datum/cooking_surface/proc/handle_cooking(mob/user)
	var/obj/item/reagent_containers/cooking/container = placed_item
	if(istype(container))
		if(isnull(container.get_cooker_time(cooker_id, temperature)))
			reset_cooktime()

		cooking_ticks_handled++
		#ifdef PCWJ_DEBUG
		log_debug("cooking_ticks_handled=[cooking_ticks_handled]")
		#endif

		container.set_cooker_data(src, cooking_ticks_handled * 2)
		container.process_item(user, parent)

		// If we have something in here that's not the start of a recipe, it's
		// probably a finished product. Slowly eat at the food quality if the burner
		// is still on and the food hasn't been removed.
		if(container.tracker && length(container.contents) && !container.tracker.recipe_started)
			if(prob_quality_decrease < 100)
				prob_quality_decrease = min(100, prob_quality_decrease + 5)
			if(prob_quality_decrease)
				for(var/obj/item in container.contents)
					var/obj/item/food/food = item
					if(istype(food))
						food.food_quality -= 0.05
						#ifdef PCWJ_DEBUG
						log_debug("[food] quality decreased to [food.food_quality]")
						#endif

	if(timer && COOLDOWN_FINISHED(src, cooktime_cd))
		turn_off(user)
		return

/datum/cooking_surface/proc/handle_switch(mob/user)
	playsound(parent, 'sound/items/lighter.ogg', 100, 1, 0)
	if(on)
		turn_off()
	else
		turn_on()

	parent.update_appearance(UPDATE_ICON)
	return on

/datum/cooking_surface/proc/set_burn_ignite_callbacks()
	if(placed_item)
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

/datum/cooking_surface/proc/timer_act(mob/user)
	#ifdef PCWJ_DEBUG
	log_debug("timer act timer=[timer] world.time=[world.time]")
	#endif
	COOLDOWN_START(src, cooktime_cd, timer)

/datum/cooking_surface/proc/turn_on(mob/user)
	on = TRUE
	set_burn_ignite_callbacks()
	reset_cooktime()
	if(timer)
		timer_act(user)

/datum/cooking_surface/proc/turn_off(mob/user)
	playsound(parent, 'sound/items/lighter.ogg', 100, 1, 0)
	on = FALSE
	unset_callbacks()
	cooking_ticks_handled = 0
	parent.update_appearance(UPDATE_ICON)

/datum/cooking_surface/proc/handle_burn()
	var/obj/item/reagent_containers/cooking/container = placed_item
	if(istype(container))
		container.handle_burning()

/datum/cooking_surface/proc/handle_fire()
	var/obj/item/reagent_containers/cooking/container = placed_item
	if(istype(container) && container.handle_ignition())
		parent.ignite()

/datum/cooking_surface/proc/unset_callbacks()
	COOLDOWN_RESET(src, cooktime_cd)
	deltimer(burn_callback)
	deltimer(fire_callback)

/datum/cooking_surface/proc/handle_timer(mob/user)
	var/old_time = timer ? round((timer / (1 SECONDS)), 1 SECONDS) : 1
	timer = (tgui_input_number(user, "Enter a timer for the burner in seconds. To keep on, set to zero.","Set Timer", old_time)) SECONDS
	if(timer != 0 && on)
		timer_act(user)

	parent.update_appearance(UPDATE_ICON)

/datum/cooking_surface/proc/handle_temperature(mob/user)
	var/old_temp = temperature
	var/choice = input(user, "Select a heat setting for the burner.\nCurrent temp :[old_temp]","Select Temperature",old_temp) in list("High","Medium","Low","Cancel")
	if(choice && choice != "Cancel" && choice != old_temp)
		temperature = choice
		if(on)
			reset_cooktime()
			handle_cooking(user)

/datum/cooking_surface/proc/reset_cooktime()
	cooking_ticks_handled = 1
	#ifdef PCWJ_DEBUG
	log_debug("reset_cooktime")
	#endif

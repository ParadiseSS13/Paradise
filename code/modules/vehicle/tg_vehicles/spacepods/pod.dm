// MARK: Space Pods
// Based on Space Pods from Ark-Station, which was based on Vectorcrafts from SPLURT

// TODO: Allow fuel tank to be filled with a reagent container
// TODO: Add extensions (weapon systems, cargo bay)

/obj/tgvehicle/sealed/vectorcraft/spacepod
	name = "ABP-01 'Pallas'"
	desc = "Designed for civilian purposes Pod."
	icon = 'icons/obj/spacepods/raptor.dmi'
	base_icon_state = "raptor"
	icon_state = "raptor-off"
	bound_width = 32
	bound_height = 32
	mouse_pointer = 'icons/mouse_icons/mecha_mouse.dmi'
	max_acceleration = 4
	accel_step = 0.22
	acceleration = 0.30
	max_deceleration = 2
	max_velocity = 50
	max_integrity = 100
	/// Pod flags, currently keyed to what's available for mechs.
	var/pod_flags = MECH_HAS_LIGHTS
	/// Reagent container holding plasma fuel.
	var/obj/item/reagent_containers/pod_fueltank
	/// Should the tank be full when spawned?
	var/starting_fuel = FALSE
	/// Maximum amount of fuel
	var/max_fuel = 1200
	/// DNA lock.
	var/dna_lock
	/// The effect system for the engine trail
	var/datum/effect_system/trail_follow/trail
	/// The typepath to instansiate our trail as, when we need it
	var/trail_effect_type = /datum/effect_system/trail_follow/ion
	/// Power of built-in light.
	var/lights_power = 5
	/// Range of built-in light.
	var/lights_range = 5

/obj/tgvehicle/sealed/vectorcraft/spacepod/Initialize(mapload)
	. = ..()

	transform = transform.Translate(-32, -32)
	pod_fueltank = new(src)
	pod_fueltank.volume = max_fuel
	pod_fueltank.create_reagents(max_fuel)
	pod_flags &= ~MECH_LIGHTS_ON
	if(starting_fuel)
		pod_fueltank.reagents.add_reagent("plasma", max_fuel)

	trail = new trail_effect_type
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()

/obj/tgvehicle/sealed/vectorcraft/spacepod/Destroy()
	. = ..()
	for(var/ejectee in occupants)
		mob_exit(ejectee, silent = TRUE)

	stop_engine()

	if(trail)
		QDEL_NULL(trail)

/obj/tgvehicle/sealed/vectorcraft/spacepod/mob_try_enter(mob/M)
	if(!ishuman(M))
		return
	if(M.dna?.species?.greater_form)
		to_chat(M, SPAN_WARNING("The knowledge to use this device eludes you!"))
		return
	if(dna_lock && M.dna)
		var/mob/living/carbon/entering_carbon = M
		if(entering_carbon.dna.unique_enzymes != dna_lock)
			to_chat(M, SPAN_WARNING("Access denied. [name] is secured with a DNA lock."))
			return
	if(!allowed(M))
		to_chat(M, SPAN_WARNING("Access denied. Insufficient operation keycodes."))
		return
	. = ..()
	if(.)
		moved_inside(M)

/obj/tgvehicle/sealed/vectorcraft/spacepod/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	add_occupant(newoccupant)
	newoccupant.forceMove(src)
	add_fingerprint(newoccupant)
	setDir(SOUTH)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	set_mouse_pointer()
	return TRUE

/obj/tgvehicle/sealed/vectorcraft/spacepod/proc/set_mouse_pointer()
	mouse_pointer = 'icons/mouse_icons/mecha_mouse.dmi'

	for(var/mob/mob_occupant as anything in occupants)
		mob_occupant.update_mousepointer()

/obj/tgvehicle/sealed/vectorcraft/spacepod/proc/get_fuel()
	return pod_fueltank.reagents.get_reagent_amount("plasma")

/obj/tgvehicle/sealed/vectorcraft/spacepod/mob_enter(mob/living/M)
	if(!driver)
		driver = M
	if(get_fuel() >=1)
		start_engine()
		icon_state = base_icon_state + "-on"
	else
		stop_engine()
		icon_state = base_icon_state + "-off"
	return ..()

/obj/tgvehicle/sealed/vectorcraft/spacepod/mob_exit(mob/living/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	if(!driver)
		stop_engine()
		return
	if(driver.client)
		driver.client.pixel_x = 0
		driver.client.pixel_y = 0
	driver.pixel_x = 0
	driver.pixel_y = 0
	if(M == driver)
		driver = null
	stop_engine()
	icon_state = base_icon_state + "-off"

/obj/tgvehicle/sealed/vectorcraft/spacepod/vehicle_move(cached_direction)
	if(!driver)
		stop_engine()
	if(driver.stat == DEAD)
		mob_exit(driver)
	if(get_fuel() >=1)
		start_engine()
		icon_state = base_icon_state + "-on"
	else
		stop_engine()
		icon_state = base_icon_state + "-off"
	dir = cached_direction
	calc_acceleration()
	calc_vector(cached_direction)
	if(pod_fueltank.reagents.has_reagent("plasma", 0.1))
		fuel_waste()

	if(trail)
		// TODO: Trail may currently look off because the direction and offset
		// of the pod doesn't always match the trail's location. 90% of the time
		// it's not a big deal, but if noticeable, it should be straightforward
		// to align the trail with the ship's direction and set an offset so that
		// it always looks like it's coming out of the back engines.
		trail.generate_effect()

// Because the pixel-movement/drift behavior doesn't actually go through
// the standard Moved proc, we have to do some cleanup manually.
/obj/tgvehicle/sealed/vectorcraft/spacepod/after_move(direction)
	. = ..()
	update_light()

/obj/tgvehicle/sealed/vectorcraft/spacepod/proc/fuel_waste()
	if(prob(50))
		pod_fueltank.reagents.remove_reagent("plasma", 0.1)

/obj/tgvehicle/sealed/vectorcraft/spacepod/start_engine()
	if(dead_check())
		return
	START_PROCESSING(SSvectorcraft, src)
	if(!driver)
		stop_engine()

/obj/tgvehicle/sealed/vectorcraft/spacepod/proc/toggle_lights(forced_state = null, mob/user)
	pod_flags ^= MECH_LIGHTS_ON

	for(var/mob/occupant as anything in occupants)
		var/datum/action/act = locate(/datum/action/vehicle/sealed/pod/mech_toggle_lights) in occupant.actions
		if(pod_flags & MECH_LIGHTS_ON)
			set_light(lights_range, lights_power)
			act.button_icon_state = "mech_lights_on"
		else
			set_light(MINIMUM_USEFUL_LIGHT_RANGE, LIGHTING_MINIMUM_POWER)
			act.button_icon_state = "mech_lights_off"
		to_chat(occupant, SPAN_NOTICE("Turned lights [pod_flags & MECH_LIGHTS_ON ? "on":"off"]."))

		act.build_all_button_icons()

/obj/tgvehicle/sealed/vectorcraft/spacepod/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/pod))
		var/datum/action/vehicle/sealed/pod/mecha_action = .
		mecha_action.set_chassis(src)

/obj/tgvehicle/sealed/vectorcraft/spacepod/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/pod/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/pod/mech_view_stats)

// MARK: UI

/obj/tgvehicle/sealed/vectorcraft/spacepod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pod", name)
		ui.open()

/obj/tgvehicle/sealed/vectorcraft/spacepod/ui_status(mob/user)
	if(contains(user))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/tgvehicle/sealed/vectorcraft/spacepod/ui_static_data(mob/user)
	var/list/data = list()

	// map of relevant flags to check tgui side, not every flag needs to be here
	data["mechflag_keys"] = list(
		"MECH_LIGHTS_ON" = MECH_LIGHTS_ON,
	)
	return data

/obj/tgvehicle/sealed/vectorcraft/spacepod/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = (user in occupants) //maintenance mode outside of mech
	data["isoperator"] = isoperator
	data["name"] = name
	data["integrity"] = obj_integrity
	data["integrity_max"] = max_integrity
	data["power_level"] = pod_fueltank.reagents.total_volume
	data["power_max"] = max_fuel
	data["mecha_flags"] = pod_flags

	data["dna_lock"] = dna_lock
	return data

/obj/tgvehicle/sealed/vectorcraft/spacepod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("changename")
			var/userinput = tgui_input_text(usr, "Choose a new pod name", "Rename Pod", max_length = MAX_NAME_LEN, default = name)
			if(!userinput)
				return
			if(userinput == format_text(name))
				to_chat(usr, SPAN_NOTICE("You rename [name] to... well, [userinput]."))
				return
			name = userinput
		if("dna_lock")
			var/mob/living/carbon/user = usr
			if(!istype(user) || !user.dna)
				to_chat(user, SPAN_NOTICE("You can't create a DNA lock with no DNA!."))
				return
			dna_lock = user.dna.unique_enzymes
			to_chat(user, SPAN_NOTICE("You feel a prick as the needle takes your DNA sample."))
		if("reset_dna")
			dna_lock = null
		if("toggle_lights")
			toggle_lights(user = usr)
	return TRUE

/obj/tgvehicle/sealed/vectorcraft/spacepod/fueled
	starting_fuel = TRUE

// MARK: Variants

/obj/tgvehicle/sealed/vectorcraft/spacepod/sci
	name = "AVP-02 'Athena'"
	icon = 'icons/obj/spacepods/raptor_sci.dmi'
	base_icon_state = "raptor_sci"
	icon_state = "raptor_sci-off"
	desc = "Designed for space exploration Pod."
	max_integrity = 150

/obj/tgvehicle/sealed/vectorcraft/spacepod/sec
	name = "ASP-03 'Themis'"
	icon = 'icons/obj/spacepods/raptor_sec.dmi'
	base_icon_state = "raptor_sec"
	icon_state = "raptor_sec-off"
	desc = "Designed for perimeter security Pod."
	max_integrity = 200

/obj/tgvehicle/sealed/vectorcraft/spacepod/sec/fueled
	starting_fuel = TRUE

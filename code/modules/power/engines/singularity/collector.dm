// stored_energy += (pulse_strength - RAD_COLLECTOR_THRESHOLD) * RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_THRESHOLD 80	// This gets subtracted from the value of absorbed radiation
#define RAD_COLLECTOR_COEFFICIENT 400
#define RAD_COLLECTOR_STORED_OUT 0.04	// (this * 100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_OUTPUT min(stored_energy, (stored_energy * RAD_COLLECTOR_STORED_OUT) + 1000) //Produces at least 1000 watts if it has more than that stored

/obj/machinery/power/rad_collector
	name = "radiation collector array"
	desc = "A device which converts raditation to useable electical energy using plasma. It absorbs Beta particles extremely well, and Gamma particles to a lesser extent"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	rad_insulation_beta = RAD_BETA_COLLECTOR
	rad_insulation_gamma = RAD_LIGHT_INSULATION
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/stored_energy = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1
	var/powerproduction_drain = 0.001
	var/power_threshold = RAD_COLLECTOR_THRESHOLD
	var/power_coefficient = RAD_COLLECTOR_COEFFICIENT
	/// A record of the absorbed strength of each beta wave that hit the collector. This keeps record up to rad_time old, and only the maximum absorption for each time point.
	var/beta_waves = list()
	/// A record of the absorbed strength of each gamma wave that hit the collector. This keeps record up to rad_time old, and only the maximum absorption for each time point.
	var/gamma_waves = list()
	/// Amount of time across which the maximum wave is checked
	var/rad_time = 5 SECONDS
	/// The current time count for clearing old data from the lists
	var/rad_time_counter = 0

/obj/machinery/power/rad_collector/pre_activated
	anchored = TRUE

/obj/machinery/power/rad_collector/pre_activated/Initialize(mapload)
	. = ..()
	loaded_tank = new /obj/item/tank/internals/plasma(src)
	toggle_power()

/obj/machinery/power/rad_collector/process()
	if(!loaded_tank)
		return
	if(!loaded_tank.air_contents.toxins())
		investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_SINGULO)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
	else
		var/gasdrained = min(powerproduction_drain * drainratio, loaded_tank.air_contents.toxins())
		loaded_tank.air_contents.set_toxins(loaded_tank.air_contents.toxins() - gasdrained)

		var/power_produced = RAD_COLLECTOR_OUTPUT
		produce_direct_power(power_produced)
		stored_energy -= power_produced
	if(world.time > rad_time_counter)
		rad_time_counter = world.time + rad_time
		for(var/listing in gamma_waves)
			if(world.time > text2num(listing) + rad_time)
				gamma_waves -= listing
			// We put the listing in oldest to newest so as soon as we hit something new enough we can keep the rest
			else
				break
		for(var/listing in beta_waves)
			if(world.time > text2num(listing) + rad_time)
				beta_waves -= listing
			// We put the listing in oldest to newest so as soon as we hit something new enough we can keep the rest
			else
				break


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(anchored)
		if(!locked)
			toggle_power()
			user.visible_message("[user.name] turns the [name] [active ? "on" : "off"].", "You turn the [name] [active ? "on" : "off"].")
			investigate_log("turned [active ? "<font color='green'>on</font>" : "<font color='red'>off</font>"] by [user.key]. [loaded_tank ? "Fuel: [round(loaded_tank.air_contents.toxins() / 0.29)]%" : "<font color='red'>It is empty</font>"].", INVESTIGATE_SINGULO)
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(loaded_tank)
		to_chat(user, "<span class='notice'>Remove the plasma tank first.</span>")
		return TRUE
	var/turf/T = get_turf(src)
	for(var/obj/machinery/power/rad_collector/can_wrench in T.contents)
		if(can_wrench.anchored && !anchored)
			to_chat(user, "<span class='notice'>You can't wrench down [src] here!</span>")
			return
	I.play_tool_sound(src)
	anchored = !anchored
	user.visible_message("[user.name] [anchored ? "secures" : "unsecures"] the [name].", "You [anchored ? "secure" : "undo"] the external bolts.", "You hear a ratchet")
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/rad_collector/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to the floor first.</span>")
			return ITEM_INTERACT_COMPLETE
		if(loaded_tank)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded.</span>")
			return ITEM_INTERACT_COMPLETE
		if(user.drop_item())
			loaded_tank = used
			used.forceMove(src)
			update_icons()
			return ITEM_INTERACT_COMPLETE
	else if(used.tool_behaviour == TOOL_CROWBAR)
		if(loaded_tank && !locked)
			eject()
			return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/card/id) || istype(used, /obj/item/pda))
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
			else
				locked = FALSE //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when [src] is active</span>")
		else
			to_chat(user, "<span class='warning'>Access denied!</span>")

		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(loaded_tank)
		return loaded_tank.return_analyzable_air()
	return null

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		// stored_energy is converted directly to watts every SSmachines.wait * 0.1 seconds.
		// Therefore, its units are joules per SSmachines.wait * 0.1 seconds.
		// So joules = stored_energy * SSmachines.wait * 0.1
		var/joules = stored_energy * SSmachines.wait * 0.1
		var/max_beta = 0
		var/max_gamma = 0
		// Find the maximum beta and gamma absorptions we have logged
		for(var/listing in beta_waves)
			if(max_beta < beta_waves[listing])
				max_beta = beta_waves[listing]
		for(var/listing in gamma_waves)
			if(max_gamma < gamma_waves[listing])
				max_gamma = gamma_waves[listing]
		var/beta_delta = max_beta - RAD_COLLECTOR_THRESHOLD
		var/gamma_delta = max_gamma - RAD_COLLECTOR_THRESHOLD
		. += "<span class='notice'>[src]'s display states that it has stored <b>[DisplayJoules(joules)]</b>, and is processing <b>[DisplayPower(RAD_COLLECTOR_OUTPUT)]</b></span>"
		. +="<span class='notice'>Strongest Beta absorption over the last [rad_time /(1 SECONDS)] seconds: <b>[max_beta]</b>, <b>[abs(beta_delta)]</b> [beta_delta >= 0 ? "above" : "below"] threshold</span>"
		. +="<span class='notice'>Strongest Gamma absorption over the last [rad_time /(1 SECONDS)] seconds: <b>[max_gamma]</b>, <b>[abs(gamma_delta)]</b> [gamma_delta >= 0 ? "above" : "below"] threshold</span>"

	else
		. += "<span class='notice'><b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>.\"</span>"

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN

/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = loaded_tank
	if(!Z)
		return
	Z.forceMove(drop_location())
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icons()

/// Converts absorbed Beta or Gamma radiation into electrical energy
/obj/machinery/power/rad_collector/rad_act(atom/source, amount, emission_type)
	// Log the absorption at current time. If we already have one logged and the new value is bigger overwrite it.
	if(emission_type == BETA_RAD)
		if(!beta_waves["[world.time]"])
			beta_waves += list("[world.time]" = amount)
		else if(beta_waves["[world.time]"] < amount)
			beta_waves["[world.time]"] = amount
	if(emission_type == GAMMA_RAD)
		if(!gamma_waves["[world.time]"])
			gamma_waves += list("[world.time]" = amount)
		else if(gamma_waves["[world.time]"] < amount)
			gamma_waves["[world.time]"] = amount
	if(emission_type != ALPHA_RAD && loaded_tank && active && amount > power_threshold)
		stored_energy += (amount - power_threshold) * power_coefficient


/obj/machinery/power/rad_collector/proc/update_icons()
	cut_overlays()
	if(loaded_tank)
		add_overlay("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay(loaded_tank ? "on" : "error")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icons()

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_OUTPUT

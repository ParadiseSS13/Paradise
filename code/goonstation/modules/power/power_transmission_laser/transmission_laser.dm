#define MINIMUM_POWER 1 MW

/obj/machinery/power/transmission_laser
	name = "power transmission laser"
	desc = "Sends power over a giant laser beam to an NT power processing facility."

	icon = 'icons/goonstation/objects/pt_laser.dmi'
	icon_state = "ptl"

	max_integrity = 10000

	density = TRUE
	anchored = TRUE

	pixel_x = 0
	pixel_y = -64

	/// Variables go below here
	/// The range we have this basically determines how far the beam goes its redone on creation so its set to a small number here
	var/range = 5
	/// Amount of power we are outputting
	var/output_level = 0
	/// The total capacity of the laser
	var/capacity = INFINITY
	/// Our current charge
	var/charge = 0
	/// Should we try to input charge paired with the var below to check if its fully inputing
	var/input_attempt = TRUE
	/// Are we currently inputting
	var/inputting = TRUE
	/// The amount of charge coming in from the inputs last tick
	var/input_available = 0
	/// Have we been switched on?
	var/turned_on = FALSE
	/// Are we attempting to fire the laser currently?
	var/firing = FALSE
	/// We need to create a list of all lasers we are creating so we can delete them in the end
	var/list/laser_effects = list()
	/// List of all blocking turfs or objects
	var/list/blocked_objects = list()
	/// Our max load we can set
	var/max_grid_load = 0
	/// Our current grid load
	var/current_grid_load = 0
	/// Out power formatting multiplier used inside tgui to convert to things like mW gW to watts for ease of setting
	var/power_format_multi = 1
	/// Same as above but for output
	var/power_format_multi_output = 1

	/// Are we selling the energy or just sending it into the ether
	var/selling_energy = FALSE

	/// How much energy have we sold in total (Joules)
	var/total_energy = 0
	/// How much energy do you have to sell in order to get an announcement
	var/announcement_threshold = 1 MJ

	/// How much credits we have earned in total
	var/total_earnings = 0
	/// The amount of money we haven't sent to cargo yet
	var/unsent_earnings = 0

	/// How much we are inputing pre multiplier
	var/input_number = 0
	/// How much we are outputting pre multiplier
	var/output_number = 0
	/// Our set input pulling
	var/input_pulling = 0
	/// Announcement configuration for updates
	var/datum/announcer/announcer = new(config_type = /datum/announcement_configuration/ptl)
	/// Last direction the laser was pointing. So offset doesn't get handles when it doesn't need to
	var/last_dir = 0


/obj/machinery/power/transmission_laser/Initialize(mapload)
	. = ..()
	range = get_dist(get_step(get_front_turf(), dir), get_edge_target_turf(get_front_turf(), dir))
	if(!powernet)
		connect_to_network()
	handle_offset()
	update_icon()

/obj/machinery/power/transmission_laser/proc/handle_offset()
	switch(dir)
		if(NORTH)
			pixel_x = -64
			pixel_y = 0
			var/datum/component/oldmap = GetComponent(/datum/component/multitile)
			if(oldmap)
				qdel(oldmap)
			AddComponent(/datum/component/multitile, 2, list(
				list(0, 0, 			0,			1, 0),
				list(0, 0, 			1,			1, 1),
				list(0, 0, 		MACH_CENTER, 	1, 1),
				list(0, 0, 			0, 			0, 0),
				list(0, 0, 			0, 			0, 0),
			))
		if(SOUTH)
			pixel_x = 0
			pixel_y = -64
			var/datum/component/oldmap = GetComponent(/datum/component/multitile)
			if(oldmap)
				qdel(oldmap)
			AddComponent(/datum/component/multitile, 2, list(
				list(0, 0, 			0,			0, 0),
				list(0, 0, 			0,			0, 0),
				list(1, 1, 		MACH_CENTER, 	0, 0),
				list(1, 1, 			1, 			0, 0),
				list(0, 1, 			0, 			0, 0),
			))
		if(WEST)
			pixel_x = -64
			pixel_y = 0
			var/datum/component/oldmap = GetComponent(/datum/component/multitile)
			if(oldmap)
				qdel(oldmap)
			AddComponent(/datum/component/multitile, 2, list(
				list(0, 0, 			1,			1, 0),
				list(0, 0, 			1,			1, 1),
				list(0, 0, 		MACH_CENTER, 	1, 0),
				list(0, 0, 			0, 			0, 0),
				list(0, 0, 			0, 			0, 0),
			))
		if(EAST)
			pixel_x = 0
			pixel_y = 0
			var/datum/component/oldmap = GetComponent(/datum/component/multitile)
			if(oldmap)
				qdel(oldmap)
			AddComponent(/datum/component/multitile, 2, list(
				list(0, 1, 			1,			0, 0),
				list(1, 1, 			1,			0, 0),
				list(0, 1, 		MACH_CENTER, 	0, 0),
				list(0, 0, 			0, 			0, 0),
				list(0, 0, 			0, 			0, 0),
			))

/obj/machinery/power/transmission_laser/Destroy()
	. = ..()
	if(length(laser_effects))
		destroy_lasers()
	blocked_objects = null

/obj/machinery/power/transmission_laser/proc/get_back_turf()
	//this is weird as i believe byond sets the bottom left corner as the source corner like
	// x-x-x
	// x-x-x
	// o-x-x
	//which would mean finding the true back turf would require centering than taking a step in the inverse direction
	var/turf/center = locate(x + 1, y + 1, z)
	if(!center)///what
		return
	var/inverse_direction = turn(dir, 180)
	return get_step(center, inverse_direction)

/obj/machinery/power/transmission_laser/proc/get_front_turf()
	//this is weird as i believe byond sets the bottom left corner as the source corner like
	// x-x-x
	// x-x-x
	// o-x-x
	//which would mean finding the true front turf would require centering than taking a step in the primary direction
	var/turf/center = locate(x + 1 + round(pixel_x / 32), y + 1 + round(pixel_y / 32), z)
	if(!center)///what
		return
	return get_step(center, dir)

/obj/machinery/power/transmission_laser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Laser currently has [unsent_earnings] unsent credits.<span/>"
	. += "<span class='notice'>Laser has generated [total_earnings] credits.<span/>"
	. += "<span class='notice'>Laser has sold [total_energy] Joules<span/>"
///appearance changes are here

/obj/machinery/power/transmission_laser/update_overlays()
	. = ..()
	if((stat & BROKEN) || !charge)
		. += "unpowered"
		return
	if(input_available > 0)
		. += "green_light"
		. += emissive_appearance(icon, "green_light", src)
	if(turned_on)
		. += "red_light"
		. += emissive_appearance(icon, "red_light", src)
		if(firing)
			. +="firing"
			. += emissive_appearance(icon, "firing", src)

	var/charge_level = return_charge()
	if(charge_level == 6)
		. += "charge_full"
		. += emissive_appearance(icon, "charge_full", src)
	else if(charge_level > 0)
		. += "charge_[charge_level]"
		. += emissive_appearance(icon, "charge_[charge_level]", src)

///returns the charge level from [0 to 6]
/obj/machinery/power/transmission_laser/proc/return_charge()
	if(!output_level)
		return 0
	return min(round((charge / abs(output_level)) * 6), 6)

/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	/// The message we send
	var/message
	var/flavor_text
	if(announcement_threshold == 1 MJ)
		message = "PTL account successfully made"
		flavor_text = "From now on, you will receive regular updates on the power exported via the onboard PTL. Good luck [station_name()]!"
		announcement_threshold = 100 MJ

	message = "New milestone reached!\n[DisplayJoules(announcement_threshold)]\n[flavor_text]"

	announcer.Announce(message)

	announcement_threshold *= 50

/obj/machinery/power/transmission_laser/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/power/transmission_laser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "goonstation_TDL")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/power/transmission_laser/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["output"] = output_level
	data["total_earnings"] = total_earnings
	data["unsent_earnings"] = unsent_earnings
	data["held_power"] = charge
	data["selling_energy"] = selling_energy
	data["max_capacity"] = capacity
	data["max_grid_load"] = max_grid_load

	data["accepting_power"] = turned_on
	data["sucking_power"] = inputting
	data["firing"] = firing

	data["power_format"] = power_format_multi
	data["input_number"] = input_number
	data["avalible_input"] = input_available
	data["output_number"] = output_number
	data["output_multiplier"] = power_format_multi_output
	data["input_total"] = input_number * power_format_multi
	data["output_total"] = output_number * power_format_multi_output

	return data

/obj/machinery/power/transmission_laser/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_input")
			turned_on = !turned_on
			update_icon()
		if("toggle_output")
			firing = !firing
			if(!firing)
				destroy_lasers()
			update_icon()

		if("set_input")
			input_number = clamp(params["set_input"], 0, 999) //multiplies our input by if input
		if("set_output")
			output_number = clamp(params["set_output"], 0, 999)

		if("inputW")
			power_format_multi = 1
		if("inputKW")
			power_format_multi = 1 KW
		if("inputMW")
			power_format_multi = 1 MW
		if("inputGW")
			power_format_multi = 1 GW

		if("outputW")
			power_format_multi_output = 1
		if("outputKW")
			power_format_multi_output = 1 KW
		if("outputMW")
			power_format_multi_output = 1 MW
		if("outputGW")
			power_format_multi_output = 1 GW

/obj/machinery/power/transmission_laser/process()
	max_grid_load = get_surplus()
	input_available = get_surplus()
	if(stat & BROKEN)
		return

	if(total_energy >= announcement_threshold)
		send_ptl_announcement()

	var/last_disp = return_charge()
	var/last_chrg = inputting
	var/last_fire = firing

	if(last_disp != return_charge() || last_chrg != inputting || last_fire != firing)
		update_icon()

	if(powernet && input_attempt && turned_on)
		input_pulling = min(input_available , input_number * power_format_multi)

		if(inputting)
			if(input_pulling > 0)
				consume_direct_power(input_pulling)
				charge += input_pulling
			else
				inputting = FALSE
		else
			if(input_attempt && input_pulling > 0)
				inputting = TRUE
	else
		inputting = FALSE

	if(charge < MINIMUM_POWER)
		firing = FALSE
		output_level = 0
		destroy_lasers()
		return

	if(!firing)
		return

	output_level = min(charge, output_number * power_format_multi_output)
	if(!length(laser_effects))
		setup_lasers()

	if(length(blocked_objects))
		var/atom/listed_atom = blocked_objects[1]
		if(prob(max((abs(output_level) * 0.1) / 500 KW, 1))) ///increased by a single % per 500 KW
			listed_atom.visible_message("<span class='danger'>[listed_atom] is melted away by the [src]!<span/>")
			blocked_objects -= listed_atom
			qdel(listed_atom)

	else
		sell_power(output_level * WATT_TICK_TO_JOULE)

	charge -= output_level

//// Selling defines are here
#define MINIMUM_BAR 1
#define PROCESS_CAP (20 - MINIMUM_BAR)

#define A1_CURVE 20

/obj/machinery/power/transmission_laser/proc/sell_power(joules)
	var/mega_joules = joules / (1 MW)

	var/generated_cash = (2 * mega_joules * PROCESS_CAP) / ((2 * mega_joules) + (PROCESS_CAP * A1_CURVE))
	generated_cash += (4 * mega_joules * MINIMUM_BAR) / (4 * mega_joules + MINIMUM_BAR)
	generated_cash = round(generated_cash)
	if(generated_cash < 0)
		return

	total_energy += mega_joules
	total_earnings += generated_cash
	generated_cash += unsent_earnings
	unsent_earnings = generated_cash

	var/datum/money_account/engineering_bank_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_ENGINEERING)
	var/datum/money_account/cargo_bank_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)

	var/medium_cut = generated_cash * 0.25
	var/high_cut = generated_cash * 0.75

	cargo_bank_account.deposit_credits(medium_cut, "Transmission Laser Payout")
	unsent_earnings -= medium_cut

	engineering_bank_account.deposit_credits(high_cut, "Transmission Laser Payout")
	unsent_earnings -= high_cut

#undef A1_CURVE
#undef PROCESS_CAP
#undef MINIMUM_BAR

// Beam related procs

/obj/machinery/power/transmission_laser/proc/setup_lasers()
	/// This is why we set the range we did
	var/turf/last_step = get_step(get_front_turf(), dir)
	for(var/num = 1 to range + 1)
		var/obj/effect/transmission_beam/new_beam = new(last_step)
		new_beam.host = src
		new_beam.dir = dir
		laser_effects += new_beam

		last_step = get_step(last_step, dir)

/obj/machinery/power/transmission_laser/proc/destroy_lasers()
	for(var/obj/effect/transmission_beam/listed_beam as anything in laser_effects)
		laser_effects -= listed_beam
		qdel(listed_beam)

/// This is called every time something enters our beams
/obj/machinery/power/transmission_laser/proc/atom_entered_beam(obj/effect/transmission_beam/triggered, atom/movable/potential_victim)
	var/mw_power = (output_number * power_format_multi_output) / (1 MW)
	if(!isliving(potential_victim))
		return
	var/mob/living/victim = potential_victim
	switch(mw_power)
		if(0 to 25)
			victim.adjustFireLoss(-mw_power * 15)
			return
		if(26 to 50)
			victim.gib(FALSE)
		else
			explosion(victim, 3, 2, 2)
			victim.gib(FALSE)

// Beam

/obj/effect/transmission_beam
	name = "Shimmering beam"
	icon = 'icons/goonstation/effects/pt_beam.dmi'
	icon_state = "ptl_beam"
	anchored = TRUE

	/// Used to deal with atoms stepping on us while firing
	var/obj/machinery/power/transmission_laser/host

/obj/effect/transmission_beam/Initialize(mapload, obj/machinery/power/transmission_laser/creator)
	. = ..()
	var/turf/source_turf = get_turf(src)
	if(source_turf)
		RegisterSignal(source_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	update_appearance()

/obj/effect/transmission_beam/Destroy(force)
	. = ..()
	var/turf/source_turf = get_turf(src)
	if(source_turf)
		UnregisterSignal(source_turf, COMSIG_ATOM_ENTERED)

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam", src)

/obj/effect/transmission_beam/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	host.atom_entered_beam(src, arrived)

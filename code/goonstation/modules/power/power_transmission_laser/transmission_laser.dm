#define MINIMUM_POWER 1 MW
#define DEFAULT_CAPACITY 2000 GJ

/obj/machinery/power/transmission_laser
	name = "power transmission laser"
	desc = "Sends power over a giant laser beam to an NT power processing facility."

	icon = 'icons/goonstation/objects/pt_laser.dmi'
	icon_state = "ptl"

	max_integrity = 500

	density = TRUE
	anchored = TRUE

	pixel_x = 0
	pixel_y = -64

	// Variables go below here
	/// How far we shoot the beam. If it isn't blocked it should go to the end of the z level.
	var/range = -1
	/// Amount of power we are outputting
	var/output_level = 0
	/// The total capacity of the laser
	var/capacity = DEFAULT_CAPACITY
	/// Our current stored energy
	var/charge = 0
	/// Are we trying to provide power to the laser
	var/input_attempt = TRUE
	/// Are we currently inputting power into the laser
	var/inputting = TRUE
	/// The amount of energy coming in from the inputs last tick
	var/input_available = 0
	/// Have we been switched on?
	var/turned_on = FALSE
	/// Are we attempting to fire the laser currently?
	var/firing = FALSE
	/// We need to create a list of all lasers we are creating so we can delete them in the end
	var/list/laser_effects = list()
	/// Our max load we can set
	var/max_grid_load = 0
	/// The load we place on the power grid we are connected to
	var/current_grid_load = 0
	/// Signifies which unit we are using for output power. Used both in TGUI for formatting purposes and output power calculations.
	var/power_format_multi = 1
	/// Signifies which unit we are using for input power. Used both in TGUI for formatting purposes and input power calculations.
	var/power_format_multi_output = 1 MW

	/// Are we selling the energy or just sending it into the ether
	var/selling_energy = FALSE

	/// How much energy have we sold in total (Joules)
	var/total_energy = 0
	/// How much energy do you have to sell in order to get an announcement
	var/static/announcement_threshold = 1 MJ

	/// How many credits we have earned in total
	var/total_earnings = 0
	/// The amount of money we haven't sent yet
	var/unsent_earnings = 0

	/// Gives our power input when multiplied with power_format_multi. The multiplier signifies the units of power, and this is how many of them we are inputting.
	var/input_number = 0
	/// Gives our power output when multiplied with power_format_multi_output. The multiplier signifies the units of power, and this is how many of them we are outputting.
	var/output_number = 0
	/// Our set input pulling
	var/input_pulling = 0
	/// Announcement configuration for updates
	var/datum/announcer/announcer

/obj/machinery/power/transmission_laser/north
	pixel_x = -64
	pixel_y = 0
	dir = NORTH

/obj/machinery/power/transmission_laser/east
	pixel_x = 0
	pixel_y = 0
	dir = EAST

/obj/machinery/power/transmission_laser/west
	pixel_x = -64
	pixel_y = 0
	dir = WEST

/obj/item/circuitboard/machine/transmission_laser
	board_name = "Power Transmission Laser"
	icon_state = "command"
	build_path = /obj/machinery/power/transmission_laser
	origin_tech = "engineering=2;combat=3;"
	req_components = list(
							/obj/item/stock_parts/capacitor = 3,
							/obj/item/stock_parts/micro_laser = 3)

/obj/machinery/power/transmission_laser/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/transmission_laser
	component_parts += new /obj/item/stock_parts/micro_laser
	component_parts += new /obj/item/stock_parts/micro_laser
	component_parts += new /obj/item/stock_parts/micro_laser
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	announcer = new(config_type = /datum/announcement_configuration/ptl)
	if(!powernet)
		connect_to_network()
	handle_offset()
	update_icon()

/obj/machinery/power/transmission_laser/screwdriver_act(mob/living/user, obj/item/I)
	if(firing)
		to_chat(user,"<span class='info'>Turn the laser off first<span/>")
		return
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return TRUE

/obj/machinery/power/transmission_laser/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/power/transmission_laser/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	if(rotate())
		return TRUE
	to_chat(user,"<span class='info'>Target area blocked, please clear all objects and personnel.<span/>")
	return TRUE

/// Rotates the laser if we have the space to do so.
/obj/machinery/power/transmission_laser/proc/rotate()
	var/new_dir = turn(dir, -90)

	var/x_offset = (new_dir == WEST) ? -2 : 2
	var/y_offset = (new_dir == SOUTH) ? -2 : 2
	var/datum/component/multitile/tiles = GetComponent(/datum/component/multitile)
	// Make sure the area we want to rotate to has enough free tiles
	for(var/turf/tile in block(x, y, z, x + x_offset, y + y_offset))
		if(tile?.density)
			return FALSE
		for(var/atom/thing as anything in tile.contents)
			// If it's the machine or one of its multitile components fillers skip it
			if(thing.UID() == UID() || (istype(thing, /obj/structure/filler/) && (thing in tiles.all_fillers)))
				continue
			if(thing?.density)
				return FALSE

	dir = new_dir
	handle_offset()
	return TRUE

/obj/machinery/power/transmission_laser/proc/handle_offset()
	switch(dir)
		if(NORTH)
			pixel_x = -64
			pixel_y = 0
			AddComponent(/datum/component/multitile, list(
				list(0, 1, 			0,		),
				list(1, 1, 			1,		),
				list(1, 1, 		MACH_CENTER),
			))
		if(SOUTH)
			pixel_x = 0
			pixel_y = -64
			AddComponent(/datum/component/multitile, list(
				list(MACH_CENTER, 	1, 1),
				list(1, 			1, 1),
				list(0, 			1, 0),
			))
		if(WEST)
			pixel_x = -64
			pixel_y = 0
			AddComponent(/datum/component/multitile, list(
				list(0, 1, 			1,		),
				list(1, 1, 			1,		),
				list(0, 1, 		MACH_CENTER),
			))
		if(EAST)
			pixel_x = 0
			pixel_y = 0
			AddComponent(/datum/component/multitile, list(
				list(1,				1, 0),
				list(1,				1, 1),
				list(MACH_CENTER, 	1, 0),
			))

/obj/machinery/power/transmission_laser/Destroy()
	. = ..()
	qdel(announcer)
	blocker = null
	if(length(laser_effects))
		destroy_lasers()

/obj/machinery/power/transmission_laser/proc/get_front_turf()
	//this is weird as i believe byond sets the bottom left corner as the source corner like
	// x-x-x
	// x-x-x
	// o-x-x
	//which would mean finding the true front turf would require centering than taking a step in the primary direction
	var/turf/center = locate(x + 1 + round(pixel_x / 32), y + 1 + round(pixel_y / 32), z)
	return get_step(center, dir)



/obj/machinery/power/transmission_laser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Laser currently has [unsent_earnings] unsent credits.<span/>"
	. += "<span class='notice'>Laser has generated [total_earnings] credits.<span/>"
	. += "<span class='notice'>Laser has sold [total_energy] Joules.<span/>"

/// Appearance changes are here
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

/// Returns the charge level from [0 to 6]
/obj/machinery/power/transmission_laser/proc/return_charge()
	if(!output_level)
		return 0
	return min(round((charge / abs(output_level)) * 6), 6)

/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	// The message we send
	var/message
	if(announcement_threshold == 1 MJ)
		message = "PTL account successfully made!\n \
		From now on, you will receive regular updates on the power exported via the onboard PTL. Good luck [station_name()]!"
		announcement_threshold = 100 MJ
	else
		message = "New milestone reached!\n[DisplayJoules(announcement_threshold)]"

	announcer.Announce(message)

	announcement_threshold = min(announcement_threshold * 5, announcement_threshold + 200 GJ)

/obj/machinery/power/transmission_laser/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/power/transmission_laser/attack_ghost(mob/user)
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
		input_pulling = min(input_available, input_number * power_format_multi)

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

	sell_power(output_level * WATT_TICK_TO_JOULE)

	charge -= output_level

//// Selling defines are here
#define MINIMUM_BAR 1
#define PROCESS_CAP (20 - MINIMUM_BAR)

#define A1_CURVE 20

#define HIGH_CUT_RATIO 0.75
#define MEDIUM_CUT_RATIO 0.25

/obj/machinery/power/transmission_laser/proc/sell_power(joules)
	var/mega_joules = joules / (1 MW)

	var/generated_cash = (2 * mega_joules * PROCESS_CAP) / ((2 * mega_joules) + (PROCESS_CAP * A1_CURVE))
	generated_cash += (4 * mega_joules * MINIMUM_BAR) / (4 * mega_joules + MINIMUM_BAR)
	if(generated_cash < 0)
		return

	total_energy += joules
	total_earnings += generated_cash
	unsent_earnings += generated_cash

	var/datum/money_account/engineering_bank_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_ENGINEERING)
	var/datum/money_account/cargo_bank_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)

	if(unsent_earnings > 200)
		var/medium_cut = round(unsent_earnings * MEDIUM_CUT_RATIO)
		var/high_cut = round(unsent_earnings * HIGH_CUT_RATIO)

		GLOB.station_money_database.credit_account(cargo_bank_account, medium_cut, "Transmission Laser Payout", "Central Command Supply Master", supress_log = FALSE)
		unsent_earnings -= medium_cut

		GLOB.station_money_database.credit_account(engineering_bank_account, high_cut, "Transmission Laser Payout", "Central Command Supply Master", supress_log = FALSE)
		unsent_earnings -= high_cut

#undef A1_CURVE
#undef PROCESS_CAP
#undef MINIMUM_BAR
#undef HIGH_CUT_RATIO
#undef MEDIUM_CUT_RATIO

// Beam related procs

/obj/machinery/power/transmission_laser/proc/setup_lasers()
	if(charge < 1 MW && !inputting) // We don't have enough power to setup the beam and we aren't receiving any.
		return
	var/turf/last_step = get_step(get_front_turf(), dir)
	// Create new lasers from the starting point to either the blocker or the edge of the map
	for(var/num in 1 to range)
		if(!(locate(/obj/effect/transmission_beam) in last_step))
			var/obj/effect/transmission_beam/new_beam = new(last_step, src)
			new_beam.host = src
			new_beam.dir = dir
			laser_effects += new_beam

		last_step = get_step(last_step, dir)

/obj/machinery/power/transmission_laser/proc/destroy_lasers()
	for(var/obj/effect/transmission_beam/listed_beam as anything in laser_effects)
		laser_effects -= listed_beam
		qdel(listed_beam)

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
	update_appearance()

/obj/effect/transmission_beam/Destroy(force)
	. = ..()

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam", src)

/// Explosions aren't supposed to make holes in a beam.
/obj/effect/transmission_beam/ex_act(severity)
	return

#undef MINIMUM_POWER
#undef DEFAULT_CAPACITY

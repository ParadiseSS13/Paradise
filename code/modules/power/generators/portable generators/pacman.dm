#define SHEET_VOLUME 1000 //cm3
#define TEMPERATURE_DIVISOR 40
#define TEMPERATURE_CHANGE_MAX 20

/obj/machinery/power/port_gen/pacman
	name = "\improper P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that runs on solid plasma sheets. Rated for 80 kW max safe output."

	var/sheet_name = "Plasma Sheets"
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/board_path = /obj/item/circuitboard/pacman

	/*
		These values were chosen so that the generator can run safely up to 80 kW
		A full 50 plasma sheet stack should last 20 minutes at power_output = 4
		temperature_gain and max_temperature are set so that the max safe power level is 4.
		Setting to 5 or higher can only be done temporarily before the generator overheats.
	*/
	power_gen = 20000	//Watts output per power_output level
	///The maximum power setting without emagging.
	var/max_power_output = 5
	/// For UI use, maximal output that won't cause overheat.
	var/max_safe_output = 4
	/// fuel efficiency - how long 1 sheet lasts at power level 1
	var/time_per_sheet = 96
	/// max capacity of the hopper
	var/max_sheets = 100
	/// max temperature before overheating increases
	var/max_temperature = 300
	/// how much the temperature increases per power output level, in degrees per level
	var/temperature_gain = 50

	/// How many sheets of material are loaded in the generator
	var/sheets = 0
	/// How much is left of the current sheet
	var/sheet_left = 0
	/// The current temperature
	var/temperature = 0
	/// if this gets high enough the generator explodes
	var/overheating = 0

/obj/machinery/power/port_gen/pacman/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/Destroy()
	drop_fuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/stock_parts/micro_laser) || istype(SP, /obj/item/stock_parts/capacitor))
			temp_rating += SP.rating

	power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	. = ..()
	. += "\The [src] appears to be producing [power_gen*power_output] W."
	. += "There [sheets == 1 ? "is" : "are"] [sheets] sheet\s left in the hopper."
	if(is_broken())
		. += "<span class='warning'>\The [src] seems to have broken down.</span>"
	if(overheating)
		. += "<span class='danger'>\The [src] is overheating!</span>"

/obj/machinery/power/port_gen/pacman/has_fuel()
	var/needed_sheets = power_output / time_per_sheet
	if(sheets >= needed_sheets - sheet_left)
		return TRUE
	return FALSE

//Removes one stack's worth of material from the generator.
/obj/machinery/power/port_gen/pacman/drop_fuel()
	if(!sheets)
		return
	var/obj/item/stack/sheet/mineral/S = new sheet_path(loc)
	var/amount = min(sheets, S.max_amount)
	S.amount = amount
	sheets -= amount

/obj/machinery/power/port_gen/pacman/use_fuel()
	//how much material are we using this iteration?
	var/needed_sheets = power_output / time_per_sheet

	//has_fuel() should guarantee us that there is enough fuel left, so no need to check that
	//the only thing we need to worry about is if we are going to rollover to the next sheet
	if(needed_sheets > sheet_left)
		sheets--
		sheet_left = (1 + sheet_left) - needed_sheets
	else
		sheet_left -= needed_sheets

	//calculate the "target" temperature range
	//This should probably depend on the external temperature somehow, but whatever.
	var/lower_limit = 56 + power_output * temperature_gain
	var/upper_limit = 76 + power_output * temperature_gain

	/*
		Hot or cold environments can affect the equilibrium temperature
		The lower the pressure the less effect it has. I guess it cools using a radiator or something when in vacuum.
		Gives traitors more opportunities to sabotage the generator or allows enterprising engineers to build additional
		cooling in order to get more power out.
	*/
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.get_readonly_air()
	if(environment)
		var/ratio = min(environment.return_pressure() / ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature() - T20C
		lower_limit += ambient * ratio
		upper_limit += ambient * ratio

	var/average = (upper_limit + lower_limit) / 2

	//calculate the temperature increase
	var/bias = 0
	if(temperature < lower_limit)
		bias = min(round((average - temperature) / TEMPERATURE_DIVISOR, 1), TEMPERATURE_CHANGE_MAX)
	else if(temperature > upper_limit)
		bias = max(round((temperature - average) / TEMPERATURE_DIVISOR, 1), -TEMPERATURE_CHANGE_MAX)

	//limit temperature increase so that it cannot raise temperature above upper_limit,
	//or if it is already above upper_limit, limit the increase to 0.
	var/inc_limit = max(upper_limit - temperature, 0)
	var/dec_limit = min(temperature - lower_limit, 0)
	temperature += clamp(rand(-7 + bias, 7 + bias), dec_limit, inc_limit)

	if(temperature > max_temperature)
		overheat()
	else if(overheating > 0)
		overheating--

/obj/machinery/power/port_gen/pacman/handle_inactive()
	var/cooling_temperature = 20
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.get_readonly_air()
	if(environment)
		var/ratio = min(environment.return_pressure()/ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature() - T20C
		cooling_temperature += ambient*ratio

	if(temperature > cooling_temperature)
		var/temp_loss = (temperature - cooling_temperature)/TEMPERATURE_DIVISOR
		temp_loss = clamp(round(temp_loss, 1), 2, TEMPERATURE_CHANGE_MAX)
		temperature = max(temperature - temp_loss, cooling_temperature)
		SStgui.update_uis(src)

	if(overheating)
		overheating--

/obj/machinery/power/port_gen/pacman/proc/overheat()
	overheating++
	if(overheating > 60)
		message_admins("Pacman overheated at [ADMIN_JMP(loc)]. Last touched by: [fingerprintslast ? "[fingerprintslast]" : "*null*"].")
		log_game("Pacman overheated at [COORD(loc)]. Last touched by: [fingerprintslast ? "[fingerprintslast]" : "*null*"].")
		explode()

/obj/machinery/power/port_gen/pacman/explode()
	sheets = 0
	sheet_left = 0
	..()

/obj/machinery/power/port_gen/pacman/emag_act(remaining_charges, mob/user)
	if(active && prob(25))
		explode() //if they're foolish enough to emag while it's running

	if(!emagged)
		emagged = TRUE
		return TRUE

/obj/machinery/power/port_gen/pacman/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, sheet_path))
		var/obj/item/stack/addstack = used
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, "<span class='notice'>[src] is full!</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You add [amount] sheet\s to [src].</span>")
		sheets += amount
		addstack.use(amount)
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/power/port_gen/pacman/crowbar_act(mob/living/user, obj/item/I)
	if(active || !panel_open)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/port_gen/pacman/screwdriver_act(mob/living/user, obj/item/I)
	if(active)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	panel_open = !panel_open
	if(panel_open)
		to_chat(user, "<span class='notice'>You open the access panel.</span>")
	else
		to_chat(user, "<span class='notice'>You close the access panel.</span>")

/obj/machinery/power/port_gen/pacman/wrench_act(mob/living/user, obj/item/I)
	if(active)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	if(!anchored)
		connect_to_network()
		to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
	else
		disconnect_from_network()
		to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
	anchored = !anchored

/obj/machinery/power/port_gen/pacman/attack_hand(mob/user as mob)
	..()
	ui_interact(user)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/power/port_gen/pacman/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/power/port_gen/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/port_gen/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pacman", name)
		ui.open()

/obj/machinery/power/port_gen/pacman/ui_data(mob/user)
	var/list/data = list()

	data["active"] = active
	if(is_ai(user))
		data["is_ai"] = TRUE
	else if(isrobot(user) && !Adjacent(user))
		data["is_ai"] = TRUE
	else
		data["is_ai"] = FALSE

	data["anchored"] = anchored
	data["broken"] = is_broken()
	data["emagged"] = emagged
	data["output_set"] = power_output
	data["output_max"] = max_power_output
	data["output_safe"] = max_safe_output
	data["power_gen"] = power_gen
	data["tmp_current"] = temperature
	data["tmp_max"] = max_temperature
	data["tmp_overheat"] = overheating
	data["fuel_stored"] = round((sheets * SHEET_VOLUME) + (sheet_left * SHEET_VOLUME))
	data["fuel_cap"] = round(max_sheets * SHEET_VOLUME, 0.1)
	data["fuel_usage"] = active ? round((power_output / time_per_sheet) * SHEET_VOLUME) : 0
	data["fuel_type"] = sheet_name
	data["has_fuel"] = has_fuel()

	return data

/obj/machinery/power/port_gen/pacman/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	switch(action)
		if("toggle_power")
			if(!powernet) //only a warning, process will disable
				atom_say("Not connected to powernet.")
			active = !active
			update_icon()
		if("eject_fuel")
			drop_fuel()
		if("change_power")
			var/newPower = text2num(params["change_power"])
			if(newPower)
				power_output = clamp(newPower, 1, (emagged ? round(max_power_output * 2.5) : max_power_output))

/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that utilizes uranium sheets as fuel. Can run for much longer than the standard PACMAN type generators. Rated for 80 kW max safe output."
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	sheet_name = "Uranium Sheets"
	time_per_sheet = 576 //same power output, but a 50 sheet stack will last 2 hours at max safe power
	board_path = /obj/item/circuitboard/pacman/super

/obj/machinery/power/port_gen/pacman/super/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/super/use_fuel()
	//produces a tiny amount of radiation when in use
	if(prob(2 * power_output))
		radiation_pulse(get_turf(src), 200, ALPHA_RAD)
	..()

/obj/machinery/power/port_gen/pacman/super/explode()
	//a nice burst of radiation
	radiation_pulse(get_turf(src), 2000, ALPHA_RAD)
	explosion(loc, 3, 3, 5, 3, cause = "Exploding [name]")
	qdel(src)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	desc = "An advanced power generator that runs on diamonds. Rated for 200 kW maximum safe output!"
	icon_state = "portgen2_0"
	base_icon = "portgen2"
	sheet_path = /obj/item/stack/sheet/mineral/diamond
	sheet_name = "Diamond Sheets"

	//max safe power output (power level = 8) is 200 kW and lasts for 1 hour - 3 or 4 of these could power the station
	power_gen = 25000 //watts
	max_power_output = 10
	max_safe_output = 8
	time_per_sheet = 576
	max_temperature = 800
	temperature_gain = 90
	board_path = /obj/item/circuitboard/pacman/mrs

/obj/machinery/power/port_gen/pacman/mrs/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/mrs/explode()
	//no special effects, but the explosion is pretty big (same as a supermatter shard).
	explosion(loc, 3, 6, 12, 16, 1, cause = "Exploding [name]")
	qdel(src)

#undef SHEET_VOLUME
#undef TEMPERATURE_DIVISOR
#undef TEMPERATURE_CHANGE_MAX

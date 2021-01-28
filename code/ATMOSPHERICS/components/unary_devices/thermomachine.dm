/obj/machinery/atmospherics/unary/thermomachine
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "freezer"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)
	layer = OBJ_LAYER

	///Check if the device should be on or off
	var/on = FALSE

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"
	///actual temperature will be defined by RefreshParts() and by the cooling var
	var/min_temperature = T20C
	//actual temperature will be defined by RefreshParts() and by the cooling var
	var/max_temperature = T20C
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/cooling = TRUE
	var/base_heating = 140
	var/base_cooling = 170

/obj/machinery/atmospherics/unary/thermomachine/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/proc/swap_function()
	cooling = !cooling
	if(cooling)
		icon_state_off = "freezer"
		icon_state_on = "freezer_1"
		icon_state_open = "freezer-o"
	else
		icon_state_off = "heater"
		icon_state_on = "heater_1"
		icon_state_open = "heater-o"
	target_temperature = T20C
	RefreshParts()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/RefreshParts()
	var/calculated_bin_rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2)
	min_temperature = T20C
	max_temperature = T20C
	if(cooling)
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	else
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts

/obj/machinery/atmospherics/unary/thermomachine/update_icon()
	if(panel_open)
		icon_state = icon_state_open
	else if(on)
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/atmospherics/unary/thermomachine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The thermostat is set to [target_temperature]K ([(T0C - target_temperature) * -1]C).</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Efficiency <b>[(heat_capacity / 5000) * 100]%</b>.</span>"
		. += "<span class='notice'>Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C - min_temperature) * -1]C - [(T0C-max_temperature) * -1]C)</b>.</span>"


/obj/machinery/atmospherics/unary/thermomachine/process_atmos()
	..()
	if(!on)
		return 0

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy / combined_heat_capacity

	//todo: have current temperature affected. require power to bring down current temperature again

	var/temperature_delta= abs(old_temperature - air_contents.temperature)
	if(temperature_delta > 1)
		active_power_usage = (heat_capacity * temperature_delta) / 10 + idle_power_usage
		parent.update = 1
	else
		active_power_usage = idle_power_usage
	return 1

/obj/machinery/atmospherics/unary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/atmospherics/unary/thermomachine/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/atmospherics/unary/thermomachine/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
		on = FALSE
		update_icon()
		return TRUE

/obj/machinery/atmospherics/unary/thermomachine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!panel_open)
		to_chat(user, "<span class='notice'>Open the maintenance panel first.</span>")
		return
	var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
	var/selected = input(user,"Select a direction for the connector.", "Connector Direction") in choices
	dir = choices[selected]
	var/node_connect = dir
	initialize_directions = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	build_network()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/unary/thermomachine/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/unary/thermomachine/attack_hand(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	ui_interact(user)

/obj/machinery/atmospherics/unary/thermomachine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ThermoMachine", name, 300, 250)
		ui.open()

/obj/machinery/atmospherics/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["cooling"] = cooling

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	data["temperature"] = air_contents.temperature
	data["pressure"] = air_contents.return_pressure()
	return data

/obj/machinery/atmospherics/unary/thermomachine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)
	switch(action)
		if("power")
			on = !on
			use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
			update_icon()
			. = TRUE
		if("cooling")
			swap_function()
			investigate_log("was changed to [cooling ? "cooling" : "heating"] by [key_name(usr)]", "atmos")
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature] - [max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", "atmos")

/obj/machinery/atmospherics/unary/thermomachine/freezer
	icon_state = "freezer"
	icon_state_off = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	cooling = TRUE

/obj/machinery/atmospherics/unary/thermomachine/freezer/on
	on = TRUE
	icon_state = "freezer_1"

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/New()
	..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/coldroom/New()
	..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/server
	name = "Server room temperature control unit"

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/server/New()
	..()
	target_temperature = SERVER_ROOM_TEMP

/obj/machinery/atmospherics/unary/thermomachine/heater
	icon_state = "heater"
	icon_state_off = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	cooling = FALSE

/obj/machinery/atmospherics/unary/thermomachine/heater/on
	on = TRUE
	icon_state = "heater_1"

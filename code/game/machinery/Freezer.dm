/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "freezer"
	density = 1
	var/min_temperature = 0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	current_heat_capacity = 1000
	layer = 3
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100)

/obj/machinery/atmospherics/unary/cold_sink/freezer/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cold_sink/freezer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cold_sink/freezer/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	min_temperature = max(0,T0C - (170 + (T*15)))
	current_heat_capacity = 1000 * ((H - 1) ** 2)

/obj/machinery/atmospherics/unary/cold_sink/freezer/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "freezer-o", "freezer", I))
		on = 0
		update_icon()
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(iswrench(I))
		if(!panel_open)
			to_chat(user, "<span class='notice'>Open the maintenance panel first.</span>")
			return
		var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
		var/selected = input(user,"Select a direction for the connector.", "Connector Direction") in choices
		dir = choices[selected]
		playsound(src.loc, I.usesound, 50, 1)
		var/node_connect = dir
		initialize_directions = dir
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break
		build_network()
		update_icon()
	else
		return ..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon()
	if(panel_open)
		icon_state = "freezer-o"
	else if(src.on)
		icon_state = "freezer_1"
	else
		icon_state = "freezer"
	return

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_ghost(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_hand(mob/user as mob)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	src.ui_interact(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "freezer.tmpl", "Gas Cooling System", 540, 300)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["on"] = on ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["gasTemperatureCelsius"] = round(air_contents.temperature - T0C,1)
	if(air_contents.total_moles() == 0 && air_contents.temperature == 0)
		data["gasTemperatureCelsius"] = 0
	data["minGasTemperature"] = round(min_temperature)
	data["maxGasTemperature"] = round(T20C)
	data["targetGasTemperature"] = round(current_temperature)
	data["targetGasTemperatureCelsius"] = round(current_temperature - T0C,1)

	var/temp_class = "good"
	if(air_contents.temperature > (T0C - 20))
		temp_class = "bad"
	else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
		temp_class = "average"
	data["gasTemperatureClass"] = temp_class
	return data

/obj/machinery/atmospherics/unary/cold_sink/freezer/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["toggleStatus"])
		src.on = !src.on
		update_icon()
	else if(href_list["minimum"])
		current_temperature = min_temperature
	else if(href_list["maximum"])
		current_temperature = T20C
	else if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.current_temperature = min(T20C, src.current_temperature+amount)
		else
			src.current_temperature = max(min_temperature, src.current_temperature+amount)
	src.add_fingerprint(usr)
	return 1

/obj/machinery/atmospherics/unary/cold_sink/freezer/power_change()
	..()
	if(stat & NOPOWER)
		on = 0
		update_icon()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/
	name = "heater"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "heater"
	density = 1
	var/max_temperature = 0
	anchored = 1.0
	layer = 3
	current_heat_capacity = 1000
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/New()
	..()
	initialize_directions = dir
	var/obj/item/circuitboard/thermomachine/H = new /obj/item/circuitboard/thermomachine(null)
	H.build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
	H.name = "circuit board (Heater)"
	component_parts = list()
	component_parts += H
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/upgraded/New()
	..()
	var/obj/item/circuitboard/thermomachine/H = new /obj/item/circuitboard/thermomachine(null)
	H.build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
	H.name = "circuit board (Heater)"
	component_parts = list()
	component_parts += H
	component_parts += new /obj/item/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	max_temperature = T20C + (140 * T)
	current_heat_capacity = 1000 * ((H - 1) ** 2)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "heater-o", "heater", I))
		on = 0
		update_icon()
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(iswrench(I))
		if(!panel_open)
			to_chat(user, "<span class='notice'>Open the maintenance panel first.</span>")
			return
		var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
		var/selected = input(user,"Select a direction for the connector.", "Connector Direction") in choices
		dir = choices[selected]
		playsound(src.loc, I.usesound, 50, 1)
		var/node_connect = dir
		initialize_directions = dir
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break
		build_network()
		update_icon()
	else
		return ..()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/update_icon()
	if(panel_open)
		icon_state = "heater-o"
	else if(src.on)
		icon_state = "heater_1"
	else
		icon_state = "heater"
	return

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_ghost(mob/user as mob)
	src.attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_hand(mob/user as mob)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	src.ui_interact(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "freezer.tmpl", "Gas Heating System", 540, 300)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["on"] = on ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["gasTemperatureCelsius"] = round(air_contents.temperature - T0C,1)
	if(air_contents.total_moles() == 0 && air_contents.temperature == 0)
		data["gasTemperatureCelsius"] = 0
	data["minGasTemperature"] = round(T20C)
	data["maxGasTemperature"] = round(T20C+max_temperature)
	data["targetGasTemperature"] = round(current_temperature)
	data["targetGasTemperatureCelsius"] = round(current_temperature - T0C,1)

	var/temp_class = "normal"
	if(air_contents.temperature > (T20C+40))
		temp_class = "bad"
	data["gasTemperatureClass"] = temp_class
	return data

/obj/machinery/atmospherics/unary/heat_reservoir/heater/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["toggleStatus"])
		src.on = !src.on
		update_icon()
	else if(href_list["minimum"])
		current_temperature = T20C
	else if(href_list["maximum"])
		current_temperature = max_temperature + T20C
	else if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.current_temperature = min((T20C+max_temperature), src.current_temperature+amount)
		else
			src.current_temperature = max(T20C, src.current_temperature+amount)
	src.add_fingerprint(usr)
	return 1

/obj/machinery/atmospherics/unary/heat_reservoir/heater/power_change()
	..()
	if(stat & NOPOWER)
		on = 0
		update_icon()

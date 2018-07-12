/obj/machinery/atmospherics/trinary/filter
	icon = 'icons/atmos/filter.dmi'
	icon_state = "map"

	can_unwrench = 1

	name = "gas filter"

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
-1: Nothing
 0: Toxins: Toxins, Oxygen Agent B
 1: Oxygen: Oxygen ONLY
 2: Nitrogen: Nitrogen ONLY
 3: Carbon Dioxide: Carbon Dioxide ONLY
 4: Sleeping Agent (N2O)
*/

	var/frequency = 0
	var/datum/radio_frequency/radio_connection


/obj/machinery/atmospherics/trinary/filter/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/trinary/filter/flipped
	icon_state = "mmap"
	flipped = 1

/obj/machinery/atmospherics/trinary/filter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = 0

/obj/machinery/atmospherics/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process_atmos()
	..()
	if(!on)
		return 0

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure || air2.return_pressure() >= target_pressure )
		//No need to mix if target is already full!
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature > 0)
		transfer_moles = pressure_delta*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature

		switch(filter_type)
			if(0) //removing hydrocarbons
				filtered_out.toxins = removed.toxins
				removed.toxins = 0

				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			if(1) //removing O2
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0

			if(2) //removing N2
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0

			if(3) //removing CO2
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0

			if(4)//removing N2O
				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/sleeping_agent))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

			else
				filtered_out = null


		air2.merge(filtered_out)
		air3.merge(removed)

	parent2.update = 1

	parent3.update = 1

	parent1.update = 1

	return 1

/obj/machinery/atmospherics/trinary/filter/atmos_init()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/trinary/filter/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/filter/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/filter/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, var/master_ui = null, var/datum/topic_state/state = default_state)
	user.set_machine(src)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_filter.tmpl", name, 475, 155, state = state)
		ui.open()

/obj/machinery/atmospherics/trinary/filter/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	data["filter_type"] = filter_type
	return data

/obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return 1

	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
		. = TRUE
	if(href_list["pressure"])
		var/pressure = href_list["pressure"]
		if(pressure == "max")
			pressure = MAX_OUTPUT_PRESSURE
			. = TRUE
		else if(pressure == "input")
			pressure = input("New output pressure (0-[MAX_OUTPUT_PRESSURE] kPa):", name, target_pressure) as num|null
			if(!isnull(pressure) && !..())
				. = TRUE
		else if(text2num(pressure) != null)
			pressure = text2num(pressure)
			. = TRUE
		if(.)
			target_pressure = Clamp(pressure, 0, MAX_OUTPUT_PRESSURE)
			investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")
	if(href_list["filter"])
		filter_type = text2num(href_list["filter"])
		investigate_log("was set to filter [filter_type] by [key_name(usr)]", "atmos")
		. = TRUE

	update_icon()
	SSnanoui.update_uis(src)
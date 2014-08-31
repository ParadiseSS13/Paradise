//--------------------------------------------
// Gas filter - omni variant
//--------------------------------------------
/obj/machinery/atmospherics/omni/filter
	name = "omni gas filter"
	icon_state = "map_filter"

	var/list/filters = new()
	var/datum/omni_port/input
	var/datum/omni_port/output

/obj/machinery/atmospherics/omni/filter/Del()
	input = null
	output = null
	filters.Cut()
	..()

/obj/machinery/atmospherics/omni/filter/sort_ports()
	for(var/datum/omni_port/P in ports)
		if(P.update)
			if(output == P)
				output = null
			if(input == P)
				input = null
			if(filters.Find(P))
				filters -= P

			P.air.volume = 200
			switch(P.mode)
				if(ATM_INPUT)
					input = P
				if(ATM_OUTPUT)
					output = P
				if(ATM_O2 to ATM_N2O)
					filters += P

/obj/machinery/atmospherics/omni/filter/error_check()
	if(!input || !output || !filters)
		return 1
	if(filters.len < 1 || filters.len > 2) //requires 1 or 2 filters ~otherwise why are you using a filter?
		return 1

	return 0

/obj/machinery/atmospherics/omni/filter/process()
	..()
	if(!on)
		return 0
	
	if(!input || !output)
		return

	var/datum/gas_mixture/output_air = output.air	//BYOND doesn't like referencing "output.air.return_pressure()" so we need to make a direct reference
	var/datum/gas_mixture/input_air = input.air		// it's completely happy with them if they're in a loop though i.e. "P.air.return_pressure()"... *shrug*

	var/output_pressure = output_air.return_pressure()
	
	if(output_pressure >= target_pressure)
		return
	for(var/datum/omni_port/P in filters)
		if(P.air.return_pressure() >= target_pressure)
			return

	var/pressure_delta = target_pressure - output_pressure

	if(input_air.return_temperature() > 0)
		input.transfer_moles = pressure_delta * output_air.volume / (input_air.return_temperature() * R_IDEAL_GAS_EQUATION)

	if(input.transfer_moles > 0)
		var/datum/gas_mixture/removed = input_air.remove(input.transfer_moles)
		
		if(!removed)
			return
		
		for(var/datum/omni_port/P in filters)
			var/datum/gas_mixture/filtered_out = new
			filtered_out.temperature = removed.return_temperature()
			
			switch(P.mode)
				if(ATM_O2)
					filtered_out.oxygen = removed.oxygen
					removed.oxygen = 0
				if(ATM_N2)
					filtered_out.nitrogen = removed.nitrogen
					removed.nitrogen = 0
				if(ATM_CO2)
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0
				if(ATM_P)
					filtered_out.phoron = removed.phoron
					removed.phoron = 0
				if(ATM_N2O)
					if(removed.trace_gases.len>0)
						for(var/datum/gas/sleeping_agent/trace_gas in removed.trace_gases)
							if(istype(trace_gas))
								removed.trace_gases -= trace_gas
								filtered_out.trace_gases += trace_gas
				else
					filtered_out = null
			
			P.air.merge(filtered_out)
			if(P.network)
				P.network.update = 1
		
		output_air.merge(removed)
		if(output.network)
			output.network.update = 1
		
		input.transfer_moles = 0
		if(input.network)
			input.network.update = 1

	return

/obj/machinery/atmospherics/omni/filter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	usr.set_machine(src)

	var/list/data = new()

	data = build_uidata()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "omni_filter.tmpl", "Omni Filter Control", 330, 330)
		ui.set_initial_data(data)

		ui.open()

/obj/machinery/atmospherics/omni/filter/proc/build_uidata()
	var/list/data = new()

	data["power"] = on
	data["config"] = configuring

	var/portData[0]
	for(var/datum/omni_port/P in ports)
		if(!configuring && P.mode == 0)
			continue

		var/input = 0
		var/output = 0
		var/filter = 1
		var/f_type = null
		switch(P.mode)
			if(ATM_INPUT)
				input = 1
				filter = 0
			if(ATM_OUTPUT)
				output = 1
				filter = 0
			if(ATM_O2 to ATM_N2O)
				f_type = mode_send_switch(P.mode)

		portData[++portData.len] = list("dir" = dir_name(P.dir, capitalize = 1), \
										"input" = input, \
										"output" = output, \
										"filter" = filter, \
										"f_type" = f_type)

	if(portData.len)
		data["ports"] = portData
	if(output)
		data["pressure"] = target_pressure

	return data

/obj/machinery/atmospherics/omni/filter/proc/mode_send_switch(var/mode = ATM_NONE)
	switch(mode)
		if(ATM_O2)
			return "Oxygen"
		if(ATM_N2)
			return "Nitrogen"
		if(ATM_CO2)
			return "Carbon Dioxide"
		if(ATM_P)
			return "Phoron" //*cough* Plasma *cough*
		if(ATM_N2O)
			return "Nitrous Oxide"
		else
			return null

/obj/machinery/atmospherics/omni/filter/Topic(href, href_list)
	if(..()) return
	switch(href_list["command"])
		if("power")
			if(!configuring)
				on = !on
			else
				on = 0
		if("configure")
			configuring = !configuring
			if(configuring)
				on = 0

	//only allows config changes when in configuring mode ~otherwise you'll get weird pressure stuff going on
	if(configuring && !on)
		switch(href_list["command"])
			if("set_pressure")
				var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",target_pressure) as num
				target_pressure = between(0, new_pressure, 4500)
			if("switch_mode")
				switch_mode(dir_flag(href_list["dir"]), mode_return_switch(href_list["mode"]))
			if("switch_filter")
				var/new_filter = input(usr,"Select filter mode:","Change filter",href_list["mode"]) in list("None", "Oxygen", "Nitrogen", "Carbon Dioxide", "Phoron", "Nitrous Oxide")
				switch_filter(dir_flag(href_list["dir"]), mode_return_switch(new_filter))

	update_icon()
	nanomanager.update_uis(src)
	return

/obj/machinery/atmospherics/omni/filter/proc/mode_return_switch(var/mode)
	switch(mode)
		if("Oxygen")
			return ATM_O2
		if("Nitrogen")
			return ATM_N2
		if("Carbon Dioxide")
			return ATM_CO2
		if("Phoron")
			return ATM_P
		if("Nitrous Oxide")
			return ATM_N2O
		if("in")
			return ATM_INPUT
		if("out")
			return ATM_OUTPUT
		if("None")
			return ATM_NONE
		else
			return null

/obj/machinery/atmospherics/omni/filter/proc/switch_filter(var/dir, var/mode)
	//check they aren't trying to disable the input or output ~this can only happen if they hack the cached tmpl file
	for(var/datum/omni_port/P in ports)
		if(P.dir == dir)
			if(P.mode == ATM_INPUT || P.mode == ATM_OUTPUT)
				return

	switch_mode(dir, mode)

/obj/machinery/atmospherics/omni/filter/proc/switch_mode(var/port, var/mode)
	if(mode == null || !port)
		return
	var/datum/omni_port/target_port = null
	var/list/other_ports = new()

	for(var/datum/omni_port/P in ports)
		if(P.dir == port)
			target_port = P
		else
			other_ports += P

	var/previous_mode = null
	if(target_port)
		previous_mode = target_port.mode
		target_port.mode = mode
		if(target_port.mode != previous_mode)
			handle_port_change(target_port)
		else
			return
	else
		return

	for(var/datum/omni_port/P in other_ports)
		if(P.mode == mode)
			var/old_mode = P.mode
			P.mode = previous_mode
			if(P.mode != old_mode)
				handle_port_change(P)

	update_ports()

/obj/machinery/atmospherics/omni/filter/proc/handle_port_change(var/datum/omni_port/P)
	switch(P.mode)
		if(ATM_NONE)
			initialize_directions &= ~P.dir
			P.disconnect()
		else
			initialize_directions |= P.dir
			P.connect()
	P.update = 1
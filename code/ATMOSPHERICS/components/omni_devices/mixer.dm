//--------------------------------------------
// Gas mixer - omni variant
//--------------------------------------------
/obj/machinery/atmospherics/omni/mixer
	name = "omni gas mixer"
	icon_state = "map_mixer"

	var/list/inputs = new()
	var/datum/omni_port/output

	//setup tags for initial concentration values (must be decimal)
	var/tag_north_con
	var/tag_south_con
	var/tag_east_con
	var/tag_west_con

/obj/machinery/atmospherics/omni/mixer/New()
	..()
	if(mapper_set())
		var/con = 0
		for(var/datum/omni_port/P in ports)
			switch(P.dir)
				if(NORTH)
					if(tag_north_con && tag_north == 1)
						P.concentration = tag_north_con
						con += max(0, tag_north_con)
				if(SOUTH)
					if(tag_south_con && tag_south == 1)
						P.concentration = tag_south_con
						con += max(0, tag_south_con)
				if(EAST)
					if(tag_east_con && tag_east == 1)
						P.concentration = tag_east_con
						con += max(0, tag_east_con)
				if(WEST)
					if(tag_west_con && tag_west == 1)
						P.concentration = tag_west_con
						con += max(0, tag_west_con)

		//mappers who are bad at maths will be punished (total concentration must be 100%)
		if(con != 1)
			tag_north_con = null
			tag_south_con = null
			tag_east_con = null
			tag_west_con = null

/obj/machinery/atmospherics/omni/mixer/Destroy()
	inputs.Cut()
	output = null
	return ..()

/obj/machinery/atmospherics/omni/mixer/sort_ports()
	for(var/datum/omni_port/P in ports)
		if(P.update)
			if(output == P)
				output = null
			if(inputs.Find(P))
				inputs -= P

			P.air.volume = 200
			switch(P.mode)
				if(ATM_INPUT)
					inputs += P
				if(ATM_OUTPUT)
					output = P

	if(!mapper_set())
		for(var/datum/omni_port/P in inputs)
			P.concentration = 1 / max(1, inputs.len)

	if(output)
		output.air.volume *= 0.75 * inputs.len
		output.concentration = 1

/obj/machinery/atmospherics/omni/mixer/proc/mapper_set()
	return (tag_north_con || tag_south_con || tag_east_con || tag_west_con)

/obj/machinery/atmospherics/omni/mixer/error_check()
	if(!output || !inputs)
		return 1
	if(inputs.len < 2 || inputs.len > 3) //requires 2 or 3 inputs ~otherwise why are you using a mixer?
		return 1

	return 0

/obj/machinery/atmospherics/omni/mixer/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/output_air = output.air
	var/output_pressure = output_air.return_pressure()


	if(output_pressure >= target_pressure * 0.999)
		//No need to mix if target is already full! - 0.1% margin of error so we minimize processing minor gas volumes
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_pressure

	for(var/datum/omni_port/P in inputs)
		if(P.air.return_temperature() > 0)
			P.transfer_moles = (P.concentration * pressure_delta) * output_air.return_volume() / (P.air.return_temperature() * R_IDEAL_GAS_EQUATION)

	var/ratio_check = null

	for(var/datum/omni_port/P in inputs)
		if(!P.transfer_moles)
			return 1
		if(P.air.total_moles() < P.transfer_moles)
			ratio_check = 1
			continue

	if(ratio_check)
		var/list/ratio_list = new()
		for(var/datum/omni_port/P in inputs)
			ratio_list.Add(P.air.total_moles() / P.transfer_moles)

		var/ratio = min(ratio_list)

		for(var/datum/omni_port/P in inputs)
			P.transfer_moles *= ratio

	for(var/datum/omni_port/P in inputs)
		if(P.transfer_moles > 0)
			output_air.merge(P.air.remove(P.transfer_moles))
			P.parent.update = 1
			P.transfer_moles = 0

	output.parent.update = 1

	return 1

/obj/machinery/atmospherics/omni/mixer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, force_open = 0)
	usr.set_machine(src)

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "omni_mixer.tmpl", "Omni Mixer Control", 360, 330)
		ui.open()

/obj/machinery/atmospherics/omni/mixer/ui_data(mob/user, datum/topic_state/state)
	var/data[0]

	data["power"] = on
	data["config"] = configuring

	var/portData[0]
	for(var/datum/omni_port/P in ports)
		if(!configuring && P.mode == 0)
			continue

		var/input = 0
		var/output = 0
		switch(P.mode)
			if(ATM_INPUT)
				input = 1
			if(ATM_OUTPUT)
				output = 1

		portData[++portData.len] = list("dir" = dir_name(P.dir, capitalize = 1), \
										"concentration" = P.concentration, \
										"input" = input, \
										"output" = output, \
										"con_lock" = P.con_lock)

	if(portData.len)
		data["ports"] = portData
	if(output)
		data["pressure"] = target_pressure

	return data

/obj/machinery/atmospherics/omni/mixer/Topic(href, href_list)
	if(..())
		return 1

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
				switch_mode(dir_flag(href_list["dir"]), href_list["mode"])
			if("switch_con")
				change_concentration(dir_flag(href_list["dir"]))
			if("switch_conlock")
				con_lock(dir_flag(href_list["dir"]))

	update_icon()
	SSnanoui.update_uis(src)
	return

/obj/machinery/atmospherics/omni/mixer/proc/switch_mode(var/port = NORTH, var/mode = ATM_NONE)
	if(mode != ATM_INPUT && mode != ATM_OUTPUT)
		switch(mode)
			if("in")
				mode = ATM_INPUT
			if("out")
				mode = ATM_OUTPUT
			else
				mode = ATM_NONE

	for(var/datum/omni_port/P in ports)
		var/old_mode = P.mode
		if(P.dir == port)
			switch(mode)
				if(ATM_INPUT)
					if(P.mode == ATM_OUTPUT)
						return
					P.mode = mode
				if(ATM_OUTPUT)
					P.mode = mode
				if(ATM_NONE)
					if(P.mode == ATM_OUTPUT)
						return
					if(P.mode == ATM_INPUT && inputs.len > 2)
						P.mode = mode
		else if(P.mode == ATM_OUTPUT && mode == ATM_OUTPUT)
			P.mode = ATM_INPUT
		if(P.mode != old_mode)
			switch(P.mode)
				if(ATM_NONE)
					initialize_directions &= ~P.dir
					P.disconnect()
				else
					initialize_directions |= P.dir
					P.connect()
			P.update = 1

	update_ports()

/obj/machinery/atmospherics/omni/mixer/proc/change_concentration(var/port = NORTH)
	tag_north_con = null
	tag_south_con = null
	tag_east_con = null
	tag_west_con = null

	var/old_con = 0
	var/non_locked = 0
	var/remain_con = 1

	for(var/datum/omni_port/P in inputs)
		if(P.dir == port)
			old_con = P.concentration
		else if(!P.con_lock)
			non_locked++
		else
			remain_con -= P.concentration

	//return if no adjustable ports
	if(non_locked < 1)
		return

	var/new_con = (input(usr,"Enter a new concentration (0-[round(remain_con * 100, 0.5)])%","Concentration control", min(remain_con, old_con)*100) as num) / 100

	//cap it between 0 and the max remaining concentration
	new_con = between(0, new_con, remain_con)

	//new_con = min(remain_con, new_con)

	//clamp remaining concentration so we don't go into negatives
	remain_con = max(0, remain_con - new_con)

	//distribute remaining concentration between unlocked ports evenly
	remain_con /= max(1, non_locked)

	for(var/datum/omni_port/P in inputs)
		if(P.dir == port)
			P.concentration = new_con
		else if(!P.con_lock)
			P.concentration = remain_con

/obj/machinery/atmospherics/omni/mixer/proc/con_lock(var/port = NORTH)
	for(var/datum/omni_port/P in inputs)
		if(P.dir == port)
			P.con_lock = !P.con_lock

/obj/machinery/atmospherics/trinary/mixer
	icon = 'icons/atmos/mixer.dmi'
	icon_state = "map"

	can_unwrench = TRUE

	name = "gas mixer"

	target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

// So we can CtrlClick without triggering the anchored message.
/obj/machinery/atmospherics/trinary/mixer/can_be_pulled(user, grab_state, force, show_message)
	return FALSE

/obj/machinery/atmospherics/trinary/mixer/CtrlClick(mob/living/user)
	if(can_use_shortcut(user))
		toggle(user)
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return ..()

/obj/machinery/atmospherics/trinary/mixer/AICtrlClick(mob/living/silicon/user)
	toggle(user)
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/mixer/AltClick(mob/living/user)
	if(can_use_shortcut(user))
		set_max(user)
		investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/mixer/AIAltClick(mob/living/silicon/user)
	set_max(user)
	investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/mixer/flipped
	icon_state = "mmap"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/mixer/update_icon_state()
	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!has_power())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = FALSE

/obj/machinery/atmospherics/trinary/mixer/update_underlays()
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

/obj/machinery/atmospherics/trinary/mixer/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/trinary/mixer/New()
	..()
	air3.volume = 300

/obj/machinery/atmospherics/trinary/mixer/process_atmos()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return FALSE

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure)
		//No need to mix if target is already full!
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles1 = 0
	var/transfer_moles2 = 0

	if(air1.temperature() > 0)
		transfer_moles1 = (node1_concentration*pressure_delta)*air3.volume/(air1.temperature() * R_IDEAL_GAS_EQUATION)

	if(air2.temperature() > 0)
		transfer_moles2 = (node2_concentration*pressure_delta)*air3.volume/(air2.temperature() * R_IDEAL_GAS_EQUATION)

	var/air1_moles = air1.total_moles()
	var/air2_moles = air2.total_moles()

	if((air1_moles < transfer_moles1) || (air2_moles < transfer_moles2))
		if(!transfer_moles1 || !transfer_moles2) return
		var/ratio = min(air1_moles/transfer_moles1, air2_moles/transfer_moles2)

		transfer_moles1 *= ratio
		transfer_moles2 *= ratio

	//Actually transfer the gas

	if(transfer_moles1 > 0)
		var/datum/gas_mixture/removed1 = air1.remove(transfer_moles1)
		air3.merge(removed1)

	if(transfer_moles2 > 0)
		var/datum/gas_mixture/removed2 = air2.remove(transfer_moles2)
		air3.merge(removed2)

	if(transfer_moles1)
		parent1.update = 1

	if(transfer_moles2)
		parent2.update = 1

	parent3.update = 1

	return 1

/obj/machinery/atmospherics/trinary/mixer/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/mixer/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/mixer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/trinary/mixer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosMixer", name)
		ui.open()

/obj/machinery/atmospherics/trinary/mixer/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"pressure" = round(target_pressure, 0.01),
		"max_pressure" = MAX_OUTPUT_PRESSURE,
		"node1_concentration" = round(node1_concentration * 100),
		"node2_concentration" = round(node2_concentration * 100)
	)
	return data



/obj/machinery/atmospherics/trinary/mixer/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("set_node")
			if(params["node_name"] == "Node 1")
				node1_concentration = clamp(round(text2num(params["concentration"]), 0.01), 0, 1)
				node2_concentration = round(1 - node1_concentration, 0.01)
				investigate_log("was set to [node1_concentration] % on node 1 by [key_name(usr)]", INVESTIGATE_ATMOS)
				return TRUE
			else
				node2_concentration = clamp(round(text2num(params["concentration"]), 0.01), 0, 1)
				node1_concentration = round(1 - node2_concentration, 0.01)
				investigate_log("was set to [node2_concentration] % on node 2 by [key_name(usr)]", INVESTIGATE_ATMOS)
				return TRUE

		if("max_pressure")
			target_pressure = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_pressure")
			target_pressure = 0
			. = TRUE

		if("custom_pressure")
			target_pressure = clamp(text2num(params["pressure"]), 0, MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/mixer/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

	return ..()

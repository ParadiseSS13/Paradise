/obj/machinery/computer/mecha
	name = "exosuit control console"
	icon_keyboard = "rd_key"
	icon_screen = "mecha"
	light_color = LIGHT_COLOR_FADEDPURPLE
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/mecha_control
	var/list/located = list()
	var/stored_data = list()

/obj/machinery/computer/mecha/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/mecha/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/mecha/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/mecha/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaControlConsole", name)
		ui.open()

/obj/machinery/computer/mecha/ui_data(mob/user)
	var/list/data = list()
	data["beacons"] = list()
	var/list/trackerlist = list()
	for(var/stompy in GLOB.mechas_list)
		var/obj/mecha/MC = stompy
		trackerlist += MC.trackers
	for(var/thing in trackerlist)
		var/obj/item/mecha_parts/mecha_tracking/TR = thing
		var/list/tr_data = TR.retrieve_data()
		if(tr_data)
			data["beacons"] += list(tr_data)

	data["stored_data"] = stored_data

	return data


/obj/machinery/computer/mecha/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("send_message")
			var/obj/item/mecha_parts/mecha_tracking/MT = locateUID(params["mt"])
			if(istype(MT))
				var/message = strip_html_simple(input(usr, "Input message", "Transmit message") as text)
				if(!message || !trim(message) || ..())
					return FALSE
				var/obj/mecha/M = MT.in_mecha()
				if(M)
					M.occupant_message(message)
				return TRUE
		if("shock")
			var/obj/item/mecha_parts/mecha_tracking/MT = locateUID(params["mt"])
			if(!istype(MT))
				return
			// Is it sabotaged already?
			var/error_message = MT.shock()
			if(error_message)
				atom_say(error_message)
				return FALSE
			return TRUE
		if("get_log")
			var/obj/item/mecha_parts/mecha_tracking/MT = locateUID(params["mt"])
			if(istype(MT))
				stored_data = MT.get_mecha_log()
				return TRUE
		if("clear_log")
			stored_data = list()
			return TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=2;magnets=2"
	var/ai_beacon = FALSE //If this beacon allows for AI control. Exists to avoid using istype() on checking.
	var/charges_left = 2

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!in_mecha())
		return FALSE
	var/obj/mecha/M = loc
	var/list/answer[0]
	answer["reference"] = "\ref[src]"
	answer["name"] = sanitize(replacetext(M.name,"\"","'")) // Double apostrophes break JSON
	if(M.cell)
		answer["cell"] = 1
		answer["cell_capacity"] = M.cell.maxcharge
		answer["cell_current"] = M.get_charge()
		answer["cell_percentage"] = round(M.cell.percent())
	else
		answer["cell"] = 0
	answer["integrity"] = round((M.obj_integrity/M.max_integrity*100), 0.01)
	answer["airtank"] = M.internal_tank.return_pressure()
	answer["pilot"] = "[M.occupant||"None"]"
	var/area/area = get_area(M)
	answer["location"] = "[sanitize(area.name)||"Unknown"]"
	answer["equipment"] = "[M.selected||"None"]"
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer["hascargo"] = 1
		answer["cargo"] = length(RM.cargo) / RM.cargo_capacity * 100

	return answer

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info_text()
	if(!in_mecha())
		return FALSE
	var/obj/mecha/M = loc
	var/cell_charge = M.get_charge()
	var/area/A = get_area(M)
	var/answer = {"<b>Name:</b> [M.name]
						<b>Integrity:</b> [M.obj_integrity / M.max_integrity * 100]%
						<b>Cell charge:</b> [isnull(cell_charge)?"Not found":"[M.cell.percent()]%"]
						<b>Airtank:</b> [M.internal_tank.return_pressure()]kPa
						<b>Pilot:</b> [M.occupant||"None"]
						<b>Location:</b> [sanitize(A.name)||"Unknown"]
						<b>Active equipment:</b> [M.selected||"None"]<br>"}
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer += "<b>Used cargo space:</b> [length(RM.cargo) / RM.cargo_capacity * 100]%<br>"

	return answer

/obj/item/mecha_parts/mecha_tracking/proc/retrieve_data()
	var/list/data = list()
	if(!in_mecha())
		return FALSE
	var/obj/mecha/M = loc
	data["uid"] = UID()
	data["charge"] = M.get_charge()
	data["name"] = M.name
	data["health"] = M.obj_integrity
	data["maxHealth"] = M.max_integrity
	data["cell"] = M.cell
	if(M.cell)
		data["cellCharge"] = M.cell.charge
		data["cellMaxCharge"] = M.cell.maxcharge
	data["airtank"] = M.internal_tank.return_pressure()
	data["pilot"] = M.occupant
	data["location"] = get_area(M)
	data["active"] = M.selected
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		data["cargoUsed"] = length(RM.cargo)
		data["cargoMax"] = RM.cargo_capacity
	return data

/obj/item/mecha_parts/mecha_tracking/emp_act()
	qdel(src)

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(ismecha(loc))
		return loc
	return FALSE

// Makes the user lose control over the exosuit's coordination system.
// They can still move around and use tools, they just cannot tell the exosuit which way to go.
/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/mech = in_mecha()
	var/error_message

	if(!mech)
		error_message = "This tracking beacon is no longer in an exosuit."
		return error_message

	if(mech.internal_damage & MECHA_INT_CONTROL_LOST)
		error_message = "The exosuit's coordination system is not responding."
		return error_message

	mech.setInternalDamage(MECHA_INT_CONTROL_LOST)
	if(mech.occupant)
		mech.occupant_message("<span class='danger'>Coordination system calibration failure. Manual restart required.</span>")
		SEND_SOUND(mech.occupant, sound('sound/machines/warning-buzzer.ogg'))

	do_sparks(3, FALSE, mech.loc)
	var/obj/effect/temp_visual/emp/sabotage_overlay = new(mech.loc)
	sabotage_overlay.layer = ABOVE_ALL_MOB_LAYER
	charges_left--
	if(charges_left < 1)
		qdel(src)

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_log()
	if(!in_mecha())
		return list()
	var/obj/mecha/M = loc
	return M.get_log_tgui()

/obj/item/mecha_parts/mecha_tracking/ai_control
	name = "exosuit AI control beacon"
	desc = "A device used to transmit exosuit data. Also allows active AI units to take control of said exosuit."
	origin_tech = "programming=3;magnets=2;engineering=2"
	ai_beacon = TRUE

/obj/item/storage/box/mechabeacons
	name = "exosuit tracking beacons"

/obj/item/storage/box/mechabeacons/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/mecha_parts/mecha_tracking(src)

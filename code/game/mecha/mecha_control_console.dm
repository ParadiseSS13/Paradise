/obj/machinery/computer/mecha
	name = "exosuit control console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "mecha"
	light_color = LIGHT_COLOR_FADEDPURPLE
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data = list()

/obj/machinery/computer/mecha/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/mecha/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/mecha/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MechaControlConsole", name, 420, 500, master_ui, state)
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
			if(istype(MT))
				MT.shock()
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
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=2;magnets=2"
	var/ai_beacon = FALSE //If this beacon allows for AI control. Exists to avoid using istype() on checking.

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
	answer["airtank"] = M.return_pressure()
	answer["pilot"] = "[M.occupant||"None"]"
	var/area/area = get_area(M)
	answer["location"] = "[sanitize(area.name)||"Unknown"]"
	answer["equipment"] = "[M.selected||"None"]"
	if(istype(M, /obj/mecha/working))
		var/obj/mecha/working/RM = M
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
						<b>Airtank:</b> [M.return_pressure()]kPa
						<b>Pilot:</b> [M.occupant||"None"]
						<b>Location:</b> [sanitize(A.name)||"Unknown"]
						<b>Active equipment:</b> [M.selected||"None"]<br>"}
	if(istype(M, /obj/mecha/working))
		var/obj/mecha/working/RM = M
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
		data["cellMaxCharge"] = M.cell.charge
	data["airtank"] = M.return_pressure()
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
	if(istype(loc, /obj/mecha))
		return loc
	return FALSE

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(2)
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
	name = "Exosuit Tracking Beacons"

/obj/item/storage/box/mechabeacons/New()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)

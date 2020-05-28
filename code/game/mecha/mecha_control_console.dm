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
	var/stored_data

/obj/machinery/computer/mecha/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/mecha/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/mecha/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "exosuit_control.tmpl", "Exosuit Control Console", 420, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/mecha/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["screen"] = screen
	if(screen == 0)
		var/list/mechas[0]
		for(var/obj/item/mecha_parts/mecha_tracking/TR in world)
			var/answer = TR.get_mecha_info()
			if(answer)
				mechas[++mechas.len] = answer
		data["mechas"] = mechas
	if(screen == 1)
		data["log"] = stored_data
	return data

/obj/machinery/computer/mecha/Topic(href, href_list)
	if(..())
		return 1

	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(href_list["send_message"])
		var/obj/item/mecha_parts/mecha_tracking/MT = afilter.getObj("send_message")
		var/message = strip_html_simple(input(usr,"Input message","Transmit message") as text)
		if(!trim(message) || ..())
			return 1
		var/obj/mecha/M = MT.in_mecha()
		if(M)
			M.occupant_message(message)

	if(href_list["shock"])
		var/obj/item/mecha_parts/mecha_tracking/MT = afilter.getObj("shock")
		MT.shock()

	if(href_list["get_log"])
		var/obj/item/mecha_parts/mecha_tracking/MT = afilter.getObj("get_log")
		stored_data = MT.get_mecha_log()
		screen = 1

	if(href_list["return"])
		screen = 0

	SSnanoui.update_uis(src)
	return

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
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer["hascargo"] = 1
		answer["cargo"] = RM.cargo.len/RM.cargo_capacity*100

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
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer += "<b>Used cargo space:</b> [RM.cargo.len/RM.cargo_capacity*100]%<br>"

	return answer

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
		return 0
	var/obj/mecha/M = loc
	return M.get_log_html()

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

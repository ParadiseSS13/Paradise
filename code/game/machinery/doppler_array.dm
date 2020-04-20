GLOBAL_LIST_EMPTY(doppler_arrays)

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = 1
	anchored = 1
	atom_say_verb = "states coldly"
	var/list/logged_explosions = list()
	var/explosion_target
	var/datum/tech/toxins/toxins_tech
	var/max_toxins_tech = 7

/datum/explosion_log
	var/logged_time
	var/epicenter
	var/actual_size_message
	var/theoretical_size_message

/datum/explosion_log/New(var/log_time, var/log_epicenter, var/log_actual_size_message, var/log_theoretical_size_message)
	..()
	logged_time = log_time
	epicenter = log_epicenter
	actual_size_message = log_actual_size_message
	theoretical_size_message = log_theoretical_size_message

/obj/machinery/doppler_array/New()
	..()
	GLOB.doppler_arrays += src
	explosion_target = rand(8, 20)
	toxins_tech = new /datum/tech/toxins(src)

/obj/machinery/doppler_array/Destroy()
	GLOB.doppler_arrays -= src
	logged_explosions.Cut()
	return ..()

/obj/machinery/doppler_array/process()
	return PROCESS_KILL

/obj/machinery/doppler_array/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = I
		disk.load_tech(toxins_tech)
		to_chat(user, "<span class='notice'>You swipe the disk into [src].</span>")
		return
	return ..()

/obj/machinery/doppler_array/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!anchored && !isinspace())
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE
	else if(anchored)
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE
	power_change()

/obj/machinery/doppler_array/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/doppler_array/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/doppler_array/AltClick(mob/user)
	rotate(user)

/obj/machinery/doppler_array/verb/rotate(mob/user)
	set name = "Rotate Tachyon-doppler Dish"
	set category = "Object"
	set src in oview(1)

	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do that!</span>")
		return
	dir = turn(dir, 90)
	to_chat(user, "<span class='notice'>You rotate [src].</span>")

/obj/machinery/doppler_array/proc/print_explosive_logs(mob/user)
	if(!logged_explosions.len)
		atom_say("<span class='notice'>No logs currently stored in internal database.</span>")
		return
	if(active_timers)
		to_chat(user, "<span class='notice'>[src] is already printing something, please wait.</span>")
		return
	atom_say("<span class='notice'>Printing explosive log. Standby...</span>")
	addtimer(CALLBACK(src, .print), 50)

/obj/machinery/doppler_array/proc/print()
	visible_message("<span class='notice'>[src] prints a piece of paper!</span>")
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
	var/obj/item/paper/explosive_log/P = new(get_turf(src))
	for(var/D in logged_explosions)
		var/datum/explosion_log/E = D
		P.info += "<tr>\
		<td>[E.logged_time]</td>\
		<td>[E.epicenter]</td>\
		<td>[E.actual_size_message]</td>\
		<td>[E.theoretical_size_message]</td>\
		</tr>"
	P.info += "</table><hr/>\
	<em>Printed at [station_time_timestamp()].</em>"

/obj/machinery/doppler_array/proc/sense_explosion(var/x0,var/y0,var/z0,var/devastation_range,var/heavy_impact_range,var/light_impact_range,
												  var/took,var/orig_dev_range,var/orig_heavy_range,var/orig_light_range)
	if(stat & NOPOWER)
		return
	if(z != z0)
		return

	var/dx = abs(x0-x)
	var/dy = abs(y0-y)
	var/distance
	var/direct
	var/capped = FALSE

	if(dx > dy)
		distance = dx
		if(x0 > x)
			direct = EAST
		else
			direct = WEST
	else
		distance = dy
		if(y0 > y)
			direct = NORTH
		else
			direct = SOUTH

	if(distance > 100)
		return
	if(!(direct & dir))
		return

	var/list/messages = list("Explosive disturbance detected.", \
							 "Epicenter at: grid ([x0],[y0]). Temporal displacement of tachyons: [took] seconds.", \
							 "Actual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		capped = TRUE
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
	logged_explosions.Insert(1, new /datum/explosion_log(station_time_timestamp(), "[x0],[y0]", "[devastation_range], [heavy_impact_range], [light_impact_range]", capped ? "[orig_dev_range], [orig_heavy_range], [orig_light_range]" : "n/a")) //Newer logs appear first
	messages += "Event successfully logged in internal database."
	var/miss_by = abs(explosion_target - orig_light_range)
	var/tmp_tech = max_toxins_tech - miss_by
	if(!miss_by)
		messages += "Explosion size matches target."
	else
		messages += "Target ([explosion_target]) missed by : [miss_by]."
	if(tmp_tech > toxins_tech.level)
		toxins_tech.level = tmp_tech
		messages += "Toxins technology level upgraded to [toxins_tech.level]. Swipe a technology disk to save data."
	for(var/message in messages)
		atom_say(message)

/obj/machinery/doppler_array/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered() && anchored)
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER

/obj/machinery/doppler_array/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "doppler_array.tmpl", "Tachyon-doppler array", 500, 650)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/doppler_array/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/list/explosion_data = list()
	for(var/D in logged_explosions)
		var/datum/explosion_log/E = D
		explosion_data += list(list(
			"logged_time" = E.logged_time,
			"epicenter" = E.epicenter,
			"actual_size_message" = E.actual_size_message,
			"theoretical_size_message" = E.theoretical_size_message,
			"unique_datum_id" = E.UID()))
	data["explosion_target"] = explosion_target
	data["toxins_tech"] = toxins_tech.level
	data["explosion_data"] = explosion_data
	data["printing"] = active_timers
	return data

/obj/machinery/doppler_array/Topic(href, href_list)
	if(..())
		return
	if(href_list["log_to_delete"])
		var/log_to_delete = sanitize(href_list["log_to_delete"])
		for(var/D in logged_explosions)
			var/datum/explosion_log/E = D
			if(E.UID() == log_to_delete)
				logged_explosions -= E
				qdel(E)
				to_chat(usr, "<span class='notice'>Log deletion successful.</span>")
				break
	else if(href_list["print_logs"])
		print_explosive_logs(usr)
	else
		return
	SSnanoui.update_uis(src)

/obj/item/paper/explosive_log
	name = "explosive log"
	info = "<h3>Explosive Log Report</h3>\
	<table style='width:380px;text-align:left;'>\
	<tr>\
	<th>Time logged</th>\
	<th>Epicenter</th>\
	<th>Actual</th>\
	<th>Theoretical</th>\
	</tr>" //NB: the <table> tag is left open, it is closed later on, when the doppler array adds its data

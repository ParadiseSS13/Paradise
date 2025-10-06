/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	atom_say_verb = "states coldly"
	var/list/logged_explosions = list()
	var/explosion_target
	var/datum/tech/toxins/toxins_tech
	var/max_toxins_tech = 7
	/// List of linked machines
	var/list/linked_machines = list()

/datum/explosion_log
	var/logged_time
	var/epicenter
	var/actual_size_message
	var/theoretical_size_message

/datum/explosion_log/New(log_time, log_epicenter, log_actual_size_message, log_theoretical_size_message)
	..()
	logged_time = log_time
	epicenter = log_epicenter
	actual_size_message = log_actual_size_message
	theoretical_size_message = log_theoretical_size_message

/obj/machinery/doppler_array/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(sense_explosion))
	explosion_target = rand(8, 20)
	toxins_tech = new /datum/tech/toxins(src)

/obj/machinery/doppler_array/Destroy()
	logged_explosions.Cut()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	return ..()

/obj/machinery/doppler_array/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = used
		disk.load_tech(toxins_tech)
		to_chat(user, "<span class='notice'>You swipe the disk into [src].</span>")
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/doppler_array/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!default_unfasten_wrench(user, I, 0))
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/doppler_array/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/multi = I
	multi.set_multitool_buffer(user, src)
	to_chat(user, "<span class='notice'>You save [src]'s linking data to the buffer.</span>")

/obj/machinery/doppler_array/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/doppler_array/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/doppler_array/AltClick(mob/user)
	rotate(user)

/obj/machinery/doppler_array/proc/rotate(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do that!</span>")
		return
	dir = turn(dir, 90)
	to_chat(user, "<span class='notice'>You rotate [src].</span>")

/obj/machinery/doppler_array/proc/print_explosive_logs(mob/user)
	if(!length(logged_explosions))
		atom_say("No logs currently stored in internal database.")
		return
	if(active_timers)
		to_chat(user, "<span class='notice'>[src] is already printing something, please wait.</span>")
		return
	atom_say("Printing explosive log. Standby...")
	addtimer(CALLBACK(src, PROC_REF(print)), 50)

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

/obj/machinery/doppler_array/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	if(stat & NOPOWER)
		return
	if(z != epicenter.z)
		return

	var/dx = abs(epicenter.x - x)
	var/dy = abs(epicenter.y - y)
	var/distance
	var/direct
	var/capped = FALSE

	if(dx > dy)
		distance = dx
		if(epicenter.x > x)
			direct = EAST
		else
			direct = WEST
	else
		distance = dy
		if(epicenter.y > y)
			direct = NORTH
		else
			direct = SOUTH

	if(distance > 100)
		return
	if(!(direct & dir))
		return

	var/coordinates = "[epicenter.x],[epicenter.y]"
	var/list/messages = list("Explosive disturbance detected.", \
							"Epicenter at: grid ([coordinates]). Temporal displacement of tachyons: [took] seconds.", \
							"Actual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		capped = TRUE
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
	logged_explosions.Insert(1, new /datum/explosion_log(station_time_timestamp(), "[coordinates]", "[devastation_range], [heavy_impact_range], [light_impact_range]", capped ? "[orig_dev_range], [orig_heavy_range], [orig_light_range]" : "n/a")) //Newer logs appear first
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
	for(var/obj/machinery/anomaly_refinery/anom_refiner in linked_machines)
		anom_refiner.refine_core(orig_light_range)

/obj/machinery/doppler_array/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		icon_state = !(stat & NOPOWER) && anchored ? initial(icon_state) : "[initial(icon_state)]-off"

/// overrides base power_change to check to make sure machine is anchored
/obj/machinery/doppler_array/power_change()
	if(has_power(power_channel) && anchored)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/doppler_array/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/doppler_array/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TachyonArray", name)
		ui.open()

/obj/machinery/doppler_array/ui_data(mob/user)
	var/list/data = list()
	var/list/records = list()
	for(var/i in 1 to length(logged_explosions))
		var/datum/explosion_log/E = logged_explosions[i]
		records += list(list(
			"logged_time" = E.logged_time,
			"epicenter" = E.epicenter,
			"actual_size_message" = E.actual_size_message,
			"theoretical_size_message" = E.theoretical_size_message,
			"index" = i))
	data["explosion_target"] = explosion_target
	data["toxins_tech"] = toxins_tech.level
	data["records"] = records
	data["printing"] = active_timers
	return data

/obj/machinery/doppler_array/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("delete_logs")
			QDEL_LIST_CONTENTS(logged_explosions)
			to_chat(usr, "<span class='notice'>All logs deleted successfully.</span>")
		if("delete_record")
			var/index = text2num(params["index"])
			if(index < 0 || index > length(logged_explosions))
				return

			var/datum/explosion_log/E = logged_explosions[index]
			logged_explosions -= E
			qdel(E)
			to_chat(usr, "<span class='notice'>Log deletion successful.</span>")
		if("print_logs")
			print_explosive_logs(usr)
		else
			return
	return TRUE

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

#define MAX_CRYSTALS 4


/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_keyboard = "tech_key"
	icon_screen = "telesci"
	circuit = /obj/item/circuitboard/telesci_console
	req_access = list(ACCESS_RESEARCH)

	/// UID of linked pad
	var/linked_pad_uid = null
	/// Temp message to show in the UI
	var/temp_msg = "Telescience control console initialized"
	/// How many teleports left until it becomes uncalibrated
	var/teles_left
	/// Data of the last teleport
	var/datum/tsci_trajectory_data/last_tele_data = null
	/// Target Z
	var/target_z = 0
	/// Offset of power
	var/power_offset
	/// Offset of rotation
	var/rotation_offset
	/// Last target reference
	var/last_target_ref
	/// Current rotation
	var/rotation = 0
	/// Current elevation
	var/angle = 45
	/// Current power
	var/power = 5
	/// Teleport cooldown, based on the power used
	var/teleport_cooldown = 0
	/// Power options available, more crystals required for more oomph
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80)
	/// Are we currently working
	var/teleporting = FALSE
	/// How many crystals are loaded
	var/crystals = 0
	/// Our currently loaded GPS
	var/obj/item/gps/inserted_gps

/obj/machinery/computer/telescience/Initialize(mapload)
	. = ..()
	target_z = level_name_to_num(MAIN_STATION)
	recalibrate()

/obj/machinery/computer/telescience/Destroy()
	eject_crystals()
	if(inserted_gps)
		inserted_gps.forceMove(loc)
		inserted_gps = null

	QDEL_NULL(last_tele_data)
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	. = ..()
	. += "There are [crystals ? crystals : "no"] bluespace crystal\s in the crystal slots."

/obj/machinery/computer/telescience/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/B = used
		if(crystals >= MAX_CRYSTALS)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return ITEM_INTERACT_COMPLETE
		crystals += 1
		user.visible_message("<span class='notice'>[user] inserts a [B.singular_name] into [src]'s crystal slot.</span>")
		B.use(1)
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/gps))
		// TODO: Provide some kind of message if there's already an inserted GPS.
		// For now, just do nothing.
		if(!inserted_gps)
			inserted_gps = used
			user.transfer_item_to(used, src)
			user.visible_message("<span class='notice'>[user] inserts [used] into [src]'s GPS device slot.</span>")
			SStgui.update_uis(src)

		return ITEM_INTERACT_COMPLETE

	return ..()


/obj/machinery/computer/telescience/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
		linked_pad_uid = M.buffer.UID()
		M.buffer = null
		to_chat(user, "<span class='notice'>You upload the data from [M]'s buffer.</span>")
		SStgui.update_uis(src)
		return TRUE

	. = ..()


/obj/machinery/computer/telescience/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='notice'>You scramble the Telescience authentication key to an unknown signal. You should be able to teleport to more places now!</span>")
		emagged = TRUE
		return TRUE
	else
		to_chat(user, "<span class='warning'>The machine seems unaffected by the card swipe...</span>")


/obj/machinery/computer/telescience/attack_ai(mob/user)
	attack_hand(user)


/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(isgolem(user)) //this is why we can't have nice things free golems
		to_chat(user, "<span class='warning'>You can't make sense of the console or how to use it.</span>")
		return

	ui_interact(user)

/obj/machinery/computer/telescience/proc/sparks()
	var/obj/machinery/telepad/TP = get_linked_pad()
	if(TP)
		do_sparks(5, 1, get_turf(TP))


/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")


/obj/machinery/computer/telescience/proc/doteleport(mob/user, sending)
	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power - Please wait [round((teleport_cooldown - world.time) / 10)] seconds"
		return FALSE

	if(teleporting)
		temp_msg = "Telepad is in use - Please wait"
		return FALSE

	var/obj/machinery/telepad/TP = get_linked_pad()

	if(!TP)
		return FALSE

	var/datum/tsci_trajectory_data/proj_data = calculate_trajectory()
	last_tele_data = proj_data

	var/trueX = clamp(round(proj_data.dest_x, 1), 1, world.maxx)
	var/trueY = clamp(round(proj_data.dest_y, 1), 1, world.maxy)
	var/spawn_time = round(proj_data.time) * 10

	var/turf/target = locate(trueX, trueY, target_z)
	last_target_ref = target.UID()
	flick("pad-beam", TP)

	if(spawn_time > 15) // 1.5 seconds
		playsound(get_turf(TP), 'sound/weapons/flash.ogg', 25, 1)
		// Wait depending on the time the projectile took to get there
		teleporting = TRUE
		temp_msg = "Powering up bluespace crystals - Please wait"

	addtimer(CALLBACK(src, PROC_REF(finish_tele), user, sending, trueX, trueY), round(proj_data.time) * 10) // We fire this on a timer
	return TRUE

/obj/machinery/computer/telescience/proc/finish_tele(mob/user, sending, trueX, trueY)
	var/obj/machinery/telepad/TP = get_linked_pad()

	if(!TP)
		return

	if(TP.stat & NOPOWER)
		return

	var/turf/target = locateUID(last_target_ref)

	if(!target)
		return // If our target turf somehow got deleted - abort

	teleporting = FALSE
	teleport_cooldown = world.time + (power * 2)
	teles_left -= 1

	// use a lot of power
	use_power(power * 10)

	do_sparks(5, 1, get_turf(TP))

	temp_msg = "Teleport successful"
	if(teles_left < 10)
		temp_msg += " - Calibration required soon"
	else
		temp_msg += " - Data printed below"

	var/sparks = get_turf(target)
	do_sparks(5, 1, sparks)

	var/turf/source = target
	var/turf/dest = get_turf(TP)

	var/list/log_msg = list()
	log_msg += "[key_name(user)] has teleported "

	if(sending)
		source = dest
		dest = target

	flick("pad-beam", TP)
	playsound(get_turf(TP), 'sound/weapons/emitter2.ogg', 25, TRUE)

	for(var/atom/movable/ROI in source)
		// if is anchored, don't let through
		if(ROI.anchored)
			if(isliving(ROI))
				var/mob/living/L = ROI
				if(L.buckled)
					// TP people on office chairs
					if(L.buckled.anchored)
						continue

					log_msg += "[key_name(L)] (on a chair), "
				else
					continue

			else if(!isobserver(ROI))
				continue

		if(ismob(ROI))
			var/mob/T = ROI
			log_msg += "[key_name(T)], "

		else
			log_msg += "[ROI.name]"

			if(istype(ROI, /obj/structure/closet))
				var/obj/structure/closet/C = ROI
				log_msg += " ("

				for(var/atom/movable/Q as mob|obj in C)
					if(ismob(Q))
						log_msg += "[key_name(Q)], "
					else
						log_msg += "[Q.name], "

				if(dd_hassuffix(log_msg, "("))
					log_msg += "empty)"

				else
					log_msg = dd_limittext(log_msg, length(log_msg) - 2)
					log_msg += ")"

			log_msg += ", "

		do_teleport(ROI, dest)

	if(dd_hassuffix(log_msg, ", "))
		log_msg = dd_limittext(log_msg, length(log_msg) - 2)

	else
		log_msg += "nothing"

	var/area/A = get_area(target)
	log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [target_z] ([A ? A.name : "null area"])"
	investigate_log(log_msg.Join(""), "telesci")
	SStgui.update_uis(src)


/obj/machinery/computer/telescience/proc/teleport(mob/user, sending)
	var/obj/machinery/telepad/TP = get_linked_pad()
	if(!TP)
		// No telefail - it just sprarks the pad
		temp_msg = "ERROR - No linked telepad"
		SStgui.update_uis(src)
		return

	if(rotation == null || angle == null || target_z == null)
		temp_msg = "ERROR - Set a bearing, elevation and sector"
		SStgui.update_uis(src)
		return

	if(power <= 0)
		telefail()
		temp_msg = "ERROR - No power selected!"
		SStgui.update_uis(src)
		return

	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR - Elevation is less than 1 or greater than 90"
		SStgui.update_uis(src)
		return

	var/cc_z = level_name_to_num(CENTCOMM)
	if(target_z <= cc_z || target_z > world.maxz)
		telefail()
		temp_msg = "ERROR - Sector must be greater than [cc_z], and less than or equal to [world.maxz]"
		SStgui.update_uis(src)
		return

	var/datum/tsci_trajectory_data/proj_data = calculate_trajectory()
	var/turf/target = locate(clamp(round(proj_data.dest_x, 1), 1, world.maxx), clamp(round(proj_data.dest_y, 1), 1, world.maxy), target_z)
	var/area/A = get_area(target)

	if(A.tele_proof)
		telefail()
		temp_msg = "ERROR - Target destination unreachable due to interference"
		SStgui.update_uis(src)
		return

	if(teles_left > 0)
		if(!doteleport(user, sending))
			telefail()
			temp_msg = "ERROR - Target destination unreachable due to interference"
	else
		telefail()
		temp_msg = "ERROR - Calibration required"

	SStgui.update_uis(src)

/obj/machinery/computer/telescience/proc/eject_crystals()
	var/to_eject
	for(var/i in 1 to crystals)
		to_eject += 1

	crystals = 0
	power = power_options[1] // Reset this
	// Yes this means some real ones put in will become artificial after
	// Lets just pretend this machine ruins the purity of them
	new /obj/item/stack/ore/bluespace_crystal/artificial(drop_location(), to_eject)

/obj/machinery/computer/telescience/proc/recalibrate()
	teles_left = rand(30, 40)
	power_offset = rand(-4, 0)
	rotation_offset = rand(-10, 10)



// TGUI Shenanigans //
/obj/machinery/computer/telescience/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/telescience/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TelescienceConsole", name)
		ui.open()

/obj/machinery/computer/telescience/ui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/telepad/TP = get_linked_pad()

	data["linked_pad"] = (TP != null)
	data["held_gps"] = (inserted_gps != null)
	data["last_msg"] = temp_msg
	data["working"] = teleporting
	data["power_levels"] = power_options
	data["current_bearing"] = rotation
	data["current_elevation"] = angle
	data["current_power"] = power
	data["max_z"] = world.maxz

	if(TP)
		data["current_max_power"] = crystals + TP.efficiency
		if(TP.panel_open)
			data["last_msg"] = "Telepad undergoing physical maintenance operations"
	else
		// This wont even show up, just a safety precaution
		data["current_max_power"] = 0

	data["current_sector"] = target_z

	if(last_tele_data)
		data["lastdata"] = list(
			"Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])",
			"Distance: [round(last_tele_data.distance, 0.1)]m",
			"Time: [round(last_tele_data.time, 0.1)] secs"
		)
	else
		data["lastdata"] = list()

	return data

/obj/machinery/computer/telescience/proc/get_linked_pad()
	if(!linked_pad_uid)
		return null

	var/obj/machinery/telepad/TP = locateUID(linked_pad_uid)

	// Is branching this out necessary? Dunno
	// Does it help for readability? Probbaly
	if(!TP)
		return null

	return TP

/obj/machinery/computer/telescience/ui_act(action, list/params)
	if(..())
		return

	. = FALSE

	if(teleporting) // Deny changes mid TP to avoid fuckups
		return

	switch(action)
		if("setbear")
			var/bear = text2num(params["bear"])
			rotation = clamp(bear, 0, 360) // We are forcing people to do proper maths now
			rotation = round(rotation, 0.01)
			return TRUE

		if("setelev")
			var/elev = text2num(params["elev"])
			angle = clamp(round(elev, 0.1), 1, 256)
			return TRUE

		if("setpwr")
			// This needs the pad
			var/obj/machinery/telepad/TP = get_linked_pad()

			if(!TP)
				return

			var/pwr_index = text2num(params["pwr"])
			if(pwr_index != null && power_options[pwr_index])
				if((crystals + TP.efficiency) >= pwr_index)
					power = power_options[pwr_index]

			return TRUE

		if("setz")
			var/newz = text2num(params["newz"])
			// Min Z is station
			var/min_z = level_name_to_num(MAIN_STATION)
			target_z = clamp(round(newz), min_z, world.maxz)
			return TRUE


		if("eject_gps")
			if(inserted_gps)
				usr.put_in_hands(inserted_gps)
				inserted_gps = null
				return TRUE

		if("store_to_gps")
			if(inserted_gps)
				if(last_tele_data)
					inserted_gps.locked_location = last_tele_data
					temp_msg = "Location saved"
				else
					temp_msg = "ERROR - No data to store"
			else
				temp_msg = "ERROR - No GPS inserted"

			return TRUE

		if("pad_send")
			teleport(usr, TRUE)
			return TRUE

		if("pad_receive")
			teleport(usr, FALSE)
			return TRUE

		if("recal_crystals")
			recalibrate()
			sparks()
			temp_msg = "NOTICE - Recalibration successful"
			return TRUE

		if("eject_crystals")
			eject_crystals()
			temp_msg = "NOTICE - Bluespace crystals ejected"
			return TRUE


// TSCI MATH STUFF //
/datum/tsci_trajectory_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/tsci_trajectory_data/New(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/obj/machinery/computer/telescience/proc/calculate_trajectory()
	var/obj/machinery/telepad/TP = get_linked_pad()

	if(!TP)
		return null

	var/true_power = clamp(power + power_offset, 1, 1000)
	var/true_rotation = rotation + rotation_offset
	var/true_angle = clamp(angle, 1, 90)

	var/power_x = true_power * cos(true_angle)
	var/power_y = true_power * sin(true_angle)
	var/time = 2 * (power_y / 10) //10 = g

	var/distance = time * power_x

	var/dest_x = TP.x + distance * sin(true_rotation);
	var/dest_y = TP.y + distance * cos(true_rotation);

	return new /datum/tsci_trajectory_data(TP.x, TP.y, time, distance, power_x, power_y, dest_x, dest_y)


#undef MAX_CRYSTALS

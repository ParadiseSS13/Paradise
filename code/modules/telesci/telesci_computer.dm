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
	var/temp_msg = "Telescience control console initialized."
	/// How many teleports left until it becomes uncalibrated
	var/teles_left
	/// Data of the last teleport
	var/datum/projectile_data/last_tele_data = null
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
	eject()
	if(inserted_gps)
		inserted_gps.forceMove(loc)
		inserted_gps = null

	QDEL_NULL(last_tele_data)
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	. = ..()
	. += "There are [crystals ? crystals : "no"] bluespace crystal\s in the crystal slots."

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/B = W
		if(crystals >= MAX_CRYSTALS)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return

		crystals += 1
		user.visible_message("<span class='notice'>[user] inserts a [B.singular_name] into [src]'s crystal slot.</span>")
		B.use(1)
		SStgui.update_uis(src)

	else if(istype(W, /obj/item/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.unEquip(W)
			W.forceMove(src)
			user.visible_message("<span class='notice'>[user] inserts [W] into [src]'s GPS device slot.</span>")
			SStgui.update_uis(src)

	else
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


/*
/obj/machinery/computer/telescience/interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='byond://?src=[UID()];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='byond://?src=[UID()];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='byond://?src=[UID()];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation] degrees</div>"
		t += "<A href='byond://?src=[UID()];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle] degrees</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= length(power_options); i++)
			if(crystals + telepad.efficiency < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='byond://?src=[UID()];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='byond://?src=[UID()];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<BR><A href='byond://?src=[UID()];send=1'>Send</A>"
		t += " <A href='byond://?src=[UID()];receive=1'>Receive</A>"
		t += "<BR><A href='byond://?src=[UID()];recal=1'>Recalibrate Crystals</A> <A href='byond://?src=[UID()];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
*/

/obj/machinery/computer/telescience/proc/sparks()
	var/obj/machinery/telepad/TP = get_linked_pad()
	if(TP)
		do_sparks(5, 1, get_turf(TP))


/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")


/obj/machinery/computer/telescience/proc/doteleport(mob/user, sending)
	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power - Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use - Please wait."
		return

	var/obj/machinery/telepad/TP = get_linked_pad()

	if(!TP)
		return

	var/true_power = clamp(power + power_offset, 1, 1000)
	var/true_rotation = rotation + rotation_offset
	var/true_angle = clamp(angle, 1, 90)

	var/datum/projectile_data/proj_data = projectile_trajectory(TP.x, TP.y, true_rotation, true_angle, true_power)
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

	temp_msg = "Teleport successful."
	if(teles_left < 10)
		temp_msg += " - Calibration required soon."
	else
		temp_msg += " - Data printed below."

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
		temp_msg = "ERROR - No linked telepad."
		SStgui.update_uis(src)
		return

	if(rotation == null || angle == null || target_z == null)
		temp_msg = "ERROR - Set a angle, rotation and sector."
		SStgui.update_uis(src)
		return

	if(power <= 0)
		telefail()
		temp_msg = "ERROR - No power selected!"
		SStgui.update_uis(src)
		return

	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR - Elevation is less than 1 or greater than 90."
		SStgui.update_uis(src)
		return

	// THIS FUCKING THING USES ZLEVEL NUMBERS WHY
	var/cc_z = level_name_to_num(CENTCOMM)
	if(target_z == cc_z || target_z < cc_z + 1 || target_z > world.maxz)
		telefail()
		temp_msg = "ERROR - Sector must be greater than or equal to 2, and less than or equal to [world.maxz]."
		SStgui.update_uis(src)
		return

	var/truePower = clamp(power + power_offset, 1, 1000)
	var/trueRotation = rotation + rotation_offset
	var/trueAngle = clamp(angle, 1, 90)

	var/datum/projectile_data/proj_data = projectile_trajectory(TP.x, TP.y, trueRotation, trueAngle, truePower)
	var/turf/target = locate(clamp(round(proj_data.dest_x, 1), 1, world.maxx), clamp(round(proj_data.dest_y, 1), 1, world.maxy), target_z)
	var/area/A = get_area(target)

	if(A.tele_proof)
		telefail()
		temp_msg = "ERROR - Target destination unreachable due to interference."
		SStgui.update_uis(src)
		return

	if(teles_left > 0)
		if(!doteleport(user, sending))
			telefail()
			temp_msg = "ERROR - Target destination unreachable due to interference."
	else
		telefail()
		temp_msg = "ERROR - Calibration required."

	SStgui.update_uis(src)

/obj/machinery/computer/telescience/proc/eject()
	var/to_eject
	for(var/i in 1 to crystals)
		to_eject += 1

	crystals = 0
	power = power_options[1] // Reset this
	new /obj/item/stack/ore/bluespace_crystal/artificial(drop_location(), to_eject)


/*
/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateUsrDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals + telepad.efficiency >= index)
				power = power_options[index]

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(..())
			return
		z_co = clamp(round(new_z), 1, 10)

	if(href_list["ejectGPS"])
		if(inserted_gps)
			usr.put_in_hands(inserted_gps)
			inserted_gps = null

	if(href_list["setMemory"])
		if(last_target && inserted_gps)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data was stored."

	if(href_list["send"])
		teleport(usr, TRUE)

	if(href_list["receive"])
		teleport(usr, FALSE)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE - Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE - Bluespace crystals ejected."
*/

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
	data["power_levels"] = power_options

	data["current_bearing"] = rotation
	data["current_elevation"] = angle
	data["current_power"] = power

	if(TP)
		data["current_max_power"] = crystals + TP.efficiency
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

	return
	// Do stuff



#undef MAX_CRYSTALS

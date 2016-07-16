/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telepad."
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	circuit = /obj/item/weapon/circuitboard/telesci_console
	req_access = list(access_research)
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telepad control console initialized.<BR>Welcome."

	// VARIABLES //
	var/atom/movable/scan_target
	var/atom/movable/locked_target
	var/screen = 0
	var/list/usage_logs

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/teleporting = 0
	var/starting_crystals = 0
	var/max_crystals = 4
	var/list/crystals = list()

/obj/machinery/computer/telescience/New()
	..()

/obj/machinery/computer/telescience/Destroy()
	eject()
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	..(user)
	to_chat(user, "There are [crystals.len ? crystals.len : "no"] bluespace crystal\s in the crystal slots.")

/obj/machinery/computer/telescience/initialize()
	..()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/weapon/ore/bluespace_crystal/artificial(null) // starting crystals

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/ore/bluespace_crystal))
		if(crystals.len >= max_crystals)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return
		user.drop_item()
		crystals += W
		W.loc = null
		user.visible_message("<span class='notice'>[user] inserts [W] into \the [src]'s crystal slot.</span>")
		updateUsrDialog()
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			to_chat(user, "<span class = 'caution'>You upload the data from the [W.name]'s buffer.</span>")
			updateUsrDialog()
	else
		..()

/obj/machinery/computer/telescience/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "\blue You scramble the Telescience authentication key to an unknown signal. You should be able to teleport to more places now!")
		emagged = 1
	else
		to_chat(user, "\red The machine seems unaffected by the card swipe...")

/obj/machinery/computer/telescience/proc/check_target_sanity()
	if(scan_target)
		if(!is_valid_scantarget(scan_target))
			scan_target = null
			if(screen == 2)
				screen = 0
	if(locked_target)
		if(!scan_target)
			locked_target = null
		if(!(locked_target in view(crystals.len, get_turf(scan_target))))
			locked_target = null

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/telescience/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	user.set_machine(src)
	var/list/data = list()
	
	check_target_sanity
	// Suit sensors data.
	data["isAI"] = isAI(user)
	data["crewmembers"] = crew_repository.health_data(get_turf(src))
	data["z"] = z
	data["screen"] = screen
	data["temp_msg"] = temp_msg
	if(locked_target)
		data["locked_target"] = locked_target.name
		var/turf/T = get_turf(locked_target)
		data["locked_target_area"] = T.loc.name
		data["locked_target_x"] = T.x
		data["locked_target_y"] = T.y
	else
		data["locked_target"] = null
	
	if(screen == 3)
		data["usage_logs"] = usage_logs
	
	data["telepad"] = telepad ? 1 : 0
	data["crystals_len"] = crystals.len
	
	if(scan_target && screen == 2)
		var/list/targets_list = list()
		data["scanned_objects"] = targets_list
		var/turf/T2 = get_turf(scan_target)
		for(var/atom/movable/A in view(crystals.len, T2)) // get_turf so that giving your metabuddy xray doesn't make stealing the CE's shit easy.
			if(A.anchored || A.invisibility)
				continue
			var/turf/T = get_turf(A)
			targets_list[++targets_list.len] = list("name" = A.name, "id" = "\ref[A]", "x" = T.x, "y" = T.y, "offset_x" = T2.x-T.x, "offset_y" = T2.y-T.y, "area" = "[get_area(A)]")
	
	var/list/beacons_list = list()
	var/list/areaindex = list()
	data["beacons"] = beacons_list
	for(var/obj/item/device/radio/beacon/R in beacons)
		var/turf/T = get_turf(R)
		if(!is_valid_scantarget(R))
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		beacons_list[++beacons_list.len] = list("area_name" = tmpname, "id" = "\ref[R]", "name" = R.name, "x" = T.x, "y" = T.y, "z" = T.z)

	for(var/obj/item/weapon/implant/tracking/I in tracked_implants)
		if(!I.implanted || !ismob(I.loc))
			continue
		else
			if(!is_valid_scantarget(I))
				continue
			var/mob/M = I.loc
			var/tmpname = M.real_name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			beacons_list[++beacons_list.len] = list("area_name" = tmpname, "id" = "\ref[I]", "name" = M.name, "x" = T.x, "y" = T.y, "z" = T.z)
	
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "telesci.tmpl", "Telepad Control", 900, 800)
		ui.add_template("mapContent", "telesci_map_content.tmpl")
		ui.add_template("mapHeader", "telesci_map_header.tmpl")
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/telescience/proc/is_valid_scantarget(var/atom/movable/O)
	var/turf/T = get_turf(O)
	if(istype(O, /obj/item/device/radio/beacon))
		var/obj/item/device/radio/beacon/R = O
		if(!T)
			return 0
		if((T.z in config.admin_levels) || T.z > 7)
			return 0
		if(R.syndicate == 1 && emagged == 0)
			return 0
		return 1
	if(istype(O, /obj/item/weapon/implant/tracking))
		var/obj/item/weapon/implant/tracking/I
		var/mob/M = I.loc
		if(M.stat == 2)
			if(M.timeofdeath + 6000 < world.time)
				return 0
		if(!T)
			return 0
		if((T.z in config.admin_levels))
			return 0
		return 1
	if(istype(O, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/under/C = H.w_uniform
		if(!istype(C) || !C.has_sensor)
			return 0
		if(C.sensor_mode < 3)
			return 0
		return 1
	return 0

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.loc = loc
		I.pixel_y = -9
		crystals -= I

/obj/machinery/computer/telescience/proc/teleport(var/direction)
	var/turf/source
	var/turf/dest
	if(direction)
		source = get_turf(telepad)
		dest = get_turf(locked_target)
	else
		source = get_turf(locked_target)
		dest = get_turf(telepad)
	
	var/log_msg = ": [key_name(usr)] has teleported "
	var/int_log_msg = "[usr] has teleported "
	
	for(var/atom/movable/A in source)
		if(A.anchored)
			if(isliving(A))
				var/mob/living/L = A
				if(L.buckled)
					if(L.buckled.anchored)
						continue
					log_msg += "[key_name(L)] (on a chair), "
					int_log_msg += "[L], "
				else
					continue
			else if(!isobserver(A))
				continue
		if(ismob(A))
			log_msg += "[key_name(A)]"
			int_log_msg += "[A]"
		else
			log_msg += "\the [A]"
			int_log_msg += "\the [A]"
			if(istype(A, /obj/structure/closet))
				log_msg += " ("
				for(var/atom/movable/Q in A)
					if(ismob(Q))
						log_msg += "[key_name(Q)]"
					else
						log_msg += "\the [Q]"
				if(dd_hassuffix(log_msg, "("))
					log_msg += "empty)"
				else
					log_msg = dd_limittext(log_msg, length(log_msg) - 2)
					log_msg += ", "
			log_msg += ", "
			int_log_msg += ", "
		teleport_object(A, dest)
	if(dd_hassuffix(log_msg, ", "))
		log_msg = dd_limittext(log_msg, length(log_msg) - 2)
		int_log_msg = dd_limittext(int_log_msg, length(int_log_msg) - 2)
	else
		log_msg += "nothing"
		int_log_msg += "nothing"
	var/turf/T = get_turf(locked_target)
	log_msg += " [direction ? "to" : "from"] [T.x], [T.y], [T.z] ([T.loc])"
	int_log_msg += " [direction ? "to" : "from"] [T.x], [T.y], [T.z] ([T.loc])"
	investigate_log(log_msg, "telesci")
	usage_logs[++usage_logs.len] = int_log_msg
	temp_msg = "Teleport complete."
	return

/obj/machinery/computer/telescience/proc/teleport_object(atom/movable/A, turf/dest)
	var/icon/flat_icon = getFlatIcon(A)
	var/icon/appear_icon = icon('icons/effects/teleport.dmi', "appear")
	var/icon/appear_icon_tmp = icon(flat_icon)
	appear_icon.Blend(appear_icon_tmp, ICON_MULTIPLY)
	
	var/icon/disappear_icon = icon('icons/effects/teleport.dmi', "disappear")
	var/icon/disappear_icon_tmp = icon(flat_icon)
	disappear_icon.Blend(disappear_icon_tmp, ICON_MULTIPLY)
	
	var/icon/blink_icon = icon('icons/effects/teleport.dmi', "blink")
	var/icon/blink_icon_tmp = icon(flat_icon)
	blink_icon_tmp.MapColors(0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  1, 1, 1, 1,  0, 0, 0, 0)
	blink_icon.Blend(blink_icon_tmp, ICON_MULTIPLY)
	
	var/obj/effect/teleport_blink/from_blink = new(get_turf(A))
	from_blink.invisibility = A.invisibility
	spawn()
		from_blink.do_blink(blink_icon, disappear_icon, 0)
	var/obj/effect/teleport_blink/to_blink = new(dest)
	to_blink.invisibility = A.invisibility
	A.forceMove(to_blink)
	spawn()
		to_blink.do_blink(blink_icon, appear_icon, 1)

/obj/effect/teleport_blink
	unacidable = 1
	anchored = 1
	density = 0

/obj/effect/teleport_blink/proc/do_blink(icon/blink_icon, icon/transition_icon, var/appear)
	icon = blink_icon
	if(!appear)
		flick(transition_icon, src)
	sleep(80)
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
		if(ismob(A))
			var/mob/M = A
			M.reset_view() // Prevent screen from flashing black
		if(appear)
			flick(transition_icon, A)
	qdel(src)

/obj/effect/teleport_blink/Destroy()
	if(contents.len)
		return QDEL_HINT_LETMELIVE
	else
		return ..()

/obj/effect/teleport_blink/singularity_pull()
	return

/obj/effect/teleport_blink/singularity_act()
	return 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE: Bluespace crystals ejected."
	if(href_list["map_select"])
		var/atom/movable/A = locate(href_list["map_select"])
		if(!is_valid_scantarget(A))
			return
		var/action = input("Select action:", "Telepad Control") as null|anything in list("Scan Nearby", "Lock Target")
		if(!is_valid_scantarget(A) || !action)
			return
		if(action == "Scan Nearby")
			scan_target = A
			screen = 2
		else
			scan_target = A
			locked_target = A
	if(href_list["scan"])
		var/atom/movable/A = locate(href_list["scan"])
		if(!is_valid_scantarget(A))
			return
		scan_target = A
		screen = 2
	if(href_list["lock"])
		var/atom/movable/A = locate(href_list["lock"])
		if(!is_valid_scantarget(A) && (!is_valid_scantarget(scan_target) || !(A in view(crystals.len, get_turf(scan_target)))))
			return
		locked_target = A
		screen = 0
	if(href_list["screen"])
		screen = text2num(href_list["screen"])
	
	if(!telepad)
		nanomanager.update_uis(src)
		return
	
	if(href_list["send"])
		teleport(1)
	if(href_list["receive"])
		teleport(0)
	if(href_list["eject"])
		eject()

	. = 1

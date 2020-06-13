/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	circuit = /obj/item/circuitboard/telesci_console
	req_access = list(ACCESS_RESEARCH)
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	//var/angle_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80)
	var/teleporting = 0
	var/crystals = 0
	var/max_crystals = 4
	var/obj/item/gps/inserted_gps

/obj/machinery/computer/telescience/New()
	..()
	recalibrate()

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.forceMove(loc)
		inserted_gps = null
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	. = ..()
	. += "There are [crystals ? crystals : "no"] bluespace crystal\s in the crystal slots."

/obj/machinery/computer/telescience/Initialize()
	..()

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/B = W
		if(crystals >= max_crystals)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return
		crystals += 1
		user.visible_message("<span class='notice'>[user] inserts a [B.singular_name] into [src]'s crystal slot.</span>")
		B.use(1)
		updateUsrDialog()
	else if(istype(W, /obj/item/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.unEquip(W)
			W.loc = src
			user.visible_message("<span class='notice'>[user] inserts [W] into [src]'s GPS device slot.</span>")
			updateUsrDialog()
	else if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			to_chat(user, "<span class = 'caution'>You upload the data from the [W.name]'s buffer.</span>")
			updateUsrDialog()
	else
		return ..()

/obj/machinery/computer/telescience/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='notice'>You scramble the Telescience authentication key to an unknown signal. You should be able to teleport to more places now!</span>")
		emagged = 1
	else
		to_chat(user, "<span class='warning'>The machine seems unaffected by the card swipe...</span>")

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(isgolem(user)) //this is why we can't have nice things free golems
		to_chat(user, "<span class='warning'>You can't make sense of the console or how to use it.</span>")
		return
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	user.set_machine(src)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=[UID()];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=[UID()];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=[UID()];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation] degrees</div>"
		t += "<A href='?src=[UID()];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle] degrees</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(crystals + telepad.efficiency < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='?src=[UID()];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='?src=[UID()];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<BR><A href='?src=[UID()];send=1'>Send</A>"
		t += " <A href='?src=[UID()];receive=1'>Receive</A>"
		t += "<BR><A href='?src=[UID()];recal=1'>Recalibrate Crystals</A> <A href='?src=[UID()];eject=1'>Eject Crystals</A>"

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
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		do_sparks(5, 1, get_turf(telepad))
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = Clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = Clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = Clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = Clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= 1

			// use a lot of power
			use_power(power * 10)

			do_sparks(5, 1, get_turf(telepad))

			temp_msg = "Teleport successful.<BR>"
			if(teles_left < 10)
				temp_msg += "<BR>Calibration required soon."
			else
				temp_msg += "Data printed below."

			var/sparks = get_turf(target)
			do_sparks(5, 1, sparks)

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			var/log_msg = ""
			log_msg += ": [key_name(user)] has teleported "

			if(sending)
				source = dest
				dest = target

			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
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
			log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			investigate_log(log_msg, "telesci")
			updateUsrDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		if(z_co == 7 & emagged == 1)
		// This should be empty, allows for it to continue if the z-level is 7 and the machine is emagged.
		else
			telefail()
			temp_msg = "ERROR! Sector is less than 1, <BR>greater than [src.emagged ? "7" : "6"], or equal to 2."
			return


	var/truePower = Clamp(power + power_off, 1, 1000)
	var/trueRotation = rotation + rotation_off
	var/trueAngle = Clamp(angle, 1, 90)

	var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
	var/turf/target = locate(Clamp(round(proj_data.dest_x, 1), 1, world.maxx), Clamp(round(proj_data.dest_y, 1), 1, world.maxy), z_co)
	var/area/A = get_area(target)

	if(A.tele_proof == 1)
		telefail()
		temp_msg = "ERROR! Target destination unreachable due to interference."
		return

	if(teles_left > 0)
		if(!doteleport(user))
			telefail()
			temp_msg = "ERROR! Target destination unreachable due to interference."
			return
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	var/to_eject
	for(var/i in 1 to crystals)
		to_eject += 1
		crystals -= 1
	new /obj/item/stack/ore/bluespace_crystal/artificial(drop_location(), to_eject)
	power = 0

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
		rotation = Clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = Clamp(round(new_angle, 0.1), 1, 9999)

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
		z_co = Clamp(round(new_z), 1, 10)

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
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateUsrDialog()

/obj/machinery/computer/telescience/proc/recalibrate()
	teles_left = rand(30, 40)
	//angle_off = rand(-25, 25)
	power_off = rand(-4, 0)
	rotation_off = rand(-10, 10)

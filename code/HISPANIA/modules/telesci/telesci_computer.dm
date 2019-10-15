/obj/machinery/computer/telescience/proto
	name = "proto telepad control console"
	desc = "Used to teleport living beings and bluespace containers to and from the telescience telepad."
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	circuit = /obj/item/circuitboard/telesci_console/proto

/obj/machinery/computer/telescience/New()
	..()
	recalibrate()

/obj/machinery/computer/telescience/proto/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = Clamp(power + power * power_off_factor + power_off, 1, 1000)
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
				if(istype(ROI, /mob/living) || istype(ROI, /obj/structure/closet/bluespace))
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

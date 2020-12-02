/area/toxins/teleci
	name = "\improper Teleci Lab"
	icon_state = "toxmisc"

/area/toxins/telereciver
	name = "\improper Teleci Reciver"
	icon_state = "toxmisc"

/obj/machinery/computer/telescience
	var/datum/tech/bluespace/bluespace_tech
	var/max_bluespace_tech = 7
	var/power_off_factor = 0

/obj/machinery/computer/telescience/proto
	name = "proto telepad control console"
	desc = "Used to teleport living beings and bluespace containers to and from the telescience telepad."
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	circuit = /obj/item/circuitboard/telesci_console/proto

/obj/machinery/computer/telescience/proto/loaded
	crystals = 4//max es 6 //con potencia cincuenta basta 4cristlaes+1ranting = 5

/obj/machinery/computer/telescience/proto/doteleport(mob/user)
	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)
		var/truePower = clamp(power + power * power_off_factor + power_off - abs((z-z_co)*power_off_factor), 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = clamp(round(proj_data.dest_y, 1), 1, world.maxy)
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
			for(var/obj/machinery/teleci_reciver/R in get_area(dest))
				R.revice_data(dest, src)
			. = FALSE
			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			for(var/atom/movable/ROI in source)
				if(ROI.anchored)
					continue// if is anchored, don't let through
				if(!istype(ROI, /obj/structure/closet/bluespace))
					continue//si no es un closet bluespace no lo teleporta
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
				. = TRUE//PARA QUE NO SALGA EL MENSAJE DE ERROR
			if(dd_hassuffix(log_msg, ", "))
				log_msg = dd_limittext(log_msg, length(log_msg) - 2)
			else
				log_msg += "nothing"
			log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			investigate_log(log_msg, "telesci")
			updateUsrDialog()

/obj/machinery/computer/telescience/proc/tech_upgrage_message()
	var/message = "Bluespace technology level upgraded to [bluespace_tech.level]. Swipe a technology disk to save data."
	atom_say(message)

/area
	var/list/teleci_reciver = list()

/obj/machinery/teleci_reciver//basicamente una antena, de momento solo existirá una, hubidaca en el z3
	name = "Antena telecientifica"
	desc = "Una antena capaz de percibir las interacciones bluespace."
	icon = 'icons/obj/machines/research.dmi'//TODO:sprite unico
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE//no quiero enrollarme mucho con esto y me gustaria poder ponerlo en cualquier sitio, a todos los aspectos esto es una estructura.
	var/area/area
	var/obj/item/gps/gps

/obj/machinery/teleci_reciver/New()
	. = ..()
	area = get_area(src)
	area.teleci_reciver |= src
	gps = new(src)
	gps.gpstag = "RECIVER"

/obj/machinery/teleci_reciver/Destroy()
	area.teleci_reciver -= src
	QDEL_NULL(gps)
	. = ..()

/obj/machinery/teleci_reciver/proc/revice_data(atom/target, obj/machinery/computer/telescience/source)
	var/new_dist = get_dist(src, target)
	if(source.max_bluespace_tech < new_dist)
		return
	source.atom_say("Una resonancia bluespace provocada por [src] provoca una recalibracion forzosa")
	source.recalibrate()//esto es un todo o nada, testeas en otro lado y luego apuntas a la entena
	var/tmp_tech = source.max_bluespace_tech - new_dist
	if(tmp_tech > source.bluespace_tech.level)
		source.bluespace_tech.level = tmp_tech
		source.tech_upgrage_message()
		if(source.bluespace_tech.level == source.max_bluespace_tech && source.bluespace_tech.level < initial(source.max_bluespace_tech)+3)
			source.max_bluespace_tech++//por cada vez que llegue al maximo aumenta un poco la tech maxima hasta cierto limite

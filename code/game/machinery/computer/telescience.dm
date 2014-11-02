/obj/machinery/computer/telescience
	name = "Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport-sci"

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var/x_co	// X coordinate
	var/y_co	// Y coordinate
	var/z_co	// Z coordinate
	var/trueX	// X + offset
	var/trueY	// Y + offset
	var/obj/machinery/telepad
	var/tele_id = "Telesci"

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	usr << "You are too primitive to use this computer."
	return

/obj/machinery/telescience/station/attack_ai(mob/user)
	src.attack_hand()

/obj/machinery/computer/telescience/attack_hand(mob/user)
	ui_interact(user)
	
/obj/machinery/computer/telescience/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	
	// On first use, the coordinates are null. Rather than displaying null, we'll set them to unset.
	if(!x_co)
		x_co = "Unset"
	if(!y_co)
		y_co = "Unset"
	if(!z_co)
		z_co = "Unset"
	
	var/data[0]
	data["coordx"] = x_co
	data["coordy"] = y_co
	data["coordz"] = z_co
	
	// Set up the Nano UI
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "telescience_console.tmpl", "Telescience Console UI", 640, 480)
		ui.set_initial_data(data)		
		ui.open()		

/obj/machinery/computer/telescience/proc/telefail(var/level)
	var/teleturf = get_turf(telepad)
	switch(level)
		if(1)
			for(var/mob/O in hearers(telepad, null))
				O.show_message("\red The telepad weakly fizzles.", 2)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, teleturf)
			s.start()
		if(2)
			for(var/mob/living/carbon/human/M in viewers(telepad, null))
				if(M.loc.loc == telepad.loc.loc) // Stops the geneticists with X-Ray vision getting irradiated
					M.apply_effect((rand(50, 100)), IRRADIATE, 0)
					M << "\red You feel irradiated."
		if(3)
			for(var/turf/simulated/floor/target_tile in range(0,telepad))
				var/datum/gas_mixture/napalm = new
				napalm.toxins = 25
				napalm.temperature = 2000
				target_tile.assume_air(napalm)
				spawn (0) target_tile.hotspot_expose(700, 400)
			for(var/mob/O in hearers(telepad, null))
				O.show_message("\red The telepad sets on fire!", 2)
		if(4)
			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/pirate,
				/mob/living/simple_animal/hostile/pirate/ranged,
				/mob/living/simple_animal/hostile/russian,
				/mob/living/simple_animal/hostile/russian/ranged,
				/mob/living/simple_animal/hostile/syndicate,
				/mob/living/simple_animal/hostile/syndicate/melee,
				/mob/living/simple_animal/hostile/syndicate/melee/space,
				/mob/living/simple_animal/hostile/syndicate/ranged,
				/mob/living/simple_animal/hostile/syndicate/ranged/space,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/giant_spider/nurse)
			var/list/hostiles = typesof(/mob/living/simple_animal/hostile) - blocked
			playsound(teleturf, 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/carbon/human/M in viewers(telepad, null))
				flick("e_flash", M.flash)
			var/chosen = pick(hostiles)
			var/mob/living/simple_animal/hostile/H = new chosen
			H.loc = teleturf
	return

/obj/machinery/computer/telescience/proc/teleprep(var/type)
	if(!telepad)
		usr << "\red Error: no associated telepad. Please recalibrate and try again."
		return
	var/numpick
	var/failure = checkFail()
	if(failure > 0)
		numpick = pick(1,1,1,1,1,2,2,2,2,3)
		telefail(numpick)
		return
	if(teles_left > 0)
		if(prob(75))
			teles_left -= 1
			tele(type)
			if(teles_left == 0)
				for(var/mob/O in hearers(src, null))
					O.show_message("\red The telepad has become uncalibrated.", 2)
			return
	else
		if(prob(35))
			tele(type)
		else
			numpick = pick(1,1,1,2,2,3,4)
			telefail(numpick)
		return
	numpick = pick(1,1,1,1,1,2,2,2,2,3)
	telefail(numpick)
	return

/obj/machinery/computer/telescience/proc/tele(var/type)
	var/tele = get_turf(telepad)
	trueX = (x_co + x_off)
	trueY = (y_co + y_off)
	var/target = locate(trueX, trueY, z_co)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, tele)
	s.start()
	flick("pad-beam", telepad)
	var/list/teleportables = list()
	switch(type)
		if(0)
			for(var/atom/A in tele)
				if(!istype(A, /obj/effect) && !istype(A, /mob/living/silicon/ai) && !istype(A, /obj/item/device/radio/intercom) && !istype(A, /obj/structure/closet/secure_closet/brig))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.anchored)
							teleportables += S
					else if(istype(A, /obj/machinery))
						var/obj/machinery/M = A
						if(!M.anchored)
							teleportables += M
					else
						teleportables += A
			for(var/atom/T in teleportables)
				do_teleport(T, target, 0)
			usr << "\blue Teleport successful."
		if(1)
			for(var/atom/A in target)
				if(!istype(A, /obj/effect) && !istype(A, /mob/living/silicon/ai) && !istype(A, /obj/item/device/radio/intercom))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.anchored)
							teleportables += S
					else if(istype(A, /obj/machinery))
						var/obj/machinery/M = A
						if(!M.anchored)
							teleportables += M
					else
						teleportables += A
			for(var/atom/T in teleportables)
				do_teleport(T, tele, 0)
			usr << "\blue Teleport successful."
	return

/obj/machinery/computer/telescience/proc/checkFail()
	var/fail = 0
	if(x_co == "" || x_co == "Unset")
		usr << "\red Error: set X coordinate."
		fail = 1
	if(y_co == "" || y_co == "Unset")
		usr << "\red Error: set Y coordinate."
		fail = 1
	if(z_co == "" || z_co == "Unset")
		usr << "\red Error: set Z coordinate."
		fail = 1
	if(x_co < 11 || x_co > 245)
		usr << "\red Error: X is less than 11 or greater than 245."
		fail = 1
	if(y_co < 11 || y_co > 245)
		usr << "\red Error: Y is less than 11 or greater than 245."
		fail = 1
	if(z_co == 2 || z_co < 1 || z_co > 6)
		if (z_co == 7 & src.emagged == 1)
		// This should be empty, allows for it to continue if the z-level is 7 and the machine is emagged.
		else
			usr << "\red Error: Z is less than 1, greater than [src.emagged ? "7" : "6"], or equal to 2."
			fail = 1
	if(istype(get_area(locate(x_co,y_co,z_co)), /area/security/armoury/gamma))
		usr << "\red Error: Attempting to access telescience-protected area."
		fail = 1
	return fail

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(href_list["setx"])
		var/a = input("Please input desired X coordinate.", name, x_co) as num
		a = copytext(sanitize(a), 1, 20)
		x_co = a
		x_co = text2num(x_co)
		nanomanager.update_uis(src)
		return
	if(href_list["sety"])
		var/b = input("Please input desired Y coordinate.", name, y_co) as num
		b = copytext(sanitize(b), 1, 20)
		y_co = b
		y_co = text2num(y_co)
		nanomanager.update_uis(src)
		return
	if(href_list["setz"])
		var/c = input("Please input desired Z coordinate.", name, z_co) as num
		c = copytext(sanitize(c), 1, 20)
		z_co = c
		z_co = text2num(z_co)
		nanomanager.update_uis(src)
		return
	if(href_list["send"])
		teleprep(0)
		nanomanager.update_uis(src)
		return
	if(href_list["receive"])
		teleprep(1)
		nanomanager.update_uis(src)
		return
	if(href_list["recal"])
		if(telepad == null)
			for(var/obj/machinery/telepad/T in range(src,10))
				telepad = T
		if(!telepad)	
			return
		var/teleturf = get_turf(telepad)
		teles_left = rand(8,12)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, teleturf)
		s.start()
		usr << "\blue Calibration successful."
		nanomanager.update_uis(src)
		return

/obj/machinery/computer/telescience/attackby(I as obj, user as mob) // Emagging
	if(istype(I,/obj/item/weapon/card/emag))
		if (src.emagged == 0)
			user << "\blue You scramble the Telescience authentication key to an unknown signal. You should be able to teleport to more places now!"
			src.emagged = 1
		else
			user << "\red The machine seems unaffected by the card swipe..."
	else
		return attack_hand(user)
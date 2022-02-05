/*

Miscellaneous traitor devices

BATTERER


*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 5

/obj/item/batterer/examine(mob/user)
	. = ..()
	if(times_used >= max_uses)
		. += "<span class='notice'>[src] is out of charge.</span>"
	if(times_used < max_uses)
		. += "<span class='notice'>[src] has [max_uses-times_used] charges left.</span>"

/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user)
		return
	if(times_used >= max_uses)
		to_chat(user, "<span class='danger'>The mind batterer has been burnt out!</span>")
		return


	for(var/mob/living/carbon/human/M in oview(7, user))
		if(prob(50))
			M.Weaken(rand(1,3))
			M.adjustStaminaLoss(rand(25, 60))
			add_attack_logs(user, M, "Stunned with [src]")
			to_chat(M, "<span class='danger'>You feel a tremendous, paralyzing wave flood your mind.</span>")
		else
			to_chat(M, "<span class='danger'>You feel a sudden, electric jolt travel through your head.</span>")

	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	times_used++
	to_chat(user, "<span class='notice'>You trigger [src]. It has [max_uses-times_used] charges left.</span>")
	if(times_used >= max_uses)
		icon_state = "battererburnt"


/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/rad_laser
	name = "Health Analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health2"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. A strange microlaser is hooked on to the scanning end."
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=1"
	var/intensity = 5 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/rad_laser/attack(mob/living/M, mob/living/user)
	if(!used)
		add_attack_logs(user, M, "Irradiated by [src]")
		user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>")
		var/cooldown = round(max(100,(((intensity*8)-(wavelength/2))+(intensity*2))*10))
		used = 1
		icon_state = "health1"
		handle_cooldown(cooldown) // splits off to handle the cooldown while handling wavelength
		spawn((wavelength+(intensity*4))*10)
			if(M)
				if(intensity >= 5)
					M.apply_effect(round(intensity/1.5), PARALYZE)
				M.apply_effect(intensity*10, IRRADIATE)
	else
		to_chat(user, "<span class='warning'>The radioactive microlaser is still recharging.</span>")

/obj/item/rad_laser/proc/handle_cooldown(cooldown)
	spawn(cooldown)
		used = 0
		icon_state = "health2"

/obj/item/rad_laser/attack_self(mob/user)
	..()
	interact(user)

/obj/item/rad_laser/interact(mob/user)
	user.set_machine(src)

	var/cooldown = round(max(10,((intensity*8)-(wavelength/2))+(intensity*2)))
	var/dat = {"<meta charset="UTF-8">
	Radiation Intensity: <A href='?src=[UID()];radint=-5'>-</A><A href='?src=[UID()];radint=-1'>-</A> [intensity] <A href='?src=[UID()];radint=1'>+</A><A href='?src=[UID()];radint=5'>+</A><BR>
	Radiation Wavelength: <A href='?src=[UID()];radwav=-5'>-</A><A href='?src=[UID()];radwav=-1'>-</A> [(wavelength+(intensity*4))] <A href='?src=[UID()];radwav=1'>+</A><A href='?src=[UID()];radwav=5'>+</A><BR>
	Laser Cooldown: [cooldown] Seconds<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()

/obj/item/rad_laser/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(10,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(1,(min(120,amount)))

	attack_self(usr)
	add_fingerprint(usr)
	return

/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	var/active = FALSE
	var/range = 12

/obj/item/jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()

/obj/item/jammer/attack_self(mob/user)
	to_chat(user,"<span class='notice'>You [active ? "deactivate" : "activate"] the [src].</span>")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src

/obj/item/teleporter
	name = "Syndicate teleporter"
	desc = "A strange syndicate version of a cult veil shifter. Warrenty voided if exposed to EMP."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-tele"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"
	var/tp_range = 8
	var/inner_tp_range = 3
	var/charges = 4
	var/max_charges = 4
	var/saving_throw_distance = 3
	var/flawless = FALSE

/obj/item/teleporter/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/teleporter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/teleporter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has [charges] out of [max_charges] charges left.</span>"

/obj/item/teleporter/attack_self(mob/user)
	attempt_teleport(user, FALSE)

/obj/item/teleporter/process()
	if(prob(10) && charges < max_charges)
		charges++

/obj/item/teleporter/emp_act(severity)
	if(prob(50 / severity))
		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='danger'>The [src] buzzes and activates!</span>")
			attempt_teleport(user, TRUE)
		else
			visible_message("<span class='warning'> The [src] activates and blinks out of existence!</span>")
			do_sparks(2, 1, src)
			qdel(src)

/obj/item/teleporter/proc/attempt_teleport(mob/user, EMP_D = FALSE)
	dir_correction(user)
	if(!charges)
		to_chat(user, "<span class='warning'>The [src] is recharging still.</span>")
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = new/list()
	var/found_turf = FALSE
	var/list/bagholding = user.search_contents_for(/obj/item/storage/backpack/holding)
	for(var/turf/T in range(user, tp_range))
		if(!is_teleport_allowed(T.z))
			break
		if(!(length(bagholding) && !flawless)) //Chaos if you have a bag of holding
			if(get_dir(C, T) != C.dir)
				continue
		if(T in range(user, inner_tp_range))
			continue
		if(T.x > world.maxx-tp_range || T.x < tp_range)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-tp_range || T.y < tp_range)
			continue

		turfs += T
		found_turf = TRUE

	if(found_turf)
		if(user.loc != mobloc) // No locker / mech / sleeper teleporting, that breaks stuff
			to_chat(C, "<span class='danger'>The [src] will not work here!</span>")
		charges--
		var/turf/destination = pick(turfs)
		if(tile_check(destination) || flawless) // Why is there so many bloody floor types
			var/turf/fragging_location = destination
			telefrag(fragging_location, user)
			C.forceMove(destination)
			playsound(mobloc, "sparks", 50, TRUE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
			playsound(destination, "sparks", 50, TRUE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		else if (EMP_D == FALSE && !(bagholding.len && !flawless)) // This is where the fun begins
			var/direction = get_dir(user, destination)
			panic_teleport(user, destination, direction)
		else // Emp activated? Bag of holding? No saving throw for you
			get_fragged(user, destination)
	else
		to_chat(C, "<span class='danger'>The [src] will not work here!</span>")

/obj/item/teleporter/proc/tile_check(turf/T)
	if(istype(T, /turf/simulated/floor) || istype(T, /turf/space) || istype(T, /turf/simulated/shuttle/floor) || istype(T, /turf/simulated/shuttle/floor4) || istype(T, /turf/simulated/shuttle/plating))
		return TRUE

/obj/item/teleporter/proc/dir_correction(mob/user) //Direction movement, screws with teleport distance and saving throw, and thus must be removed first
	var/temp_direction = user.dir
	switch(temp_direction)
		if(NORTHEAST || SOUTHEAST)
			user.dir = EAST
		if(NORTHWEST || SOUTHWEST)
			user.dir = WEST

/obj/item/teleporter/proc/panic_teleport(mob/user, turf/destination, direction = NORTH)
	var/saving_throw
	switch(direction)
		if(NORTH || SOUTH)
			if(prob(50))
				saving_throw = EAST
			else
				saving_throw = WEST
		if(EAST || WEST)
			if(prob(50))
				saving_throw = NORTH
			else
				saving_throw = SOUTH
		else
			saving_throw = NORTH // just in case

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = list()
	var/found_turf = FALSE
	for(var/turf/T in range(destination, saving_throw_distance))
		if(get_dir(destination, T) != saving_throw)
			continue
		if(T.x > world.maxx-saving_throw_distance || T.x < saving_throw_distance)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-saving_throw_distance || T.y < saving_throw_distance)
			continue
		if(!tile_check(T))
			continue // We are only looking for safe tiles on the saving throw, since we are nice
		turfs += T
		found_turf = TRUE

	if(found_turf)
		var/turf/new_destination = pick(turfs)
		var/turf/fragging_location = new_destination
		telefrag(fragging_location, user)
		C.forceMove(new_destination)
		playsound(mobloc, "sparks", 50, TRUE)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(new_destination)
		playsound(new_destination, "sparks", 50, TRUE)
	else //We tried to save. We failed. Death time.
		get_fragged(user, destination)


/obj/item/teleporter/proc/get_fragged(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	user.forceMove(destination)
	playsound(mobloc, "sparks", 50, TRUE)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	playsound(destination, "sparks", 50, TRUE)
	playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE)
	destination.ex_act(rand(1,2))
	for(var/obj/item/W in user)
		if(istype(W, /obj/item/organ)|| istype(W, /obj/item/implant))
			continue
		if(!user.unEquip(W))
			qdel(W)
	to_chat(user, "<span class='biggerdanger'>You teleport into the wall, the teleporter tries to save you, but--</span>")
	user.gib()

/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/M in fragging_location)//Hit everything in the turf
		M.apply_damage(20, BRUTE)
		M.Stun(3)
		M.Weaken(3)
		to_chat(M, "<span_class='warning'> [user] teleports into you, knocking you to the floor with the bluespace wave!</span>")

/obj/item/paper/teleporter
	name = "Teleporter Guide"
	icon_state = "paper"
	info = {"<b>Instructions on your new prototype syndicate teleporter</b><br>
	<br>
	This teleporter will teleport the user 4-8 meters in the direction they are facing. Unlike the cult veil shifter, you can not drag people with you.<br>
	<br>
	It has 4 charges, and will recharge uses over time. No, sticking the teleporter into the tesla, an APC, a microwave, or an electrified door, will not make it charge faster.<br>
	<br>
	<b>Warning:</b> Teleporting into walls will activate a failsafe teleport parallel up to 3 meters, but the user will be ripped apart and gibbed in a wall if it fails.<br>
	<br>
	Do not expose the teleporter to electromagnetic pulses or attempt to use with a bag of holding, unwanted malfunctions may occur.
"}
/obj/item/storage/box/syndie_kit/teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/teleporter/New()
	..()
	new /obj/item/teleporter(src)
	new /obj/item/paper/teleporter(src)
	return

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5

/obj/item/teleporter/admin
	desc = "A strange syndicate version of a cult veil shifter. \n This one seems EMP proof, and with much better saftey protocols."
	charges = 8
	max_charges = 8
	flawless = TRUE

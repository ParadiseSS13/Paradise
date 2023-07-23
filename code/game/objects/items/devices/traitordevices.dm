/obj/item/jammer
	name = "radio jammer"
	desc = "Fog of war that fits your pocket. Flicking the switch and extending the antenna will scramble nearby radio comms, making outgoing messages hard to understand."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	item_state = "jammer"
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/toggle_radio_jammer)
	var/active = FALSE
	var/range = 12

/obj/item/jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()

/obj/item/jammer/update_icon_state()
	if(active)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/jammer/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You [active ? "deactivate [src]. It goes quiet with a small click." : "activate [src]. It starts to hum softly."] </span>")
	active = !active
	update_icon(UPDATE_ICON_STATE)
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	for(var/datum/action/item_action/toggle_radio_jammer/A in actions)
		A.UpdateButtonIcon()

/obj/item/teleporter
	name = "syndicate teleporter"
	desc = "A strange syndicate version of a cult veil shifter. Warranty voided if exposed to EMP."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-tele-4"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"
	var/list/icons_charges = list(
		"syndi-tele-0",
		"syndi-tele-1",
		"syndi-tele-2",
		"syndi-tele-3",
		"syndi-tele-4",
	)
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
		update_icon_charges()

/obj/item/teleporter/emp_act(severity)
	var/teleported_something = FALSE
	if(prob(50 / severity))
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='userdanger'>[src] buzzes and activates!</span>")
			attempt_teleport(user, TRUE)
		else //Well, it either is on a floor / locker, and won't teleport someone, OR it's in someones bag. As such, we need to check the turf to see if people are there.
			var/turf/teleport_turf = get_turf(src)
			for(var/mob/living/user in teleport_turf)
				if(!teleported_something)
					teleport_turf.visible_message("<span class='danger'>[src] activates sporadically, teleporting everyone around it!</span>")
					teleported_something = TRUE
				attempt_teleport(user, TRUE)
			if(!teleported_something)
				visible_message("<span class='danger'>[src] activates and blinks out of existence!</span>")
				do_sparks(2, 1, src)
				qdel(src)

/obj/item/teleporter/proc/update_icon_charges()
	if(charges + 1 > length(icons_charges))
		icon_state = initial(icon_state)
		return
	icon_state = icons_charges[charges + 1]

/obj/item/teleporter/proc/attempt_teleport(mob/user, EMP_D = FALSE)
	dir_correction(user)
	if(!charges && !EMP_D) //If it's empd, you are moving no matter what.
		to_chat(user, "<span class='warning'>[src] is still recharging.</span>")
		return

	var/mob/living/M = user
	var/turf/mobloc = get_turf(M)
	var/list/turfs = new/list()
	var/found_turf = FALSE
	var/list/bagholding = user.search_contents_for(/obj/item/storage/backpack/holding)
	for(var/turf/T in range(user, tp_range))
		if(!is_teleport_allowed(T.z))
			break
		if(!(length(bagholding) && !flawless)) //Chaos if you have a bag of holding
			if(get_dir(M, T) != M.dir)
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
			to_chat(M, "<span class='danger'>[src] will not work here!</span>")
		if(charges > 0) //While we want EMP triggered teleports to drain charge, we also do not want it to go negative charge, as such we need this check here
			charges--
			update_icon_charges()
		var/turf/destination = pick(turfs)
		if(tile_check(destination) || flawless) // Why is there so many bloody floor types
			var/turf/fragging_location = destination
			telefrag(fragging_location, user)
			M.forceMove(destination)
			playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
			playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		else if (EMP_D == FALSE && !(bagholding.len && !flawless)) // This is where the fun begins
			var/direction = get_dir(user, destination)
			panic_teleport(user, destination, direction)
		else // Emp activated? Bag of holding? No saving throw for you
			get_fragged(user, destination)
	else
		to_chat(M, "<span class='danger'>[src] will not work here!</span>")

/obj/item/teleporter/proc/tile_check(turf/T)
	if(isfloorturf(T) || isspaceturf(T))
		return TRUE

/obj/item/teleporter/proc/dir_correction(mob/user) //Direction movement, screws with teleport distance and saving throw, and thus must be removed first
	var/temp_direction = user.dir
	switch(temp_direction)
		if(NORTHEAST, SOUTHEAST)
			user.dir = EAST
		if(NORTHWEST, SOUTHWEST)
			user.dir = WEST

/obj/item/teleporter/proc/panic_teleport(mob/user, turf/destination, direction = NORTH)
	var/saving_throw
	switch(direction)
		if(NORTH, SOUTH)
			if(prob(50))
				saving_throw = EAST
			else
				saving_throw = WEST
		if(EAST, WEST)
			if(prob(50))
				saving_throw = NORTH
			else
				saving_throw = SOUTH
		else
			saving_throw = NORTH // just in case

	var/mob/living/M = user
	var/turf/mobloc = get_turf(M)
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
		M.forceMove(new_destination)
		playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(new_destination)
		playsound(new_destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else //We tried to save. We failed. Death time.
		get_fragged(user, destination)


/obj/item/teleporter/proc/get_fragged(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	user.forceMove(destination)
	playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE)
	destination.ex_act(rand(1,2))
	if(iscarbon(user)) //don't want cyborgs dropping their stuff
		for(var/obj/item/W in user)
			if(istype(W, /obj/item/implant))
				continue
			if(!user.unEquip(W))
				qdel(W)
	to_chat(user, "<span class='biggerdanger'>You teleport into the wall, the teleporter tries to save you, but--</span>")
	user.gib()

/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/M in fragging_location)//Hit everything in the turf
		M.apply_damage(20, BRUTE)
		M.Weaken(6 SECONDS)
		to_chat(M, "<span_class='warning'>[user] teleports into you, knocking you to the floor with the bluespace wave!</span>")

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
	<br><hr>
	<font size =\"1\">Comes with free chameleon mesons, to help you stay stylish while seeing through walls.</font>
"}
/obj/item/storage/box/syndie_kit/teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/teleporter/populate_contents()
	new /obj/item/teleporter(src)
	new /obj/item/clothing/glasses/meson/chameleon(src)
	new /obj/item/paper/teleporter(src)

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5

/obj/item/teleporter/admin
	desc = "A strange syndicate version of a cult veil shifter. \n This one seems EMP proof, and with much better safety protocols."
	charges = 8
	max_charges = 8
	flawless = TRUE

/obj/item/batterer
	name = "mind batterer"
	desc = "A dangerous syndicate device focused on crowd control and escapes. Causes brain damage, confusion, and other nasty effects to those surrounding the user."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	/// How many times the mind batter has been used
	var/times_used = 0
	var/max_uses = 5
	/// Is this item on cooldown from being thrown
	var/on_throwing_cooldown = FALSE

/obj/item/batterer/examine(mob/user)
	. = ..()
	. += "<span class='warning'>A little label on the side reads: \"Warning: Using this item in quick succession may cause fatigue to the user!\"</span>"
	if(times_used >= max_uses)
		. += "<span class='notice'>[src] is out of charge.</span>"
	if(times_used < max_uses)
		. += "<span class='notice'>[src] has [max_uses-times_used] charges left.</span>"

/obj/item/batterer/attack_self(mob/living/carbon/user)
	activate_batterer(user)

/obj/item/batterer/proc/activate_batterer(mob/user)
	times_used++
	if(user)
		if(times_used >= max_uses)
			to_chat(user, "<span class='danger'>The mind batterer has been burnt out!</span>")
			return
		if(!do_after_once(user, 2 SECONDS, target = src, allow_moving = TRUE, attempt_cancel_message = "You think it's best to save this for later."))
			times_used--
			return
		to_chat(user, "<span class='notice'>You trigger [src]. It has [max_uses-times_used] charges left.</span>")

	for(var/mob/living/M in oview(7, get_turf(src)))
		if(issilicon(M))
			M.Weaken(10 SECONDS)
		else
			M.Confused(30 SECONDS)
		M.adjustBrainLoss(10)
		to_chat(M, "<span class='danger'>You feel a sudden, electric jolt travel through yourself,</span>")
		switch(rand(1, 10))
			if(1)
				M.apply_status_effect(STATUS_EFFECT_CLINGTENTACLE_BATTERER)
				to_chat(M, "<span class='warning'>and your legs lock up for a moment!</span>")
			if(2)
				M.apply_status_effect(STATUS_EFFECT_PACIFIED_BATTERER)
				to_chat(M, "<span class='warning'>and you feel an innate love for life for a fleeting moment!</span>")
			if(3)
				new /obj/effect/hallucination/delusion(get_turf(M), M)
				to_chat(M, "<span class='warning'>and the people around you morph in appearence!</span>")
			if(4)
				if(prob(80))
					M.EyeBlurry(25 SECONDS)
					to_chat(M, "<span class='warning'>and something in the back of your head stings like hell!</span>")
				else
					M.EyeBlind(15 SECONDS)
					to_chat(M, "<span class='warning'>and you can't see a goddamn thing!</span>")
			if(5)
				M.adjustStaminaLoss(40)
				to_chat(M, "<span class='warning'>and a wave of tiredness washes over you!</span>")
			else
				to_chat(M, "<span class='danger'>but as soon as it arrives, it fades.</span>")
		add_attack_logs(user, M, "Mind battered with [src]")

	playsound(get_turf(src), 'sound/misc/interference.ogg', 50, TRUE)
	if(times_used >= max_uses)
		icon_state = "battererburnt"

/obj/item/batterer/throw_impact(atom/hit_atom)
	..()
	if(times_used >= max_uses || on_throwing_cooldown)
		return
	addtimer(CALLBACK(src, PROC_REF(end_throwing_delay)), 3 SECONDS)
	visible_message("<span class='notice'>[src] suddenly triggers, sending a shower of sparks everywhere!</span>")
	do_sparks(4, FALSE, get_turf(src))
	activate_batterer()
	on_throwing_cooldown = TRUE

/obj/item/batterer/proc/end_throwing_delay()
	on_throwing_cooldown = FALSE

/obj/item/batterer/emp_act(severity)
	if(times_used >= max_uses)
		return
	visible_message("<span class='notice'>[src] explodes into a light show of colors!</span>")
	if(severity == EMP_HEAVY)
		activate_batterer()

	times_used = max_uses - 1
	activate_batterer()

/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	flags = ON_BORDER
	opacity = FALSE
	dir = EAST
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list(MELEE = 20, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, RAD = 100, FIRE = 70, ACID = 100)
	glass = TRUE // Used by polarized helpers. Windoors are always glass.
	var/obj/item/airlock_electronics/electronics
	var/base_state = "left"
	var/reinf = FALSE
	var/shards = 2
	var/rods = 2
	var/cable = 1
	/// Color for the window if it gets changed at some point, to preserve painter functionality
	var/old_color

/obj/machinery/door/window/New(loc, set_dir)
	..()
	if(set_dir)
		setDir(set_dir)

/obj/machinery/door/window/Initialize(mapload)
	. = ..()
	if(req_access && req_access.len)
		base_state = icon_state

/obj/machinery/door/window/Destroy()
	density = FALSE
	if(obj_integrity == 0)
		playsound(src, "shatter", 70, 1)
	QDEL_NULL(electronics)
	return ..()

/obj/machinery/door/window/toggle_polarization()
	polarized_on = !polarized_on

	if(!polarized_on)
		if(!old_color)
			old_color = "#FFFFFF"
		animate(src, color = old_color, time = 0.5 SECONDS)
		set_opacity(FALSE)
	else
		old_color = color
		animate(src, color = "#222222", time = 0.5 SECONDS)
		set_opacity(TRUE)

/obj/machinery/door/window/update_icon_state()
	if(density)
		icon_state = base_state
	else
		icon_state = "[base_state]open"

/obj/machinery/door/window/examine(mob/user)
	. = ..()
	if(emagged)
		. += "<span class='warning'>Its access panel is smoking slightly.</span>"
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += "<span class='warning'>The access panel is coated in yellow ooze...</span>"

/obj/machinery/door/window/emp_act(severity)
	. = ..()
	if(prob(20 / severity))
		open()

/obj/machinery/door/window/proc/open_and_close()
	open()
	addtimer(CALLBACK(src, PROC_REF(check_close)), check_access(null) ? 5 SECONDS : 2 SECONDS)


/// Check whether or not this door can close, based on whether or not someone's standing in front of it holding it open
/obj/machinery/door/window/proc/check_close()
	var/mob/living/blocker = locate(/mob/living) in get_turf(get_step(src, dir))  // check the facing turf
	if(!blocker || blocker.stat || !allowed(blocker))
		blocker = locate(/mob/living) in get_turf(src)
	if(blocker && !blocker.stat && allowed(blocker))
		// kick the can down the road, someone's holding the door.
		addtimer(CALLBACK(src, PROC_REF(check_close)), check_access(null) ? 5 SECONDS : 2 SECONDS)
		return

	close()

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(ismecha(AM))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && allowed(mecha.occupant))
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(FALSE)
					return
				open_and_close()
			else
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(TRUE)
					return
				do_animate("deny")
		return
	if(!SSticker)
		return
	var/mob/living/M = AM
	if(!M.restrained() && M.mob_size > MOB_SIZE_TINY && (!(isrobot(M) && M.stat)))
		bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	if(!requiresID() || allowed(user))
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			cmag_switch(FALSE, user)
			return
		open_and_close()
	else
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			cmag_switch(TRUE, user)
			return
		do_animate("deny")

/obj/machinery/door/window/unrestricted_side(mob/M)
	var/mob_dir = get_dir(src, M)
	if(mob_dir == 0) // If the mob is inside the tile
		mob_dir = GetOppositeDir(dir) // Set it to the inside direction of the windoor

	return mob_dir & unres_sides

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(HAS_TRAIT(living_mover, TRAIT_CONTORTED_BODY) && IS_HORIZONTAL(living_mover))
			return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	else
		return 1

/obj/machinery/door/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanPathfindPass(obj/item/card/id/ID, to_dir, no_id = FALSE)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(HAS_TRAIT(living_mover, TRAIT_CONTORTED_BODY) && IS_HORIZONTAL(living_mover))
			return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(forced=0)
	if(operating) //doors can still open when emag-disabled
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	if(!operating) //in case of emag
		operating = DOOR_OPENING
	do_animate("opening")
	set_opacity(FALSE)
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state ="[base_state]open"
	sleep(10)

	density = FALSE
//	sd_set_opacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating) //emag again
		operating = NONE
	return 1

/obj/machinery/door/window/close(forced=0)
	if(operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	operating = DOOR_CLOSING
	do_animate("closing")
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state = base_state

	density = TRUE
	if(polarized_on)
		set_opacity(TRUE)
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	operating = NONE
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && !disassembled)
		for(var/obj/item/shard/debris in spawnDebris(drop_location()))
			transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)

/obj/machinery/door/window/proc/spawnDebris(location)
	. = list()
	for(var/i in 1 to shards)
		. += new /obj/item/shard(location)
	if(rods)
		. += new /obj/item/stack/rods(location, rods)
	if(cable)
		. += new /obj/item/stack/cable_coil(location, cable)

/obj/machinery/door/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/obj/machinery/door/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 200), BURN, 0, 0)

/obj/machinery/door/window/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/window/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && M.environment_smash >= ENVIRONMENT_SMASH_WALLS)
		playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
		deconstruct(FALSE)
		M.visible_message("<span class='danger'>[M] smashes through [src]!</span>", "<span class='notice'>You smash through [src].</span>")

/obj/machinery/door/window/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/window/attack_hand(mob/user)
	return try_to_activate_door(user)

/obj/machinery/door/window/emag_act(mob/user, obj/weapon)
	if(!operating && density && !emagged)
		emagged = TRUE
		operating = DOOR_MALF
		electronics = new /obj/item/airlock_electronics/destroyed()
		flick("[base_state]spark", src)
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(6)
		operating = NONE
		open(2)
		return 1

/obj/machinery/door/window/cmag_act(mob/user, obj/weapon)
	if(operating || !density || HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	operating = DOOR_MALF
	flick("[base_state]spark", src)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	sleep(6)
	operating = NONE
	return TRUE

/obj/machinery/door/window/attackby(obj/item/I, mob/living/user, params)
	//If it's in the process of opening/closing, ignore the click
	if(operating)
		return

	add_fingerprint(user)
	return ..()

/obj/machinery/door/window/screwdriver_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(density || operating)
		to_chat(user, "<span class='warning'>You need to open the door to access the maintenance panel!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the [src.name].</span>")


/obj/machinery/door/window/crowbar_act(mob/user, obj/item/I)
	if(operating)
		return
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(panel_open && !density && !operating)
		user.visible_message("<span class='warning'>[user] removes the electronics from the [name].</span>", \
							"You start to remove electronics from the [name]...")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(panel_open && !density && !operating && loc)
				var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(loc)
				switch(base_state)
					if("left")
						WA.facing = "l"
					if("right")
						WA.facing = "r"
					if("leftsecure")
						WA.facing = "l"
						WA.secure = TRUE
					if("rightsecure")
						WA.facing = "r"
						WA.secure = TRUE
				WA.polarized_glass = polarized_glass
				WA.anchored = TRUE
				WA.state= "02"
				WA.setDir(dir)
				WA.ini_dir = dir
				WA.update_icon()
				if(WA.secure)
					WA.name = "secure wired windoor assembly"
				else
					WA.name = "wired windoor assembly"

				to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

				var/obj/item/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/airlock_electronics(loc)
					if(!req_access)
						check_access()
					if(req_access.len)
						ae.selected_accesses = req_access
					else if(req_one_access.len)
						ae.selected_accesses = req_one_access
						ae.one_access = 1
				else
					ae = electronics
					electronics = null
					ae.forceMove(loc)

				qdel(src)
	else
		try_to_crowbar(user, I)

/obj/machinery/door/window/try_to_crowbar(mob/user, obj/item/I)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		to_chat(user, "<span class='warning'>The door's motors resist your efforts to force it!</span>")

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)

/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = TRUE
	explosion_block = 1

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/clockwork
	name = "brass windoor"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	cable = 0
	resistance_flags = ACID_PROOF | FIRE_PROOF
	var/made_glow = FALSE

/obj/machinery/door/window/clockwork/crowbar_act(mob/user, obj/item/I)
	if(operating)
		return
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	try_to_crowbar(user, I)

/obj/machinery/door/window/clockwork/welder_act(mob/user, obj/item/I)
	if(operating)
		return
	if(flags & NODECONSTRUCT)
		return
	if(!panel_open)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return
	if(!panel_open && operating && !loc)
		return
	WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
	var/obj/item/stack/tile/brass/B = new (get_turf(src), 2)
	B.add_fingerprint(user)
	qdel(src)

/obj/machinery/door/window/clockwork/spawnDebris(location)
	. = ..()
	. = new /obj/item/stack/tile/brass(location, 2)

/obj/machinery/door/window/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/door/window(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/machinery/door/window/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/window/clockwork/hasPower()
	return TRUE //yup that's power all right

/obj/machinery/door/window/clockwork/narsie_act()
	take_damage(rand(30, 60), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/cell/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/cell/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/cell/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/cell/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

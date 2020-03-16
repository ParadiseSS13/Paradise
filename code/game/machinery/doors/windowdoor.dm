/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	visible = 0
	flags = ON_BORDER
	opacity = 0
	dir = EAST
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	var/obj/item/airlock_electronics/electronics
	var/base_state = "left"
	var/reinf = 0
	var/cancolor = TRUE
	var/shards = 2
	var/rods = 2
	var/cable = 1
	var/list/debris = list()

/obj/machinery/door/window/New(loc, set_dir)
	..()
	if(set_dir)
		setDir(set_dir)
	if(req_access && req_access.len)
		icon_state = "[icon_state]"
		base_state = icon_state
	if(!color && cancolor)
		color = color_windows(src)
	for(var/i in 1 to shards)
		debris += new /obj/item/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)
	if(cable)
		debris += new /obj/item/stack/cable_coil(src, cable)

/obj/machinery/door/window/Destroy()
	density = FALSE
	QDEL_LIST(debris)
	if(obj_integrity == 0)
		playsound(src, "shatter", 70, 1)
	QDEL_NULL(electronics)
	return ..()

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[base_state]open"

/obj/machinery/door/window/examine(mob/user)
	. = ..()
	if(emagged)
		. += "<span class='warning'>Its access panel is smoking slightly.</span>"

/obj/machinery/door/window/proc/open_and_close()
	open()
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(ismecha(AM))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && allowed(mecha.occupant))
				open_and_close()
			else
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
		open_and_close()
	else
		do_animate("deny")

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
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
/obj/machinery/door/window/CanAStarPass(obj/item/card/id/ID, to_dir)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
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
		operating = TRUE
	do_animate("opening")
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state ="[base_state]open"
	sleep(10)

	density = FALSE
//	sd_set_opacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating) //emag again
		operating = FALSE
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
	operating = TRUE
	do_animate("closing")
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state = base_state

	density = 1
//	if(visible)
//		set_opacity(1)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	operating = 0
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && !disassembled)
		for(var/obj/fragment in debris)
			fragment.forceMove(get_turf(src))
			transfer_fingerprints_to(fragment)
			debris -= fragment
	qdel(src)

/obj/machinery/door/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/obj/machinery/door/window/ratvar_act()
	var/obj/machinery/door/window/clockwork/C = new(loc, dir)
	C.name = name
	qdel(src)

/obj/machinery/door/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 200), BURN, 0, 0)

/obj/machinery/door/window/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/window/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/window/attack_hand(mob/user)
	return try_to_activate_door(user)

/obj/machinery/door/window/emag_act(mob/user, obj/weapon)
	if(!operating && density && !emagged)
		emagged = TRUE
		operating = TRUE
		flick("[base_state]spark", src)
		playsound(src, "sparks", 75, 1)
		sleep(6)
		operating = FALSE
		open(2)
		return 1

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
				WA.anchored = TRUE
				WA.state= "02"
				WA.setDir(dir)
				WA.ini_dir = dir
				WA.update_icon()
				WA.created_name = name

				if(emagged)
					to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
					qdel(src)
					return

				to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

				var/obj/item/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/airlock_electronics(loc)
					if(!req_access)
						check_access()
					if(req_access.len)
						ae.conf_access = req_access
					else if(req_one_access.len)
						ae.conf_access = req_one_access
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
	reinf = 1
	explosion_block = 1
	var/id = null

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(access_brig)

/obj/machinery/door/window/clockwork
	name = "brass windoor"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	resistance_flags = ACID_PROOF | FIRE_PROOF
	cancolor = FALSE
	var/made_glow = FALSE

/obj/machinery/door/window/clockwork/New(loc, set_dir)
	..()
	debris += new/obj/item/stack/tile/brass(src, 2)

/obj/machinery/door/window/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/door/window(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/machinery/door/window/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/window/clockwork/ratvar_act()
	obj_integrity = max_integrity

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

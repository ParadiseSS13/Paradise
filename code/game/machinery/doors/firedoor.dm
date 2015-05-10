/var/const/OPEN = 1
/var/const/CLOSED = 2

/obj/machinery/door/firedoor
	name = "Firelock"
	desc = "Apply crowbar"
	icon = 'icons/obj/doors/Doorfireglass.dmi'
	icon_state = "door_open"
	opacity = 0
	density = 0
	heat_proof = 1
	glass = 1
	power_channel = ENVIRON

	var/list/areas_added

	var/blocked = 0
	var/nextstate = null

	var/logged_users

/obj/machinery/door/firedoor/New()
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			spawn(1)
				del src
			return .

	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			A.all_doors.Add(src)
			areas_added += A


/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)	return
	if(!density)	return ..()
	return 0


/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	return attackby(null, user)

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob, params)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("\red \The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			update_icon()
			return

	if(blocked)
		user << "\red \The [src] is welded solid!"
		return

	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.air_doors_activated || A.fire

	if( istype(C, /obj/item/weapon/crowbar) || ( istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1 ) )
		if(operating)
			return
		if(blocked)
			user.visible_message("\red \The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!",\
			"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
			"You hear someone struggle and metal straining.")

		if(stat & (BROKEN|NOPOWER) || !density || !alarmed)
			user.visible_message("\red \The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!",\
			"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
			"You hear metal strain, and a door [density ? "open" : "close"].")

		else if(allowed(user))
			user.visible_message("\blue \The [user] lifts \the [src] with \a [C].",\
			"\The [src] scans your ID, and obediently opens as you apply your [C].",\
			"You hear metal move, and a door [density ? "open" : "close"].")

		if(density)
			spawn(0)
				open()
		else
			spawn(0)
				close()
		return

	var/access_granted = 0
	var/users_name
	if(!istype(C, /obj)) //If someone hit it with their hand.  We need to see if they are allowed.
		if(allowed(user))
			access_granted = 1
		if(ishuman(user))
			users_name = FindNameFromID(user)
		else
			users_name = "Unknown"

	if(ishuman(user) && !stat && (istype(C, /obj/item/weapon/card/id) || istype(C, /obj/item/device/pda)))
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			users_name = ID.registered_name

		if(check_access(ID))
			access_granted = 1

	var/answer = alert(user, "Are you sure you want to [density ? "open" : "close"] \the [src]?","\The [src] confirmation","Yes","No")
	if(answer == "No")
		return

	if(user.stat || user.stunned || user.weakened || user.paralysis || get_dist(src, user) > 1)
		user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
		return

	if(alarmed && density && !access_granted)
		user << "<span class='warning'>Access denied.  Please wait for authorities to arrive, or for the alert to clear.</span>"
		return

	else
		user.visible_message("\blue \The [src] [density ? "open" : "close"]s for \the [user].",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")
		// Accountability!
		if(!logged_users)
			logged_users = list()
		logged_users += users_name

	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open()
	else
		spawn()
			close()

	if(needs_to_close)
		spawn(50)
			if(alarmed)
				nextstate = CLOSED

/obj/machinery/door/firedoor/attack_ai(mob/user as mob)
	if(operating || stat & NOPOWER)
		return //Already doing something or depowered.

	if(blocked)
		user << "\red \The [src] is welded solid!"
		return

	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.air_doors_activated || A.fire

	var/access_granted = 0
	if(isAI(user) || isrobot(user))
		access_granted = 1

	if(access_granted == 1)
		user.visible_message("\blue \The [src] [density ? "open" : "close"]s for \the [user].",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")

	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open()
	else
		spawn()
			close()

	if(needs_to_close)
		spawn(50)
			if(alarmed)
				nextstate = CLOSED

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return

/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += "welded"
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"
	return

/obj/machinery/door/firedoor/open()
	..()
	latetoggle()
	return

/obj/machinery/door/firedoor/close()
	..()
	if(locate(/mob/living) in get_turf(src))
		open()
		return
	latetoggle()
	return

/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
			nextstate = null
			close()
	return


/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags = ON_BORDER

/obj/machinery/door/firedoor/border_only/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1
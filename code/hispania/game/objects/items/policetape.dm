GLOBAL_LIST_INIT(hazard_overlays, list())
GLOBAL_LIST_INIT(tape_roll_applications, list())

/obj/item/taperoll
	name = "police tape"
	icon = 'icons/hispania/obj/policetape.dmi'
	icon_state = "tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	w_class = WEIGHT_CLASS_SMALL
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/taper
	var/icon_base = "tape"
	var/maxlengths = 7
	var/apply_tape = FALSE
	color = COLOR_YELLOW

/obj/item/taperoll/Initialize()
	. = ..()
	if(apply_tape)
		var/turf/T = get_turf(src)
		if(!T)
			return
		var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in T
		if(airlock)
			afterattack(airlock, null, TRUE)
		return INITIALIZE_HINT_QDEL

/obj/item/taperoll/update_icon()
	overlays.Cut()
	var/image/overlay = image(icon = src.icon)
	overlay.appearance_flags = RESET_COLOR
	if(ismob(loc))
		if(!start)
			overlay.icon_state = "start"
		else
			overlay.icon_state = "stop"
		overlays += overlay

/obj/item/taperoll/dropped(mob/user)
	update_icon()
	return ..()

/obj/item/taperoll/pickup(mob/user)
	update_icon()
	return ..()

/obj/item/taperoll/attack_hand()
	update_icon()
	return ..()

/obj/item/taper
	name = "police tape"
	icon = 'icons/hispania/obj/policetape.dmi'
	icon_state = "tape"
	desc = "A length of police tape.  Do not cross."
	max_integrity = 10
	layer = ABOVE_DOOR_LAYER
	anchored = TRUE
	color = COLOR_YELLOW
	var/lifted = 0
	var/crumpled = 0
	var/tape_dir = 0
	var/icon_base = "stripetape"
	var/detail_overlay
	var/detail_color

/obj/item/taper/update_icon()
	//Possible directional bitflags: 0 (AIRLOCK), 1 (NORTH), 2 (SOUTH), 4 (EAST), 8 (WEST), 3 (VERTICAL), 12 (HORIZONTAL)
	overlays.Cut()
	var/new_state
	switch (tape_dir)
		if(0)  // AIRLOCK
			new_state = "[icon_base]_door"
		if(3)  // VERTICAL
			new_state = "[icon_base]_v"
		if(12) // HORIZONTAL
			new_state = "[icon_base]_h"
		else   // END POINT (1|2|4|8)
			new_state = "[icon_base]_dir"
			dir = tape_dir
	icon_state = "[new_state]_[crumpled]"
	if(detail_overlay)
		var/image/I = image(icon, "[new_state]_[detail_overlay]")
		I.appearance_flags = RESET_COLOR
		I.color = detail_color
		overlays |= I

/obj/item/taper/New()
	..()
	if(!GLOB.hazard_overlays)
		GLOB.hazard_overlays = list()
		GLOB.hazard_overlays["[NORTH]"]	= new/image('icons/hispania/effects/hazard_tape.dmi', icon_state = "N")
		GLOB.hazard_overlays["[EAST]"]	= new/image('icons/hispania/effects/hazard_tape.dmi', icon_state = "E")
		GLOB.hazard_overlays["[SOUTH]"]	= new/image('icons/hispania/effects/hazard_tape.dmi', icon_state = "S")
		GLOB.hazard_overlays["[WEST]"]	= new/image('icons/hispania/effects/hazard_tape.dmi', icon_state = "W")

/obj/item/taper/proc/crumple()
	playsound(src,'sound/effects/pageturn1.ogg', 100, 1)
	crumpled = 1
	update_icon()

/obj/item/taperoll/engi
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	tape_type = /obj/item/taper/engi
	color = COLOR_ORANGE

/obj/item/taper/engi
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	color = COLOR_ORANGE

/obj/item/taperoll/attack_self(mob/user)
	if(!start)
		start = get_turf(src)
		to_chat(usr, "<span class='notice'>You place the first end of \the [src].</span>")
		update_icon()
	else
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			start = null
			update_icon()
			to_chat(usr, "<span class='notice'>\The [src] can only be laid horizontally or vertically.</span>")
			return
		var/cordx = abs(end.x -  start.x)
		var/cordy = abs(end.y -  start.y)
		if(cordx > maxlengths  || cordy > maxlengths)
			cordx = null
			cordy = null
			start = null
			update_icon()
			to_chat(usr, "<span class='notice'>You can't run \the [src] more than 6 tiles!</span>")
			return
		if(start == end)
			// spread tape in all directions, provided there is a wall/window
			var/turf/T
			var/possible_dirs = 0
			for(var/dir in GLOB.cardinal)
				T = get_step(start, dir)
				if(T && T.density)
					possible_dirs += dir
				else
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == reverse_direction(dir))
							possible_dirs += dir
			if(!possible_dirs)
				start = null
				update_icon()
				to_chat(usr, "<span class='notice'>You can't place \the [src] here.</span>")
				return
			if(possible_dirs & (NORTH|SOUTH))
				var/obj/item/taper/TP = new tape_type(start)
				for(var/dir in list(NORTH, SOUTH))
					if (possible_dirs & dir)
						TP.tape_dir += dir
				TP.update_icon()
			if(possible_dirs & (EAST|WEST))
				var/obj/item/taper/TP = new tape_type(start)
				for(var/dir in list(EAST, WEST))
					if (possible_dirs & dir)
						TP.tape_dir += dir
				TP.update_icon()
			start = null
			update_icon()
			to_chat(usr, "<span class='notice'>You finish placing \the [src].</span>")
			return

		var/turf/cur = start
		var/orientation = get_dir(start, end)
		var/dir = 0
		switch(orientation)
			if(NORTH, SOUTH)	dir = NORTH|SOUTH	// North-South taping
			if(EAST,   WEST)	dir =  EAST|WEST	// East-West taping

		var/can_place = 1
		while(can_place)
			if(cur.density)
				can_place = 0
			else if (istype(cur, /turf/space))
				can_place = 0
			else
				for(var/obj/O in cur)
					if(O.density)
						can_place = 0
						break
			if(cur == end)
				break
			cur = get_step_towards(cur,end)
		if (!can_place)
			start = null
			update_icon()
			to_chat(usr, "<span class='warning'>You can't run \the [src] through that!</span>")
			return

		cur = start
		var/tapetest
		var/tape_dir
		while (1)
			tapetest = 0
			tape_dir = dir
			if(cur == start)
				var/turf/T = get_step(start, reverse_direction(orientation))
				if(T && !T.density)
					tape_dir = orientation
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == orientation)
							tape_dir = dir
			else if(cur == end)
				var/turf/T = get_step(end, orientation)
				if(T && !T.density)
					tape_dir = reverse_direction(orientation)
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == reverse_direction(orientation))
							tape_dir = dir
			for(var/obj/item/taper/T in cur)
				if((T.tape_dir == tape_dir) && (T.icon_base == icon_base))
					tapetest = 1
					break
			if(!tapetest)
				var/obj/item/taper/T = new tape_type(cur)
				T.tape_dir = tape_dir
				T.update_icon()
				if(tape_dir & SOUTH)
					T.layer += 0.1 // Must always show above other tapes
			if(cur == end)
				break
			cur = get_step_towards(cur,end)
		cordx = null
		cordy = null
		start = null
		update_icon()
		to_chat(usr, "<span class='notice'>You finish placing \the [src].</span>")
		return

/obj/item/taperoll/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/taper/P = new tape_type(T)
		P.update_icon()
		P.layer = ABOVE_DOOR_LAYER
		to_chat(user, "<span class='notice'>You finish placing \the [src].</span>")

	if (istype(A, /turf/simulated/floor))
		var/turf/F = A
		var/direction = user.loc == F ? user.dir : turn(user.dir, 180)
		var/icon/hazard_overlay = GLOB.hazard_overlays["[direction]"]
		if(GLOB.tape_roll_applications[F] == null)
			GLOB.tape_roll_applications[F] = 0

		if(GLOB.tape_roll_applications[F] & direction) // hazard_overlay in F.overlays wouldn't work.
			user.visible_message("\The [user] uses the adhesive of \the [src] to remove area markings from \the [F].", "You use the adhesive of \the [src] to remove area markings from \the [F].")
			F.overlays -= hazard_overlay
			GLOB.tape_roll_applications[F] &= ~direction
		else
			user.visible_message("\The [user] applied \the [src] on \the [F] to create area markings.", "You apply \the [src] on \the [F] to create area markings.")
			F.overlays |= hazard_overlay
			GLOB.tape_roll_applications[F] |= direction
		return

/obj/item/taper/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!lifted && ismob(mover))
		var/mob/M = mover
		add_fingerprint(M)
		if (!allowed(M))	//only select few learn art of not crumpling the tape
			to_chat(M, "<span class='warning'>You are not supposed to go past [src]...</span>")
			if(M.a_intent == INTENT_HELP)
				return FALSE
	else
		return ..(mover)

/obj/item/taper/attackby(obj/item/W, mob/user)
	if(user.a_intent == INTENT_HARM)
		breaktape(user)

/obj/item/taper/attack_hand(mob/user)
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'>\The [user] lifts \the [src], allowing passage.</span>")
		for(var/obj/item/taper/T in gettapeline())
			crumple()
			T.lift(20) //~2 seconds
	else
		breaktape(user)

/obj/item/taper/proc/lift(time)
	lifted = 1
	layer = ABOVE_ALL_MOB_LAYER
	spawn(time)
		lifted = 0
		layer = initial(layer)

// Returns a list of all tape objects connected to src, including itself.
/obj/item/taper/proc/gettapeline()
	var/list/dirs = list()
	if(tape_dir & NORTH)
		dirs += NORTH
	if(tape_dir & SOUTH)
		dirs += SOUTH
	if(tape_dir & WEST)
		dirs += WEST
	if(tape_dir & EAST)
		dirs += EAST

	var/list/obj/item/taper/tapeline = list()
	for (var/obj/item/taper/T in get_turf(src))
		tapeline += T
	for(var/dir in dirs)
		var/turf/cur = get_step(src, dir)
		var/not_found = 0
		while (!not_found)
			not_found = 1
			for (var/obj/item/taper/T in cur)
				tapeline += T
				not_found = 0
			cur = get_step(cur, dir)
	return tapeline

/obj/item/taper/proc/breaktape(mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from breaking \the [src].</span>")
		return
	user.visible_message("<span class='notice'>\The [user] breaks \the [src]!</span>","<span class='notice'>You break \the [src].</span>")
	playsound(src,'sound/items/poster_ripped.ogg', 80, 1)

	for(var/obj/item/taper/T in gettapeline())
		if(T == src)
			continue
		if(T.tape_dir & get_dir(T, src))
			qdel(T)

	qdel(src) //TODO: Dropping a trash item holding fibers/fingerprints of all broken tape parts
	return


// Basic transit tubes. Straight pieces, curved sections,
//  and basic splits/joins (no routing logic).
// Mappers: you can use "Generate Instances from Icon-states"
//  to get the different pieces.
/obj/structure/transit_tube
	name = "transit tube"
	desc = "A pneumatic tube that brings you from here to there."
	icon = 'icons/obj/pipes/transit_tube.dmi'
	icon_state = "straight"
	layer = 3.1
	anchored = TRUE
	var/list/tube_dirs = null
	var/exit_delay = 1
	var/enter_delay = 0
	var/uninstalled_type = /obj/structure/transit_tube_construction/straight

/obj/structure/transit_tube/Initialize(mapload, new_direction)
	. = ..()
	if(new_direction)
		setDir(new_direction)
	// set up our appearance after the initialize in case someone's setting our direction afterwards
	// (especially for things like admin spawning)
	addtimer(CALLBACK(src, PROC_REF(setup_appearance)), 1)

/obj/structure/transit_tube/proc/setup_appearance()
	init_tube_dirs()
	update_appearance()

/obj/structure/transit_tube/Destroy()
	for(var/obj/structure/transit_tube_pod/P in loc)
		P.empty_pod()
	return ..()

/obj/structure/transit_tube/CanPass(atom/movable/mover, border_dir)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(anchored && has_gravity(src))
		return FALSE
	return !density

// When destroyed by explosions, properly handle contents.
/obj/structure/transit_tube/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			for(var/atom/movable/AM in contents)
				AM.loc = loc
				AM.ex_act(severity++)

			deconstruct(disassembled = FALSE)
		if(EXPLODE_HEAVY)
			if(prob(50))
				for(var/atom/movable/AM in contents)
					AM.loc = loc
					AM.ex_act(severity++)

				deconstruct(disassembled = FALSE)
		if(EXPLODE_LIGHT)
			return

// Called to check if a pod should stop upon entering this tube.
/obj/structure/transit_tube/proc/should_stop_pod(obj/structure/transit_tube_pod/pod, from_dir)
	return FALSE

// Called when a pod stops in this tube section.
/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return


// Returns a /list of directions this tube section can connect to.
//  Tubes that have some sort of logic or changing direction might
//  override it with additional logic.
/obj/structure/transit_tube/proc/directions()
	return tube_dirs



/obj/structure/transit_tube/proc/has_entrance(from_dir)
	from_dir = turn(from_dir, 180)

	for(var/direction in directions())
		if(direction == from_dir)
			return TRUE

	return FALSE



/obj/structure/transit_tube/proc/has_exit(in_dir)
	for(var/direction in directions())
		if(direction == in_dir)
			return TRUE

	return FALSE



// Searches for an exit direction within 45 degrees of the
//  specified dir. Returns that direction, or 0 if none match.
/obj/structure/transit_tube/proc/get_exit(in_dir)
	var/near_dir = 0
	var/in_dir_cw = turn(in_dir, -45)
	var/in_dir_ccw = turn(in_dir, 45)

	for(var/direction in directions())
		if(direction == in_dir)
			return direction

		else if(direction == in_dir_cw)
			near_dir = direction

		else if(direction == in_dir_ccw)
			near_dir = direction

	return near_dir


// Return how many BYOND ticks to wait before entering/exiting
//  the tube section. Default action is to return the value of
//  a var, which wouldn't need a proc, but it makes it possible
//  for later tube types to interact in more interesting ways
//  such as being very fast in one direction, but slow in others
/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay

/obj/structure/transit_tube/proc/init_tube_dirs()
	switch(dir)
		if(NORTH, SOUTH)
			tube_dirs = list(NORTH, SOUTH)
		if(EAST, WEST)
			tube_dirs = list(EAST, WEST)

/obj/structure/transit_tube/update_overlays()
	. = ..()
	for(var/direction in directions())
		if(!IS_DIR_DIAGONAL(direction))
			. += create_tube_overlay(direction)
			continue
		if(!(direction & NORTH))
			continue

		. += create_tube_overlay(direction ^ (NORTH|SOUTH), NORTH)
		if(direction & EAST)
			. += create_tube_overlay(direction ^ (EAST|WEST), EAST)
		else
			. += create_tube_overlay(direction ^ (EAST|WEST), WEST)

/obj/structure/transit_tube/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, "<span class='notice'>You must uninstall [src] before disassembling it!</span>")

/obj/structure/transit_tube/screwdriver_act(mob/living/user, obj/item/I)
	var/obj/structure/transit_tube_construction/construction = new uninstalled_type(get_turf(src))
	if(!istype(construction))
		CRASH("expected [construction] to be a transit_tube construction")
	. = TRUE

	var/leaf = copytext("[type]", (findlasttext("[type]", "/") + 1))
	construction.dir = dir
	if(leaf == "flipped")
		construction.flip()

	user.visible_message("<span class='notice'>[user] uninstalls [src].</span>")
	qdel(src)

/obj/structure/transit_tube/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && !disassembled)
		playsound(src, "shatter", 70, TRUE)
		new /obj/effect/decal/cleanable/glass(loc)
	qdel(src)


/obj/structure/transit_tube/proc/create_tube_overlay(direction, shift_dir)
	// We use image() because a mutable appearance will have its dir mirror the parent which sort of fucks up what we're doing here
	var/image/tube_overlay = image(icon, dir = direction)
	if(shift_dir)
		tube_overlay.icon_state = "decorative_diag"
		switch(shift_dir)
			if(NORTH)
				tube_overlay.pixel_y = 32
			if(SOUTH)
				tube_overlay.pixel_y = -32
			if(EAST)
				tube_overlay.pixel_x = 32
			if(WEST)
				tube_overlay.pixel_x = -32
	else
		tube_overlay.icon_state = "decorative"

	tube_overlay.overlays += emissive_blocker(icon, tube_overlay.icon_state, src)
	return tube_overlay

//Some of these are mostly for mapping use
/obj/structure/transit_tube/horizontal
	dir = WEST


/obj/structure/transit_tube/diagonal
	icon_state = "diagonal"
	uninstalled_type = /obj/structure/transit_tube_construction/diagonal

/obj/structure/transit_tube/diagonal/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTHEAST, SOUTHWEST)
		if(SOUTH)
			tube_dirs = list(NORTHEAST, SOUTHWEST)
		if(EAST)
			tube_dirs = list(NORTHWEST, SOUTHEAST)
		if(WEST)
			tube_dirs = list(NORTHWEST, SOUTHEAST)

//mostly for mapping use
/obj/structure/transit_tube/diagonal/topleft
	dir = WEST

/obj/structure/transit_tube/curved
	icon_state = "curved0"
	uninstalled_type = /obj/structure/transit_tube_construction/curved

/obj/structure/transit_tube/curved/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHWEST)
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHEAST)
		if(EAST)
			tube_dirs = list(EAST, NORTHWEST)
		if(WEST)
			tube_dirs = list(SOUTHEAST, WEST)

/obj/structure/transit_tube/curved/flipped
	icon_state = "curved1"

/obj/structure/transit_tube/curved/flipped/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHEAST)
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHWEST)
		if(EAST)
			tube_dirs = list(EAST, SOUTHWEST)
		if(WEST)
			tube_dirs = list(NORTHEAST, WEST)


/obj/structure/transit_tube/junction
	icon_state = "junction0"
	uninstalled_type = /obj/structure/transit_tube_construction/junction

/obj/structure/transit_tube/junction/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHEAST, SOUTHWEST)//ending with the prefered direction
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHWEST, NORTHEAST)
		if(EAST)
			tube_dirs = list(EAST, SOUTHWEST, NORTHWEST)
		if(WEST)
			tube_dirs = list(WEST, NORTHEAST, SOUTHEAST)

/obj/structure/transit_tube/junction/flipped
	icon_state = "junction1"

/obj/structure/transit_tube/junction/flipped/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(NORTH, SOUTHWEST, SOUTHEAST)//ending with the prefered direction
		if(SOUTH)
			tube_dirs = list(SOUTH, NORTHEAST, NORTHWEST)
		if(EAST)
			tube_dirs = list(EAST, NORTHWEST, SOUTHWEST)
		if(WEST)
			tube_dirs = list(WEST, SOUTHEAST, NORTHEAST)

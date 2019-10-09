// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	level = 2
	max_integrity = 200
	var/ptype = PIPE_DISPOSALS_STRAIGHT //Use the defines
	var/base_state
	var/dpdir = 0	// directions as disposalpipe

/obj/structure/disposalconstruct/New(loc, pipe_type, direction)
	..()
	if(pipe_type)
		ptype = pipe_type
	if(dir)
		dir = direction
	update()

	// update iconstate and dpdir due to dir and type
/obj/structure/disposalconstruct/proc/update()
	base_state = get_pipe_icon(ptype)
	icon_state = "con[base_state]"
	var/flip = turn(dir, 180)
	var/left = turn(dir, 90)
	var/right = turn(dir, -90)
	name = get_pipe_name(ptype, PIPETYPE_DISPOSAL)
	switch(ptype)
		if(PIPE_DISPOSALS_STRAIGHT)
			dpdir = dir | flip
		if(PIPE_DISPOSALS_BENT)
			dpdir = dir | right
		if(PIPE_DISPOSALS_JUNCTION_RIGHT)
			dpdir = dir | right | flip
		if(PIPE_DISPOSALS_JUNCTION_LEFT)
			dpdir = dir | left | flip
		if(PIPE_DISPOSALS_Y_JUNCTION)
			dpdir = dir | left | right
		if(PIPE_DISPOSALS_TRUNK)
			dpdir = dir
		if(PIPE_DISPOSALS_SORT_RIGHT)
			dpdir = dir | right | flip
		if(PIPE_DISPOSALS_SORT_LEFT)
			dpdir = dir | left | flip
		 // disposal bin has only one dir, thus we don't need to care about setting it
		if(PIPE_DISPOSALS_BIN)
			if(!anchored)
				icon_state = "[base_state]-unanchored"
			else
				icon_state = base_state
		if(PIPE_DISPOSALS_OUTLET)
			dpdir = dir
			icon_state = base_state
		if(PIPE_DISPOSALS_CHUTE)
			dpdir = dir
			icon_state = base_state
	if(!(ptype in list(PIPE_DISPOSALS_BIN, PIPE_DISPOSALS_OUTLET, PIPE_DISPOSALS_CHUTE)))
		icon_state = "con[base_state]"
	if(invisibility)				// if invisible, fade icon
		icon -= rgb(0,0,0,128)

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
	update()


// flip and rotate verbs
/obj/structure/disposalconstruct/verb/rotate()
	set name = "Rotate Pipe"
	set src in view(1)

	if(usr.stat)
		return

	if(anchored)
		to_chat(usr, "You must unfasten the pipe before rotating it.")
		return

	dir = turn(dir, -90)
	update()

/obj/structure/disposalconstruct/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	rotate()

/obj/structure/disposalconstruct/verb/flip()
	set name = "Flip Pipe"
	set src in view(1)
	if(usr.stat)
		return

	if(anchored)
		to_chat(usr, "You must unfasten the pipe before flipping it.")
		return

	dir = turn(dir, 180)
	switch(ptype)
		if(PIPE_DISPOSALS_JUNCTION_RIGHT)
			ptype = PIPE_DISPOSALS_JUNCTION_LEFT
		if(PIPE_DISPOSALS_JUNCTION_LEFT)
			ptype = PIPE_DISPOSALS_JUNCTION_RIGHT
		if(PIPE_DISPOSALS_SORT_RIGHT)
			ptype = PIPE_DISPOSALS_SORT_LEFT
		if(PIPE_DISPOSALS_SORT_LEFT)
			ptype = PIPE_DISPOSALS_SORT_RIGHT

	update()

// returns the type path of disposalpipe corresponding to this item dtype
/obj/structure/disposalconstruct/proc/dpipetype()
	switch(ptype)
		if(PIPE_DISPOSALS_STRAIGHT, PIPE_DISPOSALS_BENT)
			return /obj/structure/disposalpipe/segment
		if(PIPE_DISPOSALS_JUNCTION_RIGHT, PIPE_DISPOSALS_JUNCTION_LEFT, PIPE_DISPOSALS_Y_JUNCTION)
			return /obj/structure/disposalpipe/junction
		if(PIPE_DISPOSALS_TRUNK)
			return /obj/structure/disposalpipe/trunk
		if(PIPE_DISPOSALS_BIN)
			return /obj/machinery/disposal
		if(PIPE_DISPOSALS_OUTLET)
			return /obj/structure/disposaloutlet
		if(PIPE_DISPOSALS_CHUTE)
			return /obj/machinery/disposal/deliveryChute
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			return /obj/structure/disposalpipe/sortjunction
	return

/obj/structure/disposalconstruct/proc/ridiculous_pipetype_proc()
	var/pipe_name
	switch(ptype)
		if(PIPE_DISPOSALS_BIN)
			pipe_name = "disposal bin"
		if(PIPE_DISPOSALS_OUTLET)
			pipe_name = "disposal outlet"
		if(PIPE_DISPOSALS_CHUTE)
			pipe_name = "delivery chute"
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			pipe_name = "sorting pipe"
	return pipe_name

/obj/structure/disposalconstruct/proc/ridiculous_pipelevel_proc()
	if(ptype in list(PIPE_DISPOSALS_BIN, PIPE_DISPOSALS_OUTLET, PIPE_DISPOSALS_CHUTE))
		return 1

/obj/structure/disposalconstruct/attackby(var/obj/item/I, var/mob/user, params)
	add_fingerprint(user)
	var/nicetype = ridiculous_pipetype_proc()
	var/ispipe = ridiculous_pipelevel_proc()
	var/turf/T = src.loc
	if(T.intact)
		to_chat(user, "You can only attach the [nicetype] if the floor plating is removed.")
		return

	if(istype(I, /obj/item/wrench))
		if(anchored)
			anchored = 0
			if(ispipe)
				level = 2
				density = 0
			else
				density = 1
			to_chat(user, "You detach the [nicetype] from the underfloor.")
		else
			anchored = 1
			if(ispipe)
				level = 1 // We don't want disposal bins to disappear under the floors
				density = 0
			else
				density = 1 // We don't want disposal bins or outlets to go density 0
			to_chat(user, "You attach the [nicetype] to the underfloor.")
		playsound(src.loc, I.usesound, 100, 1)
		update()
		return


	if(ptype in list(PIPE_DISPOSALS_BIN, PIPE_DISPOSALS_OUTLET, PIPE_DISPOSALS_CHUTE)) // Disposal or outlet
		var/obj/structure/disposalpipe/trunk/CP = locate() in T
		if(!CP) // There's no trunk
			to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
			return
	else
		for(var/obj/structure/disposalpipe/CP in T)
			if(CP)
				update()
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					to_chat(user, "There is already a [nicetype] at that location.")
					return

/obj/structure/disposalconstruct/welder_act(mob/user, obj/item/I)
	if(!anchored)
		to_chat(user, "You need to attach it to the plating first!")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/nicetype = ridiculous_pipetype_proc()
	var/ispipe = ridiculous_pipelevel_proc()
	to_chat(user, "Welding the [nicetype] in place.")
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "The [nicetype] has been welded in place!")
		update()
		if(ispipe)
			var/pipetype = dpipetype()
			var/obj/structure/disposalpipe/P = new pipetype(src.loc)
			src.transfer_fingerprints_to(P)
			P.base_icon_state = base_state
			P.dir = dir
			P.dpdir = dpdir
			P.update_icon()

			//Needs some special treatment ;)
			if(ptype == PIPE_DISPOSALS_SORT_RIGHT || ptype == PIPE_DISPOSALS_SORT_LEFT)
				var/obj/structure/disposalpipe/sortjunction/SortP = P
				SortP.updatedir()

		else if(ptype == PIPE_DISPOSALS_BIN) // Disposal bin
			var/obj/machinery/disposal/P = new /obj/machinery/disposal(src.loc)
			src.transfer_fingerprints_to(P)
			P.mode = 0 // start with pump off

		else if(ptype == PIPE_DISPOSALS_OUTLET) // Disposal outlet

			var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(src.loc)
			src.transfer_fingerprints_to(P)
			P.dir = dir

		else if(ptype==PIPE_DISPOSALS_CHUTE) // Disposal outlet

			var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(src.loc)
			src.transfer_fingerprints_to(P)
			P.dir = dir

		qdel(src)
		return

/obj/structure/disposalconstruct/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate()
	else if(our_rpd.mode == RPD_FLIP_MODE)
		flip()
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
	else
		return ..()

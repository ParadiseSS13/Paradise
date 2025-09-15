// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "conpipe-s"
	pressure_resistance = 5*ONE_ATMOSPHERE
	max_integrity = 200
	var/ptype = PIPE_DISPOSALS_STRAIGHT //Use the defines
	var/base_state
	var/dpdir = 0	// directions as disposalpipe

/obj/structure/disposalconstruct/Initialize(mapload, pipe_type, direction)
	. = ..()
	if(pipe_type)
		ptype = pipe_type
	if(dir)
		dir = direction
	update()

/obj/structure/disposalconstruct/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> to rotate it, <b>Alt-Shift-Click to flip it.</b></span>"

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
/obj/structure/disposalconstruct/hide(intact)
	invisibility = (intact && level == 1) ? INVISIBILITY_MAXIMUM : 0	// hide if floor is intact
	update()

/obj/structure/disposalconstruct/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	rotate(user)

/obj/structure/disposalconstruct/proc/rotate(mob/user)
	if(anchored)
		to_chat(user, "<span class='notice'>You must unfasten the pipe before rotating it.</span>")
		return

	dir = turn(dir, -90)
	update()

/obj/structure/disposalconstruct/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	flip(user)

/obj/structure/disposalconstruct/proc/flip(mob/user)
	if(anchored)
		to_chat(user, "<span class='notice'>You must unfasten the pipe before flipping it.</span>")
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
			return /obj/machinery/disposal/delivery_chute
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			return /obj/structure/disposalpipe/sortjunction
	return



// attackby item
// wrench: (un)anchor
// weldingtool: convert to real pipe

/obj/structure/disposalconstruct/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/ispipe = is_pipe()
	var/nicetype = get_nice_name()
	var/turf/T = get_turf(src)

	if(T.intact)
		to_chat(user, "<span class='warning'>You can only attach the [nicetype] if the floor plating is removed.</span>")
		return

	if(ispipe)
		anchored = !anchored
		level = anchored ? 1 : 2
		to_chat(user, anchored ? "<span class='notice'>You attach the [nicetype] to the underfloor.</span>" : "<span class='notice'>You detach the [nicetype] from the underfloor.</span>")
	else
		var/obj/structure/disposalpipe/trunk/CT = locate() in T //For disposal bins, chutes, outlets.
		if(!CT)
			to_chat(user, "<span class='warning'>The [nicetype] requires a trunk underneath it in order to be anchored.</span>")
			return
		anchored = !anchored
		density = anchored
		to_chat(user, anchored ? "<span class='notice'>You attach the [nicetype] to the trunk.</span>" : "<span class='notice'>You detach the [nicetype] from the trunk.</span>")

	I.play_tool_sound(src, I.tool_volume)
	update()
	. |= RPD_TOOL_SUCCESS

/obj/structure/disposalconstruct/proc/is_pipe()
	switch(ptype)
		// lewtodo: this sucks
		if(PIPE_DISPOSALS_BIN, PIPE_DISPOSALS_OUTLET, PIPE_DISPOSALS_CHUTE)
			return FALSE
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			return TRUE
		else
			return TRUE

/obj/structure/disposalconstruct/proc/get_nice_name()
	var/nicetype = "pipe"
	switch(ptype)
		if(PIPE_DISPOSALS_BIN)
			nicetype = "disposal bin"
		if(PIPE_DISPOSALS_OUTLET)
			nicetype = "disposal outlet"
		if(PIPE_DISPOSALS_CHUTE)
			nicetype = "delivery chute"
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			nicetype = "sorting pipe"
	return nicetype

/obj/structure/disposalconstruct/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	. = ITEM_INTERACT_COMPLETE
	var/nicetype = get_nice_name()
	var/ispipe = is_pipe() // Indicates if we should change the level of this pipe
	var/turf/T = get_turf(src)
	add_fingerprint(user)

	if(T.intact)
		to_chat(user, "<span class='warning'>You can only attach the [nicetype] if the floor plating is removed.</span>")
		return

	if(ptype in list(PIPE_DISPOSALS_BIN, PIPE_DISPOSALS_OUTLET, PIPE_DISPOSALS_CHUTE)) // Disposal or outlet
		var/obj/structure/disposalpipe/trunk/CP = locate() in T
		if(!CP) // There's no trunk
			to_chat(user, "<span class='warning'>The [nicetype] requires a trunk underneath it in order to work.</span>")
			return
	else
		for(var/obj/structure/disposalpipe/CP in T)
			if(CP)
				update()
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					to_chat(user, "<span class='warning'>There is already a [nicetype] at that location.</span>")
					return

	if(istype(I, /obj/item/weldingtool))
		if(anchored)
			if(I.tool_use_check(user, 0))
				to_chat(user, "<span class='notice'>You begin welding the [nicetype] in place.</span>")
				if(I.use_tool(src, user, 20, volume = I.tool_volume))
					to_chat(user, "<span class='notice'>You have welded the [nicetype] in place!</span>")
					update() // TODO: Make this neat
					if(ispipe) // Pipe

						var/pipetype = dpipetype()
						var/obj/structure/disposalpipe/P = new pipetype(src.loc)
						src.transfer_fingerprints_to(P)
						P.base_icon_state = base_state
						P.dir = dir
						P.dpdir = dpdir
						P.update_icon(UPDATE_ICON_STATE)

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

						var/obj/machinery/disposal/delivery_chute/P = new /obj/machinery/disposal/delivery_chute(src.loc)
						src.transfer_fingerprints_to(P)
						P.dir = dir

					qdel(src)
					return
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return
		else
			to_chat(user, "<span class='warning'>You need to attach it to the plating first!</span>")
			return

/obj/structure/disposalconstruct/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate(user)
	else if(our_rpd.mode == RPD_FLIP_MODE)
		flip(user)
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
	else
		return ..()

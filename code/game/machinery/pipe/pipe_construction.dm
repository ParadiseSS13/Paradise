#define CIRC_LEFT WEST
#define CIRC_RIGHT EAST

/obj/item/pipe
	name = "pipe"
	var/pipe_type = 0
	var/pipename
	var/list/connect_types = list(CONNECT_TYPE_NORMAL) //1=regular, 2=supply, 3=scrubber
	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	level = 2
	var/flipped = FALSE

/obj/item/pipe/Initialize(mapload, new_pipe_type, new_dir, obj/machinery/atmospherics/make_from)
	. = ..()
	if(make_from)
		dir = make_from.dir
		pipename = make_from.name
		color = make_from.pipe_color
		var/is_bent

		if(make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = FALSE
		else
			is_bent = TRUE


		if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			pipe_type = PIPE_JUNCTION

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			pipe_type = PIPE_HE_STRAIGHT + is_bent

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/insulated))
			pipe_type = PIPE_INSULATED_STRAIGHT + is_bent

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/supply))
			pipe_type = PIPE_SUPPLY_STRAIGHT + is_bent
			connect_types = list(CONNECT_TYPE_SUPPLY)
			color = PIPE_COLOR_BLUE

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/scrubbers))
			pipe_type = PIPE_SCRUBBERS_STRAIGHT + is_bent
			connect_types = list(CONNECT_TYPE_SCRUBBER)
			color = PIPE_COLOR_RED

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/universal) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/universal))
			pipe_type = PIPE_UNIVERSAL
			connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY, CONNECT_TYPE_SCRUBBER)

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent

		else if(istype(make_from, /obj/machinery/atmospherics/unary/portables_connector))
			pipe_type = PIPE_CONNECTOR

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/supply))
			pipe_type = PIPE_SUPPLY_MANIFOLD
			connect_types = list(CONNECT_TYPE_SUPPLY)
			color = PIPE_COLOR_BLUE

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers))
			pipe_type = PIPE_SCRUBBERS_MANIFOLD
			connect_types = list(CONNECT_TYPE_SCRUBBER)
			color = PIPE_COLOR_RED

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			pipe_type = PIPE_MANIFOLD

		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			pipe_type = PIPE_UVENT

		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve/digital))
			pipe_type = PIPE_DVALVE

		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve))
			pipe_type = PIPE_MVALVE

		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			pipe_type = PIPE_PUMP

		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			pipe_type = PIPE_GAS_FILTER

		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			pipe_type = PIPE_GAS_MIXER

		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			pipe_type = PIPE_SCRUBBER

		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			pipe_type = PIPE_PASSIVE_GATE

		else if(istype(make_from, /obj/machinery/atmospherics/binary/volume_pump))
			pipe_type = PIPE_VOLUME_PUMP

		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			pipe_type = PIPE_HEAT_EXCHANGE

		else if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve/digital))
			pipe_type = PIPE_DTVALVE

		else if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve))
			pipe_type = PIPE_TVALVE

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/supply))
			pipe_type = PIPE_SUPPLY_MANIFOLD4W
			connect_types = list(CONNECT_TYPE_SUPPLY)
			color = PIPE_COLOR_BLUE

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers))
			pipe_type = PIPE_SCRUBBERS_MANIFOLD4W
			connect_types = list(CONNECT_TYPE_SCRUBBER)
			color = PIPE_COLOR_RED

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w))
			pipe_type = PIPE_MANIFOLD4W

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/supply))
			pipe_type = PIPE_SUPPLY_CAP
			connect_types = list(CONNECT_TYPE_SUPPLY)
			color = PIPE_COLOR_BLUE

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/scrubbers))
			pipe_type = PIPE_SCRUBBERS_CAP
			connect_types = list(CONNECT_TYPE_SCRUBBER)
			color = PIPE_COLOR_RED

		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap))
			pipe_type = PIPE_CAP

		else if(istype(make_from, /obj/machinery/atmospherics/unary/outlet_injector))
			pipe_type = PIPE_INJECTOR

		else if(istype(make_from, /obj/machinery/atmospherics/unary/passive_vent))
			pipe_type = PIPE_PASV_VENT

		else if(istype(make_from, /obj/machinery/atmospherics/binary/circulator))
			pipe_type = PIPE_CIRCULATOR

		var/obj/machinery/atmospherics/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			flipped = TRUE

		var/obj/machinery/atmospherics/binary/circulator/circP = make_from
		if(istype(circP) && circP.side == CIRC_RIGHT)
			flipped = TRUE

	else
		pipe_type = new_pipe_type
		dir = new_dir
		if(pipe_type == PIPE_SUPPLY_STRAIGHT || pipe_type == PIPE_SUPPLY_BENT || pipe_type == PIPE_SUPPLY_MANIFOLD || pipe_type == PIPE_SUPPLY_MANIFOLD4W || pipe_type == PIPE_SUPPLY_CAP)
			connect_types = list(CONNECT_TYPE_SUPPLY)
			color = PIPE_COLOR_BLUE
		else if(pipe_type == PIPE_SCRUBBERS_STRAIGHT || pipe_type == PIPE_SCRUBBERS_BENT || pipe_type == PIPE_SCRUBBERS_MANIFOLD || pipe_type == PIPE_SCRUBBERS_MANIFOLD4W || pipe_type == PIPE_SCRUBBERS_CAP)
			connect_types = list(CONNECT_TYPE_SCRUBBER)
			color = PIPE_COLOR_RED
		else if(pipe_type == PIPE_UNIVERSAL)
			connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY, CONNECT_TYPE_SCRUBBER)

	update(make_from)
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/pipe/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate()

	else if(our_rpd.mode == RPD_FLIP_MODE)
		flip()

	else if(our_rpd.mode == RPD_DELETE_MODE)
		if(pipe_type == PIPE_CIRCULATOR) //Skip TEG heat circulators, they aren't really pipes
			return ..()

		our_rpd.delete_single_pipe(user, src)

	else
		return ..()

/obj/item/pipe/examine(mob/user)
	. = ..()
	. += "<span class='info'>Alt-click it to rotate, Alt-Shift-click it to flip!</span>"

/obj/item/pipe/proc/update(obj/machinery/atmospherics/make_from)
	name = "[get_pipe_name(pipe_type, PIPETYPE_ATMOS)] fitting"
	icon_state = get_pipe_icon(pipe_type)

	var/obj/machinery/atmospherics/trinary/triP = make_from
	if(istype(triP) && triP.flipped)
		icon_state = "m_[icon_state]"

	var/obj/machinery/atmospherics/binary/circulator/circP = make_from
	if(istype(circP) && circP.side == CIRC_RIGHT)
		icon_state = "m_[icon_state]"

	if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
		resistance_flags |= FIRE_PROOF | LAVA_PROOF

// called by turf to know if should treat as bent or not on placement
/obj/item/pipe/proc/is_bent_pipe()
	return pipe_type in list( \
		PIPE_SIMPLE_BENT, \
		PIPE_HE_BENT, \
		PIPE_INSULATED_BENT, \
		PIPE_SUPPLY_BENT, \
		PIPE_SCRUBBERS_BENT)

// rotate the pipe item clockwise

/obj/item/pipe/proc/rotate()
	if(pipe_type == PIPE_CIRCULATOR)
		flip()
		return

	dir = turn(dir, -90)

	fixdir()

/obj/item/pipe/proc/flip()
	if(pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE, PIPE_CIRCULATOR))
		if(flipped)
			icon_state = copytext(icon_state,3)
		else
			icon_state = "m_[icon_state]"
		flipped = !flipped
		return

	dir = turn(dir, -180)

	fixdir()

/obj/item/pipe/Move()
	. = ..()
	if(is_bent_pipe() && (dir in GLOB.cardinal))
		dir = dir | turn(dir, 90)

	else if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir == 2)
			dir = 1

		else if(dir == 8)
			dir = 4

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	. = 0

	if(!dir)
		return

	var/direct = dir
	if(flipped)
		direct = turn(dir, 45)

	var/flip = turn(direct, 180)
	var/cw = turn(direct, -90)
	var/acw = turn(direct, 90)

	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_JUNCTION,\
			PIPE_PUMP, PIPE_VOLUME_PUMP, PIPE_PASSIVE_GATE, PIPE_MVALVE, PIPE_DVALVE, PIPE_DP_VENT,
			PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL)
			return dir|flip

		if(PIPE_SIMPLE_BENT, PIPE_INSULATED_BENT, PIPE_HE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT)
			return dir //dir|acw

		if(PIPE_CONNECTOR,  PIPE_HEAT_EXCHANGE, PIPE_INJECTOR)
			return dir|flip

		if(PIPE_UVENT, PIPE_PASV_VENT, PIPE_SCRUBBER)
			return dir

		if(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W)
			return dir|flip|cw|acw

		if(PIPE_MANIFOLD, PIPE_SUPPLY_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD)
			return flip|cw|acw

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE)
			if(!flipped)
				return dir|flip|cw

			return flip|cw|acw

		if(PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP)
			return dir|flip

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes
	var/flip = turn(dir, 180)

	if(!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
		return get_pipe_dir()

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0

		if(PIPE_JUNCTION)
			return flip

	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/pipe/proc/get_hdir() //endpoints for h/e pipes
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()

		if(PIPE_HE_BENT)
			return get_pipe_dir()

		if(PIPE_JUNCTION)
			return dir

	return 0

/obj/item/pipe/proc/unflip(direction)
	if(!(direction in GLOB.cardinal))
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir == 2)
			dir = 1

		else if(dir == 8)
			dir = 4

	else if(pipe_type in list(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W))
		dir = 2

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/wrench_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(!isturf(loc))
		return

	fixdir()

	var/pipe_dir = get_pipe_dir()
	var/turf/T = get_turf(loc)

	for(var/obj/machinery/atmospherics/M in loc)
		if((M.initialize_directions & pipe_dir) && M.check_connect_types_construction(M, src))	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe of the same type at this location.</span>")
			return

	if(pipe_type in list(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT, PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_SUPPLY_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_UVENT, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP, PIPE_PASV_VENT, PIPE_DP_VENT, PIPE_PASSIVE_GATE))
		if(T.transparent_floor) //stops jank with transparent floors and pipes
			to_chat(user, "<span class='warning'>You can only fix simple pipes and devices over glass floors!</span>")
			return

	switch(pipe_type) //What kind of heartless person thought of doing this?
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/supply/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_UNIVERSAL)
			var/obj/machinery/atmospherics/pipe/simple/hidden/universal/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new (loc)
			P.initialize_directions_he = pipe_dir
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_CONNECTOR)		// connector
			var/obj/machinery/atmospherics/unary/portables_connector/C = new(loc)
			if(pipename)
				C.name = pipename
			C.on_construction(dir, pipe_dir, color)

		if(PIPE_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/supply/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers/M = new(loc)
			M.on_construction(dir, pipe_dir, color)

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new (loc)
			P.initialize_directions_he = get_hdir()
			P.on_construction(dir, get_pdir(), color)

		if(PIPE_UVENT)		//unary vent
			var/obj/machinery/atmospherics/unary/vent_pump/V = new(loc)
			V.on_construction(dir, pipe_dir, color)

		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/atmospherics/binary/valve/V = new(loc)
			if(pipename)
				V.name = pipename
			V.on_construction(dir, get_pdir(), color)

		if(PIPE_DVALVE)
			var/obj/machinery/atmospherics/binary/valve/digital/V = new(loc)
			if(pipename)
				V.name = pipename
			V.on_construction(dir, get_pdir(), color)

		if(PIPE_PUMP)		//gas pump
			var/obj/machinery/atmospherics/binary/pump/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE)
			var/obj/machinery/atmospherics/trinary/P
			switch(pipe_type)
				if(PIPE_GAS_FILTER)
					P = new /obj/machinery/atmospherics/trinary/filter(loc)
				if(PIPE_GAS_MIXER)
					P = new /obj/machinery/atmospherics/trinary/mixer(loc)
				if(PIPE_TVALVE)
					P = new /obj/machinery/atmospherics/trinary/tvalve(loc)
				if(PIPE_DTVALVE)
					P = new /obj/machinery/atmospherics/trinary/tvalve/digital(loc)

			P.flipped = flipped

			if(pipename)
				P.name = pipename

			P.on_construction(unflip(dir), pipe_dir, color)

		if(PIPE_CIRCULATOR) //circulator
			var/obj/machinery/atmospherics/binary/circulator/C = new(loc)
			if(flipped)
				C.side = CIRC_RIGHT

			if(pipename)
				C.name = pipename

			C.on_construction(C.dir, C.initialize_directions, color)

		if(PIPE_SCRUBBER)		//scrubber
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(loc)
			if(pipename)
				S.name = pipename

			S.on_construction(dir, pipe_dir, color)

		if(PIPE_INSULATED_STRAIGHT, PIPE_INSULATED_BENT)
			var/obj/machinery/atmospherics/pipe/simple/insulated/P = new(loc)
			P.on_construction(dir, pipe_dir, color)

		if(PIPE_CAP)
			var/obj/machinery/atmospherics/pipe/cap/C = new(loc)
			C.on_construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/supply/C = new(loc)
			C.on_construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers/C = new(loc)
			C.on_construction(dir, pipe_dir, color)

		if(PIPE_PASSIVE_GATE)		//passive gate
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(loc)
			if(pipename)
				P.name = pipename

			P.on_construction(dir, pipe_dir, color)

		if(PIPE_VOLUME_PUMP)		//volume pump
			var/obj/machinery/atmospherics/binary/volume_pump/P = new(loc)
			if(pipename)
				P.name = pipename

			P.on_construction(dir, pipe_dir, color)

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new(loc)
			if(pipename)
				C.name = pipename

			C.on_construction(dir, pipe_dir, color)

		if(PIPE_INJECTOR)		// air injector
			var/obj/machinery/atmospherics/unary/outlet_injector/P = new(loc)
			if(pipename)
				P.name = pipename

			P.on_construction(dir, pipe_dir, color)

		if(PIPE_PASV_VENT)
			var/obj/machinery/atmospherics/unary/passive_vent/P  = new(loc)
			if(pipename)
				P.name = pipename

			P.on_construction(dir, pipe_dir, color)

	user.visible_message( \
		"<span class='notice'>[user] fastens [src].</span>",
		"<span class='notice'>You fasten [src].</span>",
		"<span class='notice'>You hear a ratchet.</span>")
	qdel(src)	// remove the pipe item

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/pipe_meter/attackby(obj/item/W, mob/user, params)
	if(!iswrench(W))
		return ..()

	if(!locate(/obj/machinery/atmospherics/pipe, loc))
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe</span>")
		return TRUE

	new /obj/machinery/atmospherics/meter(loc)
	playsound(loc, W.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You have fastened the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
		return

	..()

/obj/item/pipe_gsensor
	name = "gas sensor"
	desc = "A sensor that can be hooked to a computer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/pipe_gsensor/attackby(obj/item/W, mob/user)
	if(!istype(W, /obj/item/wrench))
		return ..()

	var/obj/machinery/atmospherics/air_sensor/AS = new /obj/machinery/atmospherics/air_sensor(loc)
	AS.bolts = FALSE
	playsound(get_turf(src), W.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You have fastened the gas sensor.</span>")
	qdel(src)

/obj/item/pipe_gsensor/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
		return

	..()

/obj/item/pipe/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	rotate()

/obj/item/pipe/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	flip()

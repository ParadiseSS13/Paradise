GLOBAL_LIST_INIT(pipe_path2type, list(
		/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction = PIPE_JUNCTION,
		/obj/machinery/atmospherics/pipe/simple/heat_exchanging = PIPE_HE_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple/visible/supply = PIPE_SUPPLY_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple/visible/scrubbers = PIPE_SCRUBBERS_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple/hidden/supply = PIPE_SUPPLY_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers = PIPE_SCRUBBERS_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple = PIPE_SIMPLE_STRAIGHT,
		/obj/machinery/atmospherics/pipe/simple/visible/universal = PIPE_UNIVERSAL,
		/obj/machinery/atmospherics/pipe/simple/hidden/universal = PIPE_UNIVERSAL,
		/obj/machinery/atmospherics/unary/portables_connector = PIPE_CONNECTOR,
		/obj/machinery/atmospherics/pipe/manifold/visible/supply = PIPE_SUPPLY_MANIFOLD,
		/obj/machinery/atmospherics/pipe/manifold/visible/scrubbers = PIPE_SCRUBBERS_MANIFOLD,
		/obj/machinery/atmospherics/pipe/manifold/hidden/supply = PIPE_SUPPLY_MANIFOLD,
		/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers = PIPE_SCRUBBERS_MANIFOLD,
		/obj/machinery/atmospherics/pipe/manifold = PIPE_MANIFOLD,
		/obj/machinery/atmospherics/unary/vent_pump = PIPE_UVENT,
		/obj/machinery/atmospherics/binary/valve/digital = PIPE_DVALVE,
		/obj/machinery/atmospherics/binary/valve = PIPE_MVALVE,
		/obj/machinery/atmospherics/binary/pump = PIPE_PUMP,
		/obj/machinery/atmospherics/trinary/filter = PIPE_GAS_FILTER,
		/obj/machinery/atmospherics/trinary/mixer = PIPE_GAS_MIXER,
		/obj/machinery/atmospherics/unary/vent_scrubber = PIPE_SCRUBBER,
		/obj/machinery/atmospherics/binary/passive_gate = PIPE_PASSIVE_GATE,
		/obj/machinery/atmospherics/binary/volume_pump = PIPE_VOLUME_PUMP,
		/obj/machinery/atmospherics/unary/heat_exchanger = PIPE_HEAT_EXCHANGE,
		/obj/machinery/atmospherics/trinary/tvalve/digital = PIPE_DTVALVE,
		/obj/machinery/atmospherics/trinary/tvalve = PIPE_TVALVE,
		/obj/machinery/atmospherics/pipe/manifold4w/visible/supply = PIPE_SUPPLY_MANIFOLD4W,
		/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers = PIPE_SCRUBBERS_MANIFOLD4W,
		/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply = PIPE_SUPPLY_MANIFOLD4W,
		/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers = PIPE_SCRUBBERS_MANIFOLD4W,
		/obj/machinery/atmospherics/pipe/manifold4w = PIPE_MANIFOLD4W,
		/obj/machinery/atmospherics/pipe/cap/visible/supply = PIPE_SUPPLY_CAP,
		/obj/machinery/atmospherics/pipe/cap/visible/scrubbers = PIPE_SCRUBBERS_CAP,
		/obj/machinery/atmospherics/pipe/cap/hidden/supply = PIPE_SUPPLY_CAP,
		/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers = PIPE_SCRUBBERS_CAP,
		/obj/machinery/atmospherics/pipe/cap = PIPE_CAP,
		/obj/machinery/atmospherics/unary/outlet_injector = PIPE_INJECTOR,
		/obj/machinery/atmospherics/unary/passive_vent = PIPE_PASV_VENT,
		/obj/machinery/atmospherics/binary/circulator = PIPE_CIRCULATOR,
		"[PIPE_JUNCTION]" = /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction,
		"[PIPE_HE_STRAIGHT]" = /obj/machinery/atmospherics/pipe/simple/heat_exchanging,
		"[PIPE_HE_BENT]" = /obj/machinery/atmospherics/pipe/simple/heat_exchanging,
		"[PIPE_SUPPLY_STRAIGHT]" = /obj/machinery/atmospherics/pipe/simple/visible/supply,
		"[PIPE_SUPPLY_BENT]" = /obj/machinery/atmospherics/pipe/simple/visible/supply,
		"[PIPE_SCRUBBERS_STRAIGHT]" = /obj/machinery/atmospherics/pipe/simple/visible/scrubbers,
		"[PIPE_SCRUBBERS_BENT]" = /obj/machinery/atmospherics/pipe/simple/visible/scrubbers,
		"[PIPE_SIMPLE_STRAIGHT]" = /obj/machinery/atmospherics/pipe/simple,
		"[PIPE_SIMPLE_BENT]" = /obj/machinery/atmospherics/pipe/simple,
		"[PIPE_UNIVERSAL]" = /obj/machinery/atmospherics/pipe/simple/visible/universal,
		"[PIPE_CONNECTOR]" = /obj/machinery/atmospherics/unary/portables_connector,
		"[PIPE_SUPPLY_MANIFOLD]" = /obj/machinery/atmospherics/pipe/manifold/visible/supply,
		"[PIPE_SCRUBBERS_MANIFOLD]" = /obj/machinery/atmospherics/pipe/manifold/visible/scrubbers,
		"[PIPE_MANIFOLD]" = /obj/machinery/atmospherics/pipe/manifold,
		"[PIPE_UVENT]" = /obj/machinery/atmospherics/unary/vent_pump,
		"[PIPE_DVALVE]" = /obj/machinery/atmospherics/binary/valve/digital,
		"[PIPE_MVALVE]" = /obj/machinery/atmospherics/binary/valve,
		"[PIPE_PUMP]" = /obj/machinery/atmospherics/binary/pump,
		"[PIPE_GAS_FILTER]" = /obj/machinery/atmospherics/trinary/filter,
		"[PIPE_GAS_MIXER]" = /obj/machinery/atmospherics/trinary/mixer,
		"[PIPE_SCRUBBER]" = /obj/machinery/atmospherics/unary/vent_scrubber,
		"[PIPE_PASSIVE_GATE]" = /obj/machinery/atmospherics/binary/passive_gate,
		"[PIPE_VOLUME_PUMP]" = /obj/machinery/atmospherics/binary/volume_pump,
		"[PIPE_HEAT_EXCHANGE]" = /obj/machinery/atmospherics/unary/heat_exchanger,
		"[PIPE_DTVALVE]" = /obj/machinery/atmospherics/trinary/tvalve/digital,
		"[PIPE_TVALVE]" = /obj/machinery/atmospherics/trinary/tvalve,
		"[PIPE_SUPPLY_MANIFOLD4W]" = /obj/machinery/atmospherics/pipe/manifold4w/visible/supply,
		"[PIPE_SCRUBBERS_MANIFOLD4W]" = /obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers,
		"[PIPE_MANIFOLD4W]" = /obj/machinery/atmospherics/pipe/manifold4w,
		"[PIPE_SUPPLY_CAP]" = /obj/machinery/atmospherics/pipe/cap/visible/supply,
		"[PIPE_SCRUBBERS_CAP]" = /obj/machinery/atmospherics/pipe/cap/visible/scrubbers,
		"[PIPE_CAP]" = /obj/machinery/atmospherics/pipe/cap,
		"[PIPE_INJECTOR]" = /obj/machinery/atmospherics/unary/outlet_injector,
		"[PIPE_PASV_VENT]" = /obj/machinery/atmospherics/unary/passive_vent,
		"[PIPE_CIRCULATOR]" = /obj/machinery/atmospherics/binary/circulator,
))

/obj/item/pipe
	name = "pipe"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	inhand_icon_state = "buildpipe"
	force = 7
	/// Will the constructed pipe be flipped
	var/flipped = FALSE
	/// The label that will be put on the constructed pipe when this is wrenched down
	var/label = null
	/// The type of the pipe that will be created when this is wrenched down
	var/makes_type = null
	var/pipe_type = 0
	var/pipename
	var/list/connect_types = list(CONNECT_TYPE_NORMAL) //1=regular, 2=supply, 3=scrubber

/obj/item/pipe/Initialize(mapload, new_pipe_type, new_dir, obj/machinery/atmospherics/make_from)
	. = ..()
	if(make_from)
		dir = make_from.dir
		pipename = make_from.name
		color = make_from.pipe_color
		makes_type = make_from.type
		var/is_bent = FALSE

		if(make_from.initialize_directions in list(NORTH|WEST, NORTH|EAST, SOUTH|WEST, SOUTH|EAST))
			is_bent = TRUE

		// If our path is in the list use the list
		if(makes_type in GLOB.pipe_path2type)
			pipe_type = GLOB.pipe_path2type[makes_type] + is_bent
		// If our path isn't exactly in the list (e.g /obj/machinery/atmospherics/binary/pump/on) try and find an ancestor there
		else
			for(var/type_path in GLOB.pipe_path2type)
				if(ispath(makes_type, type_path))
					pipe_type = GLOB.pipe_path2type[type_path] + is_bent
					break

		switch(pipe_type)
			if(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT, PIPE_SUPPLY_MANIFOLD, PIPE_SUPPLY_MANIFOLD4W, PIPE_SUPPLY_CAP)
				connect_types = list(CONNECT_TYPE_SUPPLY)
				color = PIPE_COLOR_BLUE

			if(PIPE_SCRUBBERS_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT, PIPE_SCRUBBERS_CAP)
				connect_types = list(CONNECT_TYPE_SCRUBBER)
				color = PIPE_COLOR_RED

			if(PIPE_UNIVERSAL)
				connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY, CONNECT_TYPE_SCRUBBER)

		var/obj/machinery/atmospherics/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			flipped = TRUE

		var/obj/machinery/atmospherics/binary/circulator/circP = make_from
		if(istype(circP) && circP.side == CIRCULATOR_SIDE_RIGHT)
			flipped = TRUE

	else
		pipe_type = new_pipe_type
		makes_type = GLOB.pipe_path2type[num2text(pipe_type)]
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
	scatter_atom()

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
	. += "<span class='notice'>Alt-click it to rotate, Alt-Shift-click it to flip!</span>"

/obj/item/pipe/proc/update(obj/machinery/atmospherics/make_from)
	name = "[get_pipe_name(pipe_type, PIPETYPE_ATMOS)] fitting"
	icon_state = get_pipe_icon(pipe_type)

	var/obj/machinery/atmospherics/trinary/triP = make_from
	if(istype(triP) && triP.flipped)
		icon_state = "m_[icon_state]"

	var/obj/machinery/atmospherics/binary/circulator/circP = make_from
	if(istype(circP) && circP.side == CIRCULATOR_SIDE_RIGHT)
		icon_state = "m_[icon_state]"

	if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
		resistance_flags |= FIRE_PROOF | LAVA_PROOF

// called by turf to know if should treat as bent or not on placement
/obj/item/pipe/proc/is_bent_pipe()
	return pipe_type in list( \
		PIPE_SIMPLE_BENT, \
		PIPE_HE_BENT, \
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

	else if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
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
		if(PIPE_JUNCTION)
			return flip

		if(PIPE_SIMPLE_BENT, PIPE_HE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT,
			PIPE_UVENT, PIPE_PASV_VENT, PIPE_SCRUBBER, PIPE_INJECTOR)
			return dir

		if(PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_JUNCTION,
			PIPE_PUMP, PIPE_VOLUME_PUMP, PIPE_PASSIVE_GATE, PIPE_MVALVE, PIPE_DVALVE, PIPE_DP_VENT,
			PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL,
			PIPE_CONNECTOR, PIPE_HEAT_EXCHANGE)
			return dir|flip

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

/obj/item/pipe/proc/unflip(direction)
	if(!(direction in GLOB.cardinal))
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir == 2)
			dir = 1

		else if(dir == 8)
			dir = 4

	else if(pipe_type in list(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W))
		dir = 2

/obj/item/pipe/attack_self__legacy__attackchain(mob/user as mob)
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
		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new makes_type(loc)
			P.initialize_directions_he = pipe_dir
			if(pipename)
				P.name = pipename
			P.on_construction(dir, pipe_dir, color)
			if(label)
				P.AddComponent(/datum/component/label, label)

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new makes_type(loc)
			P.initialize_directions_he = dir
			if(pipename)
				P.name = pipename
			P.on_construction(dir, pipe_dir, color)
			if(label)
				P.AddComponent(/datum/component/label, label)

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE)
			var/obj/machinery/atmospherics/trinary/P = new makes_type(loc)
			P.flipped = flipped
			dir = unflip(dir)
			if(pipename)
				P.name = pipename
			P.on_construction(dir, pipe_dir, color)
			if(label)
				P.AddComponent(/datum/component/label, label)

		if(PIPE_CIRCULATOR) //circulator
			var/obj/machinery/atmospherics/binary/circulator/P = new makes_type(loc)
			if(flipped)
				P.side = CIRCULATOR_SIDE_RIGHT
			if(pipename)
				P.name = pipename
			P.on_construction(dir, pipe_dir, color)
			if(label)
				P.AddComponent(/datum/component/label, label)

		else
			var/obj/machinery/atmospherics/P = new makes_type(loc)
			if(pipename)
				P.name = pipename
			P.on_construction(dir, pipe_dir, color)
			if(label)
				P.AddComponent(/datum/component/label, label)

	user.visible_message( \
		"<span class='notice'>[user] fastens [src].</span>",
		"<span class='notice'>You fasten [src].</span>",
		"<span class='notice'>You hear a ratchet.</span>")
	qdel(src)	// remove the pipe item
	. |= RPD_TOOL_SUCCESS

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	inhand_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/label = null

/obj/item/pipe_meter/wrench_act(mob/living/user, obj/item/I)
	if(!locate(/obj/machinery/atmospherics/pipe, loc))
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe.</span>")
		return TRUE

	var/obj/machinery/atmospherics/meter/P = new(loc)
	if(label)
		P.AddComponent(/datum/component/label, label)
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You have fastened the meter to the pipe.</span>")
	qdel(src)
	return TRUE

/obj/item/pipe_meter/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
		return

	..()

/obj/item/pipe_gsensor
	name = "gas sensor"
	desc = "A sensor that can be hooked to a computer."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	inhand_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/label = null

/obj/item/pipe_gsensor/wrench_act(mob/living/user, obj/item/I)
	var/obj/machinery/atmospherics/air_sensor/AS = new /obj/machinery/atmospherics/air_sensor(loc)
	AS.bolts = FALSE
	if(label)
		AS.AddComponent(/datum/component/label, label)
	I.play_tool_sound(src, 50)
	to_chat(user, "<span class='notice'>You have fastened the gas sensor.</span>")
	qdel(src)
	return TRUE

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

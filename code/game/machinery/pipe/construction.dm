#define PIPE_SIMPLE_STRAIGHT		0
#define PIPE_SIMPLE_BENT			1
#define PIPE_HE_STRAIGHT			2
#define PIPE_HE_BENT				3
#define PIPE_CONNECTOR				4
#define PIPE_MANIFOLD				5
#define PIPE_JUNCTION				6
#define PIPE_UVENT					7
#define PIPE_MVALVE					8
#define PIPE_PUMP					9
#define PIPE_SCRUBBER				10
#define PIPE_INSULATED_STRAIGHT		11
#define PIPE_INSULATED_BENT			12
#define PIPE_GAS_FILTER				13
#define PIPE_GAS_MIXER				14
#define PIPE_PASSIVE_GATE      		15
#define PIPE_VOLUME_PUMP        	16
#define PIPE_HEAT_EXCHANGE     		17
#define PIPE_TVALVE					18
#define PIPE_MANIFOLD4W				19
#define PIPE_CAP					20
#define PIPE_OMNI_MIXER				21
#define PIPE_OMNI_FILTER			22
#define PIPE_UNIVERSAL				23
#define PIPE_SUPPLY_STRAIGHT		24
#define PIPE_SUPPLY_BENT			25
#define PIPE_SCRUBBERS_STRAIGHT		26
#define PIPE_SCRUBBERS_BENT			27
#define PIPE_SUPPLY_MANIFOLD		28
#define PIPE_SCRUBBERS_MANIFOLD		29
#define PIPE_SUPPLY_MANIFOLD4W		30
#define PIPE_SCRUBBERS_MANIFOLD4W	31
#define PIPE_SUPPLY_CAP				32
#define PIPE_SCRUBBERS_CAP			33
#define PIPE_INJECTOR    			34
#define PIPE_DVALVE           	 	35
#define PIPE_DP_VENT    			36
#define PIPE_PASV_VENT				37
#define PIPE_DTVALVE				38

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipename
	var/connect_types[] = list(1) //1=regular, 2=supply, 3=scrubber
	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = 3
	level = 2
	var/flipped = 0

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if(make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		color = make_from.pipe_color
		var/is_bent
		if(make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = 0
		else
			is_bent = 1
		if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			src.pipe_type = PIPE_JUNCTION
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			src.pipe_type = PIPE_HE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/insulated))
			src.pipe_type = PIPE_INSULATED_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_STRAIGHT + is_bent
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_STRAIGHT + is_bent
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/universal) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/universal))
			src.pipe_type = PIPE_UNIVERSAL
			connect_types = list(1,2,3)
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/unary/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_MANIFOLD
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_MANIFOLD
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			src.pipe_type = PIPE_UVENT
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve/digital))
			src.pipe_type = PIPE_DVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			src.pipe_type = PIPE_GAS_FILTER
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			src.pipe_type = PIPE_GAS_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			src.pipe_type = PIPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			src.pipe_type = PIPE_PASSIVE_GATE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/volume_pump))
			src.pipe_type = PIPE_VOLUME_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			src.pipe_type = PIPE_HEAT_EXCHANGE
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve/digital))
			src.pipe_type = PIPE_DTVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve))
			src.pipe_type = PIPE_TVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_MANIFOLD4W
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_MANIFOLD4W
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w))
			src.pipe_type = PIPE_MANIFOLD4W
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_CAP
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_CAP
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap))
			src.pipe_type = PIPE_CAP

		else if(istype(make_from, /obj/machinery/atmospherics/unary/outlet_injector))
			src.pipe_type = PIPE_INJECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/binary/dp_vent_pump))
			src.pipe_type = PIPE_DP_VENT
		else if(istype(make_from, /obj/machinery/atmospherics/unary/passive_vent))
			src.pipe_type = PIPE_PASV_VENT

		else if(istype(make_from, /obj/machinery/atmospherics/omni/mixer))
			src.pipe_type = PIPE_OMNI_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/omni/filter))
			src.pipe_type = PIPE_OMNI_FILTER
		
		var/obj/machinery/atmospherics/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			src.flipped = 1

	else
		src.pipe_type = pipe_type
		src.dir = dir
		if(pipe_type == PIPE_SUPPLY_STRAIGHT || pipe_type == PIPE_SUPPLY_BENT || pipe_type == PIPE_SUPPLY_MANIFOLD || pipe_type == PIPE_SUPPLY_MANIFOLD4W || pipe_type == PIPE_SUPPLY_CAP)
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if(pipe_type == PIPE_SCRUBBERS_STRAIGHT || pipe_type == PIPE_SCRUBBERS_BENT || pipe_type == PIPE_SCRUBBERS_MANIFOLD || pipe_type == PIPE_SCRUBBERS_MANIFOLD4W || pipe_type == PIPE_SCRUBBERS_CAP)
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if(pipe_type == PIPE_UNIVERSAL)
			connect_types = list(1,2,3)

	update(make_from)
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/pipe/proc/update(var/obj/machinery/atmospherics/make_from)
	var/list/nlist = list( \
		"pipe", \
		"bent pipe", \
		"h/e pipe", \
		"bent h/e pipe", \
		"connector", \
		"manifold", \
		"junction", \
		"uvent", \
		"mvalve", \
		"pump", \
		"scrubber", \
		"insulated pipe", \
		"bent insulated pipe", \
		"gas filter", \
		"gas mixer", \
		"passive gate", \
		"volume pump", \
		"heat exchanger", \
		"t-valve", \
		"4-way manifold", \
		"pipe cap", \
		"omni mixer", \
		"omni filter", \
		"universal pipe adapter", \
		"supply pipe", \
		"bent supply pipe", \
		"scrubbers pipe", \
		"bent scrubbers pipe", \
		"supply manifold", \
		"scrubbers manifold", \
		"supply 4-way manifold", \
		"scrubbers 4-way manifold", \
		"supply pipe cap", \
		"scrubbers pipe cap", \
		"air injector", \
		"digital valve", \
		"dual-port vent", \
		"passive vent", \
		"digital t-valve", \
	)
	name = nlist[pipe_type+1] + " fitting"
	var/list/islist = list( \
		"simple", \
		"simple", \
		"he", \
		"he", \
		"connector", \
		"manifold", \
		"junction", \
		"uvent", \
		"mvalve", \
		"pump", \
		"scrubber", \
		"insulated", \
		"insulated", \
		"filter", \
		"mixer", \
		"passivegate", \
		"volumepump", \
		"heunary", \
		"tvalve", \
		"manifold4w", \
		"cap", \
		"omni_mixer", \
		"omni_filter", \
		"universal", \
		"simple", \
		"simple", \
		"simple", \
		"simple", \
		"manifold", \
		"manifold", \
		"manifold4w", \
		"manifold4w", \
		"cap", \
		"cap", \
		"injector", \
		"dvalve", \
		"dual-port vent", \
		"passive vent", \
		"dtvalve", \
		)
	icon_state = islist[pipe_type + 1]
	var/obj/machinery/atmospherics/trinary/triP = make_from
	if(istype(triP) && triP.flipped)
		icon_state = "m_[icon_state]"

// called by turf to know if should treat as bent or not on placement
/obj/item/pipe/proc/is_bent_pipe()
	return pipe_type in list( \
		PIPE_SIMPLE_BENT, \
		PIPE_HE_BENT, \
		PIPE_INSULATED_BENT, \
		PIPE_SUPPLY_BENT, \
		PIPE_SCRUBBERS_BENT)
		
// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if( usr.stat || usr.restrained() )
		return

	src.dir = turn(src.dir, -90)

	fixdir()

	return
	
/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if(usr.stat || usr.restrained())
		return

	if(pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE))
		if(flipped)
			icon_state = copytext(icon_state,3)
		else
			icon_state = "m_[icon_state]"
		flipped = !flipped
		return

	src.dir = turn(src.dir, -180)

	fixdir()

	return

/obj/item/pipe/Move()
	..()
	if(is_bent_pipe() \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	return

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if(!dir)
		return 0
	
	var/direct = dir
	if(flipped)
		direct = turn(dir, 45)	
	
	var/flip = turn(direct, 180)
	var/cw = turn(direct, -90)
	var/acw = turn(direct, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_INSULATED_STRAIGHT, \
			PIPE_HE_STRAIGHT, \
			PIPE_JUNCTION ,\
			PIPE_PUMP ,\
			PIPE_VOLUME_PUMP ,\
			PIPE_PASSIVE_GATE ,\
			PIPE_MVALVE, \
			PIPE_DVALVE, \
			PIPE_DP_VENT, \
			PIPE_SUPPLY_STRAIGHT, \
			PIPE_SCRUBBERS_STRAIGHT, \
			PIPE_UNIVERSAL, \
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT, PIPE_INSULATED_BENT, PIPE_HE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT)
			return dir //dir|acw
		if(PIPE_CONNECTOR, PIPE_UVENT, PIPE_PASV_VENT, PIPE_SCRUBBER, PIPE_HEAT_EXCHANGE, PIPE_INJECTOR)
			return dir
		if(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER)
			return dir|flip|cw|acw
		if(PIPE_MANIFOLD, PIPE_SUPPLY_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD)
			return flip|cw|acw
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE)
			if(!flipped)
				return dir|flip|cw
			else
				return flip|cw|acw
		if(PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP)
			return dir
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes

	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

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

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0
		
/obj/item/pipe/proc/unflip(var/direction)
	if(!(direction in cardinal))
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if(pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	else if(pipe_type in list(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER))
		dir = 2

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	..()

	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
		
	if(!isturf(src.loc))
		return 1

	fixdir()
		
	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if((M.initialize_directions & pipe_dir) && M.check_connect_types_construction(M,src))	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe of the same type at this location.</span>")
			return 1

	switch(pipe_type) //What kind of heartless person thought of doing this?
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new( src.loc )
			P.construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/supply/P = new( src.loc )
			P.construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers/P = new( src.loc )
			P.construction(dir, pipe_dir, color)

		if(PIPE_UNIVERSAL)
			var/obj/machinery/atmospherics/pipe/simple/hidden/universal/P = new( src.loc )
			P.construction(dir, pipe_dir, color)

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new ( src.loc )
			P.initialize_directions_he = pipe_dir
			P.construction(dir, pipe_dir, color)

		if(PIPE_CONNECTOR)		// connector
			var/obj/machinery/atmospherics/unary/portables_connector/C = new( src.loc )
			if(pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, color)

		if(PIPE_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/M = new( src.loc )
			M.construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/supply/M = new( src.loc )
			M.construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers/M = new( src.loc )
			M.construction(dir, pipe_dir, color)

		if(PIPE_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new( src.loc )
			M.construction(dir, pipe_dir, color)
			
		if(PIPE_SUPPLY_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply/M = new( src.loc )
			M.construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers/M = new( src.loc )
			M.construction(dir, pipe_dir, color)

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new ( src.loc )
			P.initialize_directions_he = src.get_hdir()
			P.construction(dir, get_pdir(), color)

		if(PIPE_UVENT)		//unary vent
			var/obj/machinery/atmospherics/unary/vent_pump/V = new( src.loc )
			V.construction(dir, pipe_dir, color)

		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/atmospherics/binary/valve/V = new( src.loc)
			if(pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), color)
			
		if(PIPE_DVALVE)
			var/obj/machinery/atmospherics/binary/valve/digital/V = new( src.loc )
			if(pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), color)
			
		if(PIPE_PUMP)		//gas pump
			var/obj/machinery/atmospherics/binary/pump/P = new(src.loc)
			P.construction(dir, pipe_dir, color)

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_TVALVE, PIPE_DTVALVE)
			var/obj/machinery/atmospherics/trinary/P
			switch(pipe_type)
				if(PIPE_GAS_FILTER)
					P = new /obj/machinery/atmospherics/trinary/filter(src.loc)
				if(PIPE_GAS_MIXER)
					P = new /obj/machinery/atmospherics/trinary/mixer(src.loc)
				if(PIPE_TVALVE)
					P = new /obj/machinery/atmospherics/trinary/tvalve(src.loc)
				if(PIPE_DTVALVE)
					P = new /obj/machinery/atmospherics/trinary/tvalve/digital(src.loc)
			P.flipped = flipped
			if(pipename)
				P.name = pipename
			P.construction(unflip(dir), pipe_dir, color)

		if(PIPE_SCRUBBER)		//scrubber
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(src.loc)
			if(pipename)
				S.name = pipename
			S.construction(dir, pipe_dir, color)

		if(PIPE_INSULATED_STRAIGHT, PIPE_INSULATED_BENT)
			var/obj/machinery/atmospherics/pipe/simple/insulated/P = new( src.loc )
			P.construction(dir, pipe_dir, color)

		if(PIPE_CAP)
			var/obj/machinery/atmospherics/pipe/cap/C = new(src.loc)
			C.construction(dir, pipe_dir, color)

		if(PIPE_SUPPLY_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/supply/C = new(src.loc)
			C.construction(dir, pipe_dir, color)

		if(PIPE_SCRUBBERS_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers/C = new(src.loc)
			C.construction(dir, pipe_dir, color)

		if(PIPE_PASSIVE_GATE)		//passive gate
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(src.loc)
			if(pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, color)

		if(PIPE_VOLUME_PUMP)		//volume pump
			var/obj/machinery/atmospherics/binary/volume_pump/P = new(src.loc)
			if(pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, color)

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new( src.loc )
			if(pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, color)

		if(PIPE_INJECTOR)		// air injector
			var/obj/machinery/atmospherics/unary/outlet_injector/P = new( src.loc )
			if(pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, color)
			
		if(PIPE_DP_VENT)
			var/obj/machinery/atmospherics/binary/dp_vent_pump/P = new(src.loc)
			if(pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, color)
			
		if(PIPE_PASV_VENT)
			var/obj/machinery/atmospherics/unary/passive_vent/P  = new(src.loc)
			if(pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, color)

		if(PIPE_OMNI_MIXER)
			var/obj/machinery/atmospherics/omni/mixer/P = new(loc)
			P.construction(dir, pipe_dir, color)
			
		if(PIPE_OMNI_FILTER)
			var/obj/machinery/atmospherics/omni/filter/P = new(loc)
			P.construction(dir, pipe_dir, color)

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens the [src].", \
		"\blue You have fastened the [src].", \
		"You hear ratchet.")
	qdel(src)	// remove the pipe item

	return

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	..()

	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		to_chat(user, "\red You need to fasten it to a pipe")
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "\blue You have fastened the meter to the pipe")
	qdel(src)

/obj/item/pipe_gsensor
	name = "gas sensor"
	desc = "A sensor that can be hooked to a computer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_gsensor/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	new/obj/machinery/air_sensor( src.loc )
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "\blue You have fastened the gas sensor")
	qdel(src)

#undef PIPE_SIMPLE_STRAIGHT
#undef PIPE_SIMPLE_BENT
#undef PIPE_HE_STRAIGHT
#undef PIPE_HE_BENT
#undef PIPE_CONNECTOR
#undef PIPE_MANIFOLD
#undef PIPE_JUNCTION
#undef PIPE_UVENT
#undef PIPE_MVALVE
#undef PIPE_PUMP
#undef PIPE_SCRUBBER
#undef PIPE_INSULATED_STRAIGHT
#undef PIPE_INSULATED_BENT
#undef PIPE_GAS_FILTER
#undef PIPE_GAS_MIXER
#undef PIPE_PASSIVE_GATE
#undef PIPE_VOLUME_PUMP
#undef PIPE_HEAT_EXCHANGE
#undef PIPE_TVALVE
#undef PIPE_MANIFOLD4W
#undef PIPE_CAP
#undef PIPE_OMNI_MIXER
#undef PIPE_OMNI_FILTER
#undef PIPE_UNIVERSAL
#undef PIPE_SUPPLY_STRAIGHT
#undef PIPE_SUPPLY_BENT
#undef PIPE_SCRUBBERS_STRAIGHT
#undef PIPE_SCRUBBERS_BENT
#undef PIPE_SUPPLY_MANIFOLD
#undef PIPE_SCRUBBERS_MANIFOLD
#undef PIPE_SUPPLY_MANIFOLD4W
#undef PIPE_SCRUBBERS_MANIFOLD4W
#undef PIPE_SUPPLY_CAP
#undef PIPE_SCRUBBERS_CAP
#undef PIPE_INJECTOR
#undef PIPE_DVALVE
#undef PIPE_DP_VENT
#undef PIPE_PASV_VENT
#undef PIPE_DTVALVE

/*CONTENTS
Buildable pipes
Buildable meters
*/
#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_HE_STRAIGHT		2
#define PIPE_HE_BENT			3
#define PIPE_CONNECTOR			4
#define PIPE_MANIFOLD			5
#define PIPE_JUNCTION			6
#define PIPE_UVENT				7
#define PIPE_MVALVE				8
#define PIPE_PUMP				9
#define PIPE_SCRUBBER			10
#define PIPE_INSULATED_STRAIGHT	11
#define PIPE_INSULATED_BENT		12
#define PIPE_GAS_FILTER			13
#define PIPE_GAS_MIXER			14
#define PIPE_PASSIVE_GATE       15
#define PIPE_VOLUME_PUMP        16
#define PIPE_HEAT_EXCHANGE      17
#define PIPE_MTVALVE			18
#define PIPE_MANIFOLD4W			19
#define PIPE_CAP				20
///// Z-Level stuff
#define PIPE_UP					21
#define PIPE_DOWN				22
///// Z-Level stuff
#define PIPE_GAS_FILTER_M		23
#define PIPE_GAS_MIXER_T		24
#define PIPE_GAS_MIXER_M		25
#define PIPE_OMNI_MIXER			26
#define PIPE_OMNI_FILTER		27
///// Supply, scrubbers and universal pipes
#define PIPE_UNIVERSAL				28
#define PIPE_SUPPLY_STRAIGHT		29
#define PIPE_SUPPLY_BENT			30
#define PIPE_SCRUBBERS_STRAIGHT		31
#define PIPE_SCRUBBERS_BENT			32
#define PIPE_SUPPLY_MANIFOLD		33
#define PIPE_SCRUBBERS_MANIFOLD		34
#define PIPE_SUPPLY_MANIFOLD4W		35
#define PIPE_SCRUBBERS_MANIFOLD4W	36
#define PIPE_SUPPLY_CAP				37
#define PIPE_SCRUBBERS_CAP			38

///// /vg/ ported stuff
#define PIPE_INJECTOR    		39
#define PIPE_DVALVE             40
#define PIPE_DP_VENT    		41
#define PIPE_PASV_VENT			42

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	//var/pipe_dir = 0
	var/pipename
	var/connect_types[] = list(1) //1=regular, 2=supply, 3=scrubber
	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = 3
	level = 2

/obj/item/pipe/New(var/loc, var/pipe_type as num, var/dir as num, var/obj/machinery/atmospherics/make_from = null)
	..()
	if (make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		color = make_from.pipe_color
		var/is_bent
		if  (make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = 0
		else
			is_bent = 1
		if     (istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
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
		else if(istype(make_from, /obj/machinery/atmospherics/portables_connector))
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
		else if(istype(make_from, /obj/machinery/atmospherics/valve/digital))
			src.pipe_type = PIPE_DVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter/m_filter))
			src.pipe_type = PIPE_GAS_FILTER_M
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer/t_mixer))
			src.pipe_type = PIPE_GAS_MIXER_T
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer/m_mixer))
			src.pipe_type = PIPE_GAS_MIXER_M
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
		else if(istype(make_from, /obj/machinery/atmospherics/tvalve))
			src.pipe_type = PIPE_MTVALVE
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
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/vent))
			src.pipe_type = PIPE_PASV_VENT


		else if(istype(make_from, /obj/machinery/atmospherics/omni/mixer))
			src.pipe_type = PIPE_OMNI_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/omni/filter))
			src.pipe_type = PIPE_OMNI_FILTER
///// Z-Level stuff
		/*else if(istype(make_from, /obj/machinery/atmospherics/pipe/zpipe/up))
			src.pipe_type = PIPE_UP
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/zpipe/down))
			src.pipe_type = PIPE_DOWN*/
///// Z-Level stuff

	else
		src.pipe_type = pipe_type
		src.dir = dir
		if (pipe_type == 29 || pipe_type == 30 || pipe_type == 33 || pipe_type == 35 || pipe_type == 37)
			connect_types = list(2)
			src.color = PIPE_COLOR_BLUE
		else if (pipe_type == 31 || pipe_type == 32 || pipe_type == 34 || pipe_type == 36 || pipe_type == 38)
			connect_types = list(3)
			src.color = PIPE_COLOR_RED
		else if (pipe_type == 28)
			connect_types = list(1,2,3)
	//src.pipe_dir = get_pipe_dir()
	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/pipe/proc/update()
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
///// Z-Level stuff
		"pipe up", \
		"pipe down", \
///// Z-Level stuff
		"gas filter m", \
		"gas mixer t", \
		"gas mixer m", \
		"omni mixer", \
		"omni filter", \
///// Supply and scrubbers pipes
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
		// /vg/ ported stuff
		"air injector", \
		"Digital Valve", \
		"dual-port vent", \
		"passive vent", \
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
		"mtvalve", \
		"manifold4w", \
		"cap", \
///// Z-Level stuff
		"cap", \
		"cap", \
///// Z-Level stuff
		"m_filter", \
		"t_mixer", \
		"m_mixer", \
		"omni_mixer", \
		"omni_filter", \
///// Supply and scrubbers pipes
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
		// /vg/ ported stuff
		"injector", \
		"dvalve", \
		"dual-port vent", \
		"passive vent", \
		)
	icon_state = islist[pipe_type + 1]

//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	src.dir = turn(src.dir, -90)

	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	else if (pipe_type in list (PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W))
		dir = 2
	//src.pipe_dir = get_pipe_dir()
	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT, PIPE_HE_BENT, PIPE_INSULATED_BENT)) \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	return

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0
	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

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
			PIPE_MVALVE ,\
			PIPE_SUPPLY_STRAIGHT, \
			PIPE_SCRUBBERS_STRAIGHT, \
			PIPE_UNIVERSAL, \
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT, PIPE_INSULATED_BENT, PIPE_HE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT)
			return dir //dir|acw
		if(PIPE_CONNECTOR,PIPE_UVENT,PIPE_PASV_VENT,PIPE_SCRUBBER,PIPE_HEAT_EXCHANGE, PIPE_INJECTOR)
			return dir
		if(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER)
			return dir|flip|cw|acw
		if(PIPE_MANIFOLD, PIPE_SUPPLY_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD)
			return flip|cw|acw
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER,PIPE_MTVALVE)
			return dir|flip|cw
		if(PIPE_GAS_FILTER_M, PIPE_GAS_MIXER_M)
			return dir|flip|acw
		if(PIPE_GAS_MIXER_T)
			return dir|cw|acw
		if(PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP)
			return dir
///// Z-Level stuff
		if(PIPE_UP,PIPE_DOWN)
			return dir
///// Z-Level stuff
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes

	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

	if (!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
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

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	..()
	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1
	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	else if (pipe_type in list(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER))
		dir = 2
	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if((M.initialize_directions & pipe_dir) && M.check_connect_types_construction(M,src))	// matches at least one direction on either type of pipe
			user << "\red There is already a pipe of the same type at this location."
			return 1
	// no conflicts found

	var/pipefailtext = "\red There's nothing to connect this pipe section to!" //(with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
	var/obj/machinery/atmospherics/machineReference = null //If somebody wants to overhaul that switch statement below, be my guest. Easier to set a reference here and then transfer logs after the switch statement.

	switch(pipe_type) //What kind of heartless person thought of doing this?
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new( src.loc )
			P.pipe_color = color
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/supply/P = new( src.loc )
			P.color = color
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers/P = new( src.loc )
			P.color = color
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_UNIVERSAL)
			var/obj/machinery/atmospherics/pipe/simple/hidden/universal/P = new( src.loc )
			P.color = color
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new ( src.loc )
			P.dir = src.dir
			P.initialize_directions = pipe_dir //this var it's used to know if the pipe is bent or not
			P.initialize_directions_he = pipe_dir
			//var/turf/T = P.loc
			//P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P)
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_CONNECTOR)		// connector
			var/obj/machinery/atmospherics/portables_connector/C = new( src.loc )
			C.dir = dir
			C.initialize_directions = pipe_dir
			if (pipename)
				C.name = pipename
			var/turf/T = C.loc
			C.level = T.intact ? 2 : 1
			C.initialize()
			C.build_network()
			if (C.node)
				C.node.initialize()
				C.node.build_network()
			machineReference = C


		if(PIPE_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/M = new( src.loc )
			M.pipe_color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			machineReference = M

		if(PIPE_SUPPLY_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/supply/M = new( src.loc )
			M.color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			machineReference = M

		if(PIPE_SCRUBBERS_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers/M = new( src.loc )
			M.color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			machineReference = M

		if(PIPE_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new( src.loc )
			M.pipe_color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			if (M.node4)
				M.node4.initialize()
				M.node4.build_network()
			machineReference = M

		if(PIPE_SUPPLY_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply/M = new( src.loc )
			M.color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			M.connect_types = src.connect_types
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			if (M.node4)
				M.node4.initialize()
				M.node4.build_network()
			machineReference = M

		if(PIPE_SCRUBBERS_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers/M = new( src.loc )
			M.color = color
			M.dir = dir
			M.initialize_directions = pipe_dir
			M.connect_types = src.connect_types
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << pipefailtext
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()
			if (M.node4)
				M.node4.initialize()
				M.node4.build_network()
			machineReference = M

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new ( src.loc )
			P.dir = src.dir
			P.initialize_directions = src.get_pdir()
			P.initialize_directions_he = src.get_hdir()
			//var/turf/T = P.loc
			//P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext //"There's nothing to connect this pipe to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_UVENT)		//unary vent
			var/obj/machinery/atmospherics/unary/vent_pump/V = new( src.loc )
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node)
				V.node.initialize()
				V.node.build_network()
			machineReference = V


		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/atmospherics/valve/V = new( src.loc)
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node1)
//					world << "[V.node1.name] is connected to valve, forcing it to update its nodes."
				V.node1.initialize()
				V.node1.build_network()
			if (V.node2)
//					world << "[V.node2.name] is connected to valve, forcing it to update its nodes."
				V.node2.initialize()
				V.node2.build_network()
			machineReference = V

		if(PIPE_PUMP)		//gas pump
			var/obj/machinery/atmospherics/binary/pump/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_GAS_FILTER)		//gas filter
			var/obj/machinery/atmospherics/trinary/filter/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()
			machineReference = P

		if(PIPE_GAS_MIXER)		//gas mixer
			var/obj/machinery/atmospherics/trinary/mixer/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()
			machineReference = P

		if(PIPE_GAS_FILTER_M)		//gas filter mirrored
			var/obj/machinery/atmospherics/trinary/filter/m_filter/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()
			machineReference = P

		if(PIPE_GAS_MIXER_T)		//gas mixer-t
			var/obj/machinery/atmospherics/trinary/mixer/t_mixer/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()
			machineReference = P

		if(PIPE_GAS_MIXER_M)		//gas mixer mirrored
			var/obj/machinery/atmospherics/trinary/mixer/m_mixer/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()
			machineReference = P

		if(PIPE_SCRUBBER)		//scrubber
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(src.loc)
			S.dir = dir
			S.initialize_directions = pipe_dir
			if (pipename)
				S.name = pipename
			var/turf/T = S.loc
			S.level = T.intact ? 2 : 1
			S.initialize()
			S.build_network()
			if (S.node)
				S.node.initialize()
				S.node.build_network()
			machineReference = S

		if(PIPE_INSULATED_STRAIGHT, PIPE_INSULATED_BENT)
			var/obj/machinery/atmospherics/pipe/simple/insulated/P = new( src.loc )
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P || (!P.node1 && !P.node2) )
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_MTVALVE)		//manual t-valve
			var/obj/machinery/atmospherics/tvalve/V = new(src.loc)
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node1)
				V.node1.initialize()
				V.node1.build_network()
			if (V.node2)
				V.node2.initialize()
				V.node2.build_network()
			if (V.node3)
				V.node3.initialize()
				V.node3.build_network()
			machineReference = V

		if(PIPE_CAP)
			var/obj/machinery/atmospherics/pipe/cap/C = new(src.loc)
			C.dir = dir
			C.initialize_directions = pipe_dir
			C.initialize()
			C.build_network()
			if(C.node)
				C.node.initialize()
				C.node.build_network()
			machineReference = C

		if(PIPE_SUPPLY_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/supply/C = new(src.loc)
			C.dir = dir
			C.initialize_directions = pipe_dir
			C.initialize()
			C.build_network()
			if(C.node)
				C.node.initialize()
				C.node.build_network()
			machineReference = C

		if(PIPE_SCRUBBERS_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers/C = new(src.loc)
			C.dir = dir
			C.initialize_directions = pipe_dir
			C.initialize()
			C.build_network()
			if(C.node)
				C.node.initialize()
				C.node.build_network()
			machineReference = C

		if(PIPE_PASSIVE_GATE)		//passive gate
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_VOLUME_PUMP)		//volume pump
			var/obj/machinery/atmospherics/binary/volume_pump/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new( src.loc )
			C.dir = dir
			C.initialize_directions = pipe_dir
			if (pipename)
				C.name = pipename
			var/turf/T = C.loc
			C.level = T.intact ? 2 : 1
			C.initialize()
			C.build_network()
			if (C.node)
				C.node.initialize()
				C.node.build_network()
			machineReference = C

		if(PIPE_INJECTOR)		// air injector
			var/obj/machinery/atmospherics/unary/outlet_injector/P = new( src.loc )
			P.dir = dir
			P.initialize_directions = get_pipe_dir()
			if (pipename)
				name = pipename
			var/turf/T = loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node)
				P.node.initialize()
				P.node.build_network()
			machineReference = P

		if(PIPE_DVALVE)
			var/obj/machinery/atmospherics/valve/digital/V = new( src.loc )
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node1)
//					world << "[V.node1.name] is connected to valve, forcing it to update its nodes."
				V.node1.initialize()
				V.node1.build_network()
			if (V.node2)
//					world << "[V.node2.name] is connected to valve, forcing it to update its nodes."
				V.node2.initialize()
				V.node2.build_network()
			machineReference = V

		if(PIPE_DP_VENT)
			var/obj/machinery/atmospherics/binary/dp_vent_pump/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			machineReference = P

		if(PIPE_PASV_VENT)
			var/obj/machinery/atmospherics/pipe/vent/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = get_pipe_dir()
			if (pipename)
				name = pipename
			var/turf/T = loc
			level = T.intact ? 2 : 1
			initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			machineReference = P

///// Z-Level stuff
/*		if(PIPE_UP)
			var/obj/machinery/atmospherics/pipe/zpipe/up/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
		if(PIPE_DOWN)
			var/obj/machinery/atmospherics/pipe/zpipe/down/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()*/
///// Z-Level stuff

		if(PIPE_OMNI_MIXER)
			var/obj/machinery/atmospherics/omni/mixer/P = new(loc)
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			machineReference = P
		if(PIPE_OMNI_FILTER)
			var/obj/machinery/atmospherics/omni/filter/P = new(loc)
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			machineReference = P

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens the [src].", \
		"\blue You have fastened the [src].", \
		"You hear ratchet.")
	if(machineReference)
		transfer_fingerprints_to(machineReference)
		machineReference.add_fingerprint(user)
	qdel(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		user << "\red You need to fasten it to a pipe"
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You have fastened the meter to the pipe"
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
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	new/obj/machinery/air_sensor( src.loc )
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You have fastened the gas sensor"
	qdel(src)
//not sure why these are necessary
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
#undef PIPE_OUTLET_INJECT
#undef PIPE_MTVALVE
#undef PIPE_GAS_FILTER_M
#undef PIPE_GAS_MIXER_T
#undef PIPE_GAS_MIXER_M
#undef PIPE_SUPPLY_STRAIGHT
#undef PIPE_SUPPLY_BENT
#undef PIPE_SCRUBBERS_STRAIGHT
#undef PIPE_SCRUBBERS_BENT
#undef PIPE_SUPPLY_MANIFOLD
#undef PIPE_SCRUBBERS_MANIFOLD
#undef PIPE_UNIVERSAL
#undef PIPE_INJECTOR
#undef PIPE_DVALVE
#undef PIPE_DP_VENT
#undef PIPE_PASV_VENT
//#undef PIPE_MANIFOLD4W

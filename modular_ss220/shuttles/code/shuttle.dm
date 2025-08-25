/obj/docking_port/mobile/New(loc, ...)
	. = ..()
	if(roundstart_move)
		roundstart_move = replacetext(roundstart_move, "%id", id)

/obj/docking_port/mobile/supply
	dir = EAST
	port_direction = WEST
	preferred_direction = NORTH
	width = 12
	dwidth = 5
	height = 7

/obj/docking_port/mobile/labour
	dir = WEST
	port_direction = EAST
	preferred_direction = EAST
	width = 9
	height = 5
	dwidth = 2
	dheight = 0
	roundstart_move = "%id_away"

/obj/docking_port/mobile/mining
	dir = WEST
	port_direction = EAST
	preferred_direction = NORTH
	width = 7
	height = 5
	dwidth = 3
	dheight = 0
	roundstart_move = "%id_away"

/obj/docking_port/mobile/whiteship
	dir = NORTH
	port_direction = EAST
	preferred_direction = EAST
	width = 31
	height = 17
	dwidth = 22
	dheight = 0

/obj/docking_port/stationary/whiteship
	width = 31
	height = 17
	dwidth = 22
	dheight = 0

/obj/docking_port/mobile/scavenger
	id = "vox_shuttle"
	name = "scavenger shuttle"
	dir = SOUTH
	port_direction = NORTH
	preferred_direction = NORTH
	width = 19
	height = 18
	dwidth = 13
	dheight = 0

/obj/docking_port/mobile/trade_sol
	dir = WEST
	port_direction = SOUTH
	preferred_direction = WEST
	width = 15
	height = 18
	dwidth = 7
	dheight = 1

/obj/docking_port/mobile/specops
	dir = SOUTH
	port_direction = NORTH
	preferred_direction = NORTH
	width = 5
	height = 11
	dwidth = 2
	dheight = 0

/obj/docking_port/mobile/nuke_ops
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = NORTH
	width = 18
	height = 22
	dwidth = 8
	dheight = 0
	roundstart_move = "%id_away"

/obj/docking_port/mobile/sit
	dir = EAST
	port_direction = EAST
	preferred_direction = SOUTH
	width = 11
	height = 5
	dwidth = 7
	dheight = 0
	roundstart_move = "%id_away"

/obj/docking_port/mobile/sst
	dir = WEST
	port_direction = WEST
	preferred_direction = SOUTH
	width = 11
	height = 5
	dwidth = 3
	dheight = 0
	roundstart_move = "%id_away"

/obj/docking_port/mobile/admin
	dir = WEST
	port_direction = EAST
	preferred_direction = NORTH
	width = 18
	height = 15
	dwidth = 8
	dheight = 0
	timid = TRUE

/obj/docking_port/mobile/ferry
	dir = WEST
	port_direction = SOUTH
	preferred_direction = WEST
	width = 5
	height = 12
	dwidth = 2
	dheight = 0

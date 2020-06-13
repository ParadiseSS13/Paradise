/*
Spawners for mappers. Just plonk one down of the desired size and it will place the machinery for you. The red arrow things indicate where the chamber is.
This spawner places pipe leading up to the interior door, you will need to finish it off yourself with a connector, canister, and pipe connecting the two. It also assumes you already put in wall and floor.
*/

#define HALF_X	round((tiles_in_x_direction - 1) * 0.5) //These are required so that the airlock can be in the middle of the chamber wall
#define HALF_Y	round((tiles_in_y_direction - 1) * 0.5)
#define CHAMBER_LONG	1
#define CHAMBER_SQUARE	2
#define CHAMBER_BIGGER	3
#define DOOR_NORMAL_PLACEMENT 1
#define DOOR_FLIPPED_PLACEMENT 2

#define AIRPUMP_TAG		"[id_to_link]_pump"
#define SENSOR_TAG		"[id_to_link]_sensor"
#define OUTER_DOOR_TAG	"[id_to_link]_outer"
#define INNER_DOOR_TAG	"[id_to_link]_inner"

/obj/effect/spawner/airlock
	name = "1 by 1 airlock spawner (interior north, exterior south)"
	desc = "If you can see this, there's probably a missing airlock here. Better tell an admin and report this on the github."
	icon = 'icons/obj/airlock_spawner.dmi'
	icon_state = "1x1_N_to_S"
	layer = SPLASHSCREEN_PLANE //So we absolutely always appear above everything else. We delete ourself after spawning so this is fine
	var/interior_direction = NORTH	//This is also the direction the spawner will send the pipe
	var/exterior_direction = SOUTH
	var/opposite_interior_direction	//We're checking these often enough for them to merit their own vars
	var/interior_direction_cw
	var/interior_direction_ccw
	var/north_or_south_interior		//Used a bit everywhere for locational stuff
	var/north_or_south_exterior		//Likewise
	var/tiles_in_x_direction = 1
	var/tiles_in_y_direction = 1
	var/id_to_link
	var/radio_frequency = 1379
	var/required_access = list(ACCESS_EXTERNAL_AIRLOCKS)
	var/door_name = "external access"
	var/door_type = /obj/machinery/door/airlock/external/glass
	var/one_door_interior //For square airlocks, if you set this then a) only one door will spawn, and b) you can choose if the door should go opposite to how it normally goes. Please use the define
	var/one_door_exterior //See above

/obj/effect/spawner/airlock/Initialize()
	..()
	forceMove(locate(x + 1, y + 1, z)) //Needs to move because our icon_state implies we are one turf to the northeast, when we're not
	opposite_interior_direction = turn(interior_direction, 180) //Do it this way (instead of setting it directly) to avoid code mishaps
	interior_direction_cw = turn(interior_direction, 90)
	interior_direction_ccw = turn(interior_direction, 270)
	if(interior_direction == NORTH || interior_direction == SOUTH)
		north_or_south_interior = TRUE
	if(exterior_direction == NORTH || exterior_direction == SOUTH)
		north_or_south_exterior = TRUE
	id_to_link = "[UID()]" //We want unique IDs, this will give us a unique ID
	var/turf/turf_interior = get_airlock_location(interior_direction)
	var/turf/turf_exterior = get_airlock_location(exterior_direction)
	handle_door_creation(turf_interior, TRUE, one_door_interior)
	handle_door_creation(turf_exterior, FALSE, one_door_exterior)
	handle_pipes_creation(turf_interior)
	handle_control_placement()
	qdel(src)

/obj/effect/spawner/airlock/proc/get_airlock_location(desired_direction) //Finds a turf to place an airlock and returns it, this turf will be in the middle of the relevant wall
	var/turf/T
	switch(desired_direction)
		if(NORTH)
			T = locate(x + HALF_X, y + tiles_in_y_direction, z)
		if(SOUTH)
			T = locate(x + HALF_X, y - 1, z)
		if(EAST)
			T = locate(x + tiles_in_x_direction, y + HALF_Y, z)
		if(WEST)
			T = locate(x - 1, y + HALF_Y, z)
	return T

/obj/effect/spawner/airlock/proc/handle_door_creation(turf/T, is_this_an_interior_airlock, one_door_only) //Creates a door (or two) and also creates a button
	var/obj/machinery/door/airlock/A
	if(one_door_only != DOOR_FLIPPED_PLACEMENT)
		A = new door_type(T)
		handle_door_stuff(A, is_this_an_interior_airlock)
	var/obj/machinery/access_button/the_button = spawn_button(T, is_this_an_interior_airlock ? interior_direction : exterior_direction)
	if(one_door_only == DOOR_NORMAL_PLACEMENT) //We only need one door, we are done
		return
	if(!(tiles_in_x_direction % 2) && (is_this_an_interior_airlock && north_or_south_interior || !is_this_an_interior_airlock && north_or_south_exterior)) //Handle extra airlock for aesthetics
		A = new door_type(get_step(T, EAST))
		handle_door_stuff(A, is_this_an_interior_airlock)
		if(one_door_only == DOOR_FLIPPED_PLACEMENT)
			the_button.forceMove(get_step(the_button, EAST))
	else if(!(tiles_in_y_direction % 2) && (is_this_an_interior_airlock && !north_or_south_interior || !is_this_an_interior_airlock && !north_or_south_exterior)) //Handle extra airlock for aesthetics
		A = new door_type(get_step(T, NORTH))
		handle_door_stuff(A, is_this_an_interior_airlock)
		if(one_door_only == DOOR_FLIPPED_PLACEMENT)
			the_button.forceMove(get_step(the_button, NORTH))

/obj/effect/spawner/airlock/proc/handle_door_stuff(obj/machinery/door/airlock/A, is_this_an_interior_airlock) //This sets up the door vars correctly and then locks it before first use
	A.set_frequency(radio_frequency)
	A.id_tag = is_this_an_interior_airlock ? INNER_DOOR_TAG : OUTER_DOOR_TAG
	A.req_access = required_access
	A.name = door_name
	A.lock()

/obj/effect/spawner/airlock/proc/spawn_button(turf/T, some_direction)
	var/obj/machinery/access_button/the_button = new(T)
	the_button.master_tag = id_to_link
	the_button.set_frequency(radio_frequency)
	switch(some_direction)
		if(NORTH)
			the_button.pixel_x -= 25
			the_button.pixel_y = 7
		if(EAST)
			the_button.pixel_x = 7
			the_button.pixel_y = -25
		if(SOUTH)
			the_button.pixel_x -= 25
			the_button.pixel_y -= 7
		if(WEST)
			the_button.pixel_x -= 7
			the_button.pixel_y -= 25
	the_button.req_access = required_access
	return the_button

/obj/effect/spawner/airlock/proc/handle_control_placement() //Stick the sensor and controller on the same bit of wall, this will ONLY be unsuitable if airlocks are on both the south and west turfs
	var/turf/T = get_turf(src)
	var/obj/machinery/airlock_sensor/AS = new(T)
	var/obj/machinery/embedded_controller/radio/airlock/airlock_controller/AC = new(T, id_to_link, radio_frequency, OUTER_DOOR_TAG, INNER_DOOR_TAG, AIRPUMP_TAG, SENSOR_TAG)
	AC.req_access = required_access
	AS.id_tag = SENSOR_TAG
	AS.set_frequency(radio_frequency)
	if(interior_direction != WEST && exterior_direction != WEST) //If west wall is free, place stuff there
		AC.pixel_x -= 25
		AC.pixel_y += 9
		AS.pixel_x -= 25
		AS.pixel_y -= 9
	else if(interior_direction != SOUTH && exterior_direction != SOUTH) //If south wall is free, place stuff there
		AC.pixel_x += 9
		AC.pixel_y -= 25
		AS.pixel_x -= 9
		AS.pixel_y -= 25
	else //Send them over to the other side of the chamber
		T = locate(x + tiles_in_x_direction - 1, y + tiles_in_y_direction - 1, z)
		AC.forceMove(T)
		AS.forceMove(T)
		AC.pixel_x += 25
		AC.pixel_y += 9
		AS.pixel_x += 25
		AS.pixel_y -= 9

/obj/effect/spawner/airlock/proc/handle_pipes_creation(turf/T) //This places all required piping down, then properly initializes it. T is the turf that the interior airlock occupies
	var/turf/below_T = get_step(T, opposite_interior_direction)

	var/two_way_pipe = interior_direction | opposite_interior_direction
	var/chamber_shape //This determines the layout of the chamber and therefore how many vents should be present
	if(tiles_in_x_direction == 2 && tiles_in_y_direction == 2)
		chamber_shape = CHAMBER_SQUARE
	else if(tiles_in_x_direction > 1 && tiles_in_y_direction > 1)
		chamber_shape = CHAMBER_BIGGER
	else
		chamber_shape = CHAMBER_LONG
	pipe_creation_helper(/obj/machinery/atmospherics/pipe/simple/visible, T, interior_direction, two_way_pipe)
	switch(chamber_shape)
		if(CHAMBER_LONG) //Easy enough, place a single vent
			pipe_creation_helper(/obj/machinery/atmospherics/unary/vent_pump/high_volume,
				below_T,
				interior_direction)
		if(CHAMBER_SQUARE) //We need a T-manifold and two vents for this
			pipe_creation_helper(/obj/machinery/atmospherics/pipe/manifold/visible,
				below_T,
				north_or_south_interior ? WEST : SOUTH,
				NORTH | EAST | (north_or_south_interior ? SOUTH : WEST))
			pipe_creation_helper(/obj/machinery/atmospherics/unary/vent_pump/high_volume,
				get_step(below_T, opposite_interior_direction),
				interior_direction)
			pipe_creation_helper(/obj/machinery/atmospherics/unary/vent_pump/high_volume,
				north_or_south_interior ? EAST_OF_TURF(below_T) : NORTH_OF_TURF(below_T),
				turn(interior_direction, interior_direction == SOUTH || interior_direction == EAST ? -90 : 90))
		if(CHAMBER_BIGGER) //We need a central column of manifolds and a vent either side of each manifold
			var/depth = north_or_south_interior ? tiles_in_y_direction : tiles_in_x_direction
			var/turf/put_thing_here = below_T
			for(var/i in 1 to depth)
				if(i != depth)//We're placing more pipe later, so we need a 4-way manifold
					pipe_creation_helper(/obj/machinery/atmospherics/pipe/manifold4w/visible, put_thing_here, interior_direction, NORTH | EAST | SOUTH | WEST)
				else //We stop here, so place a T-manifold down
					pipe_creation_helper(/obj/machinery/atmospherics/pipe/manifold/visible,
						put_thing_here,
						opposite_interior_direction,
						interior_direction_cw | interior_direction | interior_direction_ccw)
				pipe_creation_helper(/obj/machinery/atmospherics/unary/vent_pump/high_volume,
					get_step(put_thing_here, interior_direction_cw),
					interior_direction_ccw)
				pipe_creation_helper(/obj/machinery/atmospherics/unary/vent_pump/high_volume,
					get_step(put_thing_here, interior_direction_ccw),
					interior_direction_cw)
				put_thing_here = get_step(put_thing_here, opposite_interior_direction) //Now move the turf we're generating stuff from 1 forward

/obj/effect/spawner/airlock/proc/pipe_creation_helper(path, location, direction, initialization_directions) //Create some kind of atmospherics machinery and initialize it properly
	var/obj/machinery/atmospherics/A = new path(location)
	A.dir = direction
	A.on_construction(A.dir, initialization_directions ? initialization_directions : A.dir)
	if(istype(A, /obj/machinery/atmospherics/unary/vent_pump/high_volume))
		var/obj/machinery/atmospherics/unary/vent_pump/high_volume/created_pump = A
		created_pump.id_tag = AIRPUMP_TAG
		created_pump.set_frequency(radio_frequency)


//Premade airlocks for mappers, probably won't need all of these but whatever
/obj/effect/spawner/airlock/s_to_n
	name = "1 by 1 airlock spawner (interior south, exterior north)"
	icon_state = "1x1_S_to_N"
	interior_direction = SOUTH
	exterior_direction = NORTH
/obj/effect/spawner/airlock/e_to_w
	name = "1 by 1 airlock spawner (interior east, exterior west)"
	icon_state = "1x1_E_to_W"
	interior_direction = EAST
	exterior_direction = WEST
/obj/effect/spawner/airlock/w_to_e
	name = "1 by 1 airlock spawner (interior west, exterior east)"
	icon_state = "1x1_W_to_E"
	interior_direction = WEST
	exterior_direction = EAST

/obj/effect/spawner/airlock/long //Long and thin
	name = "long airlock spawner (interior north, exterior south)"
	icon_state = "1x2_N_to_S"
	tiles_in_y_direction = 2
/obj/effect/spawner/airlock/s_to_n/long
	name = "long airlock spawner (interior south, exterior north)"
	icon_state = "1x2_S_to_N"
	tiles_in_y_direction = 2
/obj/effect/spawner/airlock/e_to_w/long
	name = "long airlock spawner (interior east, exterior west)"
	icon_state = "1x2_E_to_W"
	tiles_in_x_direction = 2
/obj/effect/spawner/airlock/w_to_e/long
	name = "long airlock spawner (interior west, exterior east)"
	icon_state = "1x2_W_to_E"
	tiles_in_x_direction = 2

/obj/effect/spawner/airlock/long/square //Square
	name = "square airlock spawner (interior north, exterior south)"
	icon_state = "2x2_N_to_S"
	tiles_in_x_direction = 2
/obj/effect/spawner/airlock/s_to_n/long/square
	name = "square airlock spawner (interior south, exterior north)"
	icon_state = "2x2_S_to_N"
	tiles_in_x_direction = 2
/obj/effect/spawner/airlock/e_to_w/long/square
	name = "square airlock spawner (interior east, exterior west)"
	icon_state = "2x2_E_to_W"
	tiles_in_y_direction = 2
/obj/effect/spawner/airlock/w_to_e/long/square
	name = "square airlock spawner (interior west, exterior east)"
	icon_state = "2x2_W_to_E"
	tiles_in_y_direction = 2
/obj/effect/spawner/airlock/long/square/e_to_s
	name = "square airlock spawner (interior east, exterior south)"
	icon_state = "2x2_E_to_S"
	interior_direction = EAST
	exterior_direction = SOUTH

/obj/effect/spawner/airlock/long/square/wide
	name = "rectangular airlock spawner (interior north, exterior south)"
	icon_state = "3x2_N_to_S"
	tiles_in_x_direction = 3
/obj/effect/spawner/airlock/s_to_n/long/square/wide
	name = "rectangular airlock spawner (interior south, exterior north)"
	icon_state = "3x2_S_to_N"
	tiles_in_x_direction = 3
/obj/effect/spawner/airlock/e_to_w/long/square/wide
	name = "rectangular airlock spawner (interior east, exterior west)"
	icon_state = "3x2_E_to_W"
	tiles_in_y_direction = 3
/obj/effect/spawner/airlock/w_to_e/long/square/wide
	name = "rectangular airlock spawner (interior west, exterior east)"
	icon_state = "3x2_W_to_E"
	tiles_in_y_direction = 3

/obj/effect/spawner/airlock/long/square/three
	name = "3 by 3 square airlock spawner (interior north, exterior south)"
	icon_state = "3x3_N_to_S"
	interior_direction = NORTH
	exterior_direction = SOUTH
	tiles_in_x_direction = 3
	tiles_in_y_direction = 3

/obj/effect/spawner/airlock/e_to_w/arrivals
	required_access = null

/obj/effect/spawner/airlock/engineer
	required_access = list(ACCESS_ENGINE)
	door_name = "engineering external access"
/obj/effect/spawner/airlock/e_to_w/engineer
	required_access = list(ACCESS_ENGINE)
	door_name = "engineering external access"
/obj/effect/spawner/airlock/s_to_n/engineer
	required_access = list(ACCESS_ENGINE)
	door_name = "engineering external access"
/obj/effect/spawner/airlock/long/engineer
	required_access = list(ACCESS_ENGINE)
	door_name = "engineering external access"
/obj/effect/spawner/airlock/long/square/engine
	required_access = list(ACCESS_ENGINE)
	door_name = "engine external access"
	icon_state = "2x2_N_to_S_leftdoors"
	door_type = /obj/machinery/door/airlock/external
	one_door_interior = DOOR_NORMAL_PLACEMENT
	one_door_exterior = DOOR_NORMAL_PLACEMENT
/obj/effect/spawner/airlock/long/square/engine/reversed
	icon_state = "2x2_N_to_S_rightdoors"
	one_door_interior = DOOR_FLIPPED_PLACEMENT
	one_door_exterior = DOOR_FLIPPED_PLACEMENT

/obj/effect/spawner/airlock/w_to_e/long/square/wide/mining
	door_name = "mining external access"
	required_access = list(ACCESS_MINING)
/obj/effect/spawner/airlock/long/square/wide/mining
	door_name = "mining external access"
	required_access = list(ACCESS_MINING)

/obj/effect/spawner/airlock/e_to_w/minisat
	door_name = "minisat external access"
	required_access = list(ACCESS_MINISAT)
/obj/effect/spawner/airlock/long/square/e_to_s/telecoms
	door_name = "telecoms external access"
	required_access = list(ACCESS_TCOMSAT, ACCESS_EXTERNAL_AIRLOCKS)
	door_type = /obj/machinery/door/airlock/external

/obj/effect/spawner/airlock/long/square/three/syndicate
	name = "3 by 3 square airlock spawner (interior west, exterior north)"
	icon_state = "3x3_W_to_N"
	interior_direction = WEST
	exterior_direction = NORTH
	door_name = "ship external access"
	req_access = list(ACCESS_SYNDICATE)
	door_type = /obj/machinery/door/airlock/external

#undef HALF_X
#undef HALF_Y
#undef CHAMBER_LONG
#undef CHAMBER_SQUARE
#undef CHAMBER_BIGGER
#undef DOOR_NORMAL_PLACEMENT
#undef DOOR_FLIPPED_PLACEMENT
#undef AIRPUMP_TAG
#undef SENSOR_TAG
#undef OUTER_DOOR_TAG
#undef INNER_DOOR_TAG

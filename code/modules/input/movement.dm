#define NORTH_SOUTH (NORTH | SOUTH)
#define EAST_WEST (EAST | WEST)

/atom/movable/key_loop(client/C)
	var/datum/input_data/ID = C.input_data
	if(!ID)
		return

	var/direction = (ID.desired_move_dir | ID.desired_move_dir_add) & ~ID.desired_move_dir_sub

	// Pressing two opposite directions will cancel both out
	if((direction & NORTH_SOUTH) >= NORTH_SOUTH)
		direction &= ~NORTH_SOUTH
	if((direction & EAST_WEST) >= EAST_WEST)
		direction &= ~EAST_WEST

	C.Move(get_step(src, direction), direction)

#undef NORTH_SOUTH
#undef EAST_WEST

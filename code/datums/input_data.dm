#define NORTH_SOUTH (NORTH | SOUTH)
#define EAST_WEST (EAST | WEST)

/datum/input_data
	/// Associative list of currently held keys.
	var/list/keys_held = list()
	/// Associative list of currently held key combos.
	var/list/key_combos_held = list()

	/// Bitflags of the direction the client wishes to move. Updated instantaneously.
	var/desired_move_dir = NONE
	/// Bitflags of the buffered direction the client wishes to move. Reset on client/Move().
	var/desired_move_dir_add = NONE
	/// Bitflags of the buffered direction the client wishes not to move. Reset on client/Move().
	var/desired_move_dir_sub = NONE

	// Key send spam guard.
	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE

/datum/input_data/proc/compute_actual_move_dir()
	. = (desired_move_dir | desired_move_dir_add) & ~desired_move_dir_sub
	// Pressing two opposite directions will cancel both out
	if((. & NORTH_SOUTH) >= NORTH_SOUTH)
		. &= ~NORTH_SOUTH
	if((. & EAST_WEST) >= EAST_WEST)
		. &= ~EAST_WEST

/datum/input_data/proc/reset_buffers()
	desired_move_dir_add = NONE
	desired_move_dir_sub = NONE

#undef NORTH_SOUTH
#undef EAST_WEST

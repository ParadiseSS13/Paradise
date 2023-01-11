/datum/input_data
	/// Associative list of currently held keys. Format: keys_held[key], associated value is world.time where key was pressed.
	var/list/keys_held = list()
	/// Associative list of currently held key combos.
	var/list/key_combos_held = list()

	/// Bitflags of the direction the client wishes to move. Updated instantaneously.
	var/desired_move_dir = NONE
	/// Bitflags of the buffered direction the client wishes to move. Reset on client/Move().
	var/desired_move_dir_add = NONE
	/// Bitflags of the buffered direction the client wishes not to move. Reset on client/Move().
	var/desired_move_dir_sub = NONE
	/// Whether the movement should be locked in place.
	var/move_lock = FALSE

	// Key send spam guard.
	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE

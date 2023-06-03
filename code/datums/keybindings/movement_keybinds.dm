/datum/keybinding/movement
	category = KB_CATEGORY_MOVEMENT
	/// The direction to move to when held.
	var/move_dir

/datum/keybinding/movement/north
	name = "Move North"
	keys = list("W", "North")
	move_dir = NORTH

/datum/keybinding/movement/south
	name = "Move South"
	keys = list("S", "South")
	move_dir = SOUTH

/datum/keybinding/movement/east
	name = "Move East"
	keys = list("D", "East")
	move_dir = EAST

/datum/keybinding/movement/west
	name = "Move West"
	keys = list("A", "West")
	move_dir = WEST

/datum/keybinding/lock
	name = "Movement Lock (Prevents Moving When Held)"
	category = KB_CATEGORY_MOVEMENT
	keys = list("Ctrl")

/datum/keybinding/lock/down(client/C)
	. = ..()
	C.input_data.move_lock = TRUE
	movement_restore(C)

/datum/keybinding/lock/up(client/C)
	. = ..()
	C.input_data.move_lock = FALSE
	movement_restore(C)

/datum/keybinding/lock/proc/movement_restore(client/C)
	var/datum/input_data/ID = C.input_data
	for(var/_key in C.input_data.keys_held)
		var/move_dir = C.movement_kb_dirs[_key]
		if(move_dir && ID.move_lock)
			ID.desired_move_dir &= ~move_dir
			if(!(ID.desired_move_dir_add & move_dir))
				ID.desired_move_dir_sub |= move_dir
		else if(move_dir)
			SSinput.processing[C] = world.time
			ID.desired_move_dir |= move_dir
			if(!(ID.desired_move_dir_sub & move_dir))
				ID.desired_move_dir_add |= move_dir

/datum/keybinding/movement
	category = KB_CATEGORY_MOVEMENT
	key_loop = TRUE
	/// The direction to move to when held.
	var/move_dir

/datum/keybinding/movement/down(client/C)
	. = ..()
	var/datum/input_data/ID = C.input_data
	if(!ID)
		return
	ID.desired_move_dir |= move_dir
	if(!(ID.desired_move_dir_sub & move_dir))
		ID.desired_move_dir_add |= move_dir

/datum/keybinding/movement/up(client/C)
	. = ..()
	var/datum/input_data/ID = C.input_data
	if(!ID)
		return
	ID.desired_move_dir &= ~move_dir
	if(!(ID.desired_move_dir_add & move_dir))
		ID.desired_move_dir_sub |= move_dir

/datum/keybinding/movement/should_start_looping(client/C)
	return C.input_data?.desired_move_dir_add == NONE

/datum/keybinding/movement/should_stop_looping(client/C)
	return FALSE // Handled in SSinput itself

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

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
	name = "Movement Lock"
	category = KB_CATEGORY_MOVEMENT
	keys = list("Ctrl")

/datum/keybinding/lock/down(client/C)
	. = ..()
	C.input_data.move_lock = TRUE

/datum/keybinding/lock/up(client/C)
	. = ..()
	C.input_data.move_lock = FALSE

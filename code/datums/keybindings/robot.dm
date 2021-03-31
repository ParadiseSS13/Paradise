/datum/keybinding/robot
	category = KB_CATEGORY_ROBOT

/datum/keybinding/robot/can_use(client/C, mob/M)
	return isrobot(M) && ..()

/datum/keybinding/robot/module
	/// The module number.
	var/num

/datum/keybinding/robot/module/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.toggle_module(num)

/datum/keybinding/robot/module/slot_1
	name = "Module 1"
	num = 1
	keys = list("1")

/datum/keybinding/robot/module/slot_2
	name = "Module 2"
	num = 2
	keys = list("2")

/datum/keybinding/robot/module/slot_3
	name = "Module 3"
	num = 3
	keys = list("3")

/datum/keybinding/robot/cycle_modules
	name = "Cycle Modules"
	keys = list("X")

/datum/keybinding/robot/cycle_modules/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.cycle_modules()

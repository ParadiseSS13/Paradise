/datum/keybinding/robot
	category = KB_CATEGORY_ROBOT

/datum/keybinding/robot/can_use(client/C, mob/M)
	return isrobot(M) && ..()

/datum/keybinding/robot/module
	/// The module number.
	var/module_number

/datum/keybinding/robot/module/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.toggle_module(module_number)

/datum/keybinding/robot/module/slot_1
	name = "Ячейка 1"
	module_number = 1
	keys = list("1")

/datum/keybinding/robot/module/slot_2
	name = "Ячейка 2"
	module_number = 2
	keys = list("2")

/datum/keybinding/robot/module/slot_3
	name = "Ячейка 3"
	module_number = 3
	keys = list("3")

/datum/keybinding/robot/switch_intent
	name = "Смена Intents"
	keys = list("4")

/datum/keybinding/robot/switch_intent/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)

/datum/keybinding/robot/cycle_modules
	name = "Смена ячеек"
	keys = list("X")

/datum/keybinding/robot/cycle_modules/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.cycle_modules()

/datum/keybinding/robot/drop_held_object
	name = "Деактивировать ячейку"
	keys = list("Q", "Northwest")

/datum/keybinding/robot/drop_held_object/down(client/C)
	. = ..()
	var/mob/living/silicon/robot/M = C.mob
	M.on_drop_hotkey_press()

/datum/keybinding/clickbind
	category = KB_CATEGORY_CLICK

/datum/keybinding/clickbind/can_use(client/C, mob/M)
	return istype(M) && M.can_use_clickbinds() && ..()

/datum/keybinding/clickbind/down(client/C)
	..()
	if(C.mob.next_click > world.time)
		return
	C.mob.changeNext_click(1)
	return locateUID(C.moused_over)

/datum/keybinding/clickbind/alt_click
	name = "Alt-Click"

/datum/keybinding/clickbind/alt_click/down(client/C)
	. = ..()
	if(.)
		C.mob.AltClickOn(.)

/datum/keybinding/clickbind/ctrl_click
	name = "Ctrl-Click"

/datum/keybinding/clickbind/ctrl_click/down(client/C)
	. = ..()
	if(.)
		C.mob.CtrlClickOn(.)

/datum/keybinding/clickbind/shift_click
	name = "Shift-Click"

/datum/keybinding/clickbind/shift_click/down(client/C)
	. = ..()
	if(.)
		C.mob.ShiftClickOn(.)

/datum/keybinding/clickbind/middle_click
	name = "Middle-Click"

/datum/keybinding/clickbind/middle_click/down(client/C)
	. = ..()
	if(.)
		C.mob.MiddleClickOn(.)

/datum/keybinding/clickbind/alt_shift_click
	name = "Alt-Shift-Click"

/datum/keybinding/clickbind/alt_shift_click/down(client/C)
	. = ..()
	if(.)
		C.mob.AltShiftClickOn(.)

/datum/keybinding/clickbind/ctrl_shift_click
	name = "Ctrl-Shift-Click"

/datum/keybinding/clickbind/ctrl_shift_click/down(client/C)
	. = ..()
	if(.)
		C.mob.CtrlShiftClickOn(.)

/datum/keybinding/clickbind/middle_shift_click
	name = "Middle-Shift-Click"

/datum/keybinding/clickbind/middle_shift_click/down(client/C)
	. = ..()
	if(.)
		C.mob.MiddleShiftClickOn(.)

/datum/keybinding/clickbind/middle_shift_ctrl_click
	name = "Middle-Shift-Ctrl-Click"

/datum/keybinding/clickbind/middle_shift_ctrl_click/down(client/C)
	. = ..()
	if(.)
		C.mob.MiddleShiftControlClickOn(.)


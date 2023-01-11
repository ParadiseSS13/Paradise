/datum/keybinding/silicon
	category = KB_CATEGORY_SILICON

/datum/keybinding/silicon/can_use(client/C, mob/M)
	return issilicon(M) && ..()

/datum/keybinding/silicon/switch_intent
	name = "Смена Intents"
	keys = list("4")

/datum/keybinding/silicon/switch_intent/down(client/C)
	. = ..()
	var/mob/living/silicon/M = C.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)

/datum/keybinding/silicon/ai/can_use(client/C, mob/M)
	return isAI(M) && ..()

/datum/keybinding/silicon/ai/next_camera
	name = "Следующая камера (ИИ)"
	keys = list("N")

/datum/keybinding/silicon/ai/next_camera/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.check_for_binded_cameras(C))
		M.current_camera_next(C)
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/prev_camera
	name = "Предыдущая камера (ИИ)"
	keys = list("B")

/datum/keybinding/silicon/ai/prev_camera/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.check_for_binded_cameras(C))
		M.current_camera_back(C)
		M.update_binded_camera(C)

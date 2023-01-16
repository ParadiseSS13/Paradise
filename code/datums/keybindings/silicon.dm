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

/datum/keybinding/silicon/ai/set_cameras_by_index_1
	name = "Выбрать камеру по номеру 1 (ИИ)"
	keys = list("Shift1")

/datum/keybinding/silicon/ai/set_cameras_by_index_1/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 1))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_2
	name = "Выбрать камеру по номеру 2 (ИИ)"
	keys = list("Shift2")

/datum/keybinding/silicon/ai/set_cameras_by_index_2/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 2))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_3
	name = "Выбрать камеру по номеру 3 (ИИ)"
	keys = list("Shift3")

/datum/keybinding/silicon/ai/set_cameras_by_index_3/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 3))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_4
	name = "Выбрать камеру по номеру 4 (ИИ)"
	keys = list("Shift4")

/datum/keybinding/silicon/ai/set_cameras_by_index_4/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 4))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_5
	name = "Выбрать камеру по номеру 5 (ИИ)"
	keys = list("Shift5")

/datum/keybinding/silicon/ai/set_cameras_by_index_5/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 5))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_6
	name = "Выбрать камеру по номеру 6 (ИИ)"
	keys = list("Shift6")

/datum/keybinding/silicon/ai/set_cameras_by_index_6/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 6))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_7
	name = "Выбрать камеру по номеру 7 (ИИ)"
	keys = list("Shift7")

/datum/keybinding/silicon/ai/set_cameras_by_index_7/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 7))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_8
	name = "Выбрать камеру по номеру 8 (ИИ)"
	keys = list("Shift8")

/datum/keybinding/silicon/ai/set_cameras_by_index_8/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 8))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_9
	name = "Выбрать камеру по номеру 9 (ИИ)"
	keys = list("Shift9")

/datum/keybinding/silicon/ai/set_cameras_by_index_9/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 9))
		M.update_binded_camera(C)

/datum/keybinding/silicon/ai/set_cameras_by_index_10
	name = "Выбрать камеру по номеру 10 (ИИ)"
	keys = list("Shift0")

/datum/keybinding/silicon/ai/set_cameras_by_index_10/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	if(M.set_camera_by_index(C, 0))
		M.update_binded_camera(C)

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

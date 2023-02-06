/datum/keybinding/mob
	category = KB_CATEGORY_MOB

// Hands
/datum/keybinding/mob/use_held_object
	name = "Использовать вещь в руке"
	keys = list("Y", "Z", "Southeast")

/datum/keybinding/mob/use_held_object/down(client/C)
	. = ..()
	C.mob.mode()

/datum/keybinding/mob/equip_held_object
	name = "Экипировать вещь"
	keys = list("E")

/datum/keybinding/mob/equip_held_object/down(client/C)
	. = ..()
	C.mob.quick_equip()

/datum/keybinding/mob/drop_held_object
	name = "Выложить вещь в руке"
	keys = list("Q", "Northwest")

/datum/keybinding/mob/drop_held_object/can_use(client/C, mob/M)
	return !isrobot(M) && ..()   //robots on 'q' have their own proc for drop, in keybindinds/robot.dm

/datum/keybinding/mob/drop_held_object/down(client/C)
	. = ..()
	var/obj/item/I = C.mob.get_active_hand()
	if(I)
		C.mob.drop_item(I)
		SEND_SIGNAL(C.mob, COMSIG_MOB_DROP_ITEM, keys, C)
	else
		to_chat(C, "<span class='warning'>You have nothing to drop in your hand!</span>")

/datum/keybinding/mob/swap_hands
	name = "Поменять руки"
	keys = list("X", "Northeast")

/datum/keybinding/mob/swap_hands/down(client/C)
	. = ..()
	C.mob.swap_hand()

// Intents
/datum/keybinding/mob/prev_intent
	name = "Предыдущий Intent"
	keys = list("F")

/datum/keybinding/mob/prev_intent/down(client/C)
	. = ..()
	C.mob.a_intent_change(INTENT_HOTKEY_LEFT)

/datum/keybinding/mob/next_intent
	name = "Следующий Intent"
	keys = list("G", "Insert")

/datum/keybinding/mob/next_intent/down(client/C)
	. = ..()
	C.mob.a_intent_change(INTENT_HOTKEY_RIGHT)

/datum/keybinding/mob/walk_hold
	name = "Идти (Зажать)"
	keys = list("Alt")

/datum/keybinding/mob/walk_hold/down(client/C)
	. = ..()
	C.mob.toggle_move_intent()

/datum/keybinding/mob/walk_hold/up(client/C)
	. = ..()
	C.mob.toggle_move_intent()

/datum/keybinding/mob/walk_toggle
	name = "Идти (Переключить)"

/datum/keybinding/mob/walk_toggle/down(client/C)
	. = ..()
	C.mob.toggle_move_intent()

// Other
/datum/keybinding/mob/stop_pulling
	name = "Перестать тащить"
	keys = list("C")

/datum/keybinding/mob/stop_pulling/down(client/C)
	. = ..()
	if(C.mob.pulling)
		C.mob.stop_pulling()
	else
		to_chat(C, "<span class='notice'>You are not pulling anything.</span>")

/datum/keybinding/mob/face_dir
	/// The direction to face towards.
	var/dir

/datum/keybinding/mob/face_dir/down(client/C)
	. = ..()
	C.mob.facedir(dir)

/datum/keybinding/mob/face_dir/north
	name = "Смотреть наверх"
	keys = list("CtrlW", "CtrlNorth")
	dir = NORTH

/datum/keybinding/mob/face_dir/south
	name = "Смотреть вниз"
	keys = list("CtrlS", "CtrlSouth")
	dir = SOUTH

/datum/keybinding/mob/face_dir/east
	name = "Смотреть вправо"
	keys = list("CtrlD", "CtrlEast")
	dir = EAST

/datum/keybinding/mob/face_dir/west
	name = "Смотреть влево"
	keys = list("CtrlA", "CtrlWest")
	dir = WEST

/datum/keybinding/mob/target_cycle/head
	name = "Выбрать голову/глаза/рот"
	keys = list("Numpad8")

/datum/keybinding/mob/target_cycle/head/down(client/C)
	. = ..()
	C.body_toggle_head()

/datum/keybinding/mob/target_cycle/r_arm
	name = "Выбрать правую руку/кисть"
	keys = list("Numpad4")

/datum/keybinding/mob/target_cycle/r_arm/down(client/C)
	. = ..()
	C.body_r_arm()

/datum/keybinding/mob/target_cycle/l_arm
	name = "Выбрать левую руку/кисть"
	keys = list("Numpad6")

/datum/keybinding/mob/target_cycle/l_arm/down(client/C)
	. = ..()
	C.body_l_arm()

/datum/keybinding/mob/target_cycle/r_leg
	name = "Выбрать правую ногу/ступню"
	keys = list("Numpad1")

/datum/keybinding/mob/target_cycle/r_leg/down(client/C)
	. = ..()
	C.body_r_leg()

/datum/keybinding/mob/target_cycle/l_leg
	name = "Выбрать левую ногу/ступню"
	keys = list("Numpad3")

/datum/keybinding/mob/target_cycle/l_leg/down(client/C)
	. = ..()
	C.body_l_leg()

/datum/keybinding/mob/target
	// The body part to target.
	var/body_part

/datum/keybinding/mob/target/down(client/C)
	. = ..()

	if(!C.check_has_body_select())
		return

	var/obj/screen/zone_sel/selector = C.mob.hud_used.zone_select
	selector.set_selected_zone(body_part, C.mob)

/datum/keybinding/mob/target/head
	name = "Выбрать голову"
	body_part = BODY_ZONE_HEAD

/datum/keybinding/mob/target/eyes
	name = "Выбрать глаза"
	body_part = BODY_ZONE_PRECISE_EYES

/datum/keybinding/mob/target/mouth
	name = "Выбрать рот"
	body_part = BODY_ZONE_PRECISE_MOUTH

/datum/keybinding/mob/target/chest
	name = "Выбрать грудь"
	body_part = BODY_ZONE_CHEST
	keys = list("Numpad5")

/datum/keybinding/mob/target/groin
	name = "Выбрать пах"
	body_part = BODY_ZONE_PRECISE_GROIN
	keys = list("Numpad2")

/datum/keybinding/mob/target/r_arm
	name = "Выбрать правую руку"
	body_part = BODY_ZONE_R_ARM

/datum/keybinding/mob/target/r_hand
	name = "Выбрать правую кисть"
	body_part = BODY_ZONE_PRECISE_R_HAND

/datum/keybinding/mob/target/l_arm
	name = "Выбрать левую руку"
	body_part = BODY_ZONE_L_ARM

/datum/keybinding/mob/target/l_hand
	name = "Выбрать левую кисть"
	body_part = BODY_ZONE_PRECISE_L_HAND

/datum/keybinding/mob/target/r_leg
	name = "Выбрать правую ногу"
	body_part = BODY_ZONE_R_LEG

/datum/keybinding/mob/target/r_foot
	name = "Выбрать правую ступню"
	body_part = BODY_ZONE_PRECISE_R_FOOT

/datum/keybinding/mob/target/l_leg
	name = "Выбрать левую ногу"
	body_part = BODY_ZONE_L_LEG

/datum/keybinding/mob/target/l_foot
	name = "Выбрать левую ступню"
	body_part = BODY_ZONE_PRECISE_L_FOOT

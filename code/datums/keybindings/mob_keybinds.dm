/datum/keybinding/mob
	category = KB_CATEGORY_MOB

// Hands
/datum/keybinding/mob/use_held_object
	name = "Use Held Object"
	keys = list("Y", "Z", "Southeast")

/datum/keybinding/mob/use_held_object/down(client/C)
	. = ..()
	C.mob.mode()

/datum/keybinding/mob/equip_held_object
	name = "Equip Held Object"
	keys = list("E")

/datum/keybinding/mob/equip_held_object/down(client/C)
	. = ..()
	C.mob.quick_equip()

/datum/keybinding/mob/drop_held_object
	name = "Drop Held Object"
	keys = list("Q", "Northwest")

/datum/keybinding/mob/drop_held_object/down(client/C)
	. = ..()
	var/obj/item/I = C.mob.get_active_hand()
	if(!I)
		I = C.mob.special_get_hands_check()

	if(I)
		C.mob.drop_item_v()
		return

	to_chat(C, "<span class='warning'>You have nothing to drop in your hand!</span>")

/datum/keybinding/mob/swap_hands
	name = "Swap Hands"
	keys = list("X", "Northeast")

/datum/keybinding/mob/swap_hands/down(client/C)
	. = ..()
	C.mob.swap_hand()

/datum/keybinding/mob/hand_right
	name = "Swap to/Activate Right Hand"

/datum/keybinding/mob/hand_right/down(client/C)
	. = ..()
	if(!C.mob.activate_hand(HAND_BOOL_RIGHT))
		C.mob.mode()

/datum/keybinding/mob/hand_left
	name = "Swap to/Activate Left Hand"

/datum/keybinding/mob/hand_left/down(client/C)
	. = ..()
	if(!C.mob.activate_hand(HAND_BOOL_LEFT))
		C.mob.mode()

// Intents
/datum/keybinding/mob/prev_intent
	name = "Previous Intent"
	keys = null

/datum/keybinding/mob/prev_intent/down(client/C)
	. = ..()
	C.mob.a_intent_change(INTENT_HOTKEY_LEFT)

/datum/keybinding/mob/next_intent
	name = "Next Intent"
	keys = list("Insert")

/datum/keybinding/mob/next_intent/down(client/C)
	. = ..()
	C.mob.a_intent_change(INTENT_HOTKEY_RIGHT)

/datum/keybinding/mob/walk_hold
	name = "Walk (Hold)"
	keys = list("C")

/datum/keybinding/mob/walk_hold/down(client/C)
	. = ..()
	C.mob.toggle_move_intent()

/datum/keybinding/mob/walk_hold/up(client/C)
	. = ..()
	C.mob.toggle_move_intent()

/datum/keybinding/mob/walk_toggle
	name = "Walk (Toggle)"

/datum/keybinding/mob/walk_toggle/down(client/C)
	. = ..()
	C.mob.toggle_move_intent()

// Other
/datum/keybinding/mob/stop_pulling
	name = "Stop Pulling"
	keys = list("Delete")

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
	name = "Face North"
	keys = list("CtrlW", "CtrlNorth")
	dir = NORTH

/datum/keybinding/mob/face_dir/south
	name = "Face South"
	keys = list("CtrlS", "CtrlSouth")
	dir = SOUTH

/datum/keybinding/mob/face_dir/east
	name = "Face East"
	keys = list("CtrlD", "CtrlEast")
	dir = EAST

/datum/keybinding/mob/face_dir/west
	name = "Face West"
	keys = list("CtrlA", "CtrlWest")
	dir = WEST

/datum/keybinding/mob/target_cycle/head
	name = "Target Head/Eyes/Mouth"
	keys = list("Numpad8")

/datum/keybinding/mob/target_cycle/head/down(client/C)
	. = ..()
	C.body_toggle_head()

/datum/keybinding/mob/target_cycle/r_arm
	name = "Target Right Arm/Hand"
	keys = list("Numpad4")

/datum/keybinding/mob/target_cycle/r_arm/down(client/C)
	. = ..()
	C.body_r_arm()

/datum/keybinding/mob/target_cycle/l_arm
	name = "Target Left Arm/Hand"
	keys = list("Numpad6")

/datum/keybinding/mob/target_cycle/l_arm/down(client/C)
	. = ..()
	C.body_l_arm()

/datum/keybinding/mob/target_cycle/r_leg
	name = "Target Right Leg/Foot"
	keys = list("Numpad1")

/datum/keybinding/mob/target_cycle/r_leg/down(client/C)
	. = ..()
	C.body_r_leg()

/datum/keybinding/mob/target_cycle/l_leg
	name = "Target Left Leg/Foot"
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

	var/atom/movable/screen/zone_sel/selector = C.mob.hud_used.zone_select
	selector.set_selected_zone(body_part, C.mob)

/datum/keybinding/mob/target/head
	name = "Target Head"
	body_part = BODY_ZONE_HEAD

/datum/keybinding/mob/target/eyes
	name = "Target Eyes"
	body_part = BODY_ZONE_PRECISE_EYES

/datum/keybinding/mob/target/mouth
	name = "Target Mouth"
	body_part = BODY_ZONE_PRECISE_MOUTH

/datum/keybinding/mob/target/chest
	name = "Target Upper Body"
	body_part = BODY_ZONE_CHEST
	keys = list("Numpad5")

/datum/keybinding/mob/target/groin
	name = "Target Lower Body"
	body_part = BODY_ZONE_PRECISE_GROIN
	keys = list("Numpad2")

/datum/keybinding/mob/target/r_arm
	name = "Target Right Arm"
	body_part = BODY_ZONE_R_ARM

/datum/keybinding/mob/target/r_hand
	name = "Target Right Hand"
	body_part = BODY_ZONE_PRECISE_R_HAND

/datum/keybinding/mob/target/l_arm
	name = "Target Left Arm"
	body_part = BODY_ZONE_L_ARM

/datum/keybinding/mob/target/l_hand
	name = "Target Left Hand"
	body_part = BODY_ZONE_PRECISE_L_HAND

/datum/keybinding/mob/target/r_leg
	name = "Target Right Leg"
	body_part = BODY_ZONE_R_LEG

/datum/keybinding/mob/target/r_foot
	name = "Target Right Foot"
	body_part = BODY_ZONE_PRECISE_R_FOOT

/datum/keybinding/mob/target/l_leg
	name = "Target Left Leg"
	body_part = BODY_ZONE_L_LEG

/datum/keybinding/mob/target/l_foot
	name = "Target Left Foot"
	body_part = BODY_ZONE_PRECISE_L_FOOT

/// Don't add a name to this, shouldn't show up in the prefs menu
/datum/keybinding/mob/trigger_action_button
	var/datum/action/linked_action
	var/binded_to // these are expected to actually get deleted at some point, to prevent hard deletes we need to know where to remove them from the clients list

/datum/keybinding/mob/trigger_action_button/down(client/C)
	. = ..()
	if(C.mob.next_click > world.time)
		return
	linked_action.Trigger()

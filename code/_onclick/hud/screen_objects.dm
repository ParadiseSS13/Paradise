/*
	Screen "objects"
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are not actually objects, which is counterintuitive to their name.
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	flags = NO_SCREENTIPS
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null
	appearance_flags = NO_CLIENT_COLOR
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE

/atom/movable/screen/Destroy()
	master = null
	hud = null
	return ..()

/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/close/Click()
	if(master)
		if(isstorage(master))
			var/obj/item/storage/S = master
			S.close(usr)
	return 1

/atom/movable/screen/drop
	name = "drop"
	icon_state = "act_drop"

/atom/movable/screen/drop/Click()
	usr.drop_item_v()

/atom/movable/screen/grab
	name = "grab"

/atom/movable/screen/grab/Click()
	var/obj/item/grab/G = master
	G.s_click(src)
	return 1

/atom/movable/screen/grab/attack_hand()
	return

/atom/movable/screen/grab/attackby__legacy__attackchain()
	return
/atom/movable/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = UI_ACTI

/atom/movable/screen/act_intent/Click(location, control, params)
	if(ishuman(usr))
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])
		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)
		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)
		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)
		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		usr.a_intent_change("right")

/atom/movable/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'

/atom/movable/screen/act_intent/robot
	icon = 'icons/mob/screen_robot.dmi'

/atom/movable/screen/act_intent/robot/ai
	screen_loc = "SOUTH+1:6,EAST-1:32"

/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon_state = "running"

/atom/movable/screen/act_intent/simple_animal
	icon = 'icons/mob/screen_simplemob.dmi'

/atom/movable/screen/act_intent/guardian
	icon = 'icons/mob/guardian.dmi'

/atom/movable/screen/mov_intent/Click()
	usr.toggle_move_intent()

/atom/movable/screen/pull
	name = "stop pulling"
	icon_state = "pull"

/atom/movable/screen/pull/Click()
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/atom/movable/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"

/atom/movable/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/atom/movable/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/storage
	name = "storage"

/atom/movable/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated(ignore_restraints = TRUE))
		return TRUE
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby__legacy__attackchain(I, usr, params)
	return TRUE

/atom/movable/screen/storage/proc/is_item_accessible(obj/item/I, mob/user)
	if(!user || !I)
		return FALSE

	var/storage_depth = I.storage_depth(user)
	if((I in user.loc) || (storage_depth != -1))
		return TRUE

	if(!isturf(user.loc))
		return FALSE

	var/storage_depth_turf = I.storage_depth_turf()
	if(isturf(I.loc) || (storage_depth_turf != -1))
		if(I.Adjacent(user))
			return TRUE
	return FALSE

/atom/movable/screen/storage/MouseDrop_T(obj/item/I, mob/user)
	if(!user || !istype(I) || user.incapacitated(ignore_restraints = TRUE) || ismecha(user.loc) || !master)
		return

	var/obj/item/storage/S = master
	if(!S)
		return

	if(!is_item_accessible(I, user))
		log_game("[user.simple_info_line()] tried to abuse storage remote drag&drop with '[I]' at [atom_loc_line(I)] into '[S]' at [atom_loc_line(S)]")
		message_admins("[user.simple_info_line()] tried to abuse storage remote drag&drop with '[I]' at [atom_loc_line(I)] into '[S]' at [atom_loc_line(S)]")
		return

	if(I in S.contents) // If the item is already in the storage, move them to the end of the list
		if(S.contents[length(S.contents)] == I) // No point moving them at the end if they're already there!
			return

		var/list/new_contents = S.contents.Copy()
		if(S.display_contents_with_number)
			// Basically move all occurences of I to the end of the list.
			var/list/obj/item/to_append = list()
			for(var/obj/item/stored_item in S.contents)
				if(S.can_items_stack(stored_item, I))
					new_contents -= stored_item
					to_append += stored_item

			new_contents.Add(to_append)
		else
			new_contents -= I
			new_contents += I // oof
		S.contents = new_contents

		if(user.s_active == S)
			S.orient2hud(user)
			S.show_to(user)
	else // If it's not in the storage, try putting it inside
		S.attackby__legacy__attackchain(I, user)
	return TRUE

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = UI_ZONESEL
	var/overlay_file = 'icons/mob/zone_sel.dmi'
	var/selecting = "chest"
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return 1

	return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	cut_overlay(hover_overlays_cache[hovering])
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	add_overlay(overlay_object)


/obj/effect/overlay/zone_sel
	icon = 'icons/mob/zone_sel.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		cut_overlay(hover_overlays_cache[hovering])
	hovering = null
	return ..()

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					return "r_foot"
				if(17 to 22)
					return "l_foot"
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return "r_leg"
				if(17 to 22)
					return "l_leg"
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					return "r_hand"
				if(12 to 20)
					return "groin"
				if(21 to 24)
					return "l_hand"
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return "r_arm"
				if(12 to 20)
					return "chest"
				if(21 to 24)
					return "l_arm"
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							return "eyes"
				return "head"

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice)
	if(!hud)
		return
	if(isobserver(hud.mymob))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(UPDATE_OVERLAYS)
	return TRUE

/atom/movable/screen/zone_sel/update_overlays()
	. = ..()
	var/image/sel = image(overlay_file, "[selecting]")
	sel.appearance_flags = RESET_COLOR
	. += sel
	hud.mymob.zone_selected = selecting

/atom/movable/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'
	overlay_file = 'icons/mob/screen_alien.dmi'

/atom/movable/screen/zone_sel/robot
	icon = 'icons/mob/screen_robot.dmi'

/atom/movable/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = UI_CRAFTING

/atom/movable/screen/craft/Click()
	if(!isliving(usr))
		return
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = UI_LANGUAGE_MENU

/atom/movable/screen/language_menu/Click()
	var/mob/M = usr
	if(!istype(M))
		return
	M.check_languages()

/atom/movable/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	var/list/object_overlays = list()

/atom/movable/screen/inventory/MouseEntered()
	. = ..()
	add_overlays()

/atom/movable/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlays)
	object_overlays.Cut()

/atom/movable/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	if(!user || user != usr)
		return

	if(!hud?.mymob || !slot_id || (slot_id & ITEM_SLOT_BOTH_HANDS))
		return

	var/obj/item/holding = user.get_active_hand()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!user.can_equip(holding, slot_id, TRUE))
		item_overlay.color = "#ff0000"
	else
		item_overlay.color = "#00ff00"

	object_overlays += item_overlay
	add_overlay(object_overlays)

/atom/movable/screen/inventory/MouseDrop(atom/over)
	cut_overlay(object_overlays)
	object_overlays.Cut()
	if(could_be_click_lag())
		Click()
		drag_start = 0
		return
	return ..()

/atom/movable/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return 1

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id))
		usr.update_inv_l_hand()
		usr.update_inv_r_hand()
	return TRUE

/atom/movable/screen/inventory/hand
	var/image/active_overlay
	var/image/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")

/atom/movable/screen/inventory/hand/update_overlays()
	. = ..()
	if(!handcuff_overlay)
		var/state = (slot_id == ITEM_SLOT_RIGHT_HAND) ? "markus" : "gabrielle"
		handcuff_overlay = image(icon = 'icons/mob/screen_gen.dmi', icon_state = state)

	if(!hud || !hud.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		var/obj/item/organ/external/hand = C.get_organ("[slot_id == ITEM_SLOT_LEFT_HAND ? "l" : "r"]_hand")
		if(!isalien(C) && (!hand || !hand.is_usable()))
			. += blocked_overlay

	if(slot_id == ITEM_SLOT_LEFT_HAND)
		if(hud.mymob.hand)
			. += "hand_active"
		if(hud.mymob.l_hand && (hud.mymob.l_hand.flags & NODROP) && !(hud.mymob.l_hand.flags & ABSTRACT))
			. += "locked_l"
	else if(slot_id == ITEM_SLOT_RIGHT_HAND)
		if(!hud.mymob.hand)
			. += "hand_active"
		if(hud.mymob.r_hand && (hud.mymob.r_hand?.flags & NODROP) && !(hud.mymob.r_hand.flags & ABSTRACT))
			. += "locked"

/atom/movable/screen/inventory/hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return 1

	if(ismob(usr))
		var/mob/M = usr
		switch(name)
			if("right hand", "r_hand")
				M.activate_hand(HAND_BOOL_RIGHT)
			if("left hand", "l_hand")
				M.activate_hand(HAND_BOOL_LEFT)
	return TRUE

/atom/movable/screen/swap_hand
	name = "swap hand"

/atom/movable/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = UI_HEALTH

/atom/movable/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = UI_ALIEN_HEALTH

/atom/movable/screen/healths/bot
	icon = 'icons/mob/screen_bot.dmi'
	screen_loc = UI_BORG_HEALTH

/atom/movable/screen/healths/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = UI_BORG_HEALTH

/atom/movable/screen/healths/corgi
	icon = 'icons/mob/screen_corgi.dmi'

/atom/movable/screen/healths/slime
	icon = 'icons/mob/screen_slime.dmi'
	icon_state = "slime_health0"
	screen_loc = UI_SLIME_HEALTH
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healthdoll
	name = "health doll"
	icon_state = "healthdoll_DEAD"
	screen_loc = UI_HEALTHDOLL
	var/list/cached_healthdoll_overlays = list() // List of icon states (strings) for overlays

/atom/movable/screen/healthdoll/Click()
	if(ishuman(usr) && usr.stat != DEAD)
		var/mob/living/carbon/H = usr
		H.check_self_for_injuries()

/atom/movable/screen/nutrition
	name = "nutrition"
	icon = 'icons/mob/screen_hunger.dmi'
	icon_state = null
	screen_loc = UI_NUTRITION

/atom/movable/screen/component_button
	var/atom/movable/screen/parent

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/new_parent)
	. = ..()
	parent = new_parent

/atom/movable/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)

/atom/movable/screen/healths/stamina
	icon_state = "stamina_0"
	screen_loc = UI_STAMINA

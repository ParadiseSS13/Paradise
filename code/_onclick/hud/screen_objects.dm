/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER_SCREEN
	plane = HUD_PLANE
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null
	appearance_flags = NO_CLIENT_COLOR

/obj/screen/take_damage()
	return

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/proc/component_click(obj/screen/component_button/component, params)
	return

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/storage))
			var/obj/item/storage/S = master
			S.close(usr)
	return 1

/obj/screen/drop
	name = "drop"
	icon_state = "act_drop"
	layer = 19

/obj/screen/drop/Click()
	usr.drop_item_v()

/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return
/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
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

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_acti

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = ui_borg_intents

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon_state = "running"


/obj/screen/act_intent/simple_animal
	icon = 'icons/mob/screen_simplemob.dmi'
	screen_loc = ui_acti

/obj/screen/mov_intent/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.legcuffed)
			to_chat(C, "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>")
			C.m_intent = MOVE_INTENT_WALK	//Just incase
			C.hud_used.move_intent.icon_state = "walking"
			return 1
		switch(usr.m_intent)
			if(MOVE_INTENT_RUN)
				usr.m_intent = MOVE_INTENT_WALK
				usr.hud_used.move_intent.icon_state = "walking"
			if(MOVE_INTENT_WALK)
				usr.m_intent = MOVE_INTENT_RUN
				usr.hud_used.move_intent.icon_state = "running"
		if(istype(usr,/mob/living/carbon/alien/humanoid))
			usr.update_icons()



/obj/screen/pull
	name = "stop pulling"
	icon_state = "pull"

/obj/screen/pull/Click()
	usr.stop_pulling()

/obj/screen/pull/update_icon(mob/mymob)
	if(!mymob) return
	if(mymob.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"
	layer = 19

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
	return 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"
	var/static/list/hover_overlays_cache = list()
	var/hovering

/obj/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return 1

	return set_selected_zone(choice, usr)

/obj/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/obj/screen/zone_sel/MouseMove(location, control, params)
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
	anchored = TRUE
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/obj/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		cut_overlay(hover_overlays_cache[hovering])
	hovering = null

/obj/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
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

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(usr)
	return 1

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/alien/update_icon(mob/user)
	overlays.Cut()
	overlays += image('icons/mob/screen_alien.dmi', "[selecting]")

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_robot.dmi'

/obj/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/craft/Click()
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/obj/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/language_menu/Click()
	var/mob/M = usr
	if(!istype(M))
		return
	M.check_languages()

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	var/list/object_overlays = list()
	layer = 19

/obj/screen/inventory/MouseEntered()
	..()
	add_overlays()

/obj/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlays)
	object_overlays.Cut()

/obj/screen/inventory/proc/add_overlays()
	var/mob/user = hud.mymob

	if(hud && user && slot_id)
		var/obj/item/holding = user.get_active_hand()

		if(!holding || user.get_item_by_slot(slot_id))
			return

		var/image/item_overlay = image(holding)
		item_overlay.alpha = 92

		if(!user.can_equip(holding, slot_id, disable_warning = TRUE))
			item_overlay.color = "#ff0000"
		else
			item_overlay.color = "#00ff00"

		object_overlays += item_overlay
		add_overlay(object_overlays)

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(usr.attack_ui(slot_id))
		usr.update_inv_l_hand(0)
		usr.update_inv_r_hand(0)
	return 1

/obj/screen/inventory/hand
	var/image/active_overlay
	var/image/handcuff_overlay

/obj/screen/inventory/hand/update_icon()
	..()
	if(!active_overlay)
		active_overlay = image("icon"=icon, "icon_state"="hand_active")
	if(!handcuff_overlay)
		var/state = (slot_id == slot_r_hand) ? "markus" : "gabrielle"
		handcuff_overlay = image("icon"='icons/mob/screen_gen.dmi', "icon_state"=state)

	overlays.Cut()

	if(hud && hud.mymob)
		if(iscarbon(hud.mymob))
			var/mob/living/carbon/C = hud.mymob
			if(C.handcuffed)
				overlays += handcuff_overlay

		if(slot_id == slot_l_hand && hud.mymob.hand)
			overlays += active_overlay
		else if(slot_id == slot_r_hand && !hud.mymob.hand)
			overlays += active_overlay

/obj/screen/inventory/hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1

	if(ismob(usr))
		var/mob/M = usr
		switch(name)
			if("right hand", "r_hand")
				M.activate_hand("r")
			if("left hand", "l_hand")
				M.activate_hand("l")
	return 1

/obj/screen/swap_hand
	layer = 19
	name = "swap hand"

/obj/screen/swap_hand/Click()
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

/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/bot
	icon = 'icons/mob/screen_bot.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/corgi
	icon = 'icons/mob/screen_corgi.dmi'


/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healthdoll
	name = "health doll"
	icon_state = "healthdoll_DEAD"
	screen_loc = ui_healthdoll
	var/list/cached_healthdoll_overlays = list() // List of icon states (strings) for overlays

/obj/screen/component_button
	var/obj/screen/parent


/obj/screen/component_button/Initialize(mapload, obj/screen/new_parent)
	. = ..()
	parent = new_parent

/obj/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)
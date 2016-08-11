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
	layer = 20
	plane = HUD_PLANE
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null
	appearance_flags = NO_CLIENT_COLOR

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
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
	var/obj/item/weapon/grab/G = master
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
			usr.a_intent_change(I_HARM)
		else if(_x<=16 && _y>=17)
			usr.a_intent_change(I_HELP)
		else if(_x>=17 && _y<=16)
			usr.a_intent_change(I_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(I_DISARM)

	else
		usr.a_intent_change("right")

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_acti

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_robot.dmi'
	screen_loc = ui_borg_intents

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/internals/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
		to_chat(C, "<span class='notice'>No longer running on internals.</span>")
		icon_state = "internal0"
	else
		var/no_mask = FALSE
		if(!C.wear_mask || !(C.wear_mask.flags & AIRTIGHT))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(!H.head || !(H.head.flags & AIRTIGHT))
					no_mask = TRUE

		if(no_mask)
			to_chat(C, "<span class='notice'>You are not wearing a suitable mask or helmet.</span>")
			return

		var/list/nicename = null
		var/list/tankcheck = null
		var/breathes = "oxygen"
		var/list/contents = list()
		var/from = "on"

		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			breathes = H.species.breath_type
			nicename = list("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
			tankcheck = list(H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
		else
			nicename = list("right hand", "left hand", "back")
			tankcheck = list(C.r_hand, C.l_hand, C.back)

		// Rigs are a fucking pain since they keep an air tank in nullspace.
		if(istype(C.back,/obj/item/weapon/rig))
			var/obj/item/weapon/rig/rig = C.back
			if(rig.air_supply)
				from = "in"
				nicename |= "hardsuit"
				tankcheck |= rig.air_supply

		for(var/i = 1, i < tankcheck.len + 1, ++i)
			if(istype(tankcheck[i], /obj/item/weapon/tank))
				var/obj/item/weapon/tank/t = tankcheck[i]
				switch(breathes)
					if("nitrogen")
						if(t.air_contents.nitrogen && !t.air_contents.oxygen)
							contents.Add(t.air_contents.nitrogen)
						else
							contents.Add(0)
					if("oxygen")
						if(t.air_contents.oxygen && !t.air_contents.toxins)
							contents.Add(t.air_contents.oxygen)
						else
							contents.Add(0)
					if("carbon dioxide")
						if(t.air_contents.carbon_dioxide && !t.air_contents.toxins)
							contents.Add(t.air_contents.carbon_dioxide)
						else
							contents.Add(0)
					if("plasma")
						if(t.air_contents.toxins)
							contents.Add(t.air_contents.toxins)
						else
							contents.Add(0)
			else
				//no tank so we set contents to 0
				contents.Add(0)

		//Alright now we know the contents of the tanks so we have to pick the best one.
		var/best = 0
		var/bestcontents = 0
		for(var/i=1, i <  contents.len + 1 , ++i)
			if(!contents[i])
				continue
			if(contents[i] > bestcontents)
				best = i
				bestcontents = contents[i]
		//We've determined the best container now we set it as our internals
		if(best)
			to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] [from] your [nicename[best]].</span>")
			C.internal = tankcheck[best]

		if(C.internal)
			icon_state = "internal1"
		else
			to_chat(C, "<span class='notice'>You don't have a[breathes == "oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")

	C.update_action_buttons_icon()

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon_state = "running"

/obj/screen/mov_intent/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.legcuffed)
			to_chat(C, "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>")
			C.m_intent = "walk"	//Just incase
			C.hud_used.move_intent.icon_state = "walking"
			return 1
		switch(usr.m_intent)
			if("run")
				usr.m_intent = "walk"
				usr.hud_used.move_intent.icon_state = "walking"
			if("walk")
				usr.m_intent = "run"
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

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon()
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

/obj/screen/inventory/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/inventory/craft/Click()
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	layer = 19

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
	mouse_opacity = 0

/obj/screen/healthdoll
	name = "health doll"
	icon_state = "healthdoll_DEAD"
	screen_loc = ui_healthdoll
	var/list/cached_healthdoll_overlays = list() // List of icon states (strings) for overlays

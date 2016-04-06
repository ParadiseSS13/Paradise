/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/gun_click_time = -100 //I'm lazy.

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


/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


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
	icon = 'icons/mob/screen1_midnight.dmi'
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

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"

/obj/screen/internals/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
			if(C.internal)
				C.internal = null
				to_chat(C, "<span class='notice'>No longer running on internals.</span>")
				if(C.internals)
					C.internals.icon_state = "internal0"
			else

				var/no_mask
				if(!(C.wear_mask && C.wear_mask.flags & AIRTIGHT))
					if(ishuman(C))
						var/mob/living/carbon/human/H = C
						if(!(H.head && H.head.flags & AIRTIGHT))
							no_mask = 1

				if(no_mask)
					to_chat(C, "<span class='notice'>You are not wearing a suitable mask or helmet.</span>")
					return 1
				else
					var/list/nicename = null
					var/list/tankcheck = null
					var/breathes = "oxygen"    //default, we'll check later
					var/list/contents = list()
					var/from = "on"

					if(ishuman(C))
						var/mob/living/carbon/human/H = C
						breathes = H.species.breath_type
						nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
						tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
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

					for(var/i=1, i<tankcheck.len+1, ++i)
						if(istype(tankcheck[i], /obj/item/weapon/tank))
							var/obj/item/weapon/tank/t = tankcheck[i]
/*									if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
								contents.Add(t.air_contents.total_moles)	Someone messed with the tank and put unknown gasses
								continue					in it, so we're going to believe the tank is what it says it is*/
							switch(breathes)
																//These tanks we're sure of their contents
								if("nitrogen") 							//So we're a bit more picky about them.

									if(t.air_contents.nitrogen && !t.air_contents.oxygen)
										contents.Add(t.air_contents.nitrogen)
									else
										contents.Add(0)

								if ("oxygen")
									if(t.air_contents.oxygen && !t.air_contents.toxins)
										contents.Add(t.air_contents.oxygen)
									else
										contents.Add(0)

								// No races breath this, but never know about downstream servers.
								if ("carbon dioxide")
									if(t.air_contents.carbon_dioxide && !t.air_contents.toxins)
										contents.Add(t.air_contents.carbon_dioxide)
									else
										contents.Add(0)

								// ACK ACK ACK Plasmen
								if ("plasma")
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
						if(C.internals)
							C.internals.icon_state = "internal1"
					else
						to_chat(C, "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen1_midnight.dmi'
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
	icon = 'icons/mob/screen1_Midnight.dmi'
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
	icon = 'icons/mob/screen1_midnight.dmi'
	icon_state = "act_resist"
	layer = 19

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen1_midnight.dmi'
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
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
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

/obj/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	master = null
	dir = 2

/obj/screen/gun/mode
		name = "Toggle Gun Mode"
		icon_state = "gun0"
		screen_loc = ui_gun_select

/obj/screen/gun/mode/Click()
	usr.client.ToggleGunMode()

/obj/screen/gun/item
		name = "Allow Item Use"
		icon_state = "no_item0"
		screen_loc = ui_gun1

/obj/screen/gun/item/Click()
	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return
	if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
		to_chat(usr, "You need your gun in your active hand to do that!")
		return
	usr.client.AllowTargetClick()
	gun_click_time = world.time


/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
	return 1

// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client

/mob/key_down(_key, client/user)
	if(user.prefs.toggles & PREFTOGGLE_AZERTY)
		switch(_key)
			if("Delete")
				if(!pulling)
					to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
				else
					stop_pulling()
				return
			if("Insert", "G")
				a_intent_change(INTENT_HOTKEY_RIGHT)
				return
			if("F")
				a_intent_change(INTENT_HOTKEY_LEFT)
				return
			if("X", "Northeast") // Northeast is Page-up
				swap_hand()
				return
			if("Y", "W", "Southeast")	// Southeast is Page-down
				mode()					// attack_self(). No idea who came up with "mode()"
				return
			if("A", "Northwest") // Northwest is Home
				var/obj/item/I = get_active_hand()
				if(!I)
					to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
				else
					drop_item(I)
				return
			if("E")
				quick_equip()
				return
			if("Alt")
				toggle_move_intent()
				return
	else
		switch(_key)
			if("Delete", "C")
				if(!pulling)
					to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
				else
					stop_pulling()
				return
			if("Insert", "G")
				a_intent_change(INTENT_HOTKEY_RIGHT)
				return
			if("F")
				a_intent_change(INTENT_HOTKEY_LEFT)
				return
			if("X", "Northeast") // Northeast is Page-up
				swap_hand()
				return
			if("Y", "Z", "Southeast")	// Southeast is Page-down
				mode()					// attack_self(). No idea who came up with "mode()"
				return
			if("Q", "Northwest") // Northwest is Home
				var/obj/item/I = get_active_hand()
				if(!I)
					to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
				else
					drop_item(I)
				return
			if("E")
				quick_equip()
				return
			if("Alt")
				toggle_move_intent()
				return
		//Bodypart selections
	if(client.prefs.toggles & PREFTOGGLE_NUMPAD_TARGET)
		switch(_key)
			if("Numpad8")
				user.body_toggle_head()
				return
			if("Numpad4")
				user.body_r_arm()
				return
			if("Numpad5")
				user.body_chest()
				return
			if("Numpad6")
				user.body_l_arm()
				return
			if("Numpad1")
				user.body_r_leg()
				return
			if("Numpad2")
				user.body_groin()
				return
			if("Numpad3")
				user.body_l_leg()
				return
	else
		switch(_key)
			if("Numpad1")
				a_intent_change("help")
				return
			if("Numpad2")
				a_intent_change("disarm")
				return
			if("Numpad3")
				a_intent_change("grab")
				return
			if("Numpad4")
				a_intent_change("harm")
				return
	if(client.keys_held["Ctrl"] && client.prefs.toggles & PREFTOGGLE_AZERTY)
		switch(SSinput.alt_movement_keys[_key])
			if(NORTH)
				northface()
				return
			if(SOUTH)
				southface()
				return
			if(WEST)
				westface()
				return
			if(EAST)
				eastface()
				return
	else if(client.keys_held["Ctrl"])
		switch(SSinput.movement_keys[_key])
			if(NORTH)
				northface()
				return
			if(SOUTH)
				southface()
				return
			if(WEST)
				westface()
				return
			if(EAST)
				eastface()
				return
	return ..()

/mob/key_up(_key, client/user)
	switch(_key)
		if("Alt")
			toggle_move_intent()
			return
	return ..()

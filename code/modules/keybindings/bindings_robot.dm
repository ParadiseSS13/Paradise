/mob/living/silicon/robot/key_down(_key, client/user)
	switch(_key)
		if("1", "2", "3")
			toggle_module(text2num(_key))
			return
		if("4")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if("X")
			cycle_modules()
			return
		if("Q")
			if(!(client.prefs.toggles & AZERTY))
				uneq_active()
				return
		if("A")
			if(client.prefs.toggles & AZERTY)
				uneq_active()
				return
	return ..()
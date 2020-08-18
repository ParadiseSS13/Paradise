/mob/living/silicon/ai/key_down(_key, client/user)
	switch(_key)
		if("4")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
	return ..()

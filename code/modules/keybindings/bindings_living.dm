/mob/living/key_down(_key, client/user)
	switch(_key)
		if("B")
			if(user.keys_held["Shift"])
				lay_down()
			else
				resist()
			return

	return ..()

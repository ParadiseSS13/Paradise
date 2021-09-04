/mob/living/silicon/ai/var/current_camera = 0

/mob/living/silicon/ai/key_down(_key, client/user)
	if(user.keys_held["Shift"])
		if(text2num(_key) != null)
			if(set_camera_by_index(user, text2num(_key)))
				update_binded_camera(user)
			return
		return ..()
	else
		switch(_key)
			if("4")
				a_intent_change(INTENT_HOTKEY_LEFT)
				return
			if("N")
				if(check_for_binded_cameras(user))
					current_camera_next(user)
					update_binded_camera(user)
					return
			if("B")
				if(check_for_binded_cameras(user))
					current_camera_back(user)
					update_binded_camera(user)
					return
		return ..()

/mob/living/silicon/ai/proc/check_for_binded_cameras(client/user)
	if(!length(stored_locations))
		to_chat(user, "<span class='warning'>You have no stored camera positions</span>")
		return 0
	return 1

/mob/living/silicon/ai/proc/set_camera_by_index(client/user, var/camnum)
	var/camnum_length = length(stored_locations)
	if(camnum > camnum_length || (camnum == 0 && camnum_length < 10))
		to_chat(user, "<span class='warning'>You have no stored camera on [camnum] position</span>")
		return 0
	if(camnum == 0)
		camnum = 10
	current_camera = camnum
	return 1

/mob/living/silicon/ai/proc/update_binded_camera(client/user)
	var/camname
	camname = stored_locations[current_camera]
	ai_goto_location(camname)
	to_chat(user, "<span class='notice'>Now you on camera position: [camname]</span>")

/mob/living/silicon/ai/proc/current_camera_next(client/user)
	if(current_camera >= length(stored_locations))
		current_camera = 1
	else
		current_camera += 1

/mob/living/silicon/ai/proc/current_camera_back(client/user)
	if(current_camera <= 1)
		current_camera = length(stored_locations)
	else
		current_camera -= 1

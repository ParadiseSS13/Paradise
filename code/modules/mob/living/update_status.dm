/mob/living/update_blind_effects()
	if(!has_vision())
		overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		throw_alert("blind", /obj/screen/alert/blind)
		return 1
	else
		clear_fullscreen("blind")
		clear_alert("blind")
		return 0

/mob/living/update_blurry_effects()
	if(eyes_blurred())
		overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		return 1
	else
		clear_fullscreen("blurry")
		return 0

/mob/living/update_druggy_effects()
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
		throw_alert("high", /obj/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert("high")

/mob/living/update_nearsighted_effects()
	if(disabilities & NEARSIGHTED)
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")

/mob/living/update_sleeping_effects(no_alert = FALSE)
	if(sleeping)
		if(!no_alert)
			throw_alert("asleep", /obj/screen/alert/asleep)
	else
		clear_alert("asleep")

// Querying status of the mob

// Whether the mob can hear things
/mob/living/can_hear()
	return !(ear_deaf || (disabilities & DEAF))

// Whether the mob is able to see
/mob/living/has_vision()
	return !(eye_blind || (disabilities & BLIND) || stat)

// Whether the mob is capable of talking
/mob/living/can_speak()
	return !(silent || (disabilities & MUTE) || is_muzzled())

// Whether the mob is capable of standing or not
/mob/living/proc/can_stand()
	return !(weakened || paralysis || stat || (status_flags & FAKEDEATH))

// Whether the mob is capable of actions or not
/mob/living/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_lying = FALSE)
	if(stat || paralysis || stunned || weakened || (!ignore_restraints && restrained()) || (!ignore_lying && lying))
		return TRUE

// wonderful proc names, I know - used to check whether the blur overlay
// should show or not
/mob/living/proc/eyes_blurred()
	return eye_blurry

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/living/update_canmove(delay_action_updates = 0)
	var/fall_over = !can_stand()
	var/buckle_lying = !(buckled && !buckled.buckle_lying)
	if(fall_over || resting || stunned)
		drop_r_hand()
		drop_l_hand()
	else
		lying = 0
		canmove = 1
	if(buckled)
		lying = 90 * buckle_lying
	else if((fall_over || resting) && !lying)
		fall(fall_over)

	canmove = !(fall_over || resting || stunned || buckled)
	density = !lying
	if(lying)
		if(layer == initial(layer))
			layer = MOB_LAYER - 0.2
	else
		if(layer == MOB_LAYER - 0.2)
			layer = initial(layer)

	update_transform()
	if(!delay_action_updates)
		update_action_buttons_icon()
	return canmove

/mob/living/proc/update_stamina()
	return

/mob/living/on_varedit(modified_var)
	switch(modified_var)
		if("weakened")
			SetWeakened(weakened)
		if("stunned")
			SetStunned(stunned)
		if("paralysis")
			SetParalysis(paralysis)
		if("sleeping")
			SetSleeping(sleeping)
		if("eye_blind")
			SetEyeBlind(eye_blind)
		if("eye_blurry")
			SetEyeBlurry(eye_blurry)
		if("ear_deaf")
			SetEarDeaf(ear_deaf)
		if("ear_damage")
			SetEarDamage(ear_damage)
		if("druggy")
			SetDruggy(druggy)
		if("maxHealth")
			updatehealth()
		if("resize")
			update_transform()
	..()
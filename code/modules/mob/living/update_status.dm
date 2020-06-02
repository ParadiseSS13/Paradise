/mob/living/update_blind_effects()
	if(!has_vision(information_only=TRUE))
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
	if(NEARSIGHTED in mutations)
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
	. = !(DEAF in mutations)

// Whether the mob is able to see
// `information_only` is for stuff that's purely informational - like blindness overlays
// This flag exists because certain things like angel statues expect this to be false for dead people
/mob/living/has_vision(information_only = FALSE)
	return (information_only && stat == DEAD) || !(eye_blind || (BLINDNESS in mutations) || stat)

// Whether the mob is capable of talking
/mob/living/can_speak()
	if(!(silent || (MUTE in mutations)))
		if(is_muzzled())
			var/obj/item/clothing/mask/muzzle/M = wear_mask
			if(M.mute >= MUZZLE_MUTE_MUFFLE)
				return FALSE
		return TRUE
	else
		return FALSE

// Whether the mob is capable of standing or not
/mob/living/proc/can_stand()
	return !(IsWeakened() || paralysis || stat || (status_flags & FAKEDEATH))

// Whether the mob is capable of actions or not
/mob/living/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_lying = FALSE, list/extra_checks = list(), use_default_checks = TRUE)
	// By default, checks for weakness and stunned get added to the extra_checks list.
	// Setting `use_default_checks` to FALSE means that you don't want it checking for these statuses or you are supplying your own checks.
	if(use_default_checks)
		extra_checks += CALLBACK(src, /mob.proc/IsWeakened)
		extra_checks += CALLBACK(src, /mob.proc/IsStunned)

	if(stat || paralysis || (!ignore_restraints && restrained()) || (!ignore_lying && lying) || check_for_true_callbacks(extra_checks))
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

	canmove = !(fall_over || resting || stunned || IsFrozen() || buckled)
	density = !lying
	if(lying)
		if(layer == initial(layer))
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)

	update_transform()
	if(!delay_action_updates)
		update_action_buttons_icon()
	return canmove

/mob/living/proc/update_stamina()
	return

/mob/living/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
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
		if("druggy")
			SetDruggy(druggy)
		if("maxHealth")
			updatehealth("var edit")
		if("resize")
			update_transform()

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
	if(disabilities & NEARSIGHTED)
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")

// Querying status of the mob

// Whether the mob can hear things
/mob/living/can_hear()
	. = !(disabilities & DEAF)

// Whether the mob is able to see
// `information_only` is for stuff that's purely informational - like blindness overlays
// This flag exists because certain things like angel statues expect this to be false for dead people
/mob/living/has_vision(information_only = FALSE)
	return (information_only && stat == DEAD) || !(eye_blind || (disabilities & BLIND) || stat)

// Whether the mob is capable of talking
/mob/living/can_speak()
	if(!(silent || (disabilities & MUTE)))
		if(is_muzzled())
			var/obj/item/clothing/mask/muzzle/M = wear_mask
			if(M.mute >= MUZZLE_MUTE_MUFFLE)
				return FALSE
		return TRUE
	else
		return FALSE

// Whether the mob is capable of actions or not
/mob/living/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	if(stat || IsUnconscious() || IsStun() || IsParalyzed() || (check_immobilized && IsImmobilized()) || (!ignore_restraints && restrained(ignore_grab)))
		return TRUE

// wonderful proc names, I know - used to check whether the blur overlay
// should show or not
/mob/living/proc/eyes_blurred()
	return eye_blurry

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/living/proc/update_mobility()
	var/stat_conscious = (stat == CONSCIOUS)
	var/conscious = !IsUnconscious() && stat_conscious
	var/obj/item/grab/G = locate() in grabbed_by
	var/chokehold = G && G.state >= GRAB_NECK // just neck grab
	var/killchoke = G && G.state == GRAB_KILL // strangling
	var/has_legs = get_num_legs()
	var/has_arms = get_num_arms()
	var/paralyzed = IsParalyzed()
	var/stun = IsStun()
	var/knockdown = IsKnockdown()
	var/canmove = !IsImmobilized() && !stun && conscious && !paralyzed && !buckled && !chokehold && (has_arms || has_legs)
	if(canmove)
		mobility_flags |= MOBILITY_MOVE
	else
		mobility_flags &= ~MOBILITY_MOVE
	var/canstand_involuntary = conscious && !knockdown && !killchoke && !paralyzed && has_legs && !(buckled && buckled.buckle_lying)
	var/canstand = canstand_involuntary && !resting

	if(canstand)
		mobility_flags |= (MOBILITY_STAND | MOBILITY_UI | MOBILITY_PULL)
		lying = 0
	else
		mobility_flags &= ~(MOBILITY_UI | MOBILITY_PULL)

		var/should_be_lying = (buckled && (buckled.buckle_lying != -1)) ? buckled.buckle_lying : TRUE //make lying match buckle_lying if it's not -1, else lay down

		if(should_be_lying)
			mobility_flags &= ~MOBILITY_STAND
			if(!lying) //force them on the ground
				lying = pick(90, 270)
		else
			mobility_flags |= MOBILITY_STAND //important to add this back, otherwise projectiles will pass through the mob while they're upright.
			if(lying) //stand them back up
				lying = 0
	var/canitem = !paralyzed && !stun && conscious && !chokehold && has_arms
	if(canitem)
		mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	else
		mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	if(!(mobility_flags & MOBILITY_USE))
		drop_r_hand()
		drop_l_hand()
	if(!(mobility_flags & MOBILITY_PULL))
		if(pulling)
			stop_pulling()
	if(!(mobility_flags & MOBILITY_UI))
		unset_machine()
	density = !lying
	var/changed = lying == lying_prev
	if(lying)
		if(!lying_prev)
			fall(!canstand_involuntary)
		if(layer == initial(layer)) //to avoid special cases like hiding larvas.
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)
	update_transform()
	if(changed)
		if(client)
			client.move_delay = world.time + movement_delay()
	lying_prev = lying

/mob/living/proc/update_stamina()
	return

/mob/living/proc/fall(forced)
	if(!(mobility_flags & MOBILITY_USE))
		drop_l_hand()
		drop_r_hand()

/mob/living/update_stat(reason = "None given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
		else if(IsSleeping() || IsUnconscious() || status_flags & FAKEDEATH)
			if(stat == CONSCIOUS)
				KnockOut()
				create_debug_log("fell unconscious, trigger reason: [reason]")
		else
			if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")

/mob/living/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if("knockdown")
			SetKnockdown(var_value)
		if("unconscious")
			SetUnconscious(var_value)
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

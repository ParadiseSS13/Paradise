// NOTE: These procs are called throughout the code to cause immediate sight effects.
// If you want a species to ignore these, you'll have to modify these procs for it - simply
// leaving them out of your species' `handle_vision` proc will just cause these not
// to update when needed, as they will be called elsewhere

// Call this for an immediate effect from updating tint
/mob/living/carbon/human/update_tint_effects()
	var/last_tint = tint_total
	tint_total = tintcheck()
	if(tint_total >= TINT_IMPAIR)
		// Config option for disabling tint
		if(tinted_weldhelh)
			overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
		if(tint_total >= TINT_BLIND && last_tint < TINT_BLIND)
			eyes_blocked++
			update_blind_effects()
		else if(tint_total < TINT_BLIND && last_tint >=  TINT_BLIND)
			eyes_blocked--
			update_blind_effects()
	else
		clear_fullscreen("tint")

// Call this for an immediate effect from changing nearsightedness effects
/mob/living/carbon/human/update_nearsighted_effects()
	if(disabilities & NEARSIGHTED)
		if(glasses)
			var/obj/item/clothing/glasses/G = glasses
			if(G.prescription)
				clear_fullscreen("nearsighted")
			else
				overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		else
			overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")

/mob/living/carbon/human/can_see()
	return ..() && !eyes_missing && !eyes_blocked

/mob/living/carbon/human/eyes_blurred()
	return ..() && eyes_permablurry

// Used to update whether a human has working eyes or not
/mob/living/carbon/human/proc/update_eye_presence()
	//Vision //god knows why this is here
	var/obj/item/organ/internal/vision
	if(species.vision_organ)
		vision = get_int_organ(species.vision_organ)

	eyes_missing = FALSE
	eyes_permablurry = FALSE
	if(species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
		if(!vision || vision.is_broken())   // Vision organs cut out or broken? Permablind.
			eyes_missing = TRUE

		//blurry sight
		else if(vision.is_bruised())   // Vision organs impaired? Permablurry.
			eyes_permablurry = TRUE
	update_blind_effects()
	update_blurry_effects()

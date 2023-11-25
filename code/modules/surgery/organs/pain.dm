/mob/living/carbon
	var/last_pain_message = ""
	var/next_pain_time = 0

/**
 * Whether or not a mob can feel pain.
 *
 * Returns TRUE if the mob can feel pain, FALSE otherwise
 */
/mob/living/carbon/proc/can_feel_pain()
	if(stat >= UNCONSCIOUS)
		return FALSE
	if(reagents.has_reagent("morphine"))
		return FALSE
	if(reagents.has_reagent("hydrocodone"))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NOPAIN))
		return FALSE

	return TRUE

// partname is the name of a body part
// amount is a num from 1 to 100
/mob/living/carbon/proc/pain(partname, amount)
	if(!can_feel_pain())
		return
	if(world.time < next_pain_time)
		return
	var/msg
	switch(amount)
		if(1 to 10)
			msg = "<b>Your [partname] hurts.</b>"
		if(11 to 90)
			msg = "<b><font size=2>Your [partname] hurts badly.</font></b>"
		if(91 to INFINITY)
			msg = "<b><font size=3>OH GOD! Your [partname] is hurting terribly!</font></b>"
	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		to_chat(src, msg)
	next_pain_time = world.time + (100 - amount)

/mob/living/carbon/human/proc/handle_pain()
	// not when sleeping

	if(!can_feel_pain())
		return

	var/maxdam = 0
	var/obj/item/organ/external/damaged_organ = null
	for(var/obj/item/organ/external/E in bodyparts)
		if((E.status & ORGAN_DEAD|ORGAN_ROBOT) || E.hidden_pain)
			continue
		var/dam = E.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)))
			damaged_organ = E
			maxdam = dam
		if(damaged_organ)
			pain(damaged_organ.name, maxdam)

	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/internal/I in internal_organs)
		if(I.hidden_pain)
			continue
		if(prob(2) && I.damage > 2)
			var/obj/item/organ/external/parent = get_organ(I.parent_organ)
			var/intensity
			switch(I.damage)
				if(0 to 10)
					intensity = "a dull"
				if(10 to 30)
					intensity = "a nagging"
				if(30 to 50)
					intensity = "a sharp"
				else
					intensity = "a stabbing"
			I.custom_pain("You feel [intensity] pain in your [parent.limb_name]!")

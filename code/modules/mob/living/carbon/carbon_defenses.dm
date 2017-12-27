/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked = 0)
	if(!skipcatch)
		if(in_throw_mode && !get_active_hand())  //empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(istype(AM, /obj/item))
					var/obj/item/I = AM
					if(isturf(I.loc))
						put_in_active_hand(I)
						visible_message("<span class='warning'>[src] catches [I]!</span>")
						throw_mode_off()
						return 1
	..()

/mob/living/carbon/water_act(volume, temperature, source)
	if(volume > 10) //anything over 10 volume will make the mob wetter.
		wetlevel = min(wetlevel + 1,5)
	..()


/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(lying)
		if(surgeries.len)
			if(user != src && user.a_intent == INTENT_HELP)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	..()

/mob/living/carbon/attack_hand(mob/living/carbon/human/user)
	if(!iscarbon(user))
		return

	for(var/thing in viruses)
		var/datum/disease/D = thing
		if(D.IsSpreadByTouch())
			user.ContractDisease(D)

	for(var/thing in user.viruses)
		var/datum/disease/D = thing
		if(D.IsSpreadByTouch())
			ContractDisease(D)
	return 0

/mob/living/carbon/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	if((!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)))
		return TRUE
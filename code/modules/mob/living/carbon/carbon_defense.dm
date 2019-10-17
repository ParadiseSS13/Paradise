/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!skipcatch)
		if(in_throw_mode && canmove && !restrained())  //Makes sure player is in throw mode
			if(!istype(AM,/obj/item) || !isturf(AM.loc))
				return FALSE
			if(get_active_hand())
				return FALSE
			if(istype(AM, /obj/item/twohanded))
				if(get_inactive_hand())
					return FALSE
			put_in_active_hand(AM)
			visible_message("<span class='warning'>[src] catches [AM]!</span>")
			throw_mode_off()
			return TRUE
	..()

/mob/living/carbon/water_act(volume, temperature, source, method = TOUCH)
	. = ..()
	if(volume > 10) // Anything over 10 volume will make the mob wetter.
		wetlevel = min(wetlevel + 1,5)

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(lying && surgeries.len)
		if(user != src && user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return 1
	return ..()

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

	if(lying && surgeries.len)
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return 1
	return 0

/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			var/stunprob = M.powerlevel * 7 + 10  // 17 at level 1, 80 at level 10
			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", "<span class='userdanger'>The [M.name] has shocked you!</span>")

				do_sparks(5, TRUE, src)
				var/power = M.powerlevel + rand(0,3)
				Stun(power)
				if(stuttering < power)
					stuttering = power
				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))
					updatehealth("slime attack")
		return 1

/mob/living/carbon/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	if((!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)))
		return TRUE

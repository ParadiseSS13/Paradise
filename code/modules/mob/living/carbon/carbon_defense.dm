/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!skipcatch)
		if(in_throw_mode && !HAS_TRAIT(src, TRAIT_HANDS_BLOCKED) && !restrained())  //Makes sure player is in throw mode
			if(!isitem(AM) || !isturf(AM.loc))
				return FALSE
			if(get_active_hand())
				return FALSE
			if(AM.GetComponent(/datum/component/two_handed))
				if(get_inactive_hand())
					return FALSE
			put_in_active_hand(AM)
			visible_message("<span class='warning'>[src] catches [AM]!</span>")
			throw_mode_off()
			SEND_SIGNAL(src, COMSIG_CARBON_THROWN_ITEM_CAUGHT, AM)
			return TRUE
	return ..()

/mob/living/carbon/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume > 10) // Anything over 10 volume will make the mob wetter.
		wetlevel = min(wetlevel + 1,5)

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(length(surgeries))
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return TRUE
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

	if(IS_HORIZONTAL(src) && length(surgeries))
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return TRUE
	return FALSE

/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			do_sparks(5, TRUE, src)
			adjustStaminaLoss(M.powerlevel * 5) //5-50 stamina damage, at starting power level 10 this means 50, 35, 20 on consecutive hits - stamina crit in 3 hits
			KnockDown(M.powerlevel SECONDS)
			Stuttering(M.powerlevel SECONDS)
			visible_message("<span class='danger'>[M] has shocked [src]!</span>", "<span class='userdanger'>[M] has shocked you!</span>")
			M.powerlevel -= 3
			if(M.powerlevel < 0)
				M.powerlevel = 0
		return 1

/mob/living/carbon/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	if((!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)))
		return TRUE

//Called when drawing cult runes/using cult spells. Deal damage to a random arm/hand, or chest if not there.
/mob/living/carbon/cult_self_harm(damage)
	var/dam_zone = pick("l_arm", "l_hand", "r_arm", "r_hand")
	var/obj/item/organ/external/affecting = get_organ(dam_zone)
	if(!affecting)
		affecting = get_organ("chest")
	if(!affecting) //bruh where's your chest
		return FALSE
	apply_damage(damage, BRUTE, affecting)

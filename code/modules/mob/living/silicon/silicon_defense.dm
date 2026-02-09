/mob/living/silicon/grabbedby(mob/living/user)
	remove_from_head(user)

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent
		var/damage = 20
		if(prob(90))
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(SPAN_DANGER("[M] has slashed at [src]!"), SPAN_USERDANGER("[M] has slashed at [src]!"))
			if(prob(8))
				flash_eyes(affect_silicon = 1)
			add_attack_logs(M, src, "Alien attacked")
			damage = run_armor(damage, BRUTE, MELEE)
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE, -1)
			visible_message(SPAN_DANGER("[M] took a swipe at [src]!"), \
							SPAN_USERDANGER("[M] took a swipe at [src]!"))
	return

/mob/living/silicon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		damage = run_armor(damage, M.melee_damage_type, MELEE, 0, M.armor_penetration_flat, M.armor_penetration_percentage)
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)
		updatehealth()

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L)
	if(L.a_intent == INTENT_HELP)
		visible_message(SPAN_NOTICE("[L.name] rubs its head against [src]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, SPAN_WARNING("You don't want to hurt [src]!"))
			return FALSE
		..(user, TRUE)
		adjustBruteLoss(run_armor(rand(10, 15), BRUTE, MELEE))
		playsound(loc, "punch", 25, TRUE, -1)
		visible_message(SPAN_DANGER("[user] has punched [src]!"), SPAN_USERDANGER("[user] has punched [src]!"))
		return TRUE
	return FALSE

/mob/living/silicon/attack_hand(mob/living/carbon/human/M)
	if(istype(M))
		var/obj/item/organ/external/temp = M.bodyparts_by_name["r_hand"]
		if(M.hand)
			temp = M.bodyparts_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			to_chat(M, SPAN_WARNING("You can't use your hand!"))
			return

	switch(M.a_intent)
		if(INTENT_HELP)
			M.visible_message(SPAN_NOTICE("[M] pets [src]!"), \
							SPAN_NOTICE("You pet [src]!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if("grab")
			grabbedby(M)
		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			playsound(loc, 'sound/effects/bang.ogg', 10, 1)
			visible_message(SPAN_NOTICE("[M] punches [src], but doesn't leave a dent."), \
						SPAN_NOTICE("[M] punches [src], but doesn't leave a dent."))
	return FALSE

/mob/living/silicon/handle_basic_attack(mob/living/basic/attacker, modifiers)
	. = ..()
	if(.)
		var/damage = rand(attacker.melee_damage_lower, attacker.melee_damage_upper)
		damage = run_armor(damage, attacker.melee_damage_type, MELEE, 0, attacker.armor_penetration_flat, attacker.armor_penetration_percentage)
		switch(attacker.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)
		updatehealth()

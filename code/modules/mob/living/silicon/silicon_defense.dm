/mob/living/silicon/grabbedby(mob/living/user)
	remove_from_head(user)

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent
		var/damage = 20
		if(prob(90))
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[M] has slashed at [src]!"), span_userdanger("[M] has slashed at [src]!"))
			if(prob(8))
				flash_eyes(affect_silicon = 1)
			add_attack_logs(M, src, "Alien attacked")
			damage = run_armor(damage, BRUTE, MELEE)
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE, -1)
			visible_message(span_danger("[M] took a swipe at [src]!"), \
							span_userdanger("[M] took a swipe at [src]!"))
	return

/mob/living/silicon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		damage = run_armor(damage, M.melee_damage_type, MELEE, 0, M.armour_penetration_flat, M.armour_penetration_percentage)
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
		visible_message(span_notice("[L.name] rubs its head against [src]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_warning("You don't want to hurt [src]!"))
			return FALSE
		..(user, TRUE)
		adjustBruteLoss(run_armor(rand(10, 15), BRUTE, MELEE))
		playsound(loc, "punch", 25, TRUE, -1)
		visible_message(span_danger("[user] has punched [src]!"), span_userdanger("[user] has punched [src]!"))
		return TRUE
	return FALSE

/mob/living/silicon/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			M.visible_message(span_notice("[M] pets [src]!"), \
							span_notice("You pet [src]!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if("grab")
			grabbedby(M)
		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			playsound(loc, 'sound/effects/bang.ogg', 10, 1)
			visible_message(span_notice("[M] punches [src], but doesn't leave a dent."), \
						span_notice("[M] punches [src], but doesn't leave a dent."))
	return FALSE

/mob/living/silicon/handle_basic_attack(mob/living/basic/attacker, modifiers)
	. = ..()
	if(.)
		var/damage = rand(attacker.melee_damage_lower, attacker.melee_damage_upper)
		damage = run_armor(damage, attacker.melee_damage_type, MELEE, 0, attacker.armour_penetration_flat, attacker.armour_penetration_percentage)
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

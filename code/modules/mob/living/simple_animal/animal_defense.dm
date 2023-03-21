/mob/living/simple_animal/attackby(obj/item/O, mob/living/user)
	if(user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
		if(can_collar && istype(O, /obj/item/clothing/accessory/petcollar) && !pcollar)
			add_collar(O, user)
			return
		if(istype(O, /obj/item/pet_carrier))
			var/obj/item/pet_carrier/C = O
			if(C.put_in_carrier(src, user))
				return
	return ..()

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M)
	..()
	switch(M.a_intent)

		if(INTENT_HELP)
			if(health > 0)
				visible_message("<span class='notice'>[M] [response_help] [src].</span>", "<span class='notice'>[M] [response_help] you.</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(INTENT_GRAB)
			if(holder_type)
				get_scooped(M)
			else
				grabbedby(M)
		if(INTENT_HARM, INTENT_DISARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
				to_chat(M, "<span class='warning'>You don't want to hurt [src]!</span>")
				return
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message("<span class='danger'>[M] [response_harm] [src]!</span>", "<span class='userdanger'>[M] [response_harm] you!</span>")
			playsound(loc, attacked_sound, 25, 1, -1)
			attack_threshold_check(harm_intent_damage)
			add_attack_logs(M, src, "Melee attacked with fists")
			updatehealth()
			return TRUE

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if(M.a_intent == INTENT_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] [response_disarm] [name]!</span>", "<span class='userdanger'>[M] [response_disarm] you!</span>")
			add_attack_logs(M, src, "Alien disarmed")
		else
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
					"<span class='userdanger'>[M] has slashed at [src]!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			add_attack_logs(M, src, "Alien attacked")
			attack_threshold_check(damage)
		return TRUE

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite
		if(stat != DEAD)
			var/damage = rand(5, 10)
			. = attack_threshold_check(damage)
			if(.)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		return attack_threshold_check(damage, M.melee_damage_type)

/mob/living/simple_animal/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(15, 25)
		if(M.age_state.age != SLIME_BABY)
			damage = rand(20 + M.age_state.damage, 35 + M.age_state.damage)
		return attack_threshold_check(damage)

/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = "melee")
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message("<span class='warning'>[src] looks unharmed.</span>")
		return FALSE
	else
		apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE

/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src, 0)
	return FALSE

/mob/living/simple_animal/ex_act(severity, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	var/bomb_armor = getarmor(null, "bomb")
	switch(severity)
		if(1)
			if(prob(bomb_armor))
				adjustBruteLoss(500)
			else
				gib()
				return
		if(2)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)
		if(3)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

/mob/living/simple_animal/blob_act(obj/structure/blob/B)
	adjustBruteLoss(20)

/mob/living/simple_animal/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage_upper)
		if(melee_damage_upper < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

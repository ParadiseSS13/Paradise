/datum/martial_art/boxing
	name = "Boxing"

/datum/martial_art/boxing/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't disarm while boxing!</span>")
	return 1

/datum/martial_art/boxing/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't grab while boxing!</span>")
	return 1

/datum/martial_art/boxing/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")
	
	var/damage = rand(5, 8) + A.dna.species.punchdamagelow
	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to hit [D] with a [atk_verb]!</span>")
		add_attack_logs(A, D, "Melee attacked with [src] (miss/block)", ATKLOG_ALL)
		return 0


	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)

	D.visible_message("<span class='danger'>[A] has hit [D] with a [atk_verb]!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a [atk_verb]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src]", ATKLOG_ALL)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.SetSleeping(5)
			D.forcesay(GLOB.hit_appends)
		else if(D.lying)
			D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/drunk_brawling
	name = "Drunken Brawling"

/datum/martial_art/drunk_brawling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(70))
		A.visible_message("<span class='warning'>[A] tries to grab ahold of [D], but fails!</span>", \
							"<span class='warning'>You fail to grab ahold of [D]!</span>")
		return 1
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		D.visible_message("<span class='danger'>[A] grabs ahold of [D] drunkenly!</span>", \
								"<span class='userdanger'>[A] grabs ahold of [D] drunkenly!</span>")
	return 1

/datum/martial_art/drunk_brawling/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_attack_logs(A, D, "Melee attacked with [src]")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("jab","uppercut","overhand punch","drunken right hook","drunken left hook")

	var/damage = rand(0,6)

	if(atk_verb == "uppercut")
		if(prob(90))
			damage = 0
		else //10% chance to do a massive amount of damage
			damage = 14

	if(prob(50)) //they are drunk, they aren't going to land half of their hits
		damage = 0

	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to hit [D] with a [atk_verb]!</span>")
		return 1 //returns 1 so that they actually miss and don't switch to attackhand damage

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


	D.visible_message("<span class='danger'>[A] has hit [D] with a [atk_verb]!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a [atk_verb]!</span>")

	D.apply_damage(damage, BRUTE, null, armor_block)
	D.apply_effect(damage, STAMINA, armor_block)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.Paralyse(5)
			D.forcesay(GLOB.hit_appends)
		else if(D.lying)
			D.forcesay(GLOB.hit_appends)
	return 1

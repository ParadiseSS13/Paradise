/datum/martial_art/boxing
	name = "Boxing"

/datum/martial_art/boxing/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't disarm while boxing!</span>")
	return 1

/datum/martial_art/boxing/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't grab while boxing!</span>")
	return 1

/datum/martial_art/boxing/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	A.do_attack_animation(D)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + A.species.punchdamagelow
	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to hit [D] with a [atk_verb]!</span>")
		add_logs(A, D, "attempted to hit", atk_verb)
		return 0


	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)

	D.visible_message("<span class='danger'>[A] has hit [D] with a [atk_verb]!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a [atk_verb]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	add_logs(A, D, "punched")
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.SetSleeping(5)
			D.forcesay(hit_appends)
		else if(D.lying)
			D.forcesay(hit_appends)
	return 1

/datum/martial_art/drunk_brawling
	name = "Drunken Brawling"

/datum/martial_art/drunk_brawling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(70))
		A.visible_message("<span class='warning'>[A] tries to grab ahold of [D], but fails!</span>", \
							"<span class='warning'>You fail to grab ahold of [D]!</span>")
		return 1
	D.grabbedby(A,1)
	var/obj/item/weapon/grab/G = A.get_active_hand()
	if(G)
		D.visible_message("<span class='danger'>[A] grabs ahold of [D] drunkenly!</span>", \
								"<span class='userdanger'>[A] grabs ahold of [D] drunkenly!</span>")
	return 1

/datum/martial_art/drunk_brawling/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_logs(A, D, "punched")
	A.do_attack_animation(D)

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

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
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
			D.forcesay(hit_appends)
		else if(D.lying)
			D.forcesay(hit_appends)
	return 1

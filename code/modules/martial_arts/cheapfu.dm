/datum/martial_art/cheapfu
	name = "Fairly Useful Combat"
	weight = 4 // Higher than Wrestling, Boxing or being drunk, but overruled by actual martial arts
	has_explaination_verb = TRUE
	//combos = list(/datum/martial_combo/cheapfu/triple, /datum/martial_combo/cheapfu/mixup)

/datum/martial_art/cheapfu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/attack_verb = pick("hooks", "punches", "jabs")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [attack_verb] [D]!</span>", "<span class='userdanger'>[A] [attack_verb] you!</span>")
	D.apply_damage(5, BRUTE)
	D.apply_damage(10, STAMINA)
	add_attack_logs(A, D, "Melee attacked with [src] : Punched")
	return TRUE

/datum/martial_art/cheapfu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	if(IS_HORIZONTAL(A) && !IS_HORIZONTAL(D))
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		D.visible_message("<span class='danger'>[A] trips [D]!</span>", "<span class='userdanger'>[A] trips you!</span>")
		D.apply_damage(10, STAMINA)
		D.KnockDown(3 SECONDS)
		add_attack_logs(A, D, "Disarmed with martial-art [src] : Tripped")
	else
		disarm_act(A, D)
	return TRUE

/datum/martial_art/cheapfu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	for(var/obj/item/grab/G in A.grabbed_by) // And here we get the advantageous meat of this underdog
		if(G.state == GRAB_PASSIVE)
			D.visible_message("<span class='danger'>[A] shoves [D] away!</span>", "<span class='userdanger'>[A] shoves you away!</span>")
			D.Stun(1 SECONDS)
			disarm_act(A, D)
			add_attack_logs(A, D, "Broke grab with martial-art [src] : Passive Break")
			return TRUE
		if(G.state == GRAB_AGGRESSIVE)
			D.visible_message("<span class='danger'>[A] aggressively shoves [D] away!</span>", "<span class='userdanger'>[A] breaks your grab and aggressively shoves you away!</span>")
			D.Stun(1 SECONDS)
			disarm_act(A, D)
			D.apply_damage(10, STAMINA)
			A.apply_damage(10, STAMINA)
			add_attack_logs(A, D, "Broke grab with martial-art [src] : Aggressive break")
			return TRUE
		if(G.state == GRAB_NECK && A.getStaminaLoss() <= 80)
			if(prob(50))
				D.visible_message("<span class='danger'>[A] grabs and hurls [D] over [A.p_their()] shoulder!</span>", \
									"<span class='userdanger'>[A] grabs you and hurls you over [A.p_their()] shoulder!</span>")
				playsound(get_turf(A), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
				D.Stun(3 SECONDS)
				D.forceMove(A.loc)
				D.SpinAnimation(10, 1)
				D.KnockDown(5 SECONDS)
				D.apply_damage(30, STAMINA)
				add_attack_logs(A, D, "Broke grab with martial-art [src] : Shouldertoss break")
				return TRUE
			else
				D.visible_message("<span class='danger'>[A] attempts to grab [D], but can't get a proper hold!</span>", \
									"<span class='userdanger'>[A] attempts to grab you, but can't get a proper hold!</span>")
				playsound(get_turf(A), 'sound/weapons/punchmiss.ogg', 25, TRUE, 1)
				A.apply_damage(15, STAMINA)
				return FALSE
		if(G.state == GRAB_KILL && A.getStaminaLoss() <= 50 && A.getOxyLoss() <= 50)
			if(prob(20))
				D.visible_message("<span class='danger'>[A] manages to break free of [D]'s stranglehold and knocks them down!</span>", \
									"<span class='userdanger'>[A] manages to break free of your stranglehold and knocks you down!</span>")
				playsound(get_turf(A), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
				D.Stun(3 SECONDS)
				D.forceMove(A.loc)
				D.KnockDown(5 SECONDS)
				D.apply_damage(30, STAMINA)
				add_attack_logs(A, D, "Broke grab with martial-art [src] : Strangle break")
				return TRUE
			else
				D.visible_message("<span class='danger'>[A] attempts to struggle free from [D]'s stranglehold, but fails</span>!", \
									"<span class='userdanger'>[A] attempts to struggle free from your stranglehold, but fails!</span>")
				A.apply_damage(10, STAMINA)
				return FALSE
	if(!A.grabbed_by)
		grab_act(A, D)
		return TRUE

/datum/martial_art/cheapfu/explaination_header(user)
	to_chat(user, "<b><i>Placeholder.</i></b>")

/datum/martial_art/cheapfu/explaination_footer(user)
	to_chat(user, "<b><i>The best kind.</i></b>")

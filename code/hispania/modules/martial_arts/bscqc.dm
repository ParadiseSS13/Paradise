/datum/martial_art/bscqc
	name = "Blue Flame"
	block_chance = 85 // BLUE SHIELD? 85% DE PROTECCION
	has_explaination_verb = TRUE
//	block_color = COLOR_BLUE

/datum/martial_art/bscqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/picked_hit_type = pick("blue flamed", "fisted", "beated up")
	var/bonus_damage = 10
	if(D.IsWeakened() || D.resting || D.lying)
		bonus_damage += 3
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "stomps on")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(A.resting && !D.stat && !D.IsWeakened())
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.Weaken(0.1) // Por el bien de todo.
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bscqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/I = null
	I = D.get_active_hand()

	if(prob(65) && I)
		if(!D.stat || !D.IsWeakened())
			D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
								"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.drop_item())
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, BRUTE)
			add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
			return TRUE
	else
		. = ..() // Desarm Normal
	return FALSE

/datum/martial_art/bscqc/explaination_header(user)
	to_chat(user, "<b><i>You try to remember some of the basics of Blue Flame.</i></b>")

/datum/martial_art/bscqc/explaination_footer(user)
	to_chat(user, "<b><br>Our punchs are heavy as fuck, and we can do a legsweep while resting.</br><br>If you try to disarm somone with a weapon, there's an 65% of getting his item in our hands.</br><br>In addition, by having your throw mode on when being attacked, you enter in the <font color='[COLOR_BLUE]'>BLUESHIELD</font> mode, blocking 85% of the attacks.</br></b>")

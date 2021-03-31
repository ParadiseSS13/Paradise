/datum/martial_art/superhuman
	name = "Superhuman Physiology"
	block_chance = 100
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/superhuman/hammer_fist, /datum/martial_combo/superhuman/piston_kick, /datum/martial_combo/superhuman/foot_skewer, /datum/martial_combo/superhuman/brutal_barrage)

/datum/martial_art/superhuman/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, TRUE)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)

	return TRUE

/datum/martial_art/superhuman/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
	D.apply_damage(15, BRUTE, sharp = TRUE)
	var/atk_verb = pick("slashes", "claws", "slices", "rends", "lacerates")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
				"<span class='userdanger'>[A] [atk_verb] you!</span>")
	playsound(get_turf(D), 'sound/weapons/slice.ogg', 25, 1, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/superhuman/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	if(prob(60))
		if(!D.stat && !D.IsWeakened())
			D.visible_message("<span class='warning'>[A] slams into [D], knocking them to the ground!</span>", \
								"<span class='userdanger'>[A] slams into you, knocking you to the ground!</span>")
			playsound(get_turf(D), 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			D.apply_damage(5, BRUTE)
			D.Weaken(2)
			if(A != D)
				var/atom/throw_target = get_edge_target_turf(D, A.dir)
				D.throw_at(throw_target, 1, 14, A)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", "<span class='userdanger'>[A] attempted to disarm you!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/superhuman/explaination_header(user)
	to_chat(usr, "<b><i>We scour the memories of all those we have absorbed, remembering their fighting styles... </i></b>")

/datum/martial_art/superhuman/explaination_footer(user)
	to_chat(user, "<b><i>In addition, by having our throw mode on when being attacked, we enter an active defense mode where we block and sometimes even counter melee attacks done to us.</i></b>")

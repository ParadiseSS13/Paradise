/datum/martial_art/cqc
	name = "CQC"
	block_chance = 75
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/cqc/slam, /datum/martial_combo/cqc/restrain, /datum/martial_combo/cqc/consecutive)
	var/restraining = FALSE //used in cqc's disarm_act to check if the victim is being restrained
	var/static/list/areas_under_siege = typecacheof(list(/area/crew_quarters/kitchen,
														/area/crew_quarters/cafeteria,
														/area/crew_quarters/bar))

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"

/datum/martial_art/cqc/under_siege/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(!(is_type_in_typecache(A, areas_under_siege)))
		return FALSE
	return ..()

/datum/martial_art/cqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/cqc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	///Gotta put Help Combo Here

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)

	if(restraining && istype(G) && G.affecting == D)
		///Gotta put Grab Combo Here
	else
		restraining = FALSE

	return TRUE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = A.get_inactive_hand()
	if(restraining && istype(G) && G.affecting == D)
		///Gotta put Harm Combo Here
	else
		restraining = FALSE

	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "neck chopped", "gut punched", "Big Bossed")
	var/bonus_damage = 10
	if(D.IsWeakened() || D.resting || D.lying)
		bonus_damage += 3
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
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
		D.apply_damage(10, BRUTE)
		D.Weaken(1)
		D.adjustStaminaLoss(40)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = A.get_inactive_hand()
	if(restraining && istype(G) && G.affecting == D)
		for(var/stage = 1, stage<=3, stage++)
			switch(stage)
				if(1)
					to_chat(A, "<span class='notice'>You lock your arms tighter around [D]'s neck!</span>")
					D.Jitter(4)
				if(2)
					to_chat(A, "<span class='notice'You notice [D]'s struggles becoming weaker!</span>")
					D.visible_message("<span class='warning'>[A] drags [D] down to the ground!</span>")
					D.AdjustSilence(5)
				if(3)
					to_chat(A, "<span class='notice'>You drag [D]'s limp body to the ground!</span>")
					D.visible_message("<span class='danger'>[A] knocks out [D]!</span>")
					D.AdjustSleeping(15)
			if(!do_mob(A, D, 30))
				to_chat(A, "<span class='warning'>You lose your chokehold on [D]!</span>")
				return
		if(G.state < GRAB_NECK)
			G.state = GRAB_NECK
		return TRUE
	else
		restraining = FALSE

	var/obj/item/I = null

	if(prob(65))
		if(!D.stat || !D.IsWeakened() || !restraining)
			I = D.get_active_hand()
			D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
								"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
			if(D.unEquip(I) && !(QDELETED(I) || (I.flags & ABSTRACT)))
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, BRUTE)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", "<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/explaination_header(user)
	to_chat(user, "<b><i>You try to remember some of the basics of CQC.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")

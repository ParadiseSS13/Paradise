/datum/martial_art/cqc
	name = "CQC"
	block_chance = 75
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/cqc/slam, /datum/martial_combo/cqc/kick, /datum/martial_combo/cqc/restrain, /datum/martial_combo/cqc/pressure, /datum/martial_combo/cqc/consecutive)
	var/restraining = FALSE //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/static/list/areas_under_siege = typecacheof(list(/area/crew_quarters/kitchen,
														/area/crew_quarters/cafeteria,
														/area/crew_quarters/bar,
														/area/syndicate/unpowered/syndicate_space_base/bar,
														/area/syndicate/unpowered/syndicate_space_base/kitchen
														))

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"

/datum/martial_art/cqc/under_siege/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(!(is_type_in_typecache(A, areas_under_siege)))
		return FALSE
	return ..()

/datum/martial_art/cqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)

	return TRUE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/gender_hit = genderize_ru(A.gender,"","а","о","и")
	var/picked_hit_type = pick("ударил[gender_hit] техникой CQC", "пробил[gender_hit] рубящим ударом по шее", "пнул[gender_hit]", "ударил[gender_hit] в колено", "пробил[gender_hit]", "ударил[gender_hit] в нутро", "доминировал[gender_hit] как большой босс над")
	var/bonus_damage = 13
	if(D.IsWeakened() || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "пробил[gender_hit] рубящим ударом по шее"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "пнул[gender_hit]" || picked_hit_type == "пробил[gender_hit]"|| picked_hit_type == "пробил[gender_hit] рубящим ударом по шее"|| picked_hit_type == "ударил[gender_hit] в колено")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] вас!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(A.resting && !D.stat && !D.IsWeakened())
		D.visible_message("<span class='warning'>[A] выбил[genderize_ru(A.gender,"","а","о","и")] ногу [D]!", \
							"<span class='userdanger'>[A] выбил[genderize_ru(A.gender,"","а","о","и")] вам ногу!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Weaken(1)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = A.get_inactive_hand()
	if(restraining && istype(G) && G.affecting == D)
		D.visible_message("<span class='danger'>[A] бер[pluralize_ru(A.gender,"ет","ут")] [D] в удушающий захват!</span>", \
							"<span class='userdanger'>[A] взял[genderize_ru(A.gender,"","а","о","и")] вас в удушающий захват</span>")
		D.SetSleeping(10)
		restraining = FALSE
		if(G.state < GRAB_NECK)
			G.state = GRAB_NECK
		return TRUE
	else
		restraining = FALSE

	var/obj/item/I = null

	if(prob(50))
		if(!D.stat || !D.IsWeakened() || !restraining)
			I = D.get_active_hand()
			D.visible_message("<span class='warning'>[A] ударя[pluralize_ru(A.gender,"ет","ют")] кулаком по челюсти [D]!</span>", \
								"<span class='userdanger'>[A] ударил[genderize_ru(A.gender,"","а","о","и")] в челюсть, дезоориентируя вас!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.drop_item())
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, BRUTE)
	else
		D.visible_message("<span class='danger'>[A] попытал[genderize_ru(A.gender,"ся","ась","ось","ись")] обезоружить [D]!</span>", "<span class='userdanger'>[A] попытал[genderize_ru(A.gender,"ся","ась","ось","ись")] обезоружить [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/explaination_header(user)
	to_chat(user, "<b><i>Вы пытаетесь вспомнить основы CQC.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b><i>В режиме броска, когда вас атакуют, вы переходите в режим активной защиты, имея шанс заблокировать и контратаковать направленные на вас удары.</i></b>")

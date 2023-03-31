/datum/martial_art/cqc
	name = "CQC"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/cqc/slam, /datum/martial_combo/cqc/kick, /datum/martial_combo/cqc/restrain, /datum/martial_combo/cqc/pressure, /datum/martial_combo/cqc/consecutive)
	var/restraining = FALSE //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/chokehold_active = FALSE //Then uses this to determine if the restrain actually goes anywhere
	var/static/list/areas_under_siege = typecacheof(list(/area/crew_quarters/kitchen,
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

/datum/martial_art/cqc/proc/drop_chokehold()
	chokehold_active = FALSE

/datum/martial_art/cqc/proc/start_chokehold(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
						"<span class='userdanger'>[A] puts you into a chokehold!</span>")
	add_attack_logs(A, D, "Put into a chokehold with martial-art [src]", ATKLOG_ALL)
	chokehold_active = TRUE
	var/damage_multiplier = 1 + A.getStaminaLoss() / 100 //The chokehold is more effective the more tired the target is.
	while(do_mob(A, D, 2 SECONDS) && chokehold_active)
		D.apply_damage(10 * damage_multiplier, OXY)
		D.LoseBreath(3 SECONDS)
		if(D.getOxyLoss() >= 50 || D.health <= 20)
			D.visible_message("<span class ='danger>[A] puts [D] to sleep!</span>", \
						"<span class='userdanger'>[A] knocks you out cold!</span>")
			D.SetSleeping(40 SECONDS)
			drop_chokehold()

	drop_chokehold()
	drop_restraining() //If the chokehold failed, they slip out of your grip

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		D.Immobilize(1 SECONDS) //Catch them off guard, but not long enough to do too much nonsense
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : grabbed", ATKLOG_ALL)

	return TRUE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "neck chopped", "gut punched", "Big Bossed")
	var/bonus_damage = 20
	if(IS_HORIZONTAL(D))
		bonus_damage += 10 //Being stomped on doesn't feel good.
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, STAMINA)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 10, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 10, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
						"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(IS_HORIZONTAL(A) && !IS_HORIZONTAL(D))
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 10, 1, -1)
		D.KnockDown(5 SECONDS)
		A.SetKnockDown(0 SECONDS)
		A.resting = FALSE
		A.stand_up() //Quickly get up like the cool dude you are.
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = A.get_inactive_hand()
	if(restraining && istype(G) && G.affecting == D && !chokehold_active)
		start_chokehold(A, D)
		return TRUE
	else
		drop_restraining()

	if(!IS_HORIZONTAL(D) || !restraining)
		D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
							"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 5, TRUE, -1)
		D.SetSlur(4 SECONDS)
		D.apply_damage(15, STAMINA)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", "<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 5, 1, -1)

	add_attack_logs(A, D, "Disarmed with martial-art [src]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/explaination_header(user)
	to_chat(user, "<b><i>You try to remember some of the basics of CQC.</i></b>")

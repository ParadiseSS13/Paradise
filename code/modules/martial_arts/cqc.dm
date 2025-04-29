/datum/martial_art/cqc
	name = "CQC"
	weight = 6
	has_explaination_verb = TRUE
	can_parry = TRUE
	combos = list(/datum/martial_combo/cqc/slam, /datum/martial_combo/cqc/kick, /datum/martial_combo/cqc/restrain, /datum/martial_combo/cqc/pressure, /datum/martial_combo/cqc/consecutive)
	var/restraining = FALSE //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/chokehold_active = FALSE //Then uses this to determine if the restrain actually goes anywhere
	var/static/list/areas_under_siege = typecacheof(list(/area/station/service/kitchen,
														/area/station/service/bar))

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"

/datum/martial_art/cqc/under_siege/teach(mob/living/carbon/human/H, make_temporary)
	RegisterSignal(H, COMSIG_AREA_ENTERED, PROC_REF(kitchen_check))
	return ..()

/datum/martial_art/cqc/under_siege/remove(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_AREA_ENTERED)
	. = ..()

/datum/martial_art/cqc/under_siege/proc/kitchen_check(mob/living/carbon/human/H, area/entered_area)
	SIGNAL_HANDLER //COMSIG_AREA_ENTERED
	if(!is_type_in_typecache(entered_area, areas_under_siege))
		var/list/held_items = list(H.get_active_hand(), H.get_inactive_hand())
		for(var/obj/item/slapper/parry/smacking_hand in held_items)
			qdel(smacking_hand)
		can_parry = FALSE
		weight = 0
	else
		can_parry = TRUE
		weight = 5

/datum/martial_art/cqc/under_siege/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(!(is_type_in_typecache(A, areas_under_siege)))
		return FALSE
	return ..()

/datum/martial_art/cqc/teach(mob/living/carbon/human/H, make_temporary)
	var/found = FALSE
	for(var/datum/martial_art/cqc/under_siege/M in H.mind.known_martial_arts)
		M.remove(H)
	for(var/datum/action/D in H.actions)
		if(istype(D, /datum/action/defensive_stance))
			found = TRUE
			break
	if(!found)
		var/datum/action/defensive_stance/defensive = new /datum/action/defensive_stance()
		defensive.Grant(H)
	return ..()

/datum/martial_art/cqc/remove(mob/living/carbon/human/H)
	for(var/datum/action/defensive_stance/defensive in H.actions)
		defensive.Remove(H)
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
	var/damage_multiplier = 1 + D.getStaminaLoss() / 100 //The chokehold is more effective the more tired the target is.
	while(do_mob(A, D, 2 SECONDS, hidden = TRUE) && chokehold_active)
		D.apply_damage(10 * damage_multiplier, OXY)
		D.LoseBreath(3 SECONDS)
		if(D.getOxyLoss() >= 50 || D.health <= 20)
			D.visible_message("<span class='danger'>[A] puts [D] to sleep!</span>", \
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
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 10, TRUE, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 10, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
						"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(IS_HORIZONTAL(A) && !IS_HORIZONTAL(D))
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 10, TRUE, -1)
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
		playsound(D, 'sound/weapons/punchmiss.ogg', 5, TRUE, -1)

	add_attack_logs(A, D, "Disarmed with martial-art [src]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/explaination_header(user)
	to_chat(user, "<b><i>You try to remember some of the basics of CQC.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b>Your slaps hit considerably harder, and allow you to parry incoming melee attacks.</b>")

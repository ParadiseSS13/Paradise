//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	deflection_chance = 100
	reroute_deflection = TRUE
	no_guns = TRUE
	no_guns_message = "Use of ranged weaponry would bring dishonor to the clan."
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/sleeping_carp/crashing_kick, /datum/martial_combo/sleeping_carp/kneehaul, /datum/martial_combo/sleeping_carp/gnashing_teeth)

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>",
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(rand(10,15), BRUTE)
<<<<<<< HEAD
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
=======
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(50))
		A.say(pick("HUAH!", "HYA!", "CHOO!", "WUO!", "KYA!", "HUH!", "HIYOH!", "CARP STRIKE!", "CARP BITE!"))
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[D] stumbles and falls!</span>", "<span class='userdanger'>The blow sends you to the ground!</span>")
		D.Weaken(4)
>>>>>>> upstream/master
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary)
	. = ..()
	H.faction |= "carp"// :D

/datum/martial_art/the_sleeping_carp/remove(mob/living/carbon/human/H)
	. = ..()
	H.faction -= "carp"// :C

/datum/martial_art/the_sleeping_carp/explaination_footer(user)
	to_chat(user, "<b><i>In addition, by having your throw mode on when being shot at, you enter an active defense mode where you will block and deflect all projectiles fired at you!</i></b>")

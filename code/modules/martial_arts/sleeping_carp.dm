//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	deflection_chance = 100
	no_guns = TRUE
	no_guns_message = "Use of ranged weaponry would bring dishonor to the clan."
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/sleeping_carp/wrist_wrench, /datum/martial_combo/sleeping_carp/back_kick, /datum/martial_combo/sleeping_carp/stomach_knee, /datum/martial_combo/sleeping_carp/head_kick, /datum/martial_combo/sleeping_carp/elbow_drop)

/datum/martial_art/the_sleeping_carp/can_use(mob/living/carbon/human/H)
	if(length(H.reagents.addiction_list))
		return FALSE
	return ..()

/datum/martial_art/the_sleeping_carp/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
	return TRUE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(rand(10,15), BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(50))
		A.say(pick("HUAH!", "HYA!", "CHOO!", "WUO!", "KYA!", "HUH!", "HIYOH!", "CARP STRIKE!", "CARP BITE!"))
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[D] stumbles and falls!</span>", "<span class='userdanger'>The blow sends you to the ground!</span>")
		D.Weaken(2)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

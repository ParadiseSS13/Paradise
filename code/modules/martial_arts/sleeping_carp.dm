//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	weight = 9
	name = "The Sleeping Carp"
	deflection_chance = 100
	reroute_deflection = TRUE
	no_guns = TRUE
	no_guns_message = "Use of ranged weaponry would bring dishonor to the clan."
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/sleeping_carp/crashing_kick, /datum/martial_combo/sleeping_carp/keelhaul, /datum/martial_combo/sleeping_carp/gnashing_teeth)

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>",
					"<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(rand(10, 15), BRUTE, A.zone_selected)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary)
	. = ..()
	H.faction |= "carp"// :D
	to_chat(H, "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! \
					Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles directed toward you when in throw mode. \
					However, you are also unable to use any ranged weaponry. \
					You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>")
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, "<span class='warning'>You feel the knowledge of the scroll in your mind, yet reject its more violent teachings. \
					You will instead deflect projectiles into the ground.")
	H.RegisterSignal(H, COMSIG_CARBON_THROWN_ITEM_CAUGHT, TYPE_PROC_REF(/mob/living/carbon, throw_mode_on))

/datum/martial_art/the_sleeping_carp/remove(mob/living/carbon/human/H)
	. = ..()
	H.faction -= "carp"// :C
	H.UnregisterSignal(H, COMSIG_CARBON_THROWN_ITEM_CAUGHT)

/datum/martial_art/the_sleeping_carp/explaination_footer(user)
	to_chat(user, "<b><i>In addition, by having your throw mode on when being shot at, you enter an active defensive mode where you will block and deflect all projectiles fired at you!</i></b>")

/datum/martial_art/the_sleeping_carp/try_deflect(mob/user)
	return user.in_throw_mode && ..() // in case an admin wants to var edit carp to have less deflection chance

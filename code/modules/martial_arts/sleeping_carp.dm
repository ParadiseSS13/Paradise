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
	D.visible_message(SPAN_DANGER("[A] [atk_verb] [D]!"),
					SPAN_USERDANGER("[A] [atk_verb] you!"))
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

/obj/item/sleeping_carp_scroll
	name = "mysterious scroll"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	new_attack_chain = TRUE

/obj/item/sleeping_carp_scroll/activate_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return ..()

	if(!user.mind)
		return ITEM_INTERACT_COMPLETE

	if(IS_CHANGELING(user) || IS_MINDFLAYER(user))
		to_chat(user, SPAN_WARNING("We try multiple times, but we are not able to comprehend the contents of the scroll!"))
		return ITEM_INTERACT_COMPLETE

	if(user.mind.has_antag_datum(/datum/antagonist/vampire))
		to_chat(user, SPAN_WARNING("Your blood lust distracts you too much to be able to concentrate on the contents of the scroll!"))
		return ITEM_INTERACT_COMPLETE

	else if(IS_HERETIC(user))
		to_chat(user, SPAN_HIEROPHANT_WARNING("You and everyone else are already dreaming. You need to wake up, not sleep more..."))
		return ITEM_INTERACT_COMPLETE

	var/datum/martial_art/the_sleeping_carp/theSleepingCarp = new(null)
	theSleepingCarp.teach(user)
	user.drop_item_to_ground(src, TRUE)
	visible_message(SPAN_WARNING("[src] lights up in fire and quickly burns to ash."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_COMPLETE

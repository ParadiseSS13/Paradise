/mob/living/basic/nian_caterpillar
	name = "nian caterpillar"
	desc = "Fluffier than clouds."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	icon_resting = "mothroach_sleep"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	butcher_results = list(/obj/item/food/meat = 1)
	minimum_survivable_temperature = 0

	blood_color = "#b9ae9c"

	maxHealth = 50
	health = 50
	speed = 0.75

	// What they sound like
	voice_name = "nian caterpillar"
	speak_emote = list("flutters", "chitters", "chatters")

	// Special verbs for when someone interacts with a caterpillar
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "kicks"
	response_harm_simple = "kicks"

	// Xenobiology and cargo are the only ways to get the caterpillar.
	gold_core_spawnable = FRIENDLY_SPAWN

	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	melee_damage_lower = 5
	melee_damage_upper = 8
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'

	holder_type = /obj/item/holder/nian_caterpillar

	ai_controller = /datum/ai_controller/basic_controller/mothroach

	var/list/innate_actions = list(
		/datum/action/innate/nian_caterpillar_emerge,
	)

	/// List of stuff that we want to eat
	var/static/list/edibles = list(
		/obj/item/food,
	)
	/// The amount of nutrition the nian caterpillar needs to evolve, default is 500.
	var/nutrition_need = 500

/mob/living/basic/nian_caterpillar/Initialize(mapload)
	. = ..()
	real_name = name
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_eating, heal_amt_ = 2, food_types_ = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))
	add_language("Tkachi")
	grant_actions_by_list(innate_actions)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(check_full))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(consume))

/mob/living/basic/nian_caterpillar/proc/evolve(obj/structure/moth_cocoon/C, datum/mind/M)
	if(stat != CONSCIOUS)
		return FALSE

	// A changeling caterpillar shouldn't be restricted from evolving.
	// A caterpillar needs to consume food-- similar to a dioan nymph --to evolve.
	if((nutrition < nutrition_need) && !IS_CHANGELING(M))
		to_chat(src, "<span class='warning'>You need to binge on food in order to have the energy to evolve...</span>")
		return

	if(master_commander)
		to_chat(src, "<span class='userdanger'>As you evolve, your mind grows out of it's restraints. You are no longer loyal to [master_commander]!</span>")

	// Worme is the lesser form of nian. The caterpillar evolves into this lesser form.
	var/mob/living/carbon/human/nian_worme/adult = new(get_turf(loc))

	if(istype(loc, /obj/item/holder/nian_caterpillar))
		var/turf/cocoon_turf = get_turf(loc)
		qdel(loc)
		forceMove(cocoon_turf)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()
	adult.name = name
	adult.real_name = name

	if(M)
		// Mind transfer to new worme.
		M.transfer_to(adult)
		// [Caterpillar -> worme -> nian] is from xenobio (or cargo) and does not give vampires usuble blood and cannot be converted by cult.
		ADD_TRAIT(adult.mind, TRAIT_XENOBIO_SPAWNED_HUMAN, ROUNDSTART_TRAIT)

	// Worme is placed into cacoon.
	adult.forceMove(C)
	C.preparing_to_emerge = TRUE
	adult.apply_status_effect(STATUS_EFFECT_COCOONED)
	adult.KnockOut() // Zzzz
	adult.create_log(MISC_LOG, "has woven a cocoon")

	// For any random generated names. This is for when a new nian caterpillar is spawned.
	// [ nian caterpillar (042) ] etc.
	if(findtext(adult.real_name, "nian caterpillar"))
		adult.real_name = adult.dna.species.get_random_name()
		adult.name = adult.real_name
	for(var/obj/item/W in contents)
		drop_item_to_ground(W)

	qdel(src)
	return TRUE

/mob/living/basic/nian_caterpillar/proc/check_full(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_PRE_EAT
	if(nutrition >= nutrition_need) // Prevents griefing by overeating food items without evolving.
		to_chat(src, "<span class='warning'>You're too full to consume this! Perhaps it's time to grow bigger...</span>")
		return COMSIG_MOB_TERMINATE_EAT


/mob/living/basic/nian_caterpillar/proc/consume(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_ATE
	if(potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter") < 1)
		adjust_nutrition(2)
	else
		adjust_nutrition((potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter")) * 2)

/mob/living/basic/nian_caterpillar/attack_hand(mob/living/carbon/human/M)
	// Let people pick the little buggers up.
	if(M.a_intent != INTENT_HELP)
		return ..()
	if(isrobot(M))
		M.visible_message("<span class='notice'>[M] playfully boops [src] on the head!</span>", "<span class='notice'>You playfully boop [src] on the head!</span>")
	else
		get_scooped(M)

/mob/living/basic/nian_caterpillar/attacked_by(obj/item/I, mob/living/user)
	if(..())
		return FINISH_ATTACK
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		gib() // Commit die.

/mob/living/basic/nian_caterpillar/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()


/datum/action/innate/nian_caterpillar_emerge
	name = "Evolve"
	desc = "Weave a cocoon around yourself to evolve into a greater form. The worme."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon1"

/datum/action/innate/nian_caterpillar_emerge/proc/emerge(obj/structure/moth_cocoon/C)
	for(var/mob/living/carbon/human/H in C)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)
	C.preparing_to_emerge = FALSE
	qdel(C)

/datum/action/innate/nian_caterpillar_emerge/Activate()
	var/mob/living/basic/nian_caterpillar/user = owner

	user.visible_message("<span class='notice'>[user] begins to hold still and concentrate on weaving a cocoon...</span>", "<span class='notice'>You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds, and you must hold still.)</span>")
	if(do_after(user, COCOON_WEAVE_DELAY, FALSE, user))
		var/obj/structure/moth_cocoon/C = new(get_turf(user))
		var/datum/mind/H = user.mind
		user.evolve(C, H)
		addtimer(CALLBACK(src, PROC_REF(emerge), C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)

/datum/ai_controller/basic_controller/mothroach
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_EAT_FOOD_COOLDOWN = 1 MINUTES, // Moth wants to eat, but not too fast.
		BB_SEARCH_RANGE = 3,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED | AI_FLAG_PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/moth_caterpillar,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food/nian_caterpillar,
	)

/datum/ai_planning_subtree/find_food/nian_caterpillar

/datum/ai_planning_subtree/find_food/nian_caterpillar/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/nian_caterpillar/caterpillar = controller.pawn
	if(caterpillar.nutrition >= caterpillar.nutrition_need)
		// Put eating on cooldown so it doesn't keep trying to eat.
		var/food_cooldown = controller.blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
		controller.set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/ai_planning_subtree/random_speech/moth_caterpillar
	speech_chance = 2
	emote_hear = list("flutters.", "chitters.", "chatters.")
	emote_see = list("flutters.", "chitters.", "chatters.")

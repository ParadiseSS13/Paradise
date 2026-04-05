/mob/living/basic/isopod
	name = "ahuitz"
	desc = "A large isopod from Kelune that is usually kept as a ranch animal."
	icon = 'icons/mob/animal.dmi'
	icon_state = "ahuitz"
	icon_living = "ahuitz"
	icon_dead = "ahuitz_dead"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	butcher_results = list(/obj/item/food/meat = 1)
	minimum_survivable_temperature = 0

	maxHealth = 75
	health = 75
	speed = 2

	// What they sound like
	voice_name = "ahuitz"
	speak_emote = list("chitters", "chatters", "clicks", "clacks")

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
	melee_damage_upper = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'

	ai_controller = /datum/ai_controller/basic_controller/isopod

	/// List of stuff that we want to eat
	var/static/list/edibles = list(
		/obj/item/food,
	)
	/// Max the bug can eat
	var/max_nutrition = 700

/mob/living/basic/isopod/Initialize(mapload)
	. = ..()
	real_name = name
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_eating, heal_amt_ = 2, food_types_ = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(check_full))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(consume))

/mob/living/basic/isopod/examine_more(mob/user)
	. = ..()
	. += "Ahuitz are a species incredibly similar to earth isopods - being crustaceans that are commonly found in Kelune’s oceans. Well suited for cold environments and requiring little \
	food these creatures are often kept as pets or for aquatic ranching. They have a long history of being pseudo selectively bred. With those intended to be pets often being bred for \
	bright colors or smaller sizes. They are commonly served in a stew alongside whatever could be foraged, farmed, fished or hunted for. The Ahuitz have little meat relative to their weight \
	but are very easy to fish up due to their slow speed and inquisitive nature."

/mob/living/basic/isopod/proc/check_full(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_PRE_EAT
	if(nutrition >= max_nutrition) // Prevents griefing by overeating food items without evolving.
		to_chat(src, SPAN_WARNING("You're too full to consume this!"))
		return COMSIG_MOB_TERMINATE_EAT

/mob/living/basic/isopod/proc/consume(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_ATE
	var/food_reagents = potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter") + potential_food.reagents.get_reagent_amount("protein") + potential_food.reagents.get_reagent_amount("vitamin")
	if(food_reagents < 1)
		adjust_nutrition(2)
	else
		adjust_nutrition(food_reagents * 2)
	butcher_results = list(/obj/item/food/meat = (MODULUS(nutrition, 100)))

/mob/living/basic/isopod/smol
	name = "deverka"
	desc = "A small isopod from Kelune that is usually kept as a pet."
	icon_state = "deverka"
	icon_living = "deverka"
	icon_dead = "deverka_dead"
	maxHealth = 30
	health = 30
	melee_damage_lower = 1
	melee_damage_upper = 5
	ai_controller = /datum/ai_controller/basic_controller/isopod/smol
	max_nutrition = 400

/mob/living/basic/isopod/smol/consume(datum/source, obj/item/potential_food)
	var/food_reagents = potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter") + potential_food.reagents.get_reagent_amount("protein") + potential_food.reagents.get_reagent_amount("vitamin")
	if(food_reagents < 1)
		adjust_nutrition(2)
	else
		adjust_nutrition(food_reagents * 2)

/datum/ai_controller/basic_controller/isopod
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_EAT_FOOD_COOLDOWN = 1 MINUTES, // Isopod wants to eat, but not too fast.
		BB_SEARCH_RANGE = 3,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED | AI_FLAG_PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/isopod,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food/isopod,
	)

/datum/ai_controller/basic_controller/isopod/smol
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_EAT_FOOD_COOLDOWN = 4 MINUTES, // Smol isopod wants to eat, but not fast at all.
		BB_SEARCH_RANGE = 3,
	)

/datum/ai_planning_subtree/find_food/isopod

/datum/ai_planning_subtree/find_food/isopod/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/isopod/pod = controller.pawn
	if(pod.nutrition >= pod.max_nutrition)
		// Put eating on cooldown so it doesn't keep trying to eat.
		var/food_cooldown = controller.blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
		controller.set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/ai_planning_subtree/random_speech/isopod
	speech_chance = 2
	sound = list('sound/creatures/chitter.ogg', 'sound/effects/kidanclack.ogg', 'sound/effects/kidanclack2.ogg')
	emote_hear = list("clicks.", "chitters.", "chatters.", "clacks.")
	emote_see = list("clicks.", "chitters.", "chatters.", "clacks.")


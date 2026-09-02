/datum/ai_planning_subtree/random_speech/cow
	speech_chance = 2
	speak = list("Moo?", "Moo", "MOOOOOO")
	speak_verbs = list("moos", "moos hauntingly")
	sound = list('sound/creatures/cow.ogg')
	emote_hear = list("brays.")
	emote_see = list("shakes her head.")

/datum/ai_controller/basic_controller/cow
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/cow,
	)

/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	ai_controller = /datum/ai_controller/basic_controller/cow
	speak_emote = list("moos","moos hauntingly")
	speed = 1.1
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	unintelligble_phrases = list("Moo?", "Moo", "MOOOOOOO")
	unintelligble_speak_verbs = list("moos", "moos hauntingly")

	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST

	/// what this cow munches on
	var/list/food_types = list(/obj/item/food/grown/wheat)

	var/obj/item/udder/cow/udder = null

/mob/living/basic/cow/Initialize(mapload)
	. = ..()
	udder = new()
	AddComponent(/datum/component/tippable, \
		tip_time = 0.5 SECONDS, \
		untip_time = 0.5 SECONDS, \
		self_right_time = rand(25 SECONDS, 50 SECONDS), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_cow_tipped)))

	// Have all eating components share the same exact list per mob subtype
	var/static/list/static_food_types
	if(!static_food_types)
		static_food_types = food_types.Copy()

	AddElement(/datum/element/basic_eating, food_types_ = static_food_types)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SHOE)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(static_food_types))

/mob/living/basic/cow/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/basic/cow/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return ITEM_INTERACT_COMPLETE

/mob/living/basic/cow/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/basic/cow/valid_respawn_target_for(mob/user)
	return TRUE

/*
 * Proc called via callback after the cow is tipped by the tippable component.
 * Begins a timer for us pleading for help.
 *
 * tipper - the mob who tipped us
 */
/mob/living/basic/cow/proc/after_cow_tipped(mob/living/carbon/tipper)
	addtimer(CALLBACK(src, PROC_REF(set_tip_react_blackboard), tipper), rand(10 SECONDS, 20 SECONDS))

/*
 * We've been waiting long enough, we're going to tell our AI to begin pleading.
 *
 * tipper - the mob who originally tipped us
 */
/mob/living/basic/cow/proc/set_tip_react_blackboard(mob/living/carbon/tipper)
	if(!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, TIPPED_OVER) || !ai_controller)
		return
	ai_controller.set_blackboard_key(BB_BASIC_MOB_TIP_REACTING, TRUE)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_TIPPER, tipper)

/mob/living/basic/cow/betsy
	name = "Betsy"
	real_name = "Betsy"

// Don't deprive the chef of their prized cow
/mob/living/basic/cow/betsy/valid_respawn_target_for(mob/user)
	return FALSE

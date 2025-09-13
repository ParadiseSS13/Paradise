/mob/living/basic/chick
	name = "chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("cheeps")
	density = FALSE
	butcher_results = list(/obj/item/food/meat/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	health = 3
	maxHealth = 3
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	holder_type = /obj/item/holder/chicken
	can_hide = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	step_type = FOOTSTEP_MOB_CLAW
	ai_controller = /datum/ai_controller/basic_controller/chicken/chick
	/// How grown up are we?
	var/amount_grown = 0

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	scatter_atom()
	/// Basic mobs need a language otherwise their speech is garbled
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/chick/scatter_atom(x_offset, y_offset)
	pixel_x = rand(-6, 6) + x_offset
	pixel_y = rand(0, 10) + y_offset

/mob/living/basic/chick/Life(seconds, times_fired)
	. = ..()
	if(.)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			var/mob/living/basic/chicken/C = new /mob/living/basic/chicken(loc)
			if(name != initial(name))
				C.name = name
			if(mind)
				mind.transfer_to(C)

			for(var/atom/movable/AM in contents)
				AM.forceMove(C)

			qdel(src)

/mob/living/basic/chick/valid_respawn_target_for(mob/user)
	return TRUE

/mob/living/basic/chick/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

#define MAX_CHICKENS 50
GLOBAL_VAR_INIT(chicken_count, 0)

/mob/living/basic/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak_emote = list("clucks", "croons")
	density = FALSE
	butcher_results = list(/obj/item/food/meat/chicken = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	friendly_verb_continuous = "headbutts"
	friendly_verb_simple = "headbutt"
	health = 15
	maxHealth = 15
	ventcrawler = VENTCRAWLER_ALWAYS

	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	holder_type = /obj/item/holder/chicken
	can_hide = TRUE

	gold_core_spawnable = FRIENDLY_SPAWN
	step_type = FOOTSTEP_MOB_CLAW
	ai_controller = /datum/ai_controller/basic_controller/chicken

	/// What type of egg do we lay?
	var/egg_type = /obj/item/food/egg
	/// How many eggs do we have left to lay?
	var/eggsleft = 0
	/// Are the eggs fertile?
	var/eggsFertile = TRUE
	/// What can the chicken eat?
	var/static/list/edibles = list(
		/obj/item/food/grown/wheat,
	)
	/// What color chicken are we?
	var/body_color
	/// Prefix for icon determining colors
	var/icon_prefix = "chicken"
	/// What colors can chickens be?
	var/list/validColors = list("brown", "black", "white")
	/// What message to play when laying an egg?
	var/list/layMessage = EGG_LAYING_MESSAGES

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "cluck")
	// Have all eating components share the same exact list per mob subtype
	var/static/list/static_food_types
	if(!static_food_types)
		static_food_types = edibles.Copy()
	AddElement(/datum/element/basic_eating, food_types_ = static_food_types)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_eat))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))
	scatter_atom()
	update_appearance(UPDATE_ICON_STATE)
	GLOB.chicken_count++
	/// Basic mobs need a language otherwise their speech is garbled
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/chicken/scatter_atom(x_offset, y_offset)
	pixel_x = rand(-6, 6) + x_offset
	pixel_y = rand(0, 10) + y_offset

/mob/living/basic/chicken/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	GLOB.chicken_count--

/mob/living/basic/chicken/proc/on_eat(atom/target, mob/feeder)
	SIGNAL_HANDLER // COMSIG_MOB_PRE_EAT
	if(stat == CONSCIOUS && eggsleft < 8)
		eggsleft += rand(1, 4)
	else
		to_chat(feeder, "<span class='warning'>[src] doesn't seem hungry!</span>")
		return COMSIG_MOB_CANCEL_EAT

/mob/living/basic/chicken/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

/mob/living/basic/chicken/Life(seconds, times_fired)
	. = ..()
	if((. && prob(3) && eggsleft > 0) && egg_type)
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.scatter_atom()
		if(eggsFertile)
			if(GLOB.chicken_count < MAX_CHICKENS && prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/food/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/basic/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/basic/chicken/valid_respawn_target_for(mob/user)
	return TRUE

/mob/living/basic/chicken/clucky
	name = "Commander Clucky"
	real_name = "Commander Clucky"

/mob/living/basic/chicken/clucky/valid_respawn_target_for(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/basic/chicken/kentucky
	name = "Kentucky"
	real_name = "Kentucky"

/mob/living/basic/chicken/kentucky/valid_respawn_target_for(mob/user)
	return FALSE

/mob/living/basic/chicken/featherbottom
	name = "Featherbottom"
	real_name = "Featherbottom"

/mob/living/basic/chicken/featherbottom/valid_respawn_target_for(mob/user)
	return FALSE

/datum/ai_controller/basic_controller/chicken
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/chicken,
	)

/datum/ai_planning_subtree/random_speech/chicken
	speech_chance = 15 // really talkative ladies
	speak = list("Cluck!", "BWAAAAARK BWAK BWAK BWAK!", "Bwaak bwak.")
	sound = list('sound/creatures/clucks.ogg', 'sound/creatures/bagawk.ogg')
	emote_hear = list("clucks.", "croons.")
	emote_see = list("pecks at the ground.", "flaps her wings viciously.")

/datum/ai_controller/basic_controller/chicken/chick
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/chick,
	)

/datum/ai_planning_subtree/random_speech/chick
	speech_chance = 15
	speak = list("Cherp.", "Cherp?", "Chirrup.", "Cheep!")
	sound = list('sound/creatures/chick_peep.ogg')
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground", "flaps its tiny wings")

#undef MAX_CHICKENS

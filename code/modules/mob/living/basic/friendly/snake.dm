/mob/living/basic/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/effects/bite.ogg'
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"
	faction = list("hostile", "jungle")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_REPTILE
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/snake
	/// How much poison?
	var/poison_per_bite = 0
	/// What poison
	var/poison_type = "toxin"
	/// List of stuff (mice) that we want to eat
	var/static/list/edibles = list(
		/mob/living/basic/mouse,
	)

/mob/living/basic/snake/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_eating, heal_amt_ = 2, food_types_ = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/mob/living/basic/snake/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && poison_per_bite > 0)
			L.reagents.add_reagent(poison_type, poison_per_bite)

/// Snakes are primarily concerned with getting those tasty, tasty mice, but aren't afraid to strike back at those who attack them
/datum/ai_controller/basic_controller/snake
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/snake,
	)

/datum/ai_planning_subtree/random_speech/snake
	speech_chance = 5
	speak = list("hsssss", "sssSSsssss...", "hiisssss")
	sound = list('sound/creatures/snake_hissing1.ogg', 'sound/creatures/snake_hissing2.ogg')
	emote_hear = list("hisses.")
	emote_see = list("slithers around.", "glances.", "stares.")

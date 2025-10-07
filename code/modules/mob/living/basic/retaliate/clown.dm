/mob/living/basic/clown
	name = "Clown"
	desc = "A strange creature that vaguely resembles a normal clown. Upon closer inspection, it is nothing of the sort."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	response_help_continuous = "pokes the"
	response_help_simple = "poke the"
	response_disarm_continuous = "gently pushes aside the"
	response_disarm_simple = "gently push aside the"
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_sound = 'sound/items/bikehorn.ogg'
	minimum_survivable_temperature = 270
	maximum_survivable_temperature = 370
	unsuitable_heat_damage = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	unsuitable_cold_damage = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10
	step_type = FOOTSTEP_MOB_SHOE
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/clown
	ai_controller = /datum/ai_controller/basic_controller/simple/clown

/mob/living/basic/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	add_language("Galactic Common")
	add_language("Clownish")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/clown/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/clown/harbringer in oview(src, 7))
		if(harbringer == attacker) // Do not commit suicide attacking yourself
			continue
		harbringer.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/clown/goblin
	icon = 'icons/mob/animal.dmi'
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "clowngoblin"
	icon_living = "clowngoblin"
	icon_dead = null
	mob_biotypes = MOB_ORGANIC
	response_help_continuous = "honks the"
	response_help_simple = "honk the"
	speak_emote = list("squeaks")
	maxHealth = 100
	health = 100
	speed = -1
	basic_mob_flags = DEL_ON_DEATH
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/shoes/clown_shoes)

/mob/living/basic/clown/goblin/cluwne
	name = "cluwne goblin"
	desc = "A tiny pile of misery and evil. Kill this thing before it comes for your family."
	icon_state = "cluwnegoblin"
	icon_living = "cluwnegoblin"
	response_help_continuous = "henks the"
	response_help_simple = "henk the"
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	melee_damage_lower = 17
	melee_damage_upper = 20
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	ai_controller = /datum/ai_controller/basic_controller/simple/cluwne_goblin

	loot = list(/obj/item/clothing/mask/false_cluwne_mask, /obj/item/clothing/shoes/clown_shoes/false_cluwne_shoes) // We'd rather not give them ACTUAL cluwne stuff you know?

/// Fight back if attacked
/datum/ai_controller/basic_controller/simple/clown
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/clown,
	)

/datum/ai_planning_subtree/random_speech/clown
	speech_chance = 2
	speak = list("HONK", "Honk!", "Come join the fun!")
	speak_verbs = list("honks")
	sound = list('sound/items/bikehorn.ogg')
	emote_hear = list("honks.")
	emote_see = list("honks.")

/datum/ai_controller/basic_controller/simple/cluwne_goblin
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/cluwne_goblin,
	)

/datum/ai_planning_subtree/random_speech/cluwne_goblin
	speech_chance = 2
	speak = list("HENK!")
	speak_verbs = list("henks")
	sound = list('sound/items/bikehorn.ogg')
	emote_hear = list("henks.")
	emote_see = list("henks.")

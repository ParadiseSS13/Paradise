/mob/living/basic/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "piratespace"
	icon_living = "piratespace"
	icon_dead = "piratemelee_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	death_sound = 'sound/creatures/piratedeath.ogg'
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	speed = 0
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	minimum_survivable_temperature = 0
	ai_controller = /datum/ai_controller/basic_controller/simple/pirate
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("yarrs")
	loot = list(/obj/item/melee/energy/sword/pirate,
			/obj/item/clothing/head/helmet/space/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	basic_mob_flags = DEL_ON_DEATH
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/pirate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/creatures/pirateengage.ogg', emote_chance = 100)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	if(prob(50))
		loot = list(/obj/item/clothing/head/helmet/space/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/basic/pirate/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "piratespaceranged"
	icon_living = "piratespaceranged"
	is_ranged = TRUE
	projectile_type = /obj/item/projectile/beam
	projectile_sound = 'sound/weapons/laser.ogg'
	ranged_burst_count = 2
	ranged_burst_interval = 0.5 SECONDS // Same fire rate as people!
	ai_controller = /datum/ai_controller/basic_controller/simple/pirate/ranged
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate,
				/obj/item/gun/energy/laser,
				/obj/item/clothing/head/helmet/space/pirate,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

/mob/living/basic/pirate/ranged/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot = list(/obj/item/clothing/head/helmet/space/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/datum/ai_controller/basic_controller/simple/pirate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/pirate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/pirate
	speech_chance = 10
	speak = list(
		"Arrrg!",
		"Avast!",
		"Shiver me timbers!",
		"Yo ho ho!",
		"Where's the rum gone?",
		"Dead men tell no tales!",
		"Scurvy dog!",
		"Weigh anchor!",
		"Raise the Jolly Rodger!",
		"No quarter!")

/datum/ai_controller/basic_controller/simple/pirate/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/pirate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
	)

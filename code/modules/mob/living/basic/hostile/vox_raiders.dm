/mob/living/basic/vox
	name = "Vox"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/mob/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	speak_emote = "screeches"
	speed = 0
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slice.ogg'
	speak_emote = list("screeches")
	basic_mob_flags = DEL_ON_DEATH
	faction = list("vox_raider")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/vox/Initialize(mapload)
	. = ..()
	add_language("Vox-pidgin")
	set_default_language(GLOB.all_languages["Vox-pidgin"])
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/voice/shriek1.ogg', emote_chance = 100)

/mob/living/basic/vox/examine(mob/user)
	. = ..()
	if(isvox(user))
		. += SPAN_WARNING("They are not your kin.")

/mob/living/basic/vox/miner
	name = "vox miner"
	desc = "A vox primalis wearing a strange suit and wielding a plasma cutter."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "vox_miner"
	icon_living = "vox_miner"
	icon_dead = "vox_miner" // Does not actually exist. del_on_death.
	harm_intent_damage = 5
	obj_damage = 45
	melee_damage_lower = 15
	melee_damage_upper = 20
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_miner
	loot = list(
			/obj/effect/mob_spawn/human/corpse/vox_miner,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)
	initial_traits = list(TRAIT_NOFIRE, TRAIT_SPACEWALK, TRAIT_MAGPULSE)
	is_ranged = TRUE
	projectile_type = /obj/projectile/plasma/adv
	projectile_sound = 'sound/weapons/laser.ogg'
	ranged_cooldown = 1.75 SECONDS

/mob/living/basic/vox/miner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	if(prob(50))
		loot.Add(/obj/item/salvage/loot/vox)
	if(prob(25))
		loot.Add(/obj/item/gun/energy/plasmacutter)

/mob/living/basic/vox/miner/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/vox/miner/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/vox/miner/harbinger in oview(src, 5))
		if(harbinger == attacker) // Do not commit suicide attacking yourself
			continue
		if(harbinger.faction_check_mob(attacker, FALSE)) // Don't attack your friends.
			continue
		harbinger.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/vox/miner/foreman
	name = "Vox Foreman"
	desc = "A vox primalis wearing a strange suit and wielding a spikethrower. You could swear it wasn't there a second ago..."
	health = 125
	maxHealth = 125
	icon_state = "vox_foreman"
	icon_living = "vox_foreman"
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_foreman
	projectile_type = /obj/projectile/bullet/spike
	projectile_sound = 'sound/weapons/bladeslice.ogg'
	ranged_burst_count = 2
	ranged_burst_interval = 0.5 SECONDS
	ranged_cooldown = 2.5 SECONDS
	loot = list(
			/obj/item/salvage/loot/vox,
			/obj/item/salvage/loot/vox,
			/obj/item/salvage/loot/pirate,
			/obj/item/salvage/ruin/pirate,
			/obj/effect/mob_spawn/human/corpse/vox_miner,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)

/mob/living/basic/vox/miner/foreman/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/vox/miner/harbinger in oview(src, 28)) // They call for help over a long range - take out the support first.
		if(harbinger == attacker) // Do not commit suicide attacking yourself
			continue
		if(harbinger.faction_check_mob(attacker, FALSE)) // Don't attack your friends.
			continue
		harbinger.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/vox/marauder
	name = "vox marauder"
	desc = "A vox primalis wearing a strange suit and wielding an energy shield and dangerous-looking plasma blade!"
	health = 125
	maxHealth = 125
	damage_coeff = list(BRUTE = 1, BURN = 0.8, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	initial_traits = list(TRAIT_NOFIRE, TRAIT_SPACEWALK, TRAIT_MAGPULSE)
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	icon_state = "vox_marauder"
	icon_living = "vox_marauder"
	melee_damage_lower = 25
	melee_damage_upper = 30
	armor_penetration_flat = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_marauder
	loot = list(
			/obj/item/salvage/loot/vox,
			/obj/item/salvage/loot/vox,
			/obj/effect/mob_spawn/human/corpse/vox,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)

/mob/living/basic/vox/marauder/bullet_act(obj/projectile/Proj)
	if(!Proj)
		return
	if(Proj.is_reflectable(REFLECTABILITY_ENERGY))
		Proj.reflect_back(src)
		visible_message(SPAN_DANGER("[src] reflects [Proj] with its shield!"))
		return -1

	return ..()

/mob/living/basic/vox/marauder/check_eye_prot()
	return 2

/mob/living/basic/vox/marauder/check_ear_prot()
	return 2

/mob/living/basic/vox/marauder/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/vox/raider
	name = "vox raider"
	desc = "A vox primalis wearing a strange suit and wielding a spikethrower and dangerous-looking plasma talons!"
	icon_state = "vox_raider"
	icon_living = "vox_raider"
	damage_coeff = list(BRUTE = 0.8, BURN = 0.7, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	initial_traits = list(TRAIT_NOFIRE, TRAIT_SPACEWALK, TRAIT_MAGPULSE)
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	melee_damage_lower = 15
	melee_damage_upper = 20
	armor_penetration_flat = 30
	is_ranged = TRUE
	projectile_type = /obj/projectile/bullet/spike
	projectile_sound = 'sound/weapons/bladeslice.ogg'
	ranged_burst_count = 2
	ranged_burst_interval = 0.5 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_marauder/raider
	loot = list(
			/obj/item/salvage/loot/vox,
			/obj/item/salvage/loot/vox,
			/obj/effect/mob_spawn/human/corpse/vox,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)

/mob/living/basic/vox/raider/check_eye_prot()
	return 2

/mob/living/basic/vox/raider/check_ear_prot()
	return 2

/mob/living/basic/vox/raider/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/vox/engineer
	name = "vox engineering drone"
	desc = "A vox primalis tasked with maintaining a skipjack and their ark. They are undyingly loyal!"
	icon_state = "vox_engineer"
	icon_living = "vox_engineer"
	initial_traits = list(TRAIT_NOFIRE, TRAIT_MAGPULSE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 2, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 5, "max_n2" = 0)
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_engineer
	loot = list(
			/obj/effect/mob_spawn/human/corpse/vox,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)

/mob/living/basic/vox/engineer/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot.Add(/obj/item/storage/belt/utility/full)

/mob/living/basic/vox/medic
	name = "vox medical drone"
	desc = "A vox primalis tasked with maintaining the health of their kin. They are undyingly loyal!"
	icon_state = "vox_medic"
	icon_living = "vox_medic"
	initial_traits = list(TRAIT_NOFIRE, TRAIT_SPACEWALK, TRAIT_MAGPULSE)
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_medic
	loot = list(
			/obj/item/salvage/loot/vox,
			/obj/effect/mob_spawn/human/corpse/vox,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)

/mob/living/basic/vox/medic/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot.Add(/obj/item/storage/firstaid/regular)

/mob/living/basic/vox/medic/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/vox/medic/check_eye_prot()
	return 2

/mob/living/basic/vox/medic/check_ear_prot()
	return 2

/mob/living/basic/vox/medic/proc/heal_ally(mob/living/basic/ally)
	face_atom(ally)
	ally.adjustHealth(-25)
	visible_message(
		SPAN_WARNING("[src] gently taps [ally] with an automender."),
		SPAN_NOTICE("You apply a mender to [ally]."),
		SPAN_NOTICE("You hear an automender.")
	)
	playsound(get_turf(src), pick('sound/goonstation/items/mender.ogg', 'sound/goonstation/items/mender2.ogg'), 50, 1)

/datum/ai_controller/basic_controller/simple/vox_miner
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4,
		BB_AGGRO_RANGE = 4,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/vox_miner,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_controller/basic_controller/simple/vox_foreman
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
		BB_AGGRO_RANGE = 5,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/vox_miner/foreman,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_controller/basic_controller/simple/vox_marauder
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
		BB_AGGRO_RANGE = 10,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/simple/vox_marauder/raider
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/vox_miner/foreman,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_controller/basic_controller/simple/vox_engineer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_controller/basic_controller/simple/vox_medic
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 7,
		BB_BASIC_MOB_FLEE_DISTANCE = 4
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/vox_miner,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_heal_target,
		/datum/ai_planning_subtree/vox_medic_heal_ally,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee/from_flee_key,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/from_flee_key,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_planning_subtree/random_speech/vox_miner
	speech_chance = 8
	speak = list(
		"Just another day.",
		"You think I'm going to get extra rations for this?",
		"Did you hear the latest choir chants?",
		"I think I heard something...",
		"By the Auralis!",
		"For the Auralis!",
		"For the Ark!",
		"Stars guide my aim!")
	sound = list('sound/effects/voxfcaw.ogg', 'sound/effects/voxrcaw.ogg', 'sound/effects/voxrustle.ogg', 'sound/voice/shriek1.ogg')

/datum/ai_planning_subtree/ranged_skirmish/vox_miner
	min_range = 1
	max_range = 4
	attack_behavior = /datum/ai_behavior/ranged_skirmish/avoid_friendly

/datum/ai_planning_subtree/ranged_skirmish/vox_miner/foreman
	max_range = 9

/datum/ai_planning_subtree/find_heal_target

/datum/ai_planning_subtree/find_heal_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/vox_medic_find_heal_target, BB_BASIC_MOB_CURRENT_TARGET)
		return

/datum/ai_behavior/vox_medic_find_heal_target
	action_cooldown = 2 SECONDS

/datum/ai_behavior/vox_medic_find_heal_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	for(var/mob/living/basic/vox/patient in view(7, get_turf(controller.pawn)))
		if(QDELETED(patient) || patient.stat == DEAD)
			continue
		if(!(patient.health < patient.maxHealth))
			continue

		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, patient)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/datum/ai_planning_subtree/vox_medic_heal_ally

/datum/ai_planning_subtree/vox_medic_heal_ally/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/vox_medic_heal_target, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/vox_medic_heal_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 10 SECONDS

/datum/ai_behavior/vox_medic_heal_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/vox_medic_heal_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/vox/patient = controller.blackboard[target_key]
	if(QDELETED(patient) || patient.stat == DEAD)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!(patient.health < patient.maxHealth))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/basic/vox/medic/pawn = controller.pawn
	pawn.heal_ally(patient)
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

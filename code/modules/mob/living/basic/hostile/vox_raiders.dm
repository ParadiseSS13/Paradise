/mob/living/basic/vox_miner
	name = "Vox Miner"
	desc = "A vox primalis wearing a strange suit and wielding a plasma cutter."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "vox_miner"
	icon_living = "vox_miner"
	icon_dead = "vox_miner" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "claws"
	response_harm_simple = "claw"
	speak_emote = "screeches"
	speed = 0
	harm_intent_damage = 5
	obj_damage = 45
	melee_damage_lower = 15
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slice.ogg'
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("screeches")
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_miner
	loot = list(
			/obj/effect/mob_spawn/human/corpse/vox_miner,
			/obj/effect/decal/cleanable/blood/innards/vox,
			/obj/effect/decal/cleanable/blood/vox,
			/obj/effect/gibspawner/vox)
	basic_mob_flags = DEL_ON_DEATH
	faction = list("vox_raider")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

	is_ranged = TRUE
	projectile_type = /obj/item/projectile/plasma/adv
	projectile_sound = 'sound/weapons/laser.ogg'
	ranged_cooldown = 1.75 SECONDS

/mob/living/basic/vox_miner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	add_language("Vox-pidgin")
	set_default_language(GLOB.all_languages["Vox-pidgin"])
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/voice/shriek1.ogg', emote_chance = 100)
	if(prob(50))
		loot.Add(/obj/item/salvage/loot/vox)
	if(prob(25))
		loot.Add(/obj/item/gun/energy/plasmacutter)

/mob/living/basic/vox_miner/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/vox_miner/harbinger in oview(src, 5))
		if(harbinger == attacker) // Do not commit suicide attacking yourself
			continue
		if(harbinger.faction_check_mob(attacker, FALSE)) // Don't attack your friends.
			continue
		harbinger.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/vox_miner/foreman
	name = "Vox Foreman"
	desc = "A vox primalis wearing a strange suit and wielding a spikethrower. You could swear it wasn't there a second ago..."
	health = 125
	maxHealth = 125
	icon_state = "vox_foreman"
	icon_living = "vox_foreman"
	ai_controller = /datum/ai_controller/basic_controller/simple/vox_foreman
	projectile_type = /obj/item/projectile/bullet/spike
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

/mob/living/basic/vox_miner/foreman/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/vox_miner/harbinger in oview(src, 28)) // They call for help over a long range - take out the support first.
		if(harbinger == attacker) // Do not commit suicide attacking yourself
			continue
		if(harbinger.faction_check_mob(attacker, FALSE)) // Don't attack your friends.
			continue
		harbinger.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/datum/ai_controller/basic_controller/simple/vox_miner
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
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

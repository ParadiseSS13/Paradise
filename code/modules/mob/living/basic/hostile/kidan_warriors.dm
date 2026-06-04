#define KIDAN_THRONEROOM "KIDAN_THRONEROOM"

/mob/living/basic/kidan_warrior
	name = "Kidan Warrior"
	desc = "A bulky insect-man wielding a large spear."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "kidan_warrior"
	icon_living = "kidan_warrior"
	icon_dead = "kidan_warrior_dead" // Does not actually exist. Dust on death
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	death_sound = 'sound/voice/scream_kidan.ogg'
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	speed = 0
	harm_intent_damage = 5
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1 SECONDS
	melee_attack_cooldown_max = 2 SECONDS
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	is_ranged = TRUE
	projectile_type = /obj/projectile/bullet/reusable/magspear
	projectile_sound = 'sound/weapons/grenadelaunch.ogg'
	ranged_cooldown = 1 SECONDS
	a_intent = INTENT_HARM
	damage_coeff = list(BRUTE = 0.8, BURN = 1, TOX = 1.5, STAMINA = 0, OXY = 1)
	minimum_survivable_temperature = 0
	ai_controller = /datum/ai_controller/basic_controller/simple/kidan_warrior
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("clacks")
	blood_color = "#FB9800"
	loot = list(
			/obj/effect/decal/remains/human,
			/obj/effect/decal/cleanable/ash)
	faction = list("kidan_royalty")
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/kidan_warrior/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/effects/Kidanclack.ogg', emote_chance = 100)
	add_language("Galactic Common")
	add_language("Chittin")
	set_default_language(GLOB.all_languages["Chittin"])
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	var/datum/language/lang = GLOB.all_languages["Chittin"]
	name = lang.get_random_name(gender)
	real_name = name
	if(prob(25))
		loot = list(
			/obj/effect/decal/remains/human,
			/obj/effect/decal/cleanable/ash,
			/obj/item/kidan_spear)

/mob/living/basic/kidan_warrior/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	GLOB.kidan_shitlist += attacker

/mob/living/basic/kidan_warrior/ruin/death(gibbed)
	GLOB.ragnarok_kill_count += 1
	if(GLOB.ragnarok_kill_count >= 10)
		unlock_blast_doors(KIDAN_THRONEROOM)
		src.visible_message(SPAN_NOTICE("Somewhere, a heavy door has opened."))
	return ..(gibbed)

/mob/living/basic/kidan_warrior/ruin/proc/unlock_blast_doors(target_id_tag)
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

/datum/ai_controller/basic_controller/simple/kidan_warrior
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/kidan_warrior,
		BB_AGGRO_RANGE = 9,
		BB_SEARCH_RANGE = 10,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 15

/datum/targeting_strategy/basic/kidan_warrior

/datum/targeting_strategy/basic/kidan_warrior/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(!isliving(the_target))
		return .
	if(the_target in GLOB.kidan_shitlist)
		return TRUE
	return FALSE

/mob/living/basic/kidan_warrior/throneguard
	name = "Kidan Throneguard"
	desc = "The loyal guards of Kidan nobility."
	icon_state = "kidan_throneguard"
	icon_living = "kidan_throneguard"
	damage_coeff = list(BRUTE = 0.6, BURN = 0.8, TOX = 1.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 25
	melee_damage_upper = 35
	ai_controller = /datum/ai_controller/basic_controller/simple/kidan_warrior/throneguard

/datum/ai_controller/basic_controller/simple/kidan_warrior/throneguard
	idle_behavior = null

/mob/living/basic/kidan_servant
	name = "Kidan Servant"
	desc = "A kidan who works in service of their nobility."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "kidan_servant"
	icon_living = "kidan_servant"
	icon_dead = "kidan_servant_dead" // Does not actually exist. Dust on death
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	death_sound = 'sound/voice/scream_kidan.ogg'
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	speed = 0
	harm_intent_damage = 5
	obj_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	melee_attack_cooldown_min = 1 SECONDS
	melee_attack_cooldown_max = 2 SECONDS
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	a_intent = INTENT_HELP
	damage_coeff = list(BRUTE = 0.8, BURN = 1, TOX = 1.5, STAMINA = 0, OXY = 1)
	minimum_survivable_temperature = 0
	ai_controller = /datum/ai_controller/basic_controller/kidan_servant
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("clacks")
	blood_color = "#FB9800"
	loot = list(
			/obj/effect/decal/remains/human,
			/obj/effect/decal/cleanable/ash)
	faction = list("kidan_royalty")
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/kidan_servant/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/voice/scream_kidan.ogg', emote_chance = 100)
	add_language("Galactic Common")
	add_language("Chittin")
	set_default_language(GLOB.all_languages["Chittin"])
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	var/datum/language/lang = GLOB.all_languages["Chittin"]
	name = lang.get_random_name(gender)
	real_name = name
	var/bonus_loot_type = rand(1, 5)
	switch(bonus_loot_type)
		if(1)
			loot += /obj/item/clothing/neck/necklace/long
		if(2)
			loot += /obj/item/stack/sheet/mineral/gold
		if(3)
			loot += pick(list(/obj/item/reagent_containers/drinks/bottle/wine, /obj/item/reagent_containers/drinks/bottle/white_wine, /obj/item/reagent_containers/drinks/bottle/goldschlager))
		if(4)
			for(var/i in 1 to 9)
				loot += /obj/item/coin/gold
		if(5)
			loot += /obj/item/food/beary_pie

/mob/living/basic/kidan_servant/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	GLOB.kidan_shitlist += attacker

/mob/living/basic/kidan_servant/ruin/death(gibbed)
	GLOB.ragnarok_kill_count -= 1
	return ..(gibbed)

/datum/ai_controller/basic_controller/kidan_servant
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/kidan_warrior,
		BB_AGGRO_RANGE = 9,
		BB_SEARCH_RANGE = 10,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/flee_target,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 15

#undef KIDAN_THRONEROOM

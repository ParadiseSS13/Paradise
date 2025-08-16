/mob/living/basic/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	response_help_continuous = "waves away"
	response_help_simple = "wave away"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "disrupts"
	response_harm_simple = "disrupt"
	speak_emote = list("warps")
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	friendly_verb_continuous = "mends"
	friendly_verb_simple = "mend"
	density = FALSE
	initial_traits = list(TRAIT_FLYING)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	luminosity = 4
	faction = list("neutral")
	basic_mob_flags = DEL_ON_DEATH
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	ai_controller = /datum/ai_controller/basic_controller/lightgeist
	var/heal_power = 5

/mob/living/basic/lightgeist/Initialize(mapload)
	. = ..()
	remove_verb(src, /mob/living/verb/pulled)
	remove_verb(src, /mob/verb/me_verb)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.add_hud_to(src)

/mob/living/basic/lightgeist/Destroy()
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.remove_hud_from(src)
	return ..()

/mob/living/basic/lightgeist/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(isliving(target) && target != src)
		faction |= ref(target) // Anyone we heal will treat us as a friend
		var/mob/living/L = target
		if(L.stat != DEAD)
			L.heal_overall_damage(heal_power, heal_power)
			new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")

/mob/living/basic/lightgeist/ghost()
	qdel(src)

/datum/ai_controller/basic_controller/lightgeist
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/lightgeist,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target/target_allies,
		/datum/ai_planning_subtree/basic_melee_attack_subtree, // We heal things by attacking them
	)

/// Attack only mobs who have damage that we can heal, I think this is specific enough not to be a generic type
/datum/targeting_strategy/lightgeist
	/// Types of mobs we can heal, not in a blackboard key because there is no point changing this at runtime because the component will already exist
	var/heal_biotypes = MOB_ORGANIC | MOB_MINERAL

/datum/targeting_strategy/lightgeist/can_attack(mob/living/living_mob, mob/living/target, vision_range)
	if(!isliving(target) || target.stat == DEAD)
		return FALSE
	if(!(heal_biotypes & target.mob_biotypes))
		return FALSE
	return target.getBruteLoss() > 0 || target.getFireLoss() > 0

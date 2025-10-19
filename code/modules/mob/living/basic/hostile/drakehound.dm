/mob/living/basic/drakehound_breacher
	name = "Drakehound Breacher"
	desc = "A unathi raider with a viscious streak."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "drakehound"
	icon_living = "drakehound"
	icon_dead = "drakehound_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
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
	attack_sound = 'sound/weapons/bladeslice.ogg'
	minimum_survivable_temperature = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("hisses")
	ai_controller = /datum/ai_controller/basic_controller/simple/drakehound
	loot = list(
			/obj/effect/mob_spawn/human/corpse/drakehound,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	basic_mob_flags = DEL_ON_DEATH
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/drakehound_breacher/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	add_language("Sinta'unathi")
	set_default_language(GLOB.all_languages["Sinta'unathi"])
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/effects/unathihiss.ogg', emote_chance = 100)
	if(prob(50))
		loot = list(
			/obj/item/salvage/loot/pirate,
			/obj/effect/mob_spawn/human/corpse/drakehound,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/basic/drakehound_breacher/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/drakehound_breacher/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/drakehound_breacher/harbinger in oview(src, 5))
		if(harbinger == attacker) // Do not commit suicide attacking yourself
			continue
		if(harbinger.faction_check_mob(attacker, FALSE)) // Don't attack your friends.
			continue
		harbinger.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/drakehound_breacher/ranged
	name = "Drakehound Raider"
	desc = "A unathi raider with a shotgun."
	icon_state = "drakehound_raider"
	icon_living = "drakehound_raider"
	melee_damage_lower = 15
	melee_damage_upper = 25
	ai_controller = /datum/ai_controller/basic_controller/simple/drakehound_ranged
	is_ranged = TRUE
	ranged_cooldown = 1.5 SECONDS
	casing_type = /obj/item/ammo_casing/shotgun/rubbershot
	projectile_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'

/mob/living/basic/drakehound_breacher/ranged/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BASICMOB_POST_ATTACK_RANGED, PROC_REF(rack_shotgun))

/mob/living/basic/drakehound_breacher/ranged/proc/rack_shotgun()
	sleep(0.5 SECONDS)
	playsound(src, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, TRUE)
	var/datum/component/ranged_attacks/comp = GetComponent(/datum/component/ranged_attacks)
	comp.casing_type = pick(/obj/item/ammo_casing/shotgun/rubbershot, /obj/item/ammo_casing/shotgun/laserslug, /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath)

/mob/living/basic/drakehound_breacher/ranged/captain
	name = "Drakehound Captain"
	desc = "The leader of a band of drakehounds. Wields a large shotgun with devastating effectiveness, and a very large sword for those who get too close."
	icon_state = "drakehound_captain"
	icon_living = "drakehound_captain"
	melee_damage_lower = 25
	melee_damage_upper = 40
	maxHealth = 250
	health = 250
	speed = 0.5 // Bigger and badder, slightly slower
	ai_controller = /datum/ai_controller/basic_controller/simple/drakehound_skirmish
	ranged_cooldown = 2 SECONDS
	ranged_burst_count = 3
	ranged_burst_interval = 0.5 SECONDS
	casing_type = /obj/item/ammo_casing/shotgun/buckshot
	attack_sound = 'sound/weapons/swordhitheavy.ogg'

/mob/living/basic/drakehound_breacher/ranged/captain/Initialize(mapload)
	. = ..()
	loot = list(
			/obj/effect/mob_spawn/human/corpse/drakehound,
			/obj/item/salvage/loot/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/item/salvage/loot/pirate,
			/obj/item/gun/projectile/shotgun/automatic/dual_tube,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/basic/drakehound_breacher/ranged/captain/rack_shotgun()
	var/datum/component/ranged_attacks/comp = GetComponent(/datum/component/ranged_attacks)
	comp.casing_type = pick(/obj/item/ammo_casing/shotgun/buckshot, /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath, /obj/item/ammo_casing/shotgun/lasershot)

/mob/living/basic/drakehound_breacher/ranged/captain/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!ishuman(target))
		return ..()
	var/mob/living/L = target
	var/attack_type = pick("disarm", "grab", "harm")
	switch(attack_type)
		if("disarm")
			playsound(get_turf(src), 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE, -1)
			var/atom/throw_target = get_edge_target_turf(L, src.dir, TRUE)
			L.throw_at(throw_target, 4, 1)
			return ..()
		if("grab")
			L.KnockDown(4 SECONDS)
			return ..()
		if("harm")
			return ..()

/datum/ai_controller/basic_controller/simple/drakehound
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/drakehound,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/simple/drakehound_ranged
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/drakehound,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/drakehound,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_controller/basic_controller/simple/drakehound_skirmish
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/drakehound,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish/drakehound,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/drakehound
	speech_chance = 10
	speak = list(
		"I'll send you back to the pits!",
		"Finally, some action!",
		"You're gonna be quick work!",
		"Oh, now you fucked up!",
		"Maybe don't board the clearly dangerous looking ship?",
		"Heart Smash is better, you don't know good music.",
		"We wouldn't be stuck here if we just zigged when we zagged.",
		"Well, atleast I'm away from my brother!",
		"Got any smokes?")

/datum/ai_planning_subtree/ranged_skirmish/drakehound
	min_range = 0
	max_range = 5
	attack_behavior = /datum/ai_behavior/ranged_skirmish/avoid_friendly

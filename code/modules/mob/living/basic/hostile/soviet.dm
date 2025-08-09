/mob/living/basic/soviet
	name = "Soviet"
	desc = "For the Union!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "sovietmelee"
	icon_living = "sovietmelee"
	icon_dead = "sovietmelee_dead" // Does not actually exist. del_on_death.
	icon_gib = "sovietmelee_gib" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speed = 0
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 15
	ai_controller = /datum/ai_controller/basic_controller/simple/soviet
	faction = list("soviet")
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet,
		/obj/item/kitchen/knife,
		/obj/item/salvage/loot/soviet)
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/soviet/Initialize(mapload)
	. = ..()
	add_language("Zvezhan")
	set_default_language(GLOB.all_languages["Zvezhan"])

/mob/living/basic/soviet/ranged
	icon_state = "sovietranged"
	icon_living = "sovietranged"
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/a357
	ranged_cooldown = 4 SECONDS
	projectile_sound = 'sound/weapons/gunshots/gunshot.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet/ranged, /obj/item/gun/projectile/revolver/mateba)
	ai_controller = /datum/ai_controller/basic_controller/simple/soviet/ranged

/mob/living/basic/soviet/ranged/mosin
	loot = list(/obj/effect/mob_spawn/human/corpse/soviet/ranged,
				/obj/item/gun/projectile/shotgun/boltaction,
				/obj/item/salvage/loot/soviet)
	casing_type = /obj/item/ammo_casing/a762
	projectile_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'

/mob/living/basic/soviet/nian
	name = "Soviet Nian"
	desc = "Buzz!"
	icon_state = "sovietnian"
	icon_living = "sovietnian"
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	minimum_survivable_temperature = 0
	loot = list(
		/obj/effect/mob_spawn/human/corpse/soviet_nian,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/salvage/loot/soviet
	)

/datum/ai_controller/basic_controller/simple/soviet
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/soviet,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/simple/soviet/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/soviet,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
	)

/datum/ai_planning_subtree/random_speech/soviet
	speech_chance = 10
	speak = list(
		"We work for the future.",
		"The party leads us forward.",
		"Long live socialism!",
		"One people, one purpse!",
		"For the state!",
		"Forward to communism!",
		"Glory to the worker!",
		"With sweat we strengthen the state!",
		"From each, according to ability!",
		"We forge tomorrow with our hands!")

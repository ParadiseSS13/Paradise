/mob/living/basic/malfborg
	name = "malfunctioning cyborg"
	desc = "It doesn't appear to obey the laws of robotics."
	icon = 'icons/mob/robots.dmi'
	icon_state = "Noble-STD"
	health = 200
	maxHealth = 200
	faction = list("malf_drone")
	mob_biotypes = MOB_ROBOTIC
	speed = 0.5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	speak_emote = list("states")
	a_intent = INTENT_HARM
	harm_intent_damage = 0
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_verb_simple = "slash"
	attack_verb_continuous = "slashes"
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_min = 2.5 SECONDS
	initial_traits = list(TRAIT_NOFIRE)
	attack_sound = 'sound/weapons/blade1.ogg'
	is_ranged = TRUE
	projectile_type = /obj/projectile/beam/laser
	projectile_sound = 'sound/weapons/laser.ogg'
	death_sound = 'sound/voice/borg_deathsound.ogg'
	ranged_burst_count = 2
	death_message = "blows apart!"
	bubble_icon = "machine"
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/malfborg

/mob/living/basic/malfborg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, emote_list = list("beeps", "buzzes"), emote_chance = 50)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/malfborg/emp_act(severity)
	. = ..()
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	adjustBruteLoss(50)

/mob/living/basic/malfborg/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)
	new /obj/effect/gibspawner/robot(get_turf(src))

/mob/living/basic/malfborg/sec
	name = "security cyborg"
	desc = "Oh god they still have access to these!"
	icon_state = "Noble-SEC"
	attack_verb_simple = "baton"
	attack_verb_continuous = "batons"
	projectile_type = /obj/projectile/beam/disabler/weak
	projectile_sound = 'sound/weapons/taser2.ogg'
	ranged_burst_count = 2
	var/obj/item/melee/baton/infinite_cell/baton = null // stunbaton bot uses to melee attack

/mob/living/basic/malfborg/sec/Initialize(mapload)
	. = ..()
	baton = new(src)

/mob/living/basic/malfborg/sec/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!early_melee_attack(target, modifiers, ignore_cooldown))
		return FALSE
	if(QDELETED(target))
		return FALSE
	face_atom(target)
	baton.melee_attack_chain(src, target)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, TRUE)
	return TRUE

/mob/living/basic/malfborg/sec/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A))
		used_item = baton
	..()

/mob/living/basic/malfborg/sec/Destroy()
	QDEL_NULL(baton)
	return ..()

/mob/living/basic/malfborg/sec/engi // Engiborg has a batonga. Might as well inherit it.
	name = "engineering cyborg"
	desc = "Don't let this one near the engine."
	icon_state = "Noble-ENG"
	projectile_type = /obj/projectile/beam/emitter
	projectile_sound = 'sound/weapons/emitter.ogg'
	ranged_burst_count = 1
	ranged_cooldown = 1.5 SECONDS

/mob/living/basic/malfborg/service
	name = "service cyborg"
	desc = "It's ready to serve an ass kicking."
	icon_state = "Noble-SRV"
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_verb_simple = "slam"
	attack_verb_continuous = "slams"
	attack_sound = 'sound/weapons/guitarslam.ogg'
	projectile_type = null
	projectile_sound = 'sound/weapons/laser.ogg'
	casing_type = /obj/item/ammo_casing/caseless/eshotgun
	ranged_burst_count = 1
	ranged_cooldown = 1.5 SECONDS

/obj/item/ammo_casing/caseless/eshotgun
	projectile_type = /obj/projectile/beam/scatter/eshotgun
	pellets = 6
	variance = 25
	fire_sound = 'sound/weapons/laser.ogg'

/mob/living/basic/malfborg/mining
	name = "mining cyborg"
	desc = "It digs holes in organic flesh."
	icon_state = "Noble-DIG"
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_verb_simple = "mine"
	attack_verb_continuous = "mines"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	projectile_type = /obj/projectile/kinetic/malf
	projectile_sound = 'sound/weapons/kenetic_accel.ogg'
	ranged_burst_count = 1
	ranged_cooldown = 2 SECONDS

/datum/ai_controller/basic_controller/malfborg
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_SIMPLE_INTERESTING_DIST
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

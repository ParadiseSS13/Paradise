/mob/living/basic/hostile_mech
	name = "hostile mech"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "ripley"
	health = 300
	maxHealth = 300
	faction = list("malf_drone")
	mob_biotypes = MOB_ROBOTIC
	sentience_type = SENTIENCE_ARTIFICIAL
	density = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 20000
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	speak_emote = list("states")
	a_intent = INTENT_HARM
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 40
	attack_verb_simple = "smash"
	attack_verb_continuous = "smashes"
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_min = 2.5 SECONDS
	damage_coeff = list(BRUTE = 0.7, BURN = 0.6, TOX = 0, STAMINA = 0, OXY = 0)
	initial_traits = list(TRAIT_NOFIRE)
	is_ranged = TRUE
	projectile_type = /obj/projectile/beam/laser
	projectile_sound = 'sound/weapons/laser.ogg'
	ranged_burst_count = 1
	death_message = "breaks apart!"
	bubble_icon = "machine"
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/evil_mech
	/// Time until next move
	var/can_move = 0
	/// Amount of time to add on move
	var/step_in = 1 SECONDS
	/// Chance the mech bounces a hit
	var/deflect_chance = 15
	/// Does the mech use a punch?
	var/mech_punch = FALSE
	/// Actions to grant on Initialize
	var/list/innate_actions = list()

/mob/living/basic/hostile_mech/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/misc/interference.ogg', aggro_volume = 100, emote_chance = 50, sound_vary = FALSE)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	AddElement(/datum/element/ai_retaliate)
	grant_actions_by_list(innate_actions)
	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/hostile_mech/emp_act(severity)
	. = ..()
	adjustBruteLoss(50)
	if(prob(25))
		apply_effect(3 SECONDS, STUN, 0)
		playsound(get_turf(src), 'sound/mecha/internaldmgalarm.ogg', 100, FALSE)

/mob/living/basic/hostile_mech/death(gibbed)
	// Only execute the below if we successfully died
	do_sparks(3, 1, src)
	playsound(get_turf(src), 'sound/mecha/critdestrsyndi.ogg', 100, FALSE)
	. = ..(gibbed)
	if(!.)
		return FALSE

/mob/living/basic/hostile_mech/update_overlays()
	. = ..()
	underlays.Cut()
	underlays += emissive_appearance('icons/mecha/mecha_emissive.dmi', "[icon_state]_lightmask")

/mob/living/basic/hostile_mech/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(has_gravity(src))
		return TRUE
	if(isspaceturf(get_turf(src)))
		new /obj/effect/particle_effect/ion_trails(get_turf(src), dir)
	return TRUE

/mob/living/basic/hostile_mech/attack_by(obj/item/attacking, mob/living/user, params)
	if(prob(deflect_chance))
		return
	. = ..()
	if(prob(25))
		do_sparks(3, 1, src)

/mob/living/basic/hostile_mech/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(mech_punch && isliving(target))
		var/mob/living/L = target
		step_away(L, src, 15)
		L.Paralyse(2 SECONDS)

/mob/living/basic/hostile_mech/Move(atom/destination)
	if(can_move >= world.time)
		return FALSE
	. = ..()
	playsound(get_turf(src), 'sound/mecha/mechstep.ogg', 100, TRUE)
	can_move = world.time + step_in

/// Proc used for extra weapons
/mob/living/basic/hostile_mech/proc/shoot_projectile(atom/target_atom, obj/projectile/thing_to_shoot, set_angle)
	var/turf/startloc = get_turf(src)
	dir = get_dir(src, target_atom)

	if(!startloc || !target_atom)
		return

	var/obj/projectile/P = new thing_to_shoot(startloc)
	P.preparePixelProjectile(target_atom, startloc)
	P.firer = src
	P.firer_source_atom = src

	if(isnum(set_angle))
		P.fire(set_angle)
	else
		P.fire()

/datum/ai_controller/basic_controller/evil_mech
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	ai_movement = /datum/ai_movement/jps // Need this for smashing through walls
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_SIMPLE_INTERESTING_DIST
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/evil_mech_weaponry,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/walls,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/targeted_mob_ability/evil_mech_weaponry
	ability_key = BB_HOSTILE_MECH_SECONDARY_WEAPON
	/// Minimum time between any firing
	var/weapon_swap_delay = 2 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/evil_mech_weaponry/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_HOSTILE_MECH_WEAPON_COOLDOWN] >= world.time)
		return
	var/list/ability_keys = list(BB_HOSTILE_MECH_SECONDARY_WEAPON, BB_HOSTILE_MECH_TERTIARY_WEAPON)
	ability_key = pick_n_take(ability_keys)
	var/datum/action/cooldown/mob_cooldown/selected_action = controller.blackboard[ability_key]
	while(selected_action && !selected_action.IsAvailable())
		if(!ability_keys.len) // All guns are on cooldown
			return
		ability_key = pick_n_take(ability_keys)
		selected_action = controller.blackboard[ability_key]
	controller.set_blackboard_key(BB_HOSTILE_MECH_WEAPON_COOLDOWN, world.time + weapon_swap_delay)
	return ..()

/mob/living/basic/hostile_mech/ripley
	name = "hostile ripley"
	desc = "A hacked ripley mech, armed with a malfunctioning grenade launcher, heavy plasma cutter, and a drill."
	melee_damage_lower = 10
	melee_damage_upper = 15
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_simple = "drill"
	attack_verb_continuous = "drills"
	melee_attack_cooldown_min = 0.5 SECONDS
	melee_attack_cooldown_min = 1.5 SECONDS
	attack_sound = 'sound/weapons/drill.ogg'
	is_ranged = TRUE
	projectile_type = /obj/projectile/plasma/adv/mech/evil
	projectile_sound = 'sound/weapons/laser.ogg'
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/hostile_mech/launcher/malf_grenade = BB_HOSTILE_MECH_SECONDARY_WEAPON,
	)
	loot = list(/obj/structure/mecha_wreckage/ripley)

/obj/projectile/plasma/adv/mech/evil
	damage = 15

/mob/living/basic/hostile_mech/gygax
	name = "hostile gygax"
	desc = "A hacked gygax mech, armed with a small missile pod, heavy LMG, and a bola launcher."
	icon_state = "gygax"
	health = 250
	maxHealth = 250
	melee_damage_lower = 25
	melee_damage_upper = 35
	damage_coeff = list(BRUTE = 0.8, BURN = 0.75, TOX = 0, STAMINA = 0, OXY = 0)
	projectile_type = /obj/projectile/bullet/weakbullet3
	ranged_burst_count = 3
	ranged_burst_interval = 0.2 SECONDS
	ranged_cooldown = 1.5 SECONDS
	projectile_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/hostile_mech/launcher/light_missile = BB_HOSTILE_MECH_SECONDARY_WEAPON,
		/datum/action/cooldown/mob_cooldown/hostile_mech/bola_launcher = BB_HOSTILE_MECH_TERTIARY_WEAPON
	)
	step_in = 0.3 SECONDS
	mech_punch = TRUE
	deflect_chance = 5
	loot = list(/obj/structure/mecha_wreckage/gygax)

/mob/living/basic/hostile_mech/durand
	name = "hostile durand"
	desc = "A hacked durand mech, armed with a small missile pod, solaris laser cannon, and a scattershot shotgun."
	icon_state = "durand"
	health = 400
	maxHealth = 400
	melee_damage_lower = 35
	melee_damage_upper = 45
	damage_coeff = list(BRUTE = 0.6, BURN = 0.85, TOX = 0, STAMINA = 0, OXY = 0)
	is_ranged = TRUE
	projectile_type = /obj/projectile/beam/laser/heavylaser
	ranged_burst_count = 1
	ranged_burst_interval = 1 SECONDS
	ranged_cooldown = 1.5 SECONDS
	projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/hostile_mech/launcher/light_missile = BB_HOSTILE_MECH_SECONDARY_WEAPON,
		/datum/action/cooldown/mob_cooldown/hostile_mech/scattershot = BB_HOSTILE_MECH_TERTIARY_WEAPON
	)
	step_in = 0.4 SECONDS
	mech_punch = TRUE
	deflect_chance = 20
	loot = list(/obj/structure/mecha_wreckage/durand)

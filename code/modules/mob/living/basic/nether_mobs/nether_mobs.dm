/mob/living/basic/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing-pink"
	icon_living = "otherthing-pink"
	icon_dead = "otherthing-pink-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/prowler
	attack_verb_simple = "chomp"
	attack_verb_continuous = "chomps"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAM = 0, OXY = 1)
	faction = list("nether")
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/sweating
	step_type = FOOTSTEP_MOB_SHOE
	/// The chance of it being a grappler variant
	var/grappler_chance = 20

/mob/living/basic/netherworld/Initialize(mapload)
	. = ..()
	if(prob(grappler_chance))
		AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/energy/demonic_grappler, projectile_sound = 'sound/weapons/wave.ogg')
		name = "grappling " + name
		ai_controller = new /datum/ai_controller/basic_controller/simple/simple_skirmisher/prowler(src)
		update_appearance(UPDATE_NAME)
		color = "#5494DA"
	AddElement(/datum/element/ai_retaliate)

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
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	attack_verb_simple = "chomp"
	attack_verb_continuous = "chomps"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAM = 0, OXY = 1)
	faction = list("nether")
	var/step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/netherworld/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/footstep, step_type)

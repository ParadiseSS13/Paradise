/mob/living/basic/demon
	name = "a generic demon"
	speak_emote = list("gurgles", "wails", "screeches")
	response_help_continuous  = "thinks better of touching"
	response_help_simple  = "thinks better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punches"
	a_intent = INTENT_HARM
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	attack_sound = 'sound/misc/demon_attack1.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	faction = list("demon")
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	basic_mob_flags = DEL_ON_DEATH
	var/datum/action/innate/demon_whisper/whisper_action

/mob/living/basic/demon/Initialize(mapload)
	. = ..()
	whisper_action = new()
	whisper_action.Grant(src)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/demon/Destroy()
	QDEL_NULL(whisper_action)
	return ..()

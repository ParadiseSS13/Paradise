/mob/living/simple_animal/demon
	name = "a generic demon"
	desc = "you shouldnt be reading this, file a github report."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	a_intent = INTENT_HARM
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	stop_automated_movement = TRUE
	attack_sound = 'sound/misc/demon_attack1.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("demon")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	del_on_death = TRUE
	var/datum/action/innate/demon_whisper/whisper_action

/mob/living/simple_animal/demon/Initialize(mapload)
	. = ..()
	whisper_action = new()
	whisper_action.Grant(src)

/mob/living/simple_animal/demon/Destroy()
	QDEL_NULL(whisper_action)
	return ..()

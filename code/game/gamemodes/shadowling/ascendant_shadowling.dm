/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	desc = "A large, floating eldritch horror. It has pulsing markings all about its body and large horns. It seems to be floating without any form of support."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	speak = list("Azima'dox", "Mahz'kavek", "N'ildzak", "Kaz'vadosh")
	speak_emote = list("telepathically thunders", "telepathically booms")
	force_threshold = INFINITY //Can't die by normal means
	health = 100000
	maxHealth = 100000
	speed = 0
	var/phasing = 0
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	universal_speak = 1

	response_help   = "stares at"
	response_disarm = "flails at"
	response_harm   = "flails at"

	harm_intent_damage = 0
	melee_damage_lower = 60 //Was 35, buffed
	melee_damage_upper = 60
	attacktext = "rends"
	attack_sound = 'sound/weapons/slash.ogg'

	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = ENVIRONMENT_SMASH_RWALLS

	faction = list("faithless")

/mob/living/simple_animal/ascendant_shadowling/New()
	..()
	if(prob(35))
		icon_state = "NurnKal"
		icon_living = "NurnKal"

/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(var/movement_dir = 0)
	return 1 //copypasta from carp code

/mob/living/simple_animal/ascendant_shadowling/ex_act(severity)
	return //You think an ascendant can be hurt by bombs? HA

/mob/living/simple_animal/ascendant_shadowling/singularity_act()
	return 0 //Well hi, fellow god! How are you today?

/mob/living/simple_animal/ascendant_shadowling/proc/announce(var/text, var/size = 4, var/new_sound = null)
	var/message = "<font size=[size]><span class='shadowling'><b>\"[text]\"</font></span>"
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.client)
			to_chat(M, message)
			if(new_sound)
				M << new_sound

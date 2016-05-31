/datum/species/abductor
	name = "Abductor"
	name_plural = "Abductors"
	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'
	path = /mob/living/carbon/human/abductor
	language = "Abductor Mindlink"
	default_language = "Abductor Mindlink"
	unarmed_type = /datum/unarmed_attack/punch
	darksight = 3
	eyes = "blank_eyes"

	flags = HAS_LIPS | NO_BLOOD | NO_BREATHE
	virus_immune = 1
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	blood_color = "#FF5AFF"

/datum/species/abductor/can_understand(var/mob/other) //Abductors can understand everyone, but they can only speak over their mindlink to another team-member
	return 1

/datum/species/abductor/handle_post_spawn(var/mob/living/carbon/human/H)
	H.gender = NEUTER
	if(H.mind)
		H.mind.abductor = new /datum/abductor
	H.languages.Cut() //Under no condition should you be able to speak any language
	H.add_language("Abductor Mindlink") //other than over the abductor's own mindlink
	return ..()

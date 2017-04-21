/datum/species/abductor
	name = "Abductor"
	name_plural = "Abductors"
	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'
	path = /mob/living/carbon/human/abductor
	language = "Abductor Mindlink"
	default_language = "Abductor Mindlink"
	unarmed_type = /datum/unarmed_attack/punch
	eyes = "blank_eyes"
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/abductor //3 darksight.
		)

	flags = HAS_LIPS | NO_BLOOD | NO_BREATHE | NOGUNS

	oxy_mod = 0

	virus_immune = 1
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	blood_color = "#FF5AFF"
	female_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	female_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	female_sneeze_sound = 'sound/effects/mob_effects/sneeze.ogg' //Abductors always scream like guys

/datum/species/abductor/can_understand(mob/other) //Abductors can understand everyone, but they can only speak over their mindlink to another team-member
	return 1

/datum/species/abductor/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER
	if(H.mind)
		H.mind.abductor = new /datum/abductor
	H.languages.Cut() //Under no condition should you be able to speak any language
	H.add_language("Abductor Mindlink") //other than over the abductor's own mindlink
	return ..()

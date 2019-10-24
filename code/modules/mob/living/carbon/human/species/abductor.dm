/datum/species/abductor
	name = "Abductor"
	name_plural = "Abductors"
	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'
	language = "Abductor Mindlink"
	default_language = "Abductor Mindlink"
	eyes = "blank_eyes"
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain/abductor,
		"eyes" =     /obj/item/organ/internal/eyes/abductor //3 darksight.
		)

	species_traits = list(NO_BLOOD, NO_BREATHE, VIRUSIMMUNE, NOGUNS, NO_HUNGER, NO_EXAMINE)
	dies_at_threshold = TRUE

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	blood_color = "#FF5AFF"
	female_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	female_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	female_sneeze_sound = 'sound/effects/mob_effects/sneeze.ogg' //Abductors always scream like guys
	var/team = 1
	var/scientist = FALSE // vars to not pollute spieces list with castes

/datum/species/abductor/can_understand(mob/other) //Abductors can understand everyone, but they can only speak over their mindlink to another team-member
	return TRUE

/datum/species/abductor/on_species_gain(mob/living/carbon/human/H)
	..()
	H.gender = NEUTER
	H.languages.Cut() //Under no condition should you be able to speak any language
	H.add_language("Abductor Mindlink") //other than over the abductor's own mindlink
	var/datum/atom_hud/abductor_hud = huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(H)

/datum/species/abductor/on_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/atom_hud/abductor_hud = huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(H)
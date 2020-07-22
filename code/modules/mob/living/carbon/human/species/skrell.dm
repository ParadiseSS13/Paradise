/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive_form = /datum/species/monkey/skrell

	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."


	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS
	dietflags = DIET_HERB
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	base_color = "#38b661" //RGB: 56, 182, 97.
	default_hair_colour = "#38b661"
	eyes = "skrell_eyes_s"
	//Default styles for created mobs.
	default_hair = "Skrell Male Tentacles"
	reagent_tag = PROCESS_ORG
	butt_sprite = "skrell"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/skrell,
		"lungs" =    /obj/item/organ/internal/lungs/skrell,
		"liver" =    /obj/item/organ/internal/liver/skrell,
		"kidneys" =  /obj/item/organ/internal/kidneys/skrell,
		"brain" =    /obj/item/organ/internal/brain/skrell,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/skrell, //Default darksight of 2.
		"headpocket" = /obj/item/organ/internal/headpocket
		)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their thumbs into their eye sockets!",
		"is twisting their own neck!",
		"makes like a fish and suffocates!",
		"is strangling themselves with their own tendrils!")

/datum/species/skrell/on_species_gain(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, TRAIT_WATERBREATH, "species")

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H)
	..()
	REMOVE_TRAIT(H, TRAIT_WATERBREATH, "species")
/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	language = "Qurvolious"
	primitive_form = /datum/species/monkey/skrell

	blurb = "Skrell are an amphibious species, that come from the planet Jargon 4, a humid planet filled with swamps and archipelagos. \
	Skrell are a highly advanced and logical race who live under the rule of the Qerr'Katish, the main governmental body.<br/><br/> \
	Skrell are herbivores and opulent in nature thanks to central tenets of the Skrellian religion. \
	While classically preferring diplomacy, the Skrell participate in the largest military alliance in the galaxy, the Solar-Central Compact."

	species_traits = list(LIPS, NO_HAIR)
	inherent_traits = list(TRAIT_NOFAT, TRAIT_WATERBREATH)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS | HAS_TAIL | TAIL_OVERLAPPED
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

	meat_type = /obj/item/food/meat/human
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

	plushie_type = /obj/item/toy/plushie/skrellplushie

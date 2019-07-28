/datum/species/human
	name = "Human"
	name_plural = "Humans"
	icobase = 'icons/mob/human_races/r_human.dmi'
	deform = 'icons/mob/human_races/r_def_human.dmi'
	primitive_form = /datum/species/monkey
	language = "Sol Common"
	species_traits = list(LIPS, CAN_BE_FAT)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	dietflags = DIET_OMNI
	male_medic_sounds = list('sound/effects/mob_effects/m_medic.ogg', 'sound/effects/mob_effects/m_medic2.ogg')
	female_medic_sounds = list('sound/effects/mob_effects/f_medic.ogg')
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	reagent_tag = PROCESS_ORG
	//Has standard darksight of 2.
	
/datum/species/human
	name = "Human"
	name_plural = "Humans"
	icobase = 'icons/mob/human_races/r_human.dmi'
	primitive_form = /datum/species/monkey
	language = "Sol Common"
	species_traits = list(LIPS)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_ICON_SKIN_TONE | HAS_BODY_MARKINGS
	dietflags = DIET_OMNI
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	icon_skin_tones = list(
		1 = "Default White",
		2 = "Chestnut",
		3 = "Coffee",
		4 = "Olive",
		5 = "Pale",
		6 = "Beige",
		7 = "Classic",
		8 = "Oliver"
		)
	reagent_tag = PROCESS_ORG


/datum/species/human/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for humans We can't have everyone be white.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/r_human.dmi' //Default White, counts as 1.
		switch(H.s_tone)
			if(8)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Oliverandcompany.dmi'
			if(7)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_classic.dmi'
			if(6)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_beige.dmi'
			if(5)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_pale.dmi'
			if(4)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Olive.dmi'
			if(3)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Coffee.dmi'
			if(2)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_chestnut.dmi'

		H.change_icobase(new_icobase, owner_sensitive) //Update the icobase of all our organs, but make sure we don't mess with frankenstein limbs in doing so.




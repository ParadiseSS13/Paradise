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

	icon_skin_tones = list( //Organized to be from Light to Dark.
		1 = "Default White",
		2 = "Pale",
		3 = "Classic",
		4 = "Olive",
		5 = "Oliver",
		6 = "Beige",
		7 = "Latte",
		8 = "Sienna",
		9 = "Almond",
		10 = "Bronzed",
		11 = "Caramel",
		12 = "Coffee",
		13 = "Chestnut"
		)
	reagent_tag = PROCESS_ORG


/datum/species/human/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for humans We can't have everyone be white.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/r_human.dmi' //Default White, counts as 1.
		switch(H.s_tone)
			if(13)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_chestnut.dmi'
			if(12)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Coffee.dmi'
			if(11)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_caramel.dmi'
			if(10)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_bronzed.dmi'
			if(9)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_almond.dmi'
			if(8)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_sienna.dmi'
			if(7)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_latte.dmi'
			if(6)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_beige.dmi'
			if(5)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Oliverandcompany.dmi'
			if(4)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_Olive.dmi'
			if(3)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_classic.dmi'
			if(2)
				new_icobase = 'icons/mob/human_races/human_skintones/r_human_pale.dmi'

		H.change_icobase(new_icobase, owner_sensitive) //Update the icobase of all our organs, but make sure we don't mess with frankenstein limbs in doing so.




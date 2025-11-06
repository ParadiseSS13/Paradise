/datum/species/human
	name = "Human"
	name_plural = "Humans"
	primitive_form = /datum/species/monkey
	language = "Sol Common"
	species_traits = list(LIPS)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	meat_type = /obj/item/food/meat/human
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_ICON_SKIN_TONE | HAS_BODY_MARKINGS
	dietflags = DIET_OMNI
	blurb = "Humanity, originating from the Sol system, has expanded over five centuries, branching out to forge a variety of governments and powerful corporations. \
	These range from the militaristic Trans-Solar Federation, the Union of Soviet Socialist Planets, and mega corporations like Nanotrasen.<br/><br/> \
	With a constant desire to colonize and spread their influence onto other species, they have begun to develop alliances and enemies, \
	making humans one of the most recognizable and socially diverse species in the sector."

	/// Organized to be from Light to Dark.
	icon_skin_tones = list(
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




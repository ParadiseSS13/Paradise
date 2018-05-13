
/*

Contents:
- The Ninja Space Mask
- Ninja Space Mask speech modification

*/




/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	strip_delay = 120
	burn_state = LAVA_PROOF
	unacidable = TRUE
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi')

/obj/item/clothing/mask/gas/voice/space_ninja/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == slot_wear_mask)
		for(var/datum/atom_hud/antag/H in huds)
			H.add_hud_to(user)

/obj/item/clothing/mask/gas/voice/space_ninja/dropped(mob/living/carbon/human/user)
	..()
	if(istype(user) && user.wear_mask == src)
		for(var/datum/atom_hud/antag/H in huds)
			H.remove_hud_from(user)
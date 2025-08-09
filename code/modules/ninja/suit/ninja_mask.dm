
/*

Contents:
- The Ninja Space Mask

*/

/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja(norm)"
	inhand_icon_state = "s-ninja_mask"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi'
	)
	var/obj/item/voice_changer/voice_changer

/obj/item/clothing/mask/gas/space_ninja/Initialize(mapload)
	. = ..()
	voice_changer = new(src)

/obj/item/clothing/mask/gas/space_ninja/Destroy()
	QDEL_NULL(voice_changer)
	return ..()

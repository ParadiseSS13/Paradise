/obj/item/clothing/mask/breath
	name = "breath mask"
	desc = "A close-fitting mask that can be connected to an air supply."
	icon_state = "breath"
	item_state = "breath"
	flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi',
		"Plasmaman" = 'icons/mob/species/plasmaman/mask.dmi'
		)

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/AltClick(mob/user)
	..()
	if( (!in_range(src, user)) || user.stat || user.restrained() )
		return
	adjustmask(user)

/obj/item/clothing/mask/breath/medical
	name = "medical mask"
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	put_on_delay = 10

/obj/item/clothing/mask/breath/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask."
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list("Vox", "Vox Armalis") //These should fit the "Mega Vox" just fine.
	actions_types = list()

/obj/item/clothing/mask/breath/vox/attack_self(mob/user)
	return

/obj/item/clothing/mask/breath/vox/AltClick(mob/user)
	return

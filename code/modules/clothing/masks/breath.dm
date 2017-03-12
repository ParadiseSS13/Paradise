/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	burn_state = FIRE_PROOF
	species_fit = list("Vox", "Vox Armalis", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/breath/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	put_on_delay = 10
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")

/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list("Vox")
	actions_types = list()

/obj/item/clothing/mask/breath
	name = "breath mask"
	desc = "A close-fitting mask that can be connected to an air supply."
	icon_state = "breath"
	item_state = "breath"
	flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH
	can_toggle = TRUE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Plasmaman" = 'icons/mob/clothing/species/plasmaman/mask.dmi'
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
	species_restricted = list("Vox")
	actions_types = list()

/obj/item/clothing/mask/breath/vox/attack_self(mob/user)
	return

/obj/item/clothing/mask/breath/vox/AltClick(mob/user)
	return

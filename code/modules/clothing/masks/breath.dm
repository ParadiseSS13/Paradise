/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags = MASKCOVERSMOUTH | MASKINTERNALS
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	species_fit = list("Vox")
	action_button_name = "Adjust Breath Mask"
	ignore_maskadjust = 0
	species_fit = list("Vox", "Vox Armalis")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Vox Armalis" = 'icons/mob/species/armalis/mask.dmi',
		)

/obj/item/clothing/mask/breath/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	species_fit = list("Vox")

/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list("Vox")
	action_button_name = null
	ignore_maskadjust = 1

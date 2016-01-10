/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	item_state = "balaclava"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	action_button_name = "Adjust Balaclava"
	ignore_maskadjust = 0
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/balaclava/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	item_state = "luchag"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	item_state = "luchador"
	species_fit = list("Vox")

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	item_state = "luchar"
	species_fit = list("Vox")
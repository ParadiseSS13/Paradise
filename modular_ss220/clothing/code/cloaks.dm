/obj/item/clothing/suit/mantle/armor/captain/black
	name = "чёрная капитанская мантия"
	desc = "Носится верховным лидером станции NSS Cyberiad."
	icon = 'modular_ss220/clothing/icons/object/cloaks.dmi'
	icon_state = "capcloak_black"
	icon_override = 'modular_ss220/clothing/icons/mob/cloaks.dmi'
	item_state = "capcloak_black"

/obj/item/clothing/suit/mantle/armor/captain/black/Initialize(mapload)
	. = ..()
	desc = "Носится верховным лидером станции [station_name()]."

/* EI cloak */
/obj/item/clothing/suit/hooded/ei_cloak
	name = "плащ Gold On Black"
	desc = "Корпоративный плащ, выполненный в угольных тонах все с тем же золотым покрытием и специальным логотипом от Etamin Industry – золотой звездой."
	icon = 'modular_ss220/clothing/icons/object/cloaks.dmi'
	icon_state = "ei_cloak"
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/cloaks.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/cloaks.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/cloaks.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/cloaks.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/cloaks.dmi',
	)
	hoodtype = /obj/item/clothing/head/hooded/ei_hood

/obj/item/clothing/head/hooded/ei_hood
	name = "капюшон Gold On Black"
	desc = "Капюшон, прикрепленный к плащу Gold On Black."
	icon = 'modular_ss220/clothing/icons/object/hats.dmi'
	icon_state = "ei_hood"
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/species/tajaran/hats.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/hats.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/hats.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/hats.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/hats.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/hats.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/hats.dmi',
	)
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

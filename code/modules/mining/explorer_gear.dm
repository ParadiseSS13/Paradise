/****************Explorer's Suit and Mask****************/
/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe)
	resistance_flags = FIRE_PROOF
	hide_tail_by_species = list("Vox" , "Vulpkanin" , "Unathi" , "Tajaran")

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Drask" = 'icons/mob/species/drask/suit.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi'
	)

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = HEAD
	flags = BLOCKHAIR | NODROP
	flags_cover = HEADCOVERSEYES
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi',
		"Drask" = 'icons/mob/species/drask/head.dmi',
		"Grey" = 'icons/mob/species/grey/head.dmi',
		"Skrell" = 'icons/mob/species/skrell/head.dmi'
	)
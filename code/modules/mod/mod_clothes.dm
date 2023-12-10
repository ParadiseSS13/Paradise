/obj/item/clothing/head/mod
	name = "MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-helmet"
	base_icon_state = "helmet"
	item_state = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	icon_override = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/modsuit/species/grey_helmets.dmi',
		"Vulpkanin" = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		"Tajaran" = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		"Unathi" = 'icons/mob/clothing/modsuit/species/modsuits_younahthee.dmi',
		"Vox" = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)

/obj/item/clothing/suit/mod
	name = "MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-chestplate"
	base_icon_state = "chestplate"
	item_state = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	icon_override = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/flashlight,
		/obj/item/tank/jetpack/oxygen/captain,
	)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	heat_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	hide_tail_by_species = list("modsuit")
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		"Tajaran" = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		"Unathi" = 'icons/mob/clothing/modsuit/species/modsuits_younahthee.dmi',
		"Vox" = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)


/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-gauntlets"
	base_icon_state = "gauntlets"
	item_state = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	icon_override = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		"Tajaran" = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		"Unathi" = 'icons/mob/clothing/modsuit/species/modsuits_younahthee.dmi',
		"Vox" = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)


/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-boots"
	base_icon_state = "boots"
	item_state = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	icon_override = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		"Tajaran" = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		"Unathi" = 'icons/mob/clothing/modsuit/species/modsuits_younahthee.dmi',
		"Vox" = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)
	var/magbooted

/obj/item/clothing/shoes/mod/negates_gravity()
	return magbooted

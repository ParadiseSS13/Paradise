/obj/item/clothing/head/atmta/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmetmaterials"
	flags = HEADCOVERSEYES | HEADBANGPROTECT
	item_state = "helmetmaterials"
	armor = list(melee = 30, bullet = 25, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)

/obj/item/clothing/head/atmta/helmet/hunter
	name = "Hunter's hat"
	desc = "A fine piece of hunter attire that provides stable defence to anyone facing Yharnam's beastly threat."
	icon_state = "hunter_hat"
	item_state = "hunter_hat"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 0, bomb = 0, bio = 50, rad = 50)
	flags_inv = HIDEEARS|HIDEEYES
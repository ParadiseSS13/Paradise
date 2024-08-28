/obj/item/clothing/gloves/vox
	name = "vox gauntlets"
	desc = "Плотные рукавицы причудливой формы с когтями."
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	item_color = "gloves-vox"
	icon = 'modular_ss220/antagonists/icons/clothing/obj_gloves.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/gloves.dmi')
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 30, BULLET = 0, LASER = 10, ENERGY = 10, BOMB = 0, RAD = 0, FIRE = 200, ACID = 50)

/obj/item/clothing/gloves/color/yellow/vox
	name = "insulated vox gauntlets"
	desc = "Плотные изоляционные рукавицы причудливой формы с когтями."
	icon_state = "gloves-vox-insulated"
	item_state = "gloves-vox"
	item_color = "gloves-vox-insulated"
	icon = 'modular_ss220/antagonists/icons/clothing/obj_gloves.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/gloves.dmi')
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	armor = list(MELEE = 30, BULLET = 0, LASER = 25, ENERGY = 25, BOMB = 0, RAD = 0, FIRE = 200, ACID = 50)

/datum/modpack/clothing
	name = "Одежда"
	desc = "Всё для модного приговора."
	author = "Aylong220, Yata9arasu"

/datum/modpack/clothing/initialize()
	. = ..()
	GLOB.cloth_recipes += list(
		new /datum/stack_recipe("полотенце", /obj/item/clothing/under/towel/long, 4, time = 1 SECONDS)
	)

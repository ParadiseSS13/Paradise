/datum/modpack/clothing
	name = "Одежда"
	desc = "Всё для модного приговора."
	author = "Aylong, Yata9arasu, Dekupich"

/datum/modpack/clothing/initialize()
	. = ..()
	GLOB.cloth_recipes += list(
		new /datum/stack_recipe("полотенце", /obj/item/clothing/under/towel/long, 4, time = 1 SECONDS)
	)

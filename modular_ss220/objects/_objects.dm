/datum/modpack/objects
	name = "Объекты"
	desc = "В основном включает в себя портированные объекты и всякие мелочи, которым не нужен отдельный модпак."
	author = "dj-34"

// Maybe it would be better, if i didn't make it modular, because i can't change order in the recipe list :catDespair:
/datum/modpack/objects/initialize()
	GLOB.metal_recipes += list(
		new /datum/stack_recipe("metal platform", /obj/structure/platform, 4, time = 3 SECONDS,one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("metal platform corner", /obj/structure/platform/corner, 2, time = 20, one_per_turf = TRUE, on_floor = TRUE)
	)

	GLOB.plasteel_recipes += list(
		new /datum/stack_recipe("reinforced plasteel platform", /obj/structure/platform/reinforced, 4, time = 4 SECONDS,one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("reinforced plasteel platform corner", /obj/structure/platform/reinforced/corner, 2, time = 30,one_per_turf = TRUE, on_floor = TRUE)
	)

	GLOB.wood_recipes += list(
		new /datum/stack_recipe("tribune", /obj/structure/tribune, 5, time = 5 SECONDS, one_per_turf = TRUE, on_floor = TRUE)
	)

	GLOB.plastic_recipes += list(
		new /datum/stack_recipe("пластиковый стул", /obj/structure/chair/plastic, time = 2 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	)

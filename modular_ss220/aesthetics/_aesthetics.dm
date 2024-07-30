/datum/modpack/aesthetics
	name = "Эстетика"
	desc = "Обновление визуального ряда"
	author = "larentoun, Aylong220"

/datum/modpack/aesthetics/initialize()
	for(var/datum/stack_recipe/recipe in GLOB.wood_recipes)
		if(recipe.result_type == /obj/item/stack/tile/wood)
			GLOB.wood_recipes -= recipe
			qdel(recipe)
			break

	GLOB.wood_recipes += list(
		null,
		new /datum/stack_recipe_list("Деревянный пол", list(
			new /datum/stack_recipe("Обычный деревянный пол", /obj/item/stack/tile/wood, 1, 4),
			new /datum/stack_recipe("Дубовый деревянный пол", /obj/item/stack/tile/wood/oak, 1, 4),
			new /datum/stack_recipe("Берёзовый деревянный пол", /obj/item/stack/tile/wood/birch, 1, 4),
			new /datum/stack_recipe("Вишнёвый деревянный пол", /obj/item/stack/tile/wood/cherry, 1, 4),
			)),
		new /datum/stack_recipe_list("Деревянный пол (Цельный)", list(
			new /datum/stack_recipe("Обычный цельный деревянный пол", /obj/item/stack/tile/wood/fancy, 1, 4),
			new /datum/stack_recipe("Дубовый цельный деревянный пол", /obj/item/stack/tile/wood/fancy/oak, 1, 4),
			new /datum/stack_recipe("Берёзовый цельный деревянный пол", /obj/item/stack/tile/wood/fancy/birch, 1, 4),
			new /datum/stack_recipe("Вишнёвый цельный деревянный пол", /obj/item/stack/tile/wood/fancy/cherry, 1, 4),
			)),
		new /datum/stack_recipe_list("Паркет", list(
			new /datum/stack_recipe("Обычный паркет", /obj/item/stack/tile/wood/parquet, 1, 4),
			new /datum/stack_recipe("Дубовый паркет", /obj/item/stack/tile/wood/parquet/oak, 1, 4),
			new /datum/stack_recipe("Берёзовый паркет", /obj/item/stack/tile/wood/parquet/birch, 1, 4),
			new /datum/stack_recipe("Вишнёвый паркет", /obj/item/stack/tile/wood/parquet/cherry, 1, 4),
			)),
		new /datum/stack_recipe_list("Паркет (Классический)", list(
			new /datum/stack_recipe("Классический обычный паркет", /obj/item/stack/tile/wood/parquet/tile, 1, 4),
			new /datum/stack_recipe("Классический дубовый паркет", /obj/item/stack/tile/wood/parquet/tile/oak, 1, 4),
			new /datum/stack_recipe("Классический берёзовый паркет", /obj/item/stack/tile/wood/parquet/tile/birch, 1, 4),
			new /datum/stack_recipe("Классический вишнёвый паркет", /obj/item/stack/tile/wood/parquet/tile/cherry, 1, 4),
			)),
		null)


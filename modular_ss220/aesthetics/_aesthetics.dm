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
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Деревянный пол (Цельный)", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/fancy, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/fancy/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/fancy/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/fancy/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый ", /obj/item/stack/tile/wood/fancy/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый ", /obj/item/stack/tile/wood/fancy/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый ", /obj/item/stack/tile/wood/fancy/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый ", /obj/item/stack/tile/wood/fancy/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Паркет", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/parquet, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/parquet/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/parquet/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/parquet/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/parquet/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/parquet/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/parquet/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/parquet/guaiacum, 5, 4, 20),
			)),
		new /datum/stack_recipe_list("Паркет (Классический)", list(
			new /datum/stack_recipe("Обычный", /obj/item/stack/tile/wood/parquet/tile, 1, 4, 20),
			new /datum/stack_recipe("Дубовый", /obj/item/stack/tile/wood/parquet/tile/oak, 1, 4, 20),
			new /datum/stack_recipe("Берёзовый", /obj/item/stack/tile/wood/parquet/tile/birch, 1, 4, 20),
			new /datum/stack_recipe("Вишнёвый", /obj/item/stack/tile/wood/parquet/tile/cherry, 1, 4, 20),
			new /datum/stack_recipe("Амарантовый", /obj/item/stack/tile/wood/parquet/tile/amaranth, 1, 4, 20),
			new /datum/stack_recipe("Эбонитовый", /obj/item/stack/tile/wood/parquet/tile/ebonite, 5, 4, 20),
			new /datum/stack_recipe("Умниниевый", /obj/item/stack/tile/wood/parquet/tile/pink_ivory, 5, 4, 20),
			new /datum/stack_recipe("Бакаутовый", /obj/item/stack/tile/wood/parquet/tile/guaiacum, 5, 4, 20),
			)),
		null)


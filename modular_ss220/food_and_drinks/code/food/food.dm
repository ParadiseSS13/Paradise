// Reagent Grinder
/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	blend_items = list(/obj/item/food/grown/buckwheat = list("buckwheat" = -5)) + blend_items

// Vending
/obj/machinery/economy/vending/dinnerware/Initialize(mapload)
	products += list(
		/obj/item/reagent_containers/condiment/herbs = 2,)
	. = ..()

/obj/machinery/economy/vending/snack/Initialize(mapload)
	products += list(
		/obj/item/food/fancy/doshik = 6,
		/obj/item/food/fancy/doshik_spicy = 6,)
	prices += list(
		/obj/item/food/fancy/doshik = 100,
		/obj/item/food/fancy/doshik_spicy = 120,)
	. = ..()

// Boiled Buckwheat
/obj/item/food/boiledbuckwheat
	name = "варёная гречка"
	desc = "Это просто варёная гречка, ничего необычного."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "boiledbuckwheat"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("гречка" = 1)

/datum/cooking/recipe/boiledbuckwheat
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledbuckwheat
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("buckwheat", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

// Merchant Buckwheat
/obj/item/food/buckwheat_merchant
	name = "гречка по-купечески"
	desc = "Тушёная гречка с овощами и мясом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "buckwheat_merchant"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 5, "protein" = 2, "vitamin" = 3)
	tastes = list("гречка" = 2, "мясо" = 2, "томатный соус" = 1)

/datum/cooking/recipe/buckwheat_merchant
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/buckwheat_merchant
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("buckwheat", 10),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

// Olivier Salad
/obj/item/food/oliviersalad
	name = "салат оливье"
	desc = "Не трогай, это на новый год!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "kelotane" = 2, "vitamin" = 2)
	tastes = list("варёная картошка" = 1, "огурец" = 1, "морковка" = 1, "яйцо" = 1, "Новый Год" = 1)

/datum/cooking/recipe/oliviersalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/oliviersalad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/pickles),
		PCWJ_ADD_ITEM(/obj/item/food/boiledegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
	)

// Weird Olivier Salad
/obj/item/food/weirdoliviersalad
	name = "странный салат оливье"
	desc = "Что ты сделал с этим оливье, чудовище?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "kelotane" = 2, "vitamin" = 2)
	tastes = list("варёная картошка" = 1, "огурец" = 1, "морковка" = 1, "яйцо" = 1, "Новый Год" = 1)


/datum/cooking/recipe/weirdoliviersalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/weirdoliviersalad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/pickles),
		PCWJ_ADD_ITEM(/obj/item/food/boiledegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
	)

// Vegetable Salad
/obj/item/food/vegisalad
	name = "овощной салат"
	desc = "Идеальная комбинация томатов и огурцов."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "kelotane" = 1, "vitamin" = 1)
	tastes = list("томат" = 2, "маринованные огурцы" = 2, "сметана" = 2)

/datum/cooking/recipe/vegisalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/vegisalad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cucumber),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
	)

// Pickles
/obj/item/food/pickles
	name = "маринованные огурцы"
	desc = "Черт, тут много маринованных огурчиков."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "pickles"
	trash = /obj/item/food/brine
	filling_color = "#C2CFAB"
	bitesize = 8
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("маринованые огурцы" = 1)

/obj/item/food/brine
	name = "рассол"
	desc = "Самое то после бурной ночи."
	consume_sound = 'sound/items/drink.ogg'
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "brine"
	filling_color = "#C2CFAB"
	bitesize = 4
	list_reagents = list("nutriment" = 1, "antihol" = 2)
	tastes = list("рассол" = 3)

/datum/crafting_recipe/pickles
	name = "Маринованные огурцы"
	result = list(/obj/item/food/pickles)
	reqs = list(
		/obj/item/food/grown/cucumber = 3,
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sodiumchloride = 10)
	time = 1 SECONDS
	category = CAT_FOOD
	subcategory = CAT_MISCFOOD

// Pickle Soup
/obj/item/food/soup/rassolnik
	name = "рассольник"
	desc = "Популярен в СССП."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "rassolnik"
	filling_color = "#F1FC72"
	list_reagents = list("nutriment" = 4, "kelotane" = 1, "vitamin" = 2)
	tastes = list("картошка" = 1, "огурцы" = 1, "рис" = 1)

/datum/cooking/recipe/rassolnik
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/rassolnik
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cucumber),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("rice", 5),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

// Doner
/obj/item/food/shawarma
	name = "шаурма"
	desc = "Великолепное сочетание мяса с гриля и свежих овощей. Не спрашивайте о мясе."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "shawarma"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "мясо" = 2, "овощи" = 1)

/datum/cooking/recipe/shawarma
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/shawarma
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Doner - Cheese
/obj/item/food/doner_cheese
	name = "сырная шаурма"
	desc = "Фирменное блюдо от шеф-повара - мясо с гриля и свежие овощи с теплым сырным соусом. Вкусно!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "doner_cheese"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 6, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "сыр" = 2, "мясо" = 2, "овощи" = 1)

/datum/cooking/recipe/doner_cheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/doner_cheese
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Doner - Mushroom
/obj/item/food/doner_mushroom
	name = "шаурма с грибами"
	desc = "Мясо с гриля, свежие овощи и грибы. Грибы немного вытеснили мясо, но всё так же вкусно!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "doner_mushroom"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "plantmatter" = 2, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "мясо" = 2, "овощи" = 2, "томат" = 1)

/datum/cooking/recipe/doner_mushroom
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/doner_mushroom
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Doner - Vegetable
/obj/item/food/doner_vegan
	name = "овощная шаурма"
	desc = "Свежие овощи, завернутые в длинный рулет. Мясо в комплект не входит!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "doner_vegan"
	filling_color = "#c0720c"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "vitamin" = 4, "tomatojuice" = 8)
	tastes = list("овощи" = 2, "томат" = 1, "перец" = 1)

/datum/cooking/recipe/doner_vegan
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/doner_vegan
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Slime Pie
/obj/item/food/sliceable/slimepie
	name = "слаймовый пирог"
	desc = "Блюрп блоб блуп блеп блоп. Можно нарезать."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "slimepie"
	slice_path = /obj/item/food/slimepieslice
	slices_num = 5
	bitesize = 3
	filling_color = "#00d9ff"
	list_reagents = list("nutriment" = 12, "vitamin" = 4)
	tastes = list("слизь" = 5, "сладость" = 1, "желе" = 1)

/obj/item/food/slimepieslice
	name = "кусочек слаймового пирога"
	desc = "Блюрп блоб блуп блеп блоп."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "slimepieslice"
	trash = /obj/item/trash/plate
	filling_color = "#00d9ff"
	tastes = list("слизь" = 5, "сладость" = 1, "желе" = 1)

/datum/cooking/recipe/slimepie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/slimepie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/organ/internal/brain/slime),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("custard", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Kidan Ragu
/obj/item/food/kidanragu
	name = "острое хитиновое рагу"
	desc = "Рагу из очень жесткого хитинового мяса и тушеных овощей."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "kidanragu"
	list_reagents = list("nutriment" = 6, "vitamin" = 2, "protein" = 4)
	tastes = list("насекомое" = 3, "овощи" = 2)

/datum/cooking/recipe/kidan_ragu
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/kidanragu
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/organ/internal/heart/kidan),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_STOVE(J_LO, 30 SECONDS),
	)

// Fried Unathi Meat
/obj/item/food/sliceable/lizard
	name = "жареное мясо унатха"
	desc = "Сочный стейк из мяса крупной ящерицы, вызывающий желание полежать на теплых камнях. Можно нарезать."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "lizard_steak"
	slice_path = /obj/item/food/lizardslice
	slices_num = 5
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("мясо ящерицы" = 4, "курятина" = 2)

/obj/item/food/lizardslice
	name = "стейк из унатха"
	desc = "Порция мяса унатхи."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "lizard_slice"
	trash = /obj/item/trash/plate
	filling_color = "#a55f3a"
	tastes = list("мясо ящерицы" = 2, "курятина" = 1)

/datum/cooking/recipe_step/add_item/lizardslice

/datum/cooking/recipe_step/add_item/lizardslice/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/organ/external/external = added_item
	if(!istype(external))
		return PCWJ_CHECK_INVALID

	if(istype(external.dna.species, /datum/species/unathi))
		return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe/lizardslice
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/lizardslice
	steps = list(
		new /datum/cooking/recipe_step/add_item/lizardslice(),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)
	appear_in_default_catalog = FALSE

// Tajaroni
/obj/item/food/tajaroni
	name = "таярони"
	desc = "Острая вяленая колбаса с перцем и... Оно только что мяукнуло?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "tajaroni"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 2)
	tastes = list("сухое мясо" = 3, "кошатина" = 2)

/datum/cooking/recipe_step/add_item/tajaroni

/datum/cooking/recipe_step/add_item/tajaroni/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/organ/external/external = added_item
	if(!istype(external))
		return PCWJ_CHECK_INVALID

	if(istype(external.dna.species, /datum/species/tajaran))
		return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe/tajaroni
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/tajaroni
	steps = list(
		new /datum/cooking/recipe_step/add_item/tajaroni(),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)
	appear_in_default_catalog = FALSE

// Vulpixes
/obj/item/food/vulpix
	name = "вульпиксы"
	desc = "Аппетитно выглядящие мясные шарики в тесте... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "vulpix"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3)

/datum/cooking/recipe/vulpix
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/vulpix
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/liver/vulpkanin),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("tomato_sauce", 1),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

// Cheese Vulpixes
/obj/item/food/vulpix/cheese
	name = "сырные вульпиксы"
	desc = "Аппетитно выглядящие мясные шарики в тесте с начинкой из сыра... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "vulpix_cheese"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "сыр" = 2)

/datum/cooking/recipe/vulpixcheese
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/vulpix/cheese
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/liver/vulpkanin),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("cheese_sauce", 1),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

// Bacon Vulpixes
/obj/item/food/vulpix/bacon
	name = "вульпиксы с беконом"
	desc = "Аппетитно выглядящие мясные шарики в тесте с начинкой... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "vulpix_bacon"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "бекон" = 2, "грибы" = 2)

/datum/cooking/recipe/vulpixbacon
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/vulpix/bacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/liver/vulpkanin),
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("mushroom_sauce", 1),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

// Chilli Vulpixes
/obj/item/food/vulpix/chilli
	name = "вульпиксы-чилли"
	desc = "Аппетитно выглядящие мясные шарики в тесте... Главное - не думать о том, из кого они сделаны! Язык обжигает."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "vulpix_chillie"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "чилли" = 2)

/datum/cooking/recipe/vulpixchilli
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/vulpix/chilli
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/liver/vulpkanin),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("diablo_sauce", 1),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

// Seafood Pizza
/obj/item/food/sliceable/pizza/seafood
	name = "пицца с морепродуктами"
	desc = "Дары космических озер, сыр и немного кислинки."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "fishpizza"
	slice_path = /obj/item/food/seapizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("чеснок" = 1, "сыр" = 2, "морепродукты" = 1, "кислинка" = 1)

/obj/item/food/seapizzaslice
	name = "кусочек пиццы с морепродуктами"
	desc = "Аппетитный кусочек пиццы с морепродуктами и сыром..."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "fishpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("чеснок" = 1, "сыр" = 2, "морепродукты" = 1, "кислинка" = 1)

/datum/cooking/recipe/seapizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/seafood
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/food/boiled_shrimp),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("garlic_sauce", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Bacon Pizza
/obj/item/food/sliceable/pizza/bacon
	name = "пицца с беконом"
	desc = "Классическая пицца, один из ингредиентов которой был заменен на жареный бекон."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "baconpizza"
	slice_path = /obj/item/food/baconpizzaslice
	list_reagents = list("nutriment" = 40, "vitamin" = 5, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("грибы" = 1, "сыр" = 2, "бекон" = 1)

/obj/item/food/baconpizzaslice
	name = "кусочек пиццы с беконом"
	desc = "Аппетитный кусок пиццы с беконом и грибами..."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "baconpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("грибы" = 1, "сыр" = 2, "бекон" = 1)

/datum/cooking/recipe/baconpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/bacon
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_ADD_REAGENT("mushroom_sauce", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Pizza Tajaroni
/obj/item/food/sliceable/pizza/tajaroni
	name = "пицца с таярони"
	desc = "Острые колбаски таярони с сыром и оливками. Что из этого ужаснее, еще предстоит решить."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "tajarpizza"
	slice_path = /obj/item/food/tajpizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("томат" = 1, "сыр" = 2, "таярони" = 1, "оливки" = 1)

/obj/item/food/tajpizzaslice
	name = "кусочек пиццы с таярони"
	desc = "Вкуснейший кусок пиццы с таярони и оливками..."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "tajarpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("томат" = 1, "сыр" = 2, "таярони" = 1, "оливки" = 1)

/datum/cooking/recipe/tajarpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/tajaroni
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/tajaroni),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/olive),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("tomato_sauce", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Diablo Pizza
/obj/item/food/sliceable/pizza/diablo
	name = "пицца 'Диабло'"
	desc = "Невероятно жгучая пицца с кусочками мяса, некоторые утверждают, что она может отправить вас в рэдспейс."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "diablopizza"
	slice_path = /obj/item/food/diablopizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15, "capsaicin" = 15)
	filling_color = "#ffe45d"
	tastes = list("остроту" = 1, "сыр" = 2, "мясо" = 1, "специи" = 1)

/obj/item/food/diablopizzaslice
	name = "кусочек пиццы 'Диабло'"
	desc = "Аппетитный кусок пиццы с соусом 'Диабло' и мясом..."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "diablopizzaslice"
	filling_color = "#ffe45d"
	tastes = list("остроту" = 1, "сыр" = 2, "мясо" = 1, "специи" = 1)

/datum/cooking/recipe/diablopizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/diablo
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_REAGENT("herbsmix", 1),
		PCWJ_ADD_REAGENT("diablo_sauce", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Chocolate Cake
/obj/item/food/sliceable/choccherrycake
	name = "шоколадно-вишневый торт"
	desc = "Ещё один торт. Тем не менее."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "choccherrycake"
	slice_path = /obj/item/food/choccherrycakeslice
	slices_num = 6
	bitesize = 3
	filling_color = "#5e1706"
	tastes = list("вишня" = 5, "сладость" = 1, "шоколад" = 1)
	list_reagents = list("nutriment" = 12, "sugar" = 4, "cocoa" = 4)

/obj/item/food/choccherrycakeslice
	name = "кусочек шоколадно-вишневого торта"
	desc = "Кусочек очередного торта. Подождите, что?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "choccherrycake_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"

/datum/cooking/recipe/choccherrycake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/choccherrycake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("flour", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Noel
/obj/item/food/sliceable/noel
	name = "Bûche de Noël"
	desc = "Что?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "noel"
	trash = /obj/item/trash/tray
	slice_path = /obj/item/food/noelslice
	slices_num = 5
	filling_color = "#5e1706"
	tastes = list("шоколад" = 3, "сладость" = 2, "яйца" = 1, "ягоды" = 2)
	list_reagents = list("nutriment" = 6, "plantmatter" = 2, "cocoa" = 2, "cream" = 3, "sugar" = 3, "berryjuice" = 3)

/obj/item/food/noelslice
	name = "кусочек Noël"
	desc = "Кусочек чего?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "noel_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"
	bitesize = 2

/datum/cooking/recipe/noel
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/noel
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("flour", 15),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Sundae
/obj/item/food/sundae
	name = "Сандей"
	desc = "Сливочное удовольствие."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "sundae"
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 4, "plantmatter" = 2, "bananajucie" = 4, "cream" = 3)
	tastes = list("банан" = 1, "вишня" = 1, "крем" = 1)
	bitesize = 5

/datum/cooking/recipe/sundae
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sundae
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/dough),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

// Bun-Bun
/obj/item/food/bunbun
	name = "Бун-Бун"
	desc = "Маленькая хлебная обезьянка, сформованная из двух булочек для гамбургеров."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "bunbun"
	list_reagents = list("nutriment" = 2)
	tastes = list("тесто" = 2)
	bitesize = 2

/datum/cooking/recipe/bunbun
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bunbun
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Tortilla
/obj/item/food/tortilla
	name = "тортилья"
	desc = "Hasta la vista, baby"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "tortilla"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 4)
	tastes = list("кукуруза" = 2)
	bitesize = 2

/datum/cooking/recipe/tortilla
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/tortilla
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_GRILL(J_MED, 5 SECONDS),
	)

// Nachos
/obj/item/food/nachos
	name = "начос"
	desc = "Хола!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "nachos"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 4, "salt" = 1)
	tastes = list("кукуруза" = 2)
	bitesize = 3

/datum/cooking/recipe/nachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/nachos
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Cheese Nachos
/obj/item/food/cheesenachos
	name = "сырные начос"
	desc = "Сырное хола!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "cheesenachos"
	trash = /obj/item/trash/plate
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 6, "salt" = 1)
	tastes = list("кукуруза" = 1, "сыр" = 2)
	bitesize = 4

/datum/cooking/recipe/cheesenachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cheesenachos
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Cuban Nachos
/obj/item/food/cubannachos
	name = "кубинские начос"
	desc = "Очень острое хола!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "cubannachos"
	trash = /obj/item/trash/plate
	filling_color = "#ec5c23"
	list_reagents = list("nutriment" = 6, "salt" = 1, "capsaicin" = 2, "plantmatter" = 1)
	tastes = list("кукуруза" = 1, "чили" = 2)
	bitesize = 4

/datum/cooking/recipe/cubannachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cubannachos
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Carne Buritto
/obj/item/food/carneburrito
	name = "Carne de burrito asado"
	desc = "Как классический буррито, но с мясом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "carneburrito"
	filling_color = "#69250b"
	list_reagents = list("nutriment" = 8, "protein" = 2, "soysauce" = 1)
	tastes = list("кукуруза" = 1, "мясо" = 2, "бобы" = 1)
	bitesize = 4

/datum/cooking/recipe/carneburrito
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/carneburrito
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Cheese Buritto
/obj/item/food/cheeseburrito
	name = "сырное буритто"
	desc = "Нужно ли здесь что-то говорить?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "cheeseburrito"
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 10, "milk" = 2)
	tastes = list("кукуруза" = 1, "бобы" = 1, "сыр" = 2)
	bitesize = 4

/datum/cooking/recipe/cheeseburrito
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/cheeseburrito
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Plasma Buritto
/obj/item/food/plasmaburrito
	name = "Fuego Plasma Burrito"
	desc = "Очень острое, амигос."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "plasmaburrito"
	filling_color = "#f35a46"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "capsaicin" = 4)
	tastes = list("кукуруза" = 1, "бобы" = 1, "чили" = 2)
	bitesize = 4

/datum/cooking/recipe/plasmaburrito
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/plasmaburrito
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

// Pelmeni
/obj/item/food/pelmeni
	name = "пельмени"
	desc = "Мясо завёрнутое в тесто."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "pelmeni"
	filling_color = "#d9be29"
	list_reagents = list("protein" = 2)
	bitesize = 2
	tastes = list("сырое мясо" = 1, "сырое тесто" = 1)

/obj/item/food/sliced/dough/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/rawcutlet))
		new /obj/item/food/pelmeni(src)
		to_chat(user, "Вы сделали немного пельменей.")
		qdel(src)
		qdel(I)
	else
		..()

/obj/item/food/boiledpelmeni
	name = "варёные пельмени"
	desc = "Мы не знаем, какой была Сибирь, но эти вкусные пельмени определенно прибыли оттуда."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "boiledpelmeni"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d9be29"
	list_reagents = list("protein" = 5)
	bitesize = 3
	tastes = list("мясо" = 2, "тесто" = 2)

/datum/cooking/recipe/pelmeni
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledpelmeni
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/pelmeni),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

// Smoked Sausage
/obj/item/food/smokedsausage
	name = "копчёная колбаска"
	desc = "Кусок копченой колбасы. Под пивко пойдёт."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "smokedsausage"
	list_reagents = list("protein" = 12)
	tastes = list("мясо" = 3)

/datum/cooking/recipe/smokedsausage
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/smokedsausage
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
		PCWJ_ADD_REAGENT("blackpepper", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)
// Salami
/obj/item/food/sliceable/salami
	name = "салями"
	desc = "Не лучший выбор для сэндвича."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "salami"
	slice_path = /obj/item/food/slice/salami
	slices_num = 6
	list_reagents = list("protein" = 12)
	tastes = list("мясо" = 3, "чеснок" = 1)

/obj/item/food/slice/salami
	name = "ломтик салями"
	desc = "Лучший выбор для сэндвича."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "salami_s"
	bitesize = 2

/datum/cooking/recipe/salami
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/salami
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/smokedsausage),
		PCWJ_ADD_REAGENT("garlic_sauce", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// Fruit Cup
/obj/item/food/fruitcup
	name = "фруктовая кружка"
	desc = "Фруктовый салат со съедобной кружкой."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "fruitcup"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 4, "watermelonjuice" = 5, "orangejuice" = 5, "vitamin" = 4)
	tastes = list("яблоко" = 2, "банан" = 2, "арбуз" = 2, "лимон" = 1, "амброзия" = 1)
	bitesize = 4

/datum/cooking/recipe/fruitcup
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/fruitcup
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/watermelon),
	)

// Jungle Salad
/obj/item/food/junglesalad
	name = "салат 'Джунгли'"
	desc = "Из глубин джунглей."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "junglesalad"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 6, "watermelonjuice" = 3, "vitamin" = 4)
	tastes = list("яблоко" = 1, "банан" = 2, "арбуз" = 1)

/datum/cooking/recipe/junglesalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/junglesalad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/watermelon),
	)

// Delight Salad
/obj/item/food/delightsalad
	name = "cалат 'Восторг'"
	desc = "Настоящий цитрусовый восторг."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "delightsalad"
	filling_color = "#C2CFAB"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 4, "lemonjuice" = 4, "orangejuice" = 4, "vitamin" = 4, "limejuice" = 4)
	tastes = list("лимон" = 1, "лайм" = 2, "апельсин" = 1)
	bitesize = 4

/datum/cooking/recipe/delightsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/delightsalad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
	)

// Chowmein
/obj/item/food/chowmein
	name = "чау-мейн"
	desc = "Nihao!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "chowmein"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 6, "protein" = 2)
	tastes = list("лапша" = 1, "морковка" = 1, "капуста" = 1, "мясо" = 1)
	bitesize = 3

/datum/cooking/recipe/chowmein
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/chowmein
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_USE_STOVE(J_HI, 10 SECONDS),
	)

// Beef Noodles
/obj/item/food/beefnoodles
	name = "лапша с говядиной"
	desc = "Так просто и так вкусно!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "beefnoodles"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 4, "protein" = 4, "plantmatter" = 3)
	tastes = list("лапша" = 1, "капуста" = 1, "мясо" = 2)
	bitesize = 2

/datum/cooking/recipe/beefnoodles
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/beefnoodles
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

// Father's Soup
/obj/item/food/fathersoup
	name = "батин суп"
	desc = "Адовое блюдо, усреднённый рецепт ибо вариаций масса. Ух бля."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "fathersoup"
	trash = /obj/item/trash/pan
	filling_color = "#f85210"
	list_reagents = list("nutriment" = 4, "protein" = 2, "plantmatter" = 4, "thermite" = 2)
	tastes = list("перец" = 4, "чеснок" = 2, "томат" = 2)
	bitesize = 5

/datum/cooking/recipe/fathersoup
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/fathersoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/soup/tomatosoup),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/garlic),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_ADD_REAGENT("blackpepper", 5),
		PCWJ_USE_STOVE(J_HI, 20 SECONDS), // жарим до дыма //
	)

/obj/item/food/fathersoup/On_Consume(mob/M, mob/user)
	. = ..()
	user.visible_message(span_notice("У [M] на лбу аж пот выступает."))
	if(prob(33))
		var/soup_talk = "Ух бля..."
		M.say(soup_talk)
	if(prob(33))
		M.emote("fart")

/obj/item/trash/pan
	name = "дырявая сковорода"
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "pan"

/obj/item/food/soup/sawdust_soup
	name = "суп из опилок"
	desc = "Отчаянные времена требуют отчаянных мер..."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "sawdustsoup"
	lefthand_file = 'modular_ss220/food_and_drinks/icons/food_lefthand.dmi'
	righthand_file = 'modular_ss220/food_and_drinks/icons/food_righthand.dmi'
	filling_color = "#fae4b5"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("water" = 10, "nutriment" = 2, "vitamin" = 1)
	tastes = list("опилки" = 1)
	goal_difficulty = FOOD_GOAL_SKIP

/datum/cooking/recipe/sawdust_soup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/sawdust_soup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/sheet/wood),
		PCWJ_ADD_REAGENT("water", 20),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

/obj/item/food/soup/sawdust_soup/On_Consume(mob/M, mob/user)
	. = ..()
	var/mob/living/carbon/consumer = user
	if(prob(5))
		consumer.vomit(nutritional_value * 2.5)

// Infinite Pizza Box
/obj/item/pizzabox/infinite
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF

/obj/item/pizzabox/infinite/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_deadsay("Эта коробка для пиццы является аномальной и будет производить бесконечное количество пиццы.")

/obj/item/pizzabox/infinite/attack_self__legacy__attackchain(mob/living/user)
	QDEL_NULL(pizza)
	if(ishuman(user))
		pizza = new /obj/item/food/sliceable/pizza/meatpizza(src)
	. = ..()

// Disk croutons
/obj/item/food/disk
	name = "диск с сухариками"
	desc = "Вкуснейшие сухарики с запахом дымка!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "disk"
	item_state = "chips"
	bitesize = 3
	junkiness = 20
	antable = FALSE
	trash = /obj/item/trash/disk
	filling_color = "#d1ac45"
	list_reagents = list("nutriment" = 1, "sodiumchloride" = 1, "ash" = 1, "saltpetre" = 1)
	tastes = list("хлеб" = 3, "соль" = 1, "пепел" = 1)

/obj/item/trash/disk
	name = "диск с сухариками"
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "disk"
	item_state = "chips"

// Plov
/obj/item/food/plov
	name = "плов с изюмом"
	desc = "Плов по тому самому рецепту с Земли, так ещё и с изюмом! Объедение."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "plov"
	trash = /obj/item/trash/plate
	filling_color = "#B15124"
	list_reagents = list("nutriment" = 5, "blackpepper" = 1, "vitamin" = 1, "plantmatter" = 3)
	tastes = list("рис" = 3, "мясо" = 1, "морковка" = 1, "изюм" = 1)

/datum/cooking/recipe/plov
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plov
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

// MARK: Vulpix Pizza
/obj/item/pizzabox/vulpix
	name = "MacVulPizza Extra Pepperoni"
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "MV-pizzabox1"

/obj/item/pizzabox/vulpix/update_icon_state()
	if(open)
		icon_state = "MV-pizzabox_open"
		return

	icon_state = "MV-pizzabox[boxes.len + 1]"

// Спасибо блять старому коду за хардкод путь до иконки...
/obj/item/pizzabox/vulpix/update_overlays()
	. = ..()
	if(open && pizza)
		var/image/pizzaimg = image("icon" = 'modular_ss220/food_and_drinks/icons/food.dmi', icon_state = pizza.icon_state)
		. += pizzaimg
		return

/obj/item/pizzabox/vulpix/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/food/sliceable/pizza/vulpix(src)

/obj/item/food/sliceable/pizza/vulpix
	name = "MacVulPizza Extra Pepperoni"
	desc = "Хорошо выглядящая пицца с тройной порцией пепперони, большим количеством моцареллы и ярким томатным соусом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV_pizza_pep"
	slice_path = /obj/item/food/vulpix_pizza_slice
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)
	filling_color = "#ffe45d"
	tastes = list("сыр" = 3, "пепперони" = 3, "жир" = 1)

/obj/item/food/vulpix_pizza_slice
	name = "кусочек пиццы 'MacVulPizza Extra Pepperoni'"
	desc = "Хорошо выглядящий кусочек пиццы с тройной порцией пепперони, большим количеством моцареллы и ярким томатным соусом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV_pizza_pep_slice"
	filling_color = "#ffe45d"
	tastes = list("сыр" = 3, "пепперони" = 3, "жир" = 1)

/obj/item/food/vulpix_chips
	name = "\improper MacNachos Diablo"
	desc = "Лис на упаковке словно говорит вам “Это, черт возьми, остро!”"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV-chips"
	bitesize = 1
	trash = /obj/item/trash/vulpix_chips
	filling_color = "#e8791e"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "sodiumchloride" = 1, "capsaicin" = 3)
	tastes = list("кукуруза" = 1)

/obj/item/trash/vulpix_chips
	name = "MacNachos Diablo"
	desc = "Когда-то это были вкусные чипсы."
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "MV-chips"
	item_state = "chips"

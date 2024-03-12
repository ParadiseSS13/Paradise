// Reagent Grinder
/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	blend_items = list(/obj/item/food/snacks/grown/buckwheat = list("buckwheat" = -5)) + blend_items

// Vending
/obj/machinery/economy/vending/dinnerware/Initialize(mapload)
	products += list(
		/obj/item/reagent_containers/condiment/herbs = 2,)
	. = ..()

/obj/machinery/economy/vending/snack/Initialize(mapload)
	products += list(
		/obj/item/food/snacks/doshik = 6,
		/obj/item/food/snacks/doshik_spicy = 6,)
	prices += list(
		/obj/item/food/snacks/doshik = 100,
		/obj/item/food/snacks/doshik_spicy = 120,)
	. = ..()

// Boiled Buckwheat
/obj/item/food/snacks/boiledbuckwheat
	name = "варёная гречка"
	desc = "Это просто варёная гречка, ничего необычного."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "boiledbuckwheat"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("гречка" = 1)

/datum/recipe/microwave/boiledbuckwheat
	reagents = list("water" = 5, "buckwheat" = 10)
	result = /obj/item/food/snacks/boiledbuckwheat

// Merchant Buckwheat
/obj/item/food/snacks/buckwheat_merchant
	name = "гречка по-купечески"
	desc = "Тушёная гречка с овощами и мясом."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "buckwheat_merchant"
	trash = /obj/item/trash/plate
	filling_color = "#8E633C"
	list_reagents = list("nutriment" = 5, "protein" = 2, "vitamin" = 3)
	tastes = list("гречка" = 2, "мясо" = 2, "томатный соус" = 1)

/datum/recipe/microwave/buckwheat_merchant
	reagents = list("water" = 5, "buckwheat" = 10)
	items = list(
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/meat)
	result = /obj/item/food/snacks/buckwheat_merchant

// Olivier Salad
/obj/item/food/snacks/oliviersalad
	name = "салат оливье"
	desc = "Не трогай, это на новый год!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "kelotane" = 2, "vitamin" = 2)
	tastes = list("варёная картошка" = 1, "огурец" = 1, "морковка" = 1, "яйцо" = 1, "Новый Год" = 1)

/datum/recipe/microwave/oliviersalad
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(
		/obj/item/food/snacks/pickles,
		/obj/item/food/snacks/boiledegg,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/sausage)
	result = /obj/item/food/snacks/oliviersalad

// Weird Olivier Salad
/obj/item/food/snacks/weirdoliviersalad
	name = "странный салат оливье"
	desc = "Что ты сделал с этим оливье, чудовище?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "oliviersalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "kelotane" = 2, "vitamin" = 3)
	tastes = list("варёная картошка" = 1, "огурец" = 1, "морковка" = 1, "яйца" = 1, "странно" = 1, "Новый Год" = 1)

/datum/recipe/microwave/weirdoliviersalad
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(
		/obj/item/food/snacks/pickles,
		/obj/item/food/snacks/boiledegg,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/sausage,
		/obj/item/food/snacks/grown/apple)
	result = /obj/item/food/snacks/weirdoliviersalad

// Vegetable Salad
/obj/item/food/snacks/vegisalad
	name = "овощной салат"
	desc = "Идеальная комбинация томатов и огурцов."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#C2CFAB"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "kelotane" = 1, "vitamin" = 1)
	tastes = list("томат" = 2, "маринованные огурцы" = 2, "сметана" = 2)

/datum/recipe/microwave/vegisalad
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(
		/obj/item/food/snacks/grown/cucumber,
		/obj/item/food/snacks/grown/tomato)
	result = /obj/item/food/snacks/vegisalad

// Pickles
/obj/item/food/snacks/pickles
	name = "маринованные огурцы"
	desc = "Черт, тут много маринованных огурчиков."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "pickles"
	trash = /obj/item/food/snacks/brine
	filling_color = "#C2CFAB"
	bitesize = 8
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("маринованые огурцы" = 1)

/obj/item/food/snacks/brine
	name = "рассол"
	desc = "Самое то после бурной ночи."
	consume_sound = 'sound/items/drink.ogg'
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "brine"
	filling_color = "#C2CFAB"
	bitesize = 4
	list_reagents = list("nutriment" = 1, "antihol" = 2)
	tastes = list("рассол" = 3)

/datum/crafting_recipe/pickles
	name = "Маринованные огурцы"
	result = list(/obj/item/food/snacks/pickles)
	reqs = list(
		/obj/item/food/snacks/grown/cucumber = 3,
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sodiumchloride = 10)
	time = 1 SECONDS
	category = CAT_FOOD
	subcategory = CAT_MISCFOOD

// Pickle Soup
/obj/item/food/snacks/soup/rassolnik
	name = "рассольник"
	desc = "Популярен в СССП."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "rassolnik"
	filling_color = "#F1FC72"
	list_reagents = list("nutriment" = 4, "kelotane" = 1, "vitamin" = 2)
	tastes = list("картошка" = 1, "огурцы" = 1, "рис" = 1)

/datum/recipe/microwave/rassolnik
	reagents = list("water" = 10, "rice" = 5)
	items = list(
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/cucumber)
	result = /obj/item/food/snacks/soup/rassolnik

// Doner
/obj/item/food/snacks/shawarma
	name = "шаурма"
	desc = "Великолепное сочетание мяса с гриля и свежих овощей. Не спрашивайте о мясе."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "shawarma"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "мясо" = 2, "овощи" = 1)

/datum/recipe/microwave/shawarma
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/onion_slice,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/sliceable/flatdough)
	result = /obj/item/food/snacks/shawarma

// Doner - Cheese
/obj/item/food/snacks/doner_cheese
	name = "сырная шаурма"
	desc = "Фирменное блюдо от шеф-повара - мясо с гриля и свежие овощи с теплым сырным соусом. Вкусно!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doner_cheese"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 6, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "сыр" = 2, "мясо" = 2, "овощи" = 1)

/datum/recipe/microwave/doner_cheese
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/sliceable/flatdough)
	result = /obj/item/food/snacks/doner_cheese

// Doner - Mushroom
/obj/item/food/snacks/doner_mushroom
	name = "шаурма с грибами"
	desc = "Мясо с гриля, свежие овощи и грибы. Грибы немного вытеснили мясо, но всё так же вкусно!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doner_mushroom"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "plantmatter" = 2, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("счастье" = 3, "мясо" = 2, "овощи" = 2, "томат" = 1)

/datum/recipe/microwave/doner_mushroom
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/onion_slice,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/sliceable/flatdough)
	result = /obj/item/food/snacks/doner_mushroom

// Doner - Vegetable
/obj/item/food/snacks/doner_vegan
	name = "овощная шаурма"
	desc = "Свежие овощи, завернутые в длинный рулет. Мясо в комплект не входит!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doner_vegan"
	filling_color = "#c0720c"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "vitamin" = 4, "tomatojuice" = 8)
	tastes = list("овощи" = 2, "томат" = 1, "перец" = 1)

/datum/recipe/microwave/doner_vegan
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/onion_slice,
		/obj/item/food/snacks/onion_slice,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/sliceable/flatdough)
	result = /obj/item/food/snacks/doner_vegan

// Slime Pie
/obj/item/food/snacks/sliceable/slimepie
	name = "слаймовый пирог"
	desc = "Блюрп блоб блуп блеп блоп. Можно нарезать."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "slimepie"
	slice_path = /obj/item/food/snacks/slimepieslice
	slices_num = 5
	bitesize = 3
	filling_color = "#00d9ff"
	list_reagents = list("nutriment" = 12, "vitamin" = 4)
	tastes = list("слизь" = 5, "сладость" = 1, "желе" = 1)

/obj/item/food/snacks/slimepieslice
	name = "кусочек слаймового пирога"
	desc = "Блюрп блоб блуп блеп блоп."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "slimepieslice"
	trash = /obj/item/trash/plate
	filling_color = "#00d9ff"
	tastes = list("слизь" = 5, "сладость" = 1, "желе" = 1)

/datum/recipe/oven/slimepie
	reagents = list("custard" = 1, "milk" = 5, "sugar" = 15)
	items = list(/obj/item/organ/internal/brain/slime)
	result = /obj/item/food/snacks/sliceable/slimepie

// Kidan Ragu
/obj/item/food/snacks/kidanragu
	name = "острое хитиновое рагу"
	desc = "Рагу из очень жесткого хитинового мяса и тушеных овощей."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "kidanragu"
	list_reagents = list("nutriment" = 6, "vitamin" = 2, "protein" = 4)
	tastes = list("насекомое" = 3, "овощи" = 2)

/datum/recipe/microwave/kidan_ragu
	reagents = list("water" = 10, "sodiumchloride" = 1)
	items = list(
		/obj/item/organ/internal/heart/kidan,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/chili)
	result = /obj/item/food/snacks/kidanragu

// Fried Unathi Meat
/obj/item/food/snacks/sliceable/lizard
	name = "жареное мясо унатха"
	desc = "Сочный стейк из мяса крупной ящерицы, вызывающий желание полежать на теплых камнях. Можно нарезать."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "lizard_steak"
	slice_path = /obj/item/food/snacks/lizardslice
	slices_num = 5
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("мясо ящерицы" = 4, "курятина" = 2)

/obj/item/food/snacks/lizardslice
	name = "стейк из унатха"
	desc = "Порция мяса унатхи."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "lizard_slice"
	trash = /obj/item/trash/plate
	filling_color = "#a55f3a"
	tastes = list("мясо ящерицы" = 2, "курятина" = 1)

/datum/deepfryer_special/unathi
	input = /obj/item/organ/external
	output = /obj/item/food/snacks/sliceable/lizard

/datum/deepfryer_special/unathi/validate(obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = I
	return istype(E.dna.species, /datum/species/unathi)

// Tajaroni
/obj/item/food/snacks/tajaroni
	name = "таярони"
	desc = "Острая вяленая колбаса с перцем и... Оно только что мяукнуло?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "tajaroni"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 2)
	tastes = list("сухое мясо" = 3, "кошатина" = 2)

/datum/deepfryer_special/tajaroni
	input = /obj/item/organ/external
	output = /obj/item/food/snacks/tajaroni

/datum/deepfryer_special/tajaroni/validate(obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = I
	return istype(E.dna.species, /datum/species/tajaran)

// Vulpixes
/obj/item/food/snacks/vulpix
	name = "вульпиксы"
	desc = "Аппетитно выглядящие мясные шарики в тесте... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "vulpix"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3)

/datum/recipe/oven/vuplix
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "tomato_sauce" = 1, "cream" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin)
	result = /obj/item/food/snacks/vulpix

// Cheese Vulpixes
/obj/item/food/snacks/vulpix/cheese
	name = "сырные вульпиксы"
	desc = "Аппетитно выглядящие мясные шарики в тесте с начинкой из сыра... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "vulpix_cheese"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "сыр" = 2)

/datum/recipe/oven/vulpixcheese
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "cheese_sauce" = 1, "cream" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/food/snacks/cheesewedge)
	result = /obj/item/food/snacks/vulpix/cheese

// Bacon Vulpixes
/obj/item/food/snacks/vulpix/bacon
	name = "вульпиксы с беконом"
	desc = "Аппетитно выглядящие мясные шарики в тесте с начинкой... Главное - не думать о том, из кого они сделаны!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "vulpix_bacon"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "бекон" = 2, "грибы" = 2)

/datum/recipe/oven/vulpixbacon
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "mushroom_sauce" = 1, "cream" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/food/snacks/raw_bacon,
		/obj/item/food/snacks/grown/mushroom)
	result = /obj/item/food/snacks/vulpix/bacon

// Chilli Vulpixes
/obj/item/food/snacks/vulpix/chilli
	name = "вульпиксы-чилли"
	desc = "Аппетитно выглядящие мясные шарики в тесте... Главное - не думать о том, из кого они сделаны! Язык обжигает."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "vulpix_chillie"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "protein" = 4)
	tastes = list("тесто" = 2, "собачатина" = 3, "чилли" = 2)

/datum/recipe/oven/vulpixchilli
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "diablo_sauce" = 1, "cream" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/food/snacks/grown/chili)
	result = /obj/item/food/snacks/vulpix/chilli

// Seafood Pizza
/obj/item/food/snacks/sliceable/pizza/seafood
	name = "пицца с морепродуктами"
	desc = "Дары космических озер, сыр и немного кислинки."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "fishpizza"
	slice_path = /obj/item/food/snacks/seapizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("чеснок" = 1, "сыр" = 2, "морепродукты" = 1, "кислинка" = 1)

/obj/item/food/snacks/seapizzaslice
	name = "кусочек пиццы с морепродуктами"
	desc = "Аппетитный кусочек пиццы с морепродуктами и сыром..."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "fishpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("чеснок" = 1, "сыр" = 2, "морепродукты" = 1, "кислинка" = 1)

/datum/recipe/oven/seapizza
	reagents = list("herbsmix" = 1, "garlic_sauce" = 1)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/salmonmeat,
		/obj/item/food/snacks/salmonmeat,
		/obj/item/food/snacks/boiled_shrimp,
		/obj/item/food/snacks/grown/citrus/lemon)
	result = /obj/item/food/snacks/sliceable/pizza/seafood

// Bacon Pizza
/obj/item/food/snacks/sliceable/pizza/bacon
	name = "пицца с беконом"
	desc = "Классическая пицца, один из ингредиентов которой был заменен на жареный бекон."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "baconpizza"
	slice_path = /obj/item/food/snacks/baconpizzaslice
	list_reagents = list("nutriment" = 40, "vitamin" = 5, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("грибы" = 1, "сыр" = 2, "бекон" = 1)

/obj/item/food/snacks/baconpizzaslice
	name = "кусочек пиццы с беконом"
	desc = "Аппетитный кусок пиццы с беконом и грибами..."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "baconpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("грибы" = 1, "сыр" = 2, "бекон" = 1)

/datum/recipe/oven/baconpizza
	reagents = list("mushroom_sauce" = 1)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/raw_bacon,
		/obj/item/food/snacks/raw_bacon)
	result = /obj/item/food/snacks/sliceable/pizza/bacon

// Pizza Tajaroni
/obj/item/food/snacks/sliceable/pizza/tajaroni
	name = "пицца с таярони"
	desc = "Острые колбаски таярони с сыром и оливками. Что из этого ужаснее, еще предстоит решить."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "tajarpizza"
	slice_path = /obj/item/food/snacks/tajpizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15)
	filling_color = "#ffe45d"
	tastes = list("томат" = 1, "сыр" = 2, "таярони" = 1, "оливки" = 1)

/obj/item/food/snacks/tajpizzaslice
	name = "кусочек пиццы с таярони"
	desc = "Вкуснейший кусок пиццы с таярони и оливками..."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "tajarpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("томат" = 1, "сыр" = 2, "таярони" = 1, "оливки" = 1)

/datum/recipe/oven/tajarpizza
	reagents = list("herbsmix" = 1, "tomato_sauce" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/tajaroni,
		/obj/item/food/snacks/grown/olive,)
	result = /obj/item/food/snacks/sliceable/pizza/tajaroni

// Diablo Pizza
/obj/item/food/snacks/sliceable/pizza/diablo
	name = "пицца 'Диабло'"
	desc = "Невероятно жгучая пицца с кусочками мяса, некоторые утверждают, что она может отправить вас в рэдспейс."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "diablopizza"
	slice_path = /obj/item/food/snacks/diablopizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 15, "protein" = 15, "capsaicin" = 15)
	filling_color = "#ffe45d"
	tastes = list("остроту" = 1, "сыр" = 2, "мясо" = 1, "специи" = 1)

/obj/item/food/snacks/diablopizzaslice
	name = "кусочек пиццы 'Диабло'"
	desc = "Аппетитный кусок пиццы с соусом 'Диабло' и мясом..."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "diablopizzaslice"
	filling_color = "#ffe45d"
	tastes = list("остроту" = 1, "сыр" = 2, "мясо" = 1, "специи" = 1)

/datum/recipe/oven/diablopizza
	reagents = list("herbsmix" = 1, "diablo_sauce" = 1)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball)
	result = /obj/item/food/snacks/sliceable/pizza/diablo

// Doshik
/obj/item/food/snacks/doshik
	name = "дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doshik"
	bitesize = 3
	trash = /obj/item/trash/doshik
	list_reagents = list("dry_ramen" = 30)
	junkiness = 25
	tastes = list("курятина" = 1, "лапша" = 1)

/obj/item/food/snacks/doshik_spicy
	name = "острый дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау. Кажется, что в ней есть острые специи."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doshikspicy"
	bitesize = 3
	trash = /obj/item/trash/doshik
	list_reagents = list("dry_ramen" = 30,"capsaicin" = 5)
	junkiness = 30
	tastes = list("говядина" = 1, "лапша" = 1)

/obj/item/trash/doshik
	name = "упаковка из под дошика"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "doshik-empty"
	desc = "Всё ещё вкусно пахнет."

// Chocolate Cake
/obj/item/food/snacks/sliceable/choccherrycake
	name = "шоколадно-вишневый торт"
	desc = "Ещё один торт. Тем не менее."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "choccherrycake"
	slice_path = /obj/item/food/snacks/choccherrycakeslice
	slices_num = 6
	bitesize = 3
	filling_color = "#5e1706"
	tastes = list("вишня" = 5, "сладость" = 1, "шоколад" = 1)
	list_reagents = list("nutriment" = 12, "sugar" = 4, "coco" = 4)

/obj/item/food/snacks/choccherrycakeslice
	name = "кусочек шоколадно-вишневого торта"
	desc = "Кусочек очередного торта. Подождите, что?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "choccherrycake_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"

/datum/recipe/oven/choccherrycake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/chocolatebar,
		/obj/item/food/snacks/chocolatebar,
		/obj/item/food/snacks/grown/cherries)
	result = /obj/item/food/snacks/sliceable/choccherrycake

// Noel
/obj/item/food/snacks/sliceable/noel
	name = "Bûche de Noël"
	desc = "Что?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "noel"
	trash = /obj/item/trash/tray
	slice_path = /obj/item/food/snacks/noelslice
	slices_num = 5
	filling_color = "#5e1706"
	tastes = list("шоколад" = 3, "сладость" = 2, "яйца" = 1, "ягоды" = 2)
	list_reagents = list("nutriment" = 6, "plantmatter" = 2, "coco" = 2, "cream" = 3, "sugar" = 3, "berryjucie" = 3)

/obj/item/food/snacks/noelslice
	name = "кусочек Noël"
	desc = "Кусочек чего?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "noel_s"
	trash = /obj/item/trash/plate
	filling_color = "#5e1706"
	bitesize = 2

/datum/recipe/oven/noel
	reagents = list("flour" = 15, "cream" = 10, "milk" = 5)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/chocolatebar,
		/obj/item/food/snacks/chocolatebar,
		/obj/item/food/snacks/grown/berries,
		/obj/item/food/snacks/grown/berries)
	result = /obj/item/food/snacks/sliceable/noel

// Sundae
/obj/item/food/snacks/sundae
	name = "Сандей"
	desc = "Сливочное удовольствие."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "sundae"
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 4, "plantmatter" = 2, "bananajucie" = 4, "cream" = 3)
	tastes = list("банан" = 1, "вишня" = 1, "крем" = 1)
	bitesize = 5

/datum/recipe/oven/sundae
	reagents = list("cream" = 10)
	items = list(
		/obj/item/food/snacks/grown/cherries,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/doughslice)
	result = /obj/item/food/snacks/sundae

// Bun-Bun
/obj/item/food/snacks/bunbun
	name = "Бун-Бун"
	desc = "Маленькая хлебная обезьянка, сформованная из двух булочек для гамбургеров."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "bunbun"
	list_reagents = list("nutriment" = 2)
	tastes = list("тесто" = 2)
	bitesize = 2

/datum/recipe/oven/bunbun
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/bun)
	result = /obj/item/food/snacks/bunbun

// Tortilla
/obj/item/food/snacks/tortilla
	name = "тортилья"
	desc = "Hasta la vista, baby"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "tortilla"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 4)
	tastes = list("кукуруза" = 2)
	bitesize = 2

/datum/recipe/microwave/tortilla
	reagents = list("flour" = 10)
	items = list(/obj/item/food/snacks/grown/corn)
	result = /obj/item/food/snacks/tortilla

// Nachos
/obj/item/food/snacks/nachos
	name = "начос"
	desc = "Хола!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "nachos"
	trash = /obj/item/trash/plate
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 4, "salt" = 1)
	tastes = list("кукуруза" = 2)
	bitesize = 3

/datum/recipe/microwave/nachos
	reagents = list("sodiumchloride" = 1)
	items = list(/obj/item/food/snacks/tortilla)
	result = /obj/item/food/snacks/nachos

// Cheese Nachos
/obj/item/food/snacks/cheesenachos
	name = "сырные начос"
	desc = "Сырное хола!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "cheesenachos"
	trash = /obj/item/trash/plate
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 6, "salt" = 1)
	tastes = list("кукуруза" = 1, "сыр" = 2)
	bitesize = 4

/datum/recipe/microwave/cheesenachos
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/food/snacks/tortilla,
		/obj/item/food/snacks/cheesewedge)
	result = /obj/item/food/snacks/cheesenachos

// Cuban Nachos
/obj/item/food/snacks/cubannachos
	name = "кубинские начос"
	desc = "Очень острое хола!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "cubannachos"
	trash = /obj/item/trash/plate
	filling_color = "#ec5c23"
	list_reagents = list("nutriment" = 6, "salt" = 1, "capsaicin" = 2, "plantmatter" = 1)
	tastes = list("кукуруза" = 1, "чили" = 2)
	bitesize = 4

/datum/recipe/microwave/cubannachos
	items = list(
		/obj/item/food/snacks/tortilla,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/chili)
	result = /obj/item/food/snacks/cubannachos

// Carne Buritto
/obj/item/food/snacks/carneburrito
	name = "Carne de burrito asado"
	desc = "Как классический буррито, но с мясом."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "carneburrito"
	filling_color = "#69250b"
	list_reagents = list("nutriment" = 8, "protein" = 2, "soysauce" = 1)
	tastes = list("кукуруза" = 1, "мясо" = 2, "бобы" = 1)
	bitesize = 4

/datum/recipe/microwave/carneburrito
	items = list(
		/obj/item/food/snacks/tortilla,
		/obj/item/food/snacks/grown/soybeans,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cutlet)
	result = /obj/item/food/snacks/carneburrito

// Cheese Buritto
/obj/item/food/snacks/cheeseburrito
	name = "сырное буритто"
	desc = "Нужно ли здесь что-то говорить?"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "cheeseburrito"
	filling_color = "#f1d65c"
	list_reagents = list("nutriment" = 10, "milk" = 2)
	tastes = list("кукуруза" = 1, "бобы" = 1, "сыр" = 2)
	bitesize = 4

/datum/recipe/microwave/cheeseburrito
	items = list(
		/obj/item/food/snacks/tortilla,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge)
	result = /obj/item/food/snacks/cheeseburrito

// Plasma Buritto
/obj/item/food/snacks/plasmaburrito
	name = "Fuego Plasma Burrito"
	desc = "Очень острое, амигос."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "plasmaburrito"
	filling_color = "#f35a46"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "capsaicin" = 4)
	tastes = list("кукуруза" = 1, "бобы" = 1, "чили" = 2)
	bitesize = 4

/datum/recipe/microwave/plasmaburrito
	items = list(
		/obj/item/food/snacks/tortilla,
		/obj/item/food/snacks/grown/soybeans,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/chili)
	result = /obj/item/food/snacks/plasmaburrito

// Pelmeni
/obj/item/food/snacks/pelmeni
	name = "пельмени"
	desc = "Мясо завёрнутое в тесто."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "pelmeni"
	filling_color = "#d9be29"
	list_reagents = list("protein" = 2)
	bitesize = 2
	tastes = list("сырое мясо" = 1, "сырое тесто" = 1)

/obj/item/food/snacks/doughslice/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/snacks/rawcutlet))
		new /obj/item/food/snacks/pelmeni(src)
		to_chat(user, "Вы сделали немного пельменей.")
		qdel(src)
		qdel(I)
	else
		..()

/obj/item/food/snacks/boiledpelmeni
	name = "варёные пельмени"
	desc = "Мы не знаем, какой была Сибирь, но эти вкусные пельмени определенно прибыли оттуда."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "boiledpelmeni"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d9be29"
	list_reagents = list("protein" = 5)
	bitesize = 3
	tastes = list("мясо" = 2, "тесто" = 2)

/datum/recipe/microwave/pelmeni
	reagents = list("water" = 5)
	items = list(/obj/item/food/snacks/pelmeni)
	result = /obj/item/food/snacks/boiledpelmeni

// Smoked Sausage
/obj/item/food/snacks/smokedsausage
	name = "копчёная колбаска"
	desc = "Кусок копченой колбасы. Под пивко пойдёт."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "smokedsausage"
	list_reagents = list("protein" = 12)
	tastes = list("мясо" = 3)

/datum/recipe/oven/smokedsausage
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(/obj/item/food/snacks/sausage)
	result = /obj/item/food/snacks/smokedsausage

// Salami
/obj/item/food/snacks/sliceable/salami
	name = "салями"
	desc = "Не лучший выбор для сэндвича."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "salami"
	slice_path = /obj/item/food/snacks/slice/salami
	slices_num = 6
	list_reagents = list("protein" = 12)
	tastes = list("мясо" = 3, "чеснок" = 1)

/obj/item/food/snacks/slice/salami
	name = "ломтик салями"
	desc = "Лучший выбор для сэндвича."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "salami_s"
	bitesize = 2

/datum/recipe/oven/salami
	reagents = list("garlic_sauce" = 5)
	items = list(/obj/item/food/snacks/smokedsausage)
	result = /obj/item/food/snacks/sliceable/salami

// Fruit Cup
/obj/item/food/snacks/fruitcup
	name = "фруктовая кружка"
	desc = "Фруктовый салат со съедобной кружкой."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "fruitcup"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 4, "watermelonjuice" = 5, "orangejuice" = 5, "vitamin" = 4)
	tastes = list("яблоко" = 2, "банан" = 2, "арбуз" = 2, "лимон" = 1, "амброзия" = 1)
	bitesize = 4

/datum/recipe/microwave/fruitcup
	items = list(
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/ambrosia,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/citrus/lemon,
		/obj/item/food/snacks/grown/watermelon)
	result = /obj/item/food/snacks/fruitcup

// Jungle Salad
/obj/item/food/snacks/junglesalad
	name = "салат 'Джунгли'"
	desc = "Из глубин джунглей."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "junglesalad"
	filling_color = "#C2CFAB"
	list_reagents = list("nutriment" = 6, "watermelonjuice" = 3, "vitamin" = 4)
	tastes = list("яблоко" = 1, "банан" = 2, "арбуз" = 1)

/datum/recipe/microwave/junglesalad
	items = list(
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/watermelon)
	result = /obj/item/food/snacks/junglesalad

// Delight Salad
/obj/item/food/snacks/delightsalad
	name = "cалат 'Восторг'"
	desc = "Настоящий цитрусовый восторг."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "delightsalad"
	filling_color = "#C2CFAB"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 4, "lemonjuice" = 4, "orangejuice" = 4, "vitamin" = 4, "limejuice" = 4)
	tastes = list("лимон" = 1, "лайм" = 2, "апельсин" = 1)
	bitesize = 4

/datum/recipe/microwave/delightsalad
	items = list(
		/obj/item/food/snacks/grown/citrus/lemon,
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/citrus/lime)
	result = /obj/item/food/snacks/delightsalad

// Chowmein
/obj/item/food/snacks/chowmein
	name = "чау-мейн"
	desc = "Nihao!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "chowmein"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 6, "protein" = 2)
	tastes = list("лапша" = 1, "морковка" = 1, "капуста" = 1, "мясо" = 1)
	bitesize = 3

/datum/recipe/microwave/chowmein
	items = list(
		/obj/item/food/snacks/boiledspaghetti,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/grown/carrot)
	result = /obj/item/food/snacks/chowmein

// Beef Noodles
/obj/item/food/snacks/beefnoodles
	name = "лапша с говядиной"
	desc = "Так просто и так вкусно!"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "beefnoodles"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 4, "protein" = 4, "plantmatter" = 3)
	tastes = list("лапша" = 1, "капуста" = 1, "мясо" = 2)
	bitesize = 2

/datum/recipe/microwave/beefnoodles
	items = list(
		/obj/item/food/snacks/boiledspaghetti,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/grown/cabbage)
	result = /obj/item/food/snacks/beefnoodles

// Father's Soup
/obj/item/food/snacks/fathersoup
	name = "батин суп"
	desc = "Адовое блюдо, усреднённый рецепт ибо вариаций масса. Ух бля."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "fathersoup"
	trash = /obj/item/trash/pan
	filling_color = "#f85210"
	list_reagents = list("nutriment" = 4, "protein" = 2, "plantmatter" = 4, "thermite" = 2)
	tastes = list("перец" = 4, "чеснок" = 2, "томат" = 2)
	bitesize = 5

/datum/recipe/oven/fathersoup
	reagents = list("flour" = 10, "blackpepper" = 5)
	items = list(
		/obj/item/food/snacks/soup/tomatosoup,
		/obj/item/food/snacks/grown/garlic,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/ghost_chili,
		/obj/item/food/snacks/grown/ghost_chili,
		/obj/item/food/snacks/grown/tomato)
	result = /obj/item/food/snacks/fathersoup

/obj/item/food/snacks/fathersoup/On_Consume(mob/M, mob/user)
	. = ..()
	user.visible_message("<span class='notice'>У [M] на лбу аж пот выступает.</span>")
	if(prob(33))
		var/soup_talk = "Ух бля..."
		M.say(soup_talk)
	if(prob(33))
		M.emote("fart")

/obj/item/trash/pan
	name = "дырявая сковорода"
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "pan"

// Infinite Pizza Box
/obj/item/pizzabox/infinite
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF

/obj/item/pizzabox/infinite/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_deadsay("Эта коробка для пиццы является аномальной и будет производить бесконечное количество пиццы.")

/obj/item/pizzabox/infinite/attack_self(mob/living/user)
	QDEL_NULL(pizza)
	if(ishuman(user))
		pizza = new /obj/item/food/snacks/sliceable/pizza/meatpizza(src)
	. = ..()

// Disk croutons
/obj/item/food/snacks/disk
	name = "диск с сухариками"
	desc = "Вкуснейшие сухарики с запахом дымка!"
	icon = 'modular_ss220/food/icons/food.dmi'
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
	icon = 'modular_ss220/food/icons/trash.dmi'
	icon_state = "disk"
	item_state = "chips"

// Plov
/obj/item/food/snacks/plov
	name = "плов с изюмом"
	desc = "Плов по тому самому рецепту с Земли, так ещё и с изюмом! Объедение."
	icon = 'modular_ss220/food/icons/food.dmi'
	icon_state = "plov"
	trash = /obj/item/trash/plate
	filling_color = "#B15124"
	list_reagents = list("nutriment" = 5, "blackpepper" = 1, "vitamin" = 1, "plantmatter" = 3)
	tastes = list("рис" = 3, "мясо" = 1, "морковка" = 1, "изюм" = 1)

/datum/recipe/oven/plov
	reagents = list("blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/grown/berries,
	)
	result = /obj/item/food/snacks/plov

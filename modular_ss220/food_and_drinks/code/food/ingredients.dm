// Reagents
/datum/reagent/consumable/buckwheat
	name = "Гречка"
	id = "buckwheat"
	description = "Ходят слухи, что советские люди жрут только водку и... это?"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#8E633C"
	taste_description = "сухая гречка"

/datum/reagent/consumable/tomato_sauce
	name = "томатный соус"
	id = "tomato_sauce"
	description = "Отец всех соусов. Помидоры, немного специй и ничего лишнего."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#ee1000"
	taste_description = "томатный соус"

/datum/reagent/consumable/cheesesauce
	name = "сырный соус"
	id = "cheese_sauce"
	description = "Сыр, сливки и молоко... максимальная концентрация белка!"
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#e6d600"
	taste_description = "сырный соус"

/datum/reagent/consumable/mushroomsauce
	name = "грибной соус"
	id = "mushroom_sauce"
	description = "Сливочный соус с грибами, имеет довольно резкий запах."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#beb58a"
	taste_description = "грибной соус"

/datum/reagent/consumable/garlicsauce
	name = "чесночный соус"
	id = "garlic_sauce"
	description = "Сильный соус с чесноком, его запах бьет в нос. Некоторые члены экипажа, вероятно, будут шипеть на вас и уходить."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#fffee1"
	taste_description = "чесночный соус"

/datum/reagent/consumable/diablosauce
	name = "соус 'Диабло'"
	id = "diablo_sauce"
	description = "Старинный жгучий соус, рецепт которого практически не изменился с момента его создания."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#440804"
	taste_description = "острый кетчуп"

/datum/reagent/consumable/custard
	name = "заварной крем"
	id = "custard"
	description = "Мягкий и сладкий крем, используемый в кондитерском производстве."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#fffed1"
	taste_description = "сладкий нежный крем"

/datum/reagent/consumable/herbs
	name = "приправа"
	id = "herbsmix"
	description = "Смесь различных трав."
	reagent_state = SOLID
	color = "#2c5c04"
	taste_description = "сухая приправа"

// Slices
/obj/item/food/cucumberslice
	name = "ломтик огурца"
	desc = "Нарезанный огурец, неожиданно, правда?"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "cucumberslice"
	filling_color = "#00DB00"
	bitesize = 6
	list_reagents = list("kelotane" = 1)
	tastes = list("cucumber" = 1)

// Tomato Sauce
/obj/item/reagent_containers/condiment/tomato_sauce
	name = "томатный соус"
	desc = "Отец всех соусов. Помидоры, немного специй и ничего лишнего."
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "tomato_sauce"
	list_reagents = list("tomato_sauce" = 50)
	possible_states = list()

/datum/recipe/microwave/tomato_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/food/grown/garlic,
		/obj/item/food/grown/tomato)
	result = /obj/item/reagent_containers/condiment/tomato_sauce

// Diablo Sauce
/obj/item/reagent_containers/condiment/diablo_sauce
	name = "соус 'Диабло'"
	desc = "Старинный жгучий соус, рецепт которого практически не изменился с момента его создания."
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "diablo_sauce"
	list_reagents = list("diablo_sauce" = 30, "capsaicin" = 20)
	possible_states = list()

/datum/recipe/microwave/diablo_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 2, "herbsmix" = 1)
	items = list(
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/chili)
	result = /obj/item/reagent_containers/condiment/diablo_sauce

// Cheese Sauce
/obj/item/reagent_containers/condiment/cheese_sauce
	name = "сырный соус"
	desc = "Сыр, сливки и молоко... максимальная концентрация белка!"
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "cheese_sauce"
	list_reagents = list("cheese_sauce" = 50)
	possible_states = list()

/datum/recipe/microwave/cheese_sauce
	reagents = list("milk" = 15, "cream" = 5)
	items = list(
		/obj/item/food/cheesewedge,
		/obj/item/food/cheesewedge)
	result = /obj/item/reagent_containers/condiment/cheese_sauce

// Mushroom Sauce
/obj/item/reagent_containers/condiment/mushroom_sauce
	name = "грибной соус"
	desc = "Сливочный соус с грибами, имеет довольно резкий запах."
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "mushroom_sauce"
	list_reagents = list("mushroom_sauce" = 50)
	possible_states = list()

/datum/recipe/microwave/mushroom_sauce
	reagents = list("milk" = 15, "cream" = 5, "sodiumchloride" = 1,)
	items = list(
		/obj/item/food/grown/onion,
		/obj/item/food/grown/mushroom)
	result = /obj/item/reagent_containers/condiment/mushroom_sauce

// Garlic Sauce
/obj/item/reagent_containers/condiment/garlic_sauce
	name = "чесночный соус"
	desc = "Сильный соус с чесноком, его запах бьет в нос. Некоторые члены экипажа, вероятно, будут шипеть на вас и уходить."
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "garlic_sauce"
	list_reagents = list("garlic_sauce" = 50)
	possible_states = list()

/datum/recipe/microwave/garlic_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/food/grown/garlic,
		/obj/item/food/grown/cucumber)
	result = /obj/item/reagent_containers/condiment/garlic_sauce

// Custard
/obj/item/reagent_containers/condiment/custard
	name = "заварной крем"
	desc = "Мягкий и сладкий крем, используемый в кондитерском производстве."
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "custard"
	list_reagents = list("custard" = 50)
	possible_states = list()

/datum/recipe/microwave/custard
	reagents = list("sugar" = 10, "milk" = 10, "cream" = 5, "vanilla" = 5)
	items = list(/obj/item/food/egg)
	result = /obj/item/reagent_containers/condiment/custard

// Herbs
/obj/item/reagent_containers/condiment/herbs
	name = "приправа"
	desc = "Смесь различных трав. Идеально подходит для пиццы!"
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon = 'modular_ss220/food_and_drinks/icons/containers.dmi'
	icon_state = "herbs"
	list_reagents = list("herbsmix" = 50)
	possible_states = list()

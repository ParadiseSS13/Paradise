//Hispania foods
// see code/datums/recipe.dm



//Mugcakes by Ralph & Ume <3

/datum/recipe/microwave/mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/mugcake

/datum/recipe/microwave/vanilla_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5, "vanilla" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/vanilla_mugcake

/datum/recipe/microwave/chocolate_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5, "cocoa" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/chocolate_mugcake

/datum/recipe/microwave/banana_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/grown/banana, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/banana_mugcake

/datum/recipe/microwave/cherry_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/grown/cherries, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/cherry_mugcake

/datum/recipe/microwave/bluecherry_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/grown/bluecherries, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/bluecherry_mugcake

/datum/recipe/microwave/lime_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/grown/citrus/lime, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/lime_mugcake

/datum/recipe/microwave/amanita_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/grown/mushroom/amanita, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/amanita_mugcake

//HoneyMugcake (for Luka) //

/datum/recipe/microwave/honey_mugcake
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5,"honey" = 5)
	items = list(/obj/item/reagent_containers/food/drinks/mug, /obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/honey_mugcake

/// Soups

/datum/recipe/microwave/macacosoup /// By Hexi
	reagents = list("water" = 10, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/grown/banana, /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/reagent_containers/food/snacks/monkeycube )
	result = /obj/item/reagent_containers/food/snacks/macacosoup

/datum/recipe/microwave/furamingosoup
	reagents = list("water" = 10,"sugar" = 5,"milk" = 5,)
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp
	)
	result = /obj/item/reagent_containers/food/snacks/furamingosoup

//Arepa descogelada

/datum/recipe/microwave/arepa
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa_ice
	)
	result = /obj/item/reagent_containers/food/snacks/arepa


/////Hot dogs///////

/datum/recipe/microwave/hot_dog
	items = list(
		/obj/item/reagent_containers/food/snacks/sausage,
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/hot_dog


/datum/recipe/microwave/butter_dog
	items = list(
		/obj/item/reagent_containers/food/snacks/butter,
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/hot_dog/butter

///Drake steak

/datum/recipe/microwave/drakesteak
	items = list(/obj/item/reagent_containers/food/snacks/drakemeat, /obj/item/organ/internal/regenerative_core/legion)
	result = /obj/item/reagent_containers/food/snacks/drakesteak

// ENSALADASS CALENTITAS

/datum/recipe/microwave/ensaladacactus
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/grown/cabbage, /obj/item/reagent_containers/food/snacks/grown/tomato, /obj/item/reagent_containers/food/snacks/grown/prickly_pear)
	result = /obj/item/reagent_containers/food/snacks/ensaladacactus

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



/// Soups

/datum/recipe/microwave/macacosoup /// By Hexi
	reagents = list("water" = 10, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/grown/banana, /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/reagent_containers/food/snacks/monkeycube )
	result = /obj/item/reagent_containers/food/snacks/macacosoup
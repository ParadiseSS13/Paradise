//Hispania recipes
// /datum/recipe/oven

///empanadas by Soulster
/datum/recipe/oven/empanada
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/cutlet
	)
	result = /obj/item/reagent_containers/food/snacks/empanada


///HoneyPie by Nothing (Thanks Ume)
/datum/recipe/oven/honeypie
    reagents = list("honey" = 5)
    items = list(
        /obj/item/reagent_containers/food/snacks/sliceable/flatdough,
    )
    result = /obj/item/reagent_containers/food/snacks/pie/honey

///HoneyBread(For Luka <3 )
/datum/recipe/oven/honeybread
    reagents = list("honey" = 15)
    items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
    )
    result = /obj/item/reagent_containers/food/snacks/sliceable/honeybread

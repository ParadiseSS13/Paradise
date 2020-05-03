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

//Pancake by Nothing (Con ayuda de Ume, gracias!)
/datum/recipe/oven/pancake
    reagents = list("sugar" = 5, "sodiumchloride" = 1)
    items = list(
        /obj/item/reagent_containers/food/snacks/sliceable/flatdough,
    )
    result = /obj/item/reagent_containers/food/snacks/pancake

/datum/recipe/oven/pancake_mermelada
    reagents = list("sugar" = 5, "sodiumchloride" = 1)
    items = list(
        /obj/item/reagent_containers/food/snacks/sliceable/flatdough,
        /obj/item/reagent_containers/food/snacks/grown/nispero,
        /obj/item/reagent_containers/food/snacks/grown/berries,
    )
    result = /obj/item/reagent_containers/food/snacks/pancake_mermelada

// Codigo chad abajo, ponganse lentes

/datum/recipe/oven/cheeseanonnacake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/anonna
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/cheeseanonnacake

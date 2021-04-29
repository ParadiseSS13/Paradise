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
/datum/recipe/oven/pancake_sal
    reagents = list("sugar" = 5, "sodiumchloride" = 1)
    items = list(
        /obj/item/reagent_containers/food/snacks/sliceable/flatdough,
    )
    result = /obj/item/reagent_containers/food/snacks/pancake_sal

//Peachmeat//
/datum/recipe/oven/peachmeat
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "guacamole" = 10)
	items = list(
	/obj/item/reagent_containers/food/snacks/grown/peach,
	/obj/item/reagent_containers/food/snacks/grown/peach,
	/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/peach_meat

//Stuffed mushroom//
/datum/recipe/oven/stuffed_mushrooms
	items = list(
	/obj/item/reagent_containers/food/snacks/grown/chanter/champignon,
	/obj/item/reagent_containers/food/snacks/grown/chanter/champignon,
	/obj/item/reagent_containers/food/snacks/cheesewedge,
	/obj/item/reagent_containers/food/snacks/cheesewedge,
	/obj/item/reagent_containers/food/snacks/bacon,
	/obj/item/reagent_containers/food/snacks/bacon,
	)
	result = /obj/item/reagent_containers/food/snacks/stuffed_mushrooms

/datum/recipe/oven/pancake_mermelada
    reagents = list("sugar" = 5, "sodiumchloride" = 1)
    items = list(
        /obj/item/reagent_containers/food/snacks/sliceable/flatdough,
        /obj/item/reagent_containers/food/snacks/grown/nispero,
        /obj/item/reagent_containers/food/snacks/grown/berries,
    )
    result = /obj/item/reagent_containers/food/snacks/pancake_mermelada

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


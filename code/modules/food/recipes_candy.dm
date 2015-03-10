
/*
* /datum/recipe/candy/
*	reagents = list()
*	items = list()
*	result = /obj/item/weapon/reagent_containers/food/snacks/
*	byproduct = /obj/item/		// only set this if the recipe has a byproduct, like returning it's mould
*
* NOTE: If using a mould, make sure to list it in *BOTH* the items and byproduct lists if it is to be returned.
* Failure to list in both places will result in either consumption of the mould, or spontaneous generation of a mould.
*
*/

// ***********************************************************
// Candy Ingredients / Flavorings Recipes
// ***********************************************************

/datum/recipe/candy/chocolate_bar
	reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar

/datum/recipe/candy/chocolate_bar2
	reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar

/datum/recipe/candy/fudge
	reagents = list("sugar" = 5, "cream" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/fudge

/datum/recipe/candy/caramel
	reagents = list("sugar" = 5, "cream" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/caramel

/datum/recipe/candy/toffee
	reagents = list("sugar" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/flour)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/toffee

/datum/recipe/candy/taffy
	reagents = list("sugar" = 5, "water" = 5, "sodiumchloride" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/taffy

/datum/recipe/candy/nougat
	reagents = list("sugar" = 5, "cornoil" = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/nougat

// ***********************************************************
// Base Candy Recipes (unflavored / plain)
// ***********************************************************

/datum/recipe/candy/cotton
	reagents = list("sugar" = 15)
	items = list(
		/obj/item/weapon/c_tube,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton

/datum/recipe/candy/gummybear
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/bear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear
	byproduct = /obj/item/weapon/kitchen/mould/bear

/datum/recipe/candy/gummyworm
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/worm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	byproduct = /obj/item/weapon/kitchen/mould/worm

/datum/recipe/candy/jellybean
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/bean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	byproduct = /obj/item/weapon/kitchen/mould/bean

/datum/recipe/candy/jawbreaker
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/ball,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	byproduct = /obj/item/weapon/kitchen/mould/ball

/datum/recipe/candy/candycane
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/cane,
		/obj/item/weapon/reagent_containers/food/snacks/mint,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mint
	byproduct = /obj/item/weapon/kitchen/mould/cane

/datum/recipe/candy/gum
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gum

/datum/recipe/candy/candybar
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar

/datum/recipe/candy/cash
	reagents = list()
	items = list(
		/obj/item/weapon/kitchen/mould/cash,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cash
	byproduct = /obj/item/weapon/kitchen/mould/cash

/datum/recipe/candy/coin
	reagents = list()
	items = list(
		/obj/item/weapon/kitchen/mould/coin,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/coin
	byproduct = /obj/item/weapon/kitchen/mould/coin

/datum/recipe/candy/sucker
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/weapon/kitchen/mould/loli,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	byproduct = /obj/item/weapon/kitchen/mould/loli

// ***********************************************************
// Cotton Candy Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/cotton/red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red

/datum/recipe/candy/cotton/blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue

/datum/recipe/candy/cotton/poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/poison

/datum/recipe/candy/cotton/green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green

/datum/recipe/candy/cotton/yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow

/datum/recipe/candy/cotton/orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange

/datum/recipe/candy/cotton/purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple

/datum/recipe/candy/cotton/pink
	reagents = list("watermelonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink

/datum/recipe/candy/cotton/rainbow
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow

/datum/recipe/candy/cotton/rainbow2
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/poison,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple,
		/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/cotton/bad_rainbow

// ***********************************************************
// Gummy Bear Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummybear/red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red

/datum/recipe/candy/gummybear/blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue

/datum/recipe/candy/gummybear/poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/poison

/datum/recipe/candy/gummybear/green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green

/datum/recipe/candy/gummybear/yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow

/datum/recipe/candy/gummybear/orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange

/datum/recipe/candy/gummybear/purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple

/datum/recipe/candy/gummybear/wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf

/datum/recipe/candy/gummybear/wtf2
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf

// ***********************************************************
// Gummy Worm Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummyworm/red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red

/datum/recipe/candy/gummyworm/blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue

/datum/recipe/candy/gummyworm/poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/poison

/datum/recipe/candy/gummyworm/green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green

/datum/recipe/candy/gummyworm/yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow

/datum/recipe/candy/gummyworm/orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange

/datum/recipe/candy/gummyworm/purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple

/datum/recipe/candy/gummyworm/wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf

/datum/recipe/candy/gummyworm/wtf2
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf

// ***********************************************************
// Jelly Bean Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/jellybean/red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red

/datum/recipe/candy/jellybean/blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue

/datum/recipe/candy/jellybean/poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/poison

/datum/recipe/candy/jellybean/green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green

/datum/recipe/candy/jellybean/yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow

/datum/recipe/candy/jellybean/orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange

/datum/recipe/candy/jellybean/purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple

/datum/recipe/candy/jellybean/chocolate
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate

/datum/recipe/candy/jellybean/cola
	reagents = list("cola" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola

/datum/recipe/candy/jellybean/popcorn
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/popcorn,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn

/datum/recipe/candy/jellybean/coffee
	reagents = list("coffee" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola

/datum/recipe/candy/jellybean/drgibb
	reagents = list("dr_gibb" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola


/datum/recipe/candy/jellybean/wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf

/datum/recipe/candy/jellybean/wtf2
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf

// ***********************************************************
// Candybar Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/candybar/caramel
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,
		/obj/item/weapon/reagent_containers/food/snacks/candy/caramel,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar/caramel

/datum/recipe/candy/candybar/nougat
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,
		/obj/item/weapon/reagent_containers/food/snacks/candy/nougat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar/nougat

/datum/recipe/candy/candybar/toffee
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,
		/obj/item/weapon/reagent_containers/food/snacks/candy/toffee,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar/toffee

/datum/recipe/candy/candybar/rice
	reagents = list("rice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar/rice

/datum/recipe/candy/candybar/caramel_nougat
	reagents = list()
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar,
		/obj/item/weapon/reagent_containers/food/snacks/candy/caramel,
		/obj/item/weapon/reagent_containers/food/snacks/candy/nougat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candy/candybar/caramel_nougat
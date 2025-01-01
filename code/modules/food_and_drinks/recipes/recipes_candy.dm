
/*
* /datum/recipe/candy/
*	reagents = list()
*	items = list()
*	result = /obj/item/food/
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
	reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/food/chocolatebar

/datum/recipe/candy/chocolate_bar2
	reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/food/chocolatebar

/datum/recipe/candy/fudge_peanut
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(/obj/item/food/chocolatebar, /obj/item/food/grown/peanuts,
				/obj/item/food/grown/peanuts, /obj/item/food/grown/peanuts)
	result = /obj/item/food/candy/fudge/peanut

/datum/recipe/candy/fudge_cherry
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(/obj/item/food/chocolatebar, /obj/item/food/grown/cherries,
				/obj/item/food/grown/cherries, /obj/item/food/grown/cherries)
	result = /obj/item/food/candy/fudge/cherry

/datum/recipe/candy/fudge_cookies_n_cream
	reagents = list("sugar" = 5, "milk" = 5, "cream" = 5)
	items = list(
				/obj/item/food/chocolatebar,
				/obj/item/food/cookie,
				)
	result = /obj/item/food/candy/fudge/cookies_n_cream

/datum/recipe/candy/fudge_turtle
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
				/obj/item/food/chocolatebar,
				/obj/item/food/candy/caramel,
				/obj/item/food/grown/peanuts
				)
	result = /obj/item/food/candy/fudge/turtle

/datum/recipe/candy/fudge
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(/obj/item/food/chocolatebar)
	result = /obj/item/food/candy/fudge

/datum/recipe/candy/caramel
	reagents = list("sugar" = 5, "cream" = 5)
	items = list()
	result = /obj/item/food/candy/caramel

/datum/recipe/candy/toffee
	reagents = list("sugar" = 5, "flour" = 10)
	result = /obj/item/food/candy/toffee

/datum/recipe/candy/taffy
	reagents = list("salglu_solution" = 15)
	items = list()
	result = /obj/item/food/candy/taffy

/datum/recipe/candy/nougat
	reagents = list("sugar" = 5, "cornoil" = 5)
	items = list(/obj/item/food/egg)
	result = /obj/item/food/candy/nougat

/datum/recipe/candy/nougat/make_food(obj/container)
	var/obj/item/food/candy/nougat/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/candy/wafflecone
	reagents = list("milk" = 1, "sugar" = 1)
	result = /obj/item/food/wafflecone

/datum/recipe/candy/candied_pineapple
	reagents = list("sugar" = 2, "water" = 2)
	items = list(
		/obj/item/food/pineappleslice
	)
	result = /obj/item/food/candy/candied_pineapple

/datum/recipe/candy/chocolate_orange
	items = list(
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/candy/chocolate_orange

/datum/recipe/candy/chocolate_coin
	items = list(
		/obj/item/coin,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/candy/chocolate_coin

/datum/recipe/candy/chocolate_bunny
	reagents = list("sugar" = 2)
	items = list(
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/candy/chocolate_bunny

/datum/recipe/candy/fudge_dice
	items = list(
		/obj/item/dice,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/candy/fudge_dice

// ***********************************************************
// Base Candy Recipes (unflavored / plain)
// ***********************************************************

/datum/recipe/candy/cottoncandy
	reagents = list("sugar" = 15)
	items = list(
		/obj/item/c_tube,
		)
	result = /obj/item/food/candy/cotton

/datum/recipe/candy/gummybear
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/bear,
		)
	result = /obj/item/food/candy/gummybear
	byproduct = /obj/item/kitchen/mould/bear

/datum/recipe/candy/gummyworm
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/worm,
		)
	result = /obj/item/food/candy/gummyworm
	byproduct = /obj/item/kitchen/mould/worm

/datum/recipe/candy/jellybean
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/bean,
		)
	result = /obj/item/food/candy/jellybean
	byproduct = /obj/item/kitchen/mould/bean

/datum/recipe/candy/jawbreaker
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/ball,
		)
	result = /obj/item/food/candy/jawbreaker
	byproduct = /obj/item/kitchen/mould/ball

/datum/recipe/candy/candycane
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/kitchen/mould/cane,
		/obj/item/food/mint,
		)
	result = /obj/item/food/candy/candycane
	byproduct = /obj/item/kitchen/mould/cane

/datum/recipe/candy/gum
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list()
	result = /obj/item/food/candy/gum

/datum/recipe/candy/candybar
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/chocolatebar,
		)
	result = /obj/item/food/candy/candybar

/datum/recipe/candy/cash
	items = list(
		/obj/item/kitchen/mould/cash,
		/obj/item/food/chocolatebar,
		)
	result = /obj/item/food/candy/cash
	byproduct = /obj/item/kitchen/mould/cash

/datum/recipe/candy/coin
	items = list(
		/obj/item/kitchen/mould/coin,
		/obj/item/food/chocolatebar,
		)
	result = /obj/item/food/candy/coin
	byproduct = /obj/item/kitchen/mould/coin

/datum/recipe/candy/sucker
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/loli,
		)
	result = /obj/item/food/candy/sucker
	byproduct = /obj/item/kitchen/mould/loli

// ***********************************************************
// Cotton Candy Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/cottoncandy_red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/red

/datum/recipe/candy/cottoncandy_blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/blue

/datum/recipe/candy/cottoncandy_poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/poison

/datum/recipe/candy/cottoncandy_green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/green

/datum/recipe/candy/cottoncandy_yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/yellow

/datum/recipe/candy/cottoncandy_orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/orange

/datum/recipe/candy/cottoncandy_purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/purple

/datum/recipe/candy/cottoncandy_pink
	reagents = list("watermelonjuice" = 5)
	items = list(
		/obj/item/food/candy/cotton,
		)
	result = /obj/item/food/candy/cotton/pink

/datum/recipe/candy/cottoncandy_rainbow
	reagents = list()
	items = list(
		/obj/item/food/candy/cotton/red,
		/obj/item/food/candy/cotton/blue,
		/obj/item/food/candy/cotton/green,
		/obj/item/food/candy/cotton/yellow,
		/obj/item/food/candy/cotton/orange,
		/obj/item/food/candy/cotton/purple,
		/obj/item/food/candy/cotton/pink,
		)
	result = /obj/item/food/candy/cotton/rainbow

/datum/recipe/candy/cottoncandy_rainbow2
	reagents = list()
	items = list(
		/obj/item/food/candy/cotton/red,
		/obj/item/food/candy/cotton/poison,
		/obj/item/food/candy/cotton/green,
		/obj/item/food/candy/cotton/yellow,
		/obj/item/food/candy/cotton/orange,
		/obj/item/food/candy/cotton/purple,
		/obj/item/food/candy/cotton/pink,
		)
	result = /obj/item/food/candy/cotton/bad_rainbow

// ***********************************************************
// Gummy Bear Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummybear_red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/red

/datum/recipe/candy/gummybear_blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/blue

/datum/recipe/candy/gummybear_poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/poison

/datum/recipe/candy/gummybear_green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/green

/datum/recipe/candy/gummybear_yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/yellow

/datum/recipe/candy/gummybear_orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/orange

/datum/recipe/candy/gummybear_purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/purple

/datum/recipe/candy/gummybear_wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/food/candy/gummybear,
		)
	result = /obj/item/food/candy/gummybear/wtf

/datum/recipe/candy/gummybear_wtf2
	reagents = list()
	items = list(/obj/item/food/candy/gummybear, /obj/item/food/grown/ambrosia/vulgaris)
	result = /obj/item/food/candy/gummybear/wtf

// ***********************************************************
// Gummy Worm Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummyworm_red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/red

/datum/recipe/candy/gummyworm_blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/blue

/datum/recipe/candy/gummyworm_poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/poison

/datum/recipe/candy/gummyworm_green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/green

/datum/recipe/candy/gummyworm_yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/yellow

/datum/recipe/candy/gummyworm_orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/orange

/datum/recipe/candy/gummyworm_purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/purple

/datum/recipe/candy/gummyworm_wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/food/candy/gummyworm,
		)
	result = /obj/item/food/candy/gummyworm/wtf

/datum/recipe/candy/gummyworm_wtf2
	items = list(/obj/item/food/candy/gummyworm, /obj/item/food/grown/ambrosia/vulgaris)
	result = /obj/item/food/candy/gummyworm/wtf

// ***********************************************************
// Jelly Bean Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/jellybean_red
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/red

/datum/recipe/candy/jellybean_blue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/blue

/datum/recipe/candy/jellybean_poison
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/poison

/datum/recipe/candy/jellybean_green
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/green

/datum/recipe/candy/jellybean_yellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/yellow

/datum/recipe/candy/jellybean_orange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/orange

/datum/recipe/candy/jellybean_purple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/purple

/datum/recipe/candy/jellybean_chocolate
	reagents = list()
	items = list(
		/obj/item/food/candy/jellybean,
		/obj/item/food/chocolatebar,
		)
	result = /obj/item/food/candy/jellybean/chocolate

/datum/recipe/candy/jellybean_cola
	reagents = list("cola" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/cola

/datum/recipe/candy/jellybean_popcorn
	reagents = list()
	items = list(
		/obj/item/food/popcorn,
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/popcorn

/datum/recipe/candy/jellybean_coffee
	reagents = list("coffee" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/cola

/datum/recipe/candy/jellybean_drgibb
	reagents = list("dr_gibb" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/cola

/datum/recipe/candy/jellybean_wtf
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/food/candy/jellybean,
		)
	result = /obj/item/food/candy/jellybean/wtf

/datum/recipe/candy/jellybean_wtf2
	items = list(/obj/item/food/candy/jellybean, /obj/item/food/grown/ambrosia/vulgaris)
	result = /obj/item/food/candy/jellybean/wtf

// ***********************************************************
// Candybar Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/malper
	reagents = list()
	items = list(
		/obj/item/food/candy/candybar,
		/obj/item/food/candy/caramel,
		)
	result = /obj/item/food/candy/confectionery/caramel

/datum/recipe/candy/toolerone
	reagents = list()
	items = list(
		/obj/item/food/candy/candybar,
		/obj/item/food/candy/nougat,
		)
	result = /obj/item/food/candy/confectionery/nougat

/datum/recipe/candy/yumbaton
	reagents = list()
	items = list(
		/obj/item/food/candy/candybar,
		/obj/item/food/candy/toffee,
		)
	result = /obj/item/food/candy/confectionery/toffee

/datum/recipe/candy/crunch
	reagents = list("rice" = 5)
	items = list(
		/obj/item/food/candy/candybar,
		)
	result = /obj/item/food/candy/confectionery/rice

/datum/recipe/candy/toxinstest
	reagents = list()
	items = list(
		/obj/item/food/candy/candybar,
		/obj/item/food/candy/caramel,
		/obj/item/food/candy/nougat,
		)
	result = /obj/item/food/candy/confectionery/caramel_nougat



// /datum/recipe/oven

/datum/recipe/oven/bun
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/bun

/datum/recipe/oven/meatbread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/meatbread

/datum/recipe/oven/syntibread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat/syntiflesh,
		/obj/item/food/snacks/meat/syntiflesh,
		/obj/item/food/snacks/meat/syntiflesh,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/meatbread

/datum/recipe/oven/xenomeatbread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/monstermeat/xenomeat,
		/obj/item/food/snacks/monstermeat/xenomeat,
		/obj/item/food/snacks/monstermeat/xenomeat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/xenomeatbread

/datum/recipe/oven/bananabread
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/sliceable/bananabread

/datum/recipe/oven/banarnarbread
	reagents = list("milk" = 5, "sugar" = 5, "blood" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/sliceable/banarnarbread

/datum/recipe/oven/muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough,
	)
	result = /obj/item/food/snacks/muffin

/datum/recipe/oven/carrotcake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/carrot
	)
	result = /obj/item/food/snacks/sliceable/carrotcake

/datum/recipe/oven/cheesecake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/cheesecake

/datum/recipe/oven/plaincake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
	)
	result = /obj/item/food/snacks/sliceable/plaincake

/datum/recipe/oven/clowncake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/frozen/sundae,
		/obj/item/food/snacks/frozen/sundae,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/sliceable/clowncake

/datum/recipe/oven/meatpie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/meat,
	)
	result = /obj/item/food/snacks/meatpie

/datum/recipe/oven/tofupie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/tofu,
	)
	result = /obj/item/food/snacks/tofupie

/datum/recipe/oven/xemeatpie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/food/snacks/xemeatpie

/datum/recipe/oven/pie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/pie

/datum/recipe/oven/cherrypie
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/cherries
	)
	result = /obj/item/food/snacks/cherrypie

/datum/recipe/oven/berryclafoutis
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/berries
	)
	result = /obj/item/food/snacks/berryclafoutis

/datum/recipe/oven/tofubread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/tofubread

/datum/recipe/oven/loadedbakedpotato
	items = list(
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/potato
	)
	result = /obj/item/food/snacks/loadedbakedpotato

/datum/recipe/oven/yakiimo
	items = list(
		/obj/item/food/snacks/grown/potato/sweet
	)
	result = /obj/item/food/snacks/yakiimo

////cookies by Ume

/datum/recipe/oven/cookies
	items = list(
		/obj/item/food/snacks/rawcookies/chocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray

/datum/recipe/oven/sugarcookies
	items = list(
		/obj/item/food/snacks/rawcookies,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/sugarcookie


////

/datum/recipe/oven/fortunecookie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/snacks/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/food/snacks/fortunecookie

/datum/recipe/oven/fortunecookie/make_food(obj/container)
	var/obj/item/paper/P = locate() in container
	P.loc = null //So we don't delete the paper while cooking the cookie
	var/obj/item/food/snacks/fortunecookie/being_cooked = ..()
	if(P.info) //If there's anything written on the paper, just move it into the fortune cookie
		P.forceMove(being_cooked) //Prevents the oven deleting our paper
		being_cooked.trash = P //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	else
		qdel(P)
	return being_cooked

// Pizzas
/datum/recipe/oven/pizzamargherita
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/sliceable/pizza/margheritapizza

/datum/recipe/oven/meatpizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/oven/mushroompizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/oven/vegetablepizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/eggplant,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/corn,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/oven/hawaiianpizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/pineappleslice,
		/obj/item/food/snacks/pineappleslice,
		/obj/item/food/snacks/meat,
	)
	result = /obj/item/food/snacks/sliceable/pizza/hawaiianpizza

/datum/recipe/oven/macncheesepizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/macncheese,
	)
	result = /obj/item/food/snacks/sliceable/pizza/macpizza

/datum/recipe/oven/cheesepizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/sliceable/pizza/cheesepizza

/datum/recipe/oven/pepperonipizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/sausage
	)
	result = /obj/item/food/snacks/sliceable/pizza/pepperonipizza

/datum/recipe/oven/donkpocketpizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/donkpocket,
		/obj/item/food/snacks/donkpocket
	)
	result = /obj/item/food/snacks/sliceable/pizza/donkpocketpizza

/datum/recipe/oven/dankpizza
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/cannabis,
		/obj/item/food/snacks/grown/cannabis,
		/obj/item/food/snacks/grown/cannabis,
		/obj/item/food/snacks/grown/cannabis
	)
	result = /obj/item/food/snacks/sliceable/pizza/dankpizza

/datum/recipe/oven/firecrackerpizza
	reagents = list("capsaicin" = 5)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/chili
	)
	result = /obj/item/food/snacks/sliceable/pizza/firecrackerpizza

/datum/recipe/oven/pestopizza
	reagents = list("wasabi" = 5)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/sliceable/pizza/pestopizza

/datum/recipe/oven/garlicpizza
	reagents = list("garlic" = 5)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/garlic,
		/obj/item/food/snacks/grown/garlic,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/sliceable/pizza/garlicpizza



/datum/recipe/oven/amanita_pie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/mushroom/amanita
	)
	result = /obj/item/food/snacks/amanita_pie

/datum/recipe/oven/plump_pie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/mushroom/plumphelmet
	)
	result = /obj/item/food/snacks/plump_pie

/datum/recipe/oven/plumphelmetbiscuit
	reagents = list("water" = 5, "flour" = 5)
	items = list(/obj/item/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/food/snacks/plumphelmetbiscuit

/datum/recipe/oven/creamcheesebread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
	)
	result = /obj/item/food/snacks/sliceable/creamcheesebread

/datum/recipe/oven/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
	)
	result = /obj/item/food/snacks/baguette

/datum/recipe/oven/croissant
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/egg
	)
	reagents = list("sodiumchloride" = 1, "milk" = 5, "sugar" = 5)
	result = /obj/item/food/snacks/croissant

/datum/recipe/oven/birthdaycake
	reagents = list("milk" = 5, "sugar" = 15, "vanilla" = 10)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/candle,
		/obj/item/candle,
		/obj/item/candle,
	)
	result = /obj/item/food/snacks/sliceable/birthdaycake

/datum/recipe/oven/bread
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/egg
	)
	result = /obj/item/food/snacks/sliceable/bread

/datum/recipe/oven/bread/make_food(obj/container)
	var/obj/item/food/snacks/sliceable/bread/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/applepie
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/apple
	)
	result = /obj/item/food/snacks/applepie

/datum/recipe/oven/applecake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/apple
	)
	result = /obj/item/food/snacks/sliceable/applecake

/datum/recipe/oven/orangecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/citrus/orange
	)
	result = /obj/item/food/snacks/sliceable/orangecake

/datum/recipe/oven/bananacake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/sliceable/bananacake

/datum/recipe/oven/limecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/citrus/lime,
		/obj/item/food/snacks/grown/citrus/lime
	)
	result = /obj/item/food/snacks/sliceable/limecake

/datum/recipe/oven/lemoncake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/citrus/lemon,
		/obj/item/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/food/snacks/sliceable/lemoncake

/datum/recipe/oven/chocolatecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/chocolatebar,
		/obj/item/food/snacks/chocolatebar,
	)
	result = /obj/item/food/snacks/sliceable/chocolatecake

/datum/recipe/oven/braincake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/food/snacks/sliceable/braincake

/datum/recipe/oven/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/grown/pumpkin
	)
	result = /obj/item/food/snacks/sliceable/pumpkinpie

/datum/recipe/oven/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 10)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/grown/apple/gold
	)
	result = /obj/item/food/snacks/appletart

/datum/recipe/oven/appletart/make_food(obj/container)
	var/obj/item/food/snacks/appletart/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/cracker
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/food/snacks/doughslice
	)
	result = /obj/item/food/snacks/cracker

/datum/recipe/oven/sugarcookie/make_food(obj/container)
	var/obj/item/food/snacks/sugarcookie/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/flatbread
	items = list(
		/obj/item/food/snacks/sliceable/flatdough
	)
	result = /obj/item/food/snacks/flatbread

/datum/recipe/oven/toastedsandwich
	items = list(
		/obj/item/food/snacks/sandwich
	)
	result = /obj/item/food/snacks/toastedsandwich

/// Magic
/datum/recipe/oven/turkey
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/stuffing,
		/obj/item/food/snacks/stuffing
	)
	result = /obj/item/food/snacks/sliceable/turkey

/datum/recipe/oven/tofurkey
	items = list(
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/stuffing,
	)
	result = /obj/item/food/snacks/tofurkey

/datum/recipe/oven/lasagna
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/lasagna

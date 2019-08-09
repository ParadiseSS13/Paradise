
// /datum/recipe/oven

/datum/recipe/oven/bun
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/bun

/datum/recipe/oven/meatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/oven/syntibread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/oven/xenomeatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/oven/bananabread
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bananabread

/datum/recipe/oven/muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/muffin

/datum/recipe/oven/carrotcake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/oven/cheesecake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/oven/plaincake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/oven/meatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie

/datum/recipe/oven/tofupie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofupie

/datum/recipe/oven/xemeatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/xemeatpie

/datum/recipe/oven/pie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/pie

/datum/recipe/oven/cherrypie
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/cherries
	)
	result = /obj/item/reagent_containers/food/snacks/cherrypie

/datum/recipe/oven/berryclafoutis
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/berries
	)
	result = /obj/item/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/oven/tofubread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/oven/loadedbakedpotato
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/potato
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato

////cookies by Ume

/datum/recipe/oven/cookies
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies/chocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray

/datum/recipe/oven/sugarcookies
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/sugarcookie


////

/datum/recipe/oven/fortunecookie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/snacks/fortunecookie

/datum/recipe/oven/fortunecookie/make_food(obj/container)
	var/obj/item/paper/P = locate() in container
	P.loc = null //So we don't delete the paper while cooking the cookie
	var/obj/item/reagent_containers/food/snacks/fortunecookie/being_cooked = ..()
	if(P.info) //If there's anything written on the paper, just move it into the fortune cookie
		P.forceMove(being_cooked) //Prevents the oven deleting our paper
		being_cooked.trash = P //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	else
		qdel(P)
	return being_cooked

/datum/recipe/oven/pizzamargherita
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/oven/meatpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/oven/syntipizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/oven/mushroompizza

	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/oven/vegetablepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/oven/hawaiianpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza

/datum/recipe/oven/macncheesepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/macncheese,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/macpizza

/datum/recipe/oven/amanita_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita
	)
	result = /obj/item/reagent_containers/food/snacks/amanita_pie

/datum/recipe/oven/plump_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	)
	result = /obj/item/reagent_containers/food/snacks/plump_pie

/datum/recipe/oven/plumphelmetbiscuit
	reagents = list("water" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/oven/creamcheesebread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/oven/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/baguette

/datum/recipe/oven/birthdaycake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/clothing/head/cakehat
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/oven/bread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/oven/bread/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sliceable/bread/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/applepie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/applepie

/datum/recipe/oven/applecake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/oven/orangecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/oven/bananacake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bananacake

/datum/recipe/oven/limecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/oven/lemoncake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/oven/chocolatecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/oven/braincake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/oven/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie

/datum/recipe/oven/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold
	)
	result = /obj/item/reagent_containers/food/snacks/appletart

/datum/recipe/oven/appletart/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/appletart/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/cracker
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice
	)
	result = /obj/item/reagent_containers/food/snacks/cracker

/datum/recipe/oven/sugarcookie/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sugarcookie/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/flatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/flatbread

/datum/recipe/oven/turkey  // Magic
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/stuffing,
		/obj/item/reagent_containers/food/snacks/stuffing
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/turkey

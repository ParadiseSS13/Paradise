

// /datum/recipe/oven

/datum/recipe/oven/bun
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/bun

/datum/recipe/oven/meatbread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/meatbread

/datum/recipe/oven/syntibread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/meat/syntiflesh,
		/obj/item/food/meat/syntiflesh,
		/obj/item/food/meat/syntiflesh,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/meatbread

/datum/recipe/oven/xenomeatbread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/monstermeat/xenomeat,
		/obj/item/food/monstermeat/xenomeat,
		/obj/item/food/monstermeat/xenomeat,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/xenomeatbread

/datum/recipe/oven/bananabread
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/sliceable/bananabread

/datum/recipe/oven/banarnarbread
	reagents = list("milk" = 5, "sugar" = 5, "blood" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/sliceable/banarnarbread

/datum/recipe/oven/muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
	)
	result = /obj/item/food/muffin

/datum/recipe/oven/berry_muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/berries
	)
	result = /obj/item/food/berry_muffin

/datum/recipe/oven/booberry_muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/berries,
		/obj/item/food/ectoplasm
	)
	result = /obj/item/food/booberry_muffin

/datum/recipe/oven/moffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/grown/cotton
	)
	result = /obj/item/food/moffin

/datum/recipe/oven/holy_cake
	reagents = list("milk" = 5, "sugar" = 15, "holywater" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough
	)
	result = /obj/item/food/sliceable/holy_cake

/datum/recipe/oven/liars_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/chocolatebar,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/sliceable/liars_cake

/datum/recipe/oven/vanilla_berry_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/berries
	)
	result = /obj/item/food/sliceable/vanilla_berry_cake

/datum/recipe/oven/hardware_cake
	reagents = list("milk" = 5, "sugar" = 15, "sacid" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/circuitboard,
		/obj/item/circuitboard
	)
	result = /obj/item/food/sliceable/hardware_cake

/datum/recipe/oven/plum_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/plum,
		/obj/item/food/grown/plum
	)
	result = /obj/item/food/sliceable/plum_cake

/datum/recipe/oven/pound_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/sliceable/plaincake,
		/obj/item/food/sliceable/plaincake,
		/obj/item/food/sliceable/plaincake,
		/obj/item/food/sliceable/plaincake
	)
	result = /obj/item/food/sliceable/pound_cake

/datum/recipe/oven/pumpkin_spice_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/pumpkin,
		/obj/item/food/grown/pumpkin
	)
	result = /obj/item/food/sliceable/pumpkin_spice_cake

/datum/recipe/oven/slime_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/slime_extract
	)
	result = /obj/item/food/sliceable/slime_cake

/datum/recipe/oven/spaceman_cake
	reagents = list("milk" = 5, "sugar" = 15, "cream" = 5, "berryjuice" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/trumpet,
		/obj/item/food/grown/trumpet
	)
	result = /obj/item/food/sliceable/spaceman_cake

/datum/recipe/oven/vanilla_cake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/vanillapod,
		/obj/item/food/grown/vanillapod
	)
	result = /obj/item/food/sliceable/vanilla_cake

/datum/recipe/oven/mothmallow
	reagents = list("vanilla" = 5, "sugar" = 15, "rum" = 5)
	items = list(
		/obj/item/food/grown/soybeans
	)
	result = /obj/item/food/sliceable/mothmallow

/datum/recipe/oven/carrotcake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/carrot
	)
	result = /obj/item/food/sliceable/carrotcake

/datum/recipe/oven/cheesecake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/cheesecake

/datum/recipe/oven/plaincake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
	)
	result = /obj/item/food/sliceable/plaincake

/datum/recipe/oven/clowncake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/frozen/sundae,
		/obj/item/food/frozen/sundae,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/sliceable/clowncake

/datum/recipe/oven/meatpie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/meat,
	)
	result = /obj/item/food/meatpie

/datum/recipe/oven/tofupie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/tofu,
	)
	result = /obj/item/food/tofupie

/datum/recipe/oven/xemeatpie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/monstermeat/xenomeat
	)
	result = /obj/item/food/xemeatpie

/datum/recipe/oven/pie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/pie

/datum/recipe/oven/cherrypie
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/cherries
	)
	result = /obj/item/food/cherrypie

/datum/recipe/oven/berryclafoutis
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/berries
	)
	result = /obj/item/food/berryclafoutis

/datum/recipe/oven/cherry_cupcake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/cherries
	)
	result = /obj/item/food/cherry_cupcake

/datum/recipe/oven/cherry_cupcake/blue
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/bluecherries
	)
	result = /obj/item/food/cherry_cupcake/blue

/datum/recipe/oven/oatmeal_cookie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/oat
	)
	result = /obj/item/food/oatmeal_cookie

/datum/recipe/oven/raisin_cookie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/no_raisin
	)
	result = /obj/item/food/raisin_cookie

/datum/recipe/oven/peanut_butter_cookie
	reagents = list("milk" = 5, "sugar" = 5, "peanutbutter" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/peanut_butter_cookie

/datum/recipe/oven/chocolate_cornet
	reagents = list("milk" = 5, "sugar" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/food/cookiedough,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/chocolate_cornet

/datum/recipe/oven/honey_bun
	reagents = list("milk" = 5, "sugar" = 5, "honey" = 5)
	items = list(
		/obj/item/food/cookiedough
	)
	result = /obj/item/food/honey_bun

/datum/recipe/oven/cannoli
	reagents = list("milk" = 1, "sugar" = 3)
	items = list(
		/obj/item/food/cookiedough
	)
	result = /obj/item/food/cannoli

/datum/recipe/oven/beary_pie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/monstermeat/bearmeat,
		/obj/item/food/grown/berries
	)
	result = /obj/item/food/beary_pie

/datum/recipe/oven/blumpkin_pie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/pumpkin/blumpkin
	)
	result = /obj/item/food/sliceable/blumpkin_pie

/datum/recipe/oven/chocolate_lava_tart
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/chocolatebar,
		/obj/item/food/chocolatebar,
		/obj/item/food/chocolatebar,
		/obj/item/slime_extract
	)
	result = /obj/item/food/chocolate_lava_tart

/datum/recipe/oven/french_silk_pie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/chocolatebar,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/sliceable/french_silk_pie

/datum/recipe/oven/frosty_pie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/bluecherries
	)
	result = /obj/item/food/sliceable/frosty_pie

/datum/recipe/oven/grape_tart
	reagents = list("milk = 5", "sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/grapes,
		/obj/item/food/grown/grapes,
		/obj/item/food/grown/grapes
	)
	result = /obj/item/food/grape_tart

/datum/recipe/oven/mime_tart
	reagents = list("nothing" = 5, "milk = 5", "sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough
	)
	result = /obj/item/food/mime_tart

/datum/recipe/oven/tofubread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/tofu,
		/obj/item/food/tofu,
		/obj/item/food/tofu,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/tofubread

/datum/recipe/oven/loadedbakedpotato
	items = list(
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/potato
	)
	result = /obj/item/food/loadedbakedpotato

/datum/recipe/oven/yakiimo
	items = list(
		/obj/item/food/grown/potato/sweet
	)
	result = /obj/item/food/yakiimo

////cookies by Ume

/datum/recipe/oven/cookies
	items = list(
		/obj/item/food/rawcookies/chocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray

/datum/recipe/oven/sugarcookies
	items = list(
		/obj/item/food/rawcookies,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/sugarcookie


////

/datum/recipe/oven/fortunecookie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/sliced/dough,
		/obj/item/paper,
	)
	result = /obj/item/food/fortunecookie

/datum/recipe/oven/fortunecookie/make_food(obj/container)
	var/obj/item/paper/P = locate() in container
	P.loc = null //So we don't delete the paper while cooking the cookie
	var/obj/item/food/fortunecookie/being_cooked = ..()
	if(P.info) //If there's anything written on the paper, just move it into the fortune cookie
		P.forceMove(being_cooked) //Prevents the oven deleting our paper
		being_cooked.trash = P //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	else
		qdel(P)
	return being_cooked

// Pizzas
/datum/recipe/oven/pizzamargherita
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge
	)
	result = /obj/item/food/sliceable/pizza/margheritapizza

/datum/recipe/oven/meatpizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/sliceable/pizza/meatpizza

/datum/recipe/oven/mushroompizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/mushroom,
		/obj/item/food/grown/mushroom,
		/obj/item/food/grown/mushroom,
		/obj/item/food/grown/mushroom,
		/obj/item/food/grown/mushroom,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/sliceable/pizza/mushroompizza

/datum/recipe/oven/vegetablepizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/eggplant,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/corn,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/sliceable/pizza/vegetablepizza

/datum/recipe/oven/hawaiianpizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/pineapple,
		/obj/item/food/sliced/pineapple,
		/obj/item/food/meat,
	)
	result = /obj/item/food/sliceable/pizza/hawaiianpizza

/datum/recipe/oven/macncheesepizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/macncheese,
	)
	result = /obj/item/food/sliceable/pizza/macpizza

/datum/recipe/oven/cheesepizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge
	)
	result = /obj/item/food/sliceable/pizza/cheesepizza

/datum/recipe/oven/pepperonipizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sausage
	)
	result = /obj/item/food/sliceable/pizza/pepperonipizza

/datum/recipe/oven/donkpocketpizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/donkpocket,
		/obj/item/food/donkpocket
	)
	result = /obj/item/food/sliceable/pizza/donkpocketpizza

/datum/recipe/oven/dankpizza
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/cannabis,
		/obj/item/food/grown/cannabis,
		/obj/item/food/grown/cannabis,
		/obj/item/food/grown/cannabis
	)
	result = /obj/item/food/sliceable/pizza/dankpizza

/datum/recipe/oven/firecrackerpizza
	reagents = list("capsaicin" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/chili
	)
	result = /obj/item/food/sliceable/pizza/firecrackerpizza

/datum/recipe/oven/pestopizza
	reagents = list("wasabi" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato,
		/obj/item/food/sliced/cheesewedge
	)
	result = /obj/item/food/sliceable/pizza/pestopizza

/datum/recipe/oven/garlicpizza
	reagents = list("garlic" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/garlic,
		/obj/item/food/grown/garlic,
		/obj/item/food/sliced/cheesewedge
	)
	result = /obj/item/food/sliceable/pizza/garlicpizza



/datum/recipe/oven/amanita_pie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/mushroom/amanita
	)
	result = /obj/item/food/amanita_pie

/datum/recipe/oven/plump_pie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/mushroom/plumphelmet
	)
	result = /obj/item/food/plump_pie

/datum/recipe/oven/plumphelmetbiscuit
	reagents = list("water" = 5, "flour" = 5)
	items = list(/obj/item/food/grown/mushroom/plumphelmet)
	result = /obj/item/food/plumphelmetbiscuit

/datum/recipe/oven/creamcheesebread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
	)
	result = /obj/item/food/sliceable/creamcheesebread

/datum/recipe/oven/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
	)
	result = /obj/item/food/baguette

/datum/recipe/oven/croissant
	items = list(
		/obj/item/food/dough,
		/obj/item/food/egg
	)
	reagents = list("sodiumchloride" = 1, "milk" = 5, "sugar" = 5)
	result = /obj/item/food/croissant

/datum/recipe/oven/birthdaycake
	reagents = list("milk" = 5, "sugar" = 15, "vanilla" = 10)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/candle,
		/obj/item/candle,
		/obj/item/candle,
	)
	result = /obj/item/food/sliceable/birthdaycake

/datum/recipe/oven/bread
	items = list(
		/obj/item/food/dough,
		/obj/item/food/egg
	)
	result = /obj/item/food/sliceable/bread

/datum/recipe/oven/bread/make_food(obj/container)
	var/obj/item/food/sliceable/bread/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/applepie
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/apple
	)
	result = /obj/item/food/applepie

/datum/recipe/oven/applecake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/apple
	)
	result = /obj/item/food/sliceable/applecake

/datum/recipe/oven/orangecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/grown/citrus/orange
	)
	result = /obj/item/food/sliceable/orangecake

/datum/recipe/oven/bananacake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/sliceable/bananacake

/datum/recipe/oven/limecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/citrus/lime,
		/obj/item/food/grown/citrus/lime
	)
	result = /obj/item/food/sliceable/limecake

/datum/recipe/oven/lemoncake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/grown/citrus/lemon,
		/obj/item/food/grown/citrus/lemon
	)
	result = /obj/item/food/sliceable/lemoncake

/datum/recipe/oven/chocolatecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/chocolatebar,
		/obj/item/food/chocolatebar,
	)
	result = /obj/item/food/sliceable/chocolatecake

/datum/recipe/oven/braincake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/food/dough,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/food/sliceable/braincake

/datum/recipe/oven/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/grown/pumpkin
	)
	result = /obj/item/food/sliceable/pumpkinpie

/datum/recipe/oven/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 10)
	items = list(
		/obj/item/food/egg,
		/obj/item/food/grown/apple/gold
	)
	result = /obj/item/food/appletart

/datum/recipe/oven/appletart/make_food(obj/container)
	var/obj/item/food/appletart/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/cracker
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/food/sliced/dough
	)
	result = /obj/item/food/cracker

/datum/recipe/oven/sugarcookie/make_food(obj/container)
	var/obj/item/food/sugarcookie/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/flatbread
	items = list(
		/obj/item/food/sliceable/flatdough
	)
	result = /obj/item/food/flatbread

/datum/recipe/oven/toastedsandwich
	items = list(
		/obj/item/food/sandwich
	)
	result = /obj/item/food/toastedsandwich

/// Magic
/datum/recipe/oven/turkey
	items = list(
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/stuffing,
		/obj/item/food/stuffing
	)
	result = /obj/item/food/sliceable/turkey

/datum/recipe/oven/tofurkey
	items = list(
		/obj/item/food/tofu,
		/obj/item/food/tofu,
		/obj/item/food/stuffing,
	)
	result = /obj/item/food/tofurkey

/datum/recipe/oven/lasagna
	items = list(
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/sliced/cheesewedge,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato,
		/obj/item/food/dough
	)
	result = /obj/item/food/lasagna

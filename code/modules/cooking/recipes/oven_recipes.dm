/datum/cooking/recipe/amanita_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/amanita_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/applecake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/applecake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/applepie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/applepie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/appletart
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/appletart
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/baguette
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/baguette
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bananabread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bananabread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/bananacake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bananacake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/banarnarbread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/banarnarbread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("blood", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/beary_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/beary_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/bearmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berry_muffin
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/berry_muffin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berryclafoutis
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/berryclafoutis
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birthdaycake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/birthdaycake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/candle),
		PCWJ_ADD_ITEM(/obj/item/candle),
		PCWJ_ADD_ITEM(/obj/item/candle),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("vanilla", 10),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/blumpkin_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/blumpkin_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin/blumpkin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/booberry_muffin
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/booberry_muffin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/ectoplasm),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/braincake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/braincake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/brain),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/bread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bun
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bun
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cannoli
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cannoli
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_REAGENT("milk", 1),
		PCWJ_ADD_REAGENT("sugar", 3),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/carrotcake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/carrotcake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/cheesecake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/cheesecake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheesepizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/cheesepizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/cherry_cupcake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherry_cupcake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/blue
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherry_cupcake/blue
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cherrypie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherrypie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_cornet
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/chocolate_cornet
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_lava_tart
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/chocolate_lava_tart
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/chocolatecake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/chocolatecake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/clowncake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/clowncake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/frozen/sundae),
		PCWJ_ADD_ITEM(/obj/item/food/frozen/sundae),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 50 SECONDS),
	)

/datum/cooking/recipe/cookies
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/storage/bag/tray/cookies_tray
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcookies/chocochips),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cracker
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cracker
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/dough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/creamcheesebread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/creamcheesebread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/croissant
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/croissant
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/dankpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/dankpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/donkpocketpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/donkpocketpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/donkpocket),
		PCWJ_ADD_ITEM(/obj/item/food/donkpocket),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/firecrackerpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/firecrackerpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("capsaicin", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/flatbread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/flatbread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fortunecookie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/fortunecookie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/dough),
		PCWJ_ADD_ITEM(/obj/item/paper),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/french_silk_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/french_silk_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/frosty_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/frosty_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/garlicpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/garlicpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/garlic),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/garlic),
		PCWJ_ADD_REAGENT("garlic", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/grape_tart
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/grape_tart
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hardware_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/hardware_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/circuitboard),
		PCWJ_ADD_ITEM(/obj/item/circuitboard),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("sacid", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hawaiianpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/hawaiianpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/holy_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/holy_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("holywater", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/honey_bun
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/honey_bun
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/lasagna
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/lasagna
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/lemoncake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/lemoncake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/liars_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/liars_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 50 SECONDS),
	)

/datum/cooking/recipe/limecake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/limecake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/loadedbakedpotato
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/loadedbakedpotato
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/macncheesepizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/macpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/macncheese),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatbread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/meatbread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/meatpie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/meatpie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatpizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/meatpizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/mime_tart
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/mime_tart
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("nothing", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/moffin
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/moffin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/grown/cotton),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mothmallow
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/mothmallow
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("rum", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/muffin
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mushroompizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/mushroompizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/oatmeal_cookie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/oatmeal_cookie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/oat),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/orangecake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/orangecake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/peanut_butter_cookie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/peanut_butter_cookie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pepperonipizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/pepperonipizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pestopizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/pestopizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("wasabi", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pizzamargherita
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/margheritapizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/plaincake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/plaincake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plum_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/plum_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/plum),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/plum),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/plump_pie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plump_pie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plumphelmetbiscuit
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plumphelmetbiscuit
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("flour", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pound_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pound_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pumpkin_spice_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pumpkin_spice_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pumpkinpie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pumpkinpie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/raisin_cookie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/raisin_cookie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/no_raisin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/slime_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/slime_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spaceman_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/spaceman_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sugarcookies
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/storage/bag/tray/cookies_tray/sugarcookie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcookies),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntibread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/meatbread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/toastedsandwich
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/toastedsandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sandwich),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofubread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/tofubread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/tofupie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/tofupie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofurkey
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/tofurkey
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/turkey
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/turkey
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/vanilla_berry_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/vanilla_berry_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/vanilla_cake
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/vanilla_cake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/vegetablepizza
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/vegetablepizza
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/xemeatpie
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/xemeatpie
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/xenomeatbread
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/xenomeatbread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 40 SECONDS),
	)

/datum/cooking/recipe/yakiimo
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/yakiimo
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/poppypretzel
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/poppypretzel
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/seeds/poppy),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/dionaroast
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/dionaroast
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/holder/diona),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("facid", 5),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/donkpocket
	cooking_container = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_USE_OVEN(J_MED, 20 SECONDS),
	)

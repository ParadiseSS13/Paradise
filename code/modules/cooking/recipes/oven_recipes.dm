/datum/cooking/recipe/amanita_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/amanita_pie
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/applecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/applecake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/applepie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/applepie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/appletart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/appletart
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/baguette
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/baguette
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bananabread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bananabread
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bananacake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bananacake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/banarnarbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/banarnarbread
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("blood", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/beary_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/beary_pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/bearmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berry_muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/berry_muffin
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berryclafoutis
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/berryclafoutis
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birthdaycake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/birthdaycake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/blumpkin_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/blumpkin_pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin/blumpkin, exact = TRUE),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/booberry_muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/booberry_muffin
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/ectoplasm),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/braincake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/braincake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/brain),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/bread
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bun
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bun
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cannoli
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cannoli
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_REAGENT("milk", 1),
		PCWJ_ADD_REAGENT("sugar", 3),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/carrotcake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/carrotcake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/cheesecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/cheesecake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cheesepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/cheesepizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/cherry_cupcake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherry_cupcake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/blue
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherry_cupcake/blue
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cherrypie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherrypie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_cornet
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/chocolate_cornet
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_lava_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/chocolate_lava_tart
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolatecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/chocolatecake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/clowncake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/clowncake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/cookies
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/storage/bag/tray/cookies_tray
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcookies/chocochips),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cracker
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cracker
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/dough),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/creamcheesebread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/creamcheesebread
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/croissant
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/croissant
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/dankpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/dankpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/donkpocketpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/donkpocketpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/donkpocket),
		PCWJ_ADD_ITEM(/obj/item/food/donkpocket),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/firecrackerpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/firecrackerpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("capsaicin", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/flatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/flatbread
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fortunecookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/fortunecookie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/dough),
		PCWJ_ADD_ITEM(/obj/item/paper),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/french_silk_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/french_silk_pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/frosty_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/frosty_pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/garlicpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/garlicpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/garlic),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/garlic),
		PCWJ_ADD_REAGENT("garlic", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/grape_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/grape_tart
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/hardware_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/hardware_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/circuitboard),
		PCWJ_ADD_ITEM(/obj/item/circuitboard),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("sacid", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/hawaiianpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/hawaiianpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/holy_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/holy_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/honey_bun
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/lasagna
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/lasagna
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/lemoncake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/lemoncake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/liars_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/liars_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
		PCWJ_USE_OVEN(J_MED, 30 SECONDS),
	)

/datum/cooking/recipe/limecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/limecake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/loadedbakedpotato
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/loadedbakedpotato
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/macncheesepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/macpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/macncheese),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/meatbread
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/meatpie
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/meatpizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/mime_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/mime_tart
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_REAGENT("nothing", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/moffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/moffin
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/grown/cotton),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mothmallow
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/mothmallow
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_ADD_REAGENT("rum", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mushroompizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/mushroompizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/oatmeal_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/oatmeal_cookie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/oat),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/orangecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/orangecake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/peanut_butter_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/peanut_butter_cookie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pepperonipizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/pepperonipizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pestopizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/pestopizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("wasabi", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pizzamargherita
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/margheritapizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plaincake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/plaincake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plum_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/plum_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/plum),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/plum),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plump_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plump_pie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plumphelmetbiscuit
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plumphelmetbiscuit
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("flour", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pound_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pound_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/plaincake),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pumpkin_spice_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pumpkin_spice_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pumpkinpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pumpkinpie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/pumpkin, exact = TRUE),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/raisin_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/raisin_cookie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/no_raisin),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/slime_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/slime_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/spaceman_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/spaceman_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sugarcookies
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/storage/bag/tray/cookies_tray/sugarcookie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcookies),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntibread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/meatbread
	catalog_category = COOKBOOK_CATEGORY_MEAT
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
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/toastedsandwich
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/toastedsandwich
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sandwich),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofubread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/tofubread
	catalog_category = COOKBOOK_CATEGORY_BREAD
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
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofupie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/tofupie
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofurkey
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/tofurkey
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/turkey
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/turkey
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_ADD_ITEM(/obj/item/food/stuffing),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/vanilla_berry_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/vanilla_berry_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
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
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/vanilla_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/vanilla_cake
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/vegetablepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/pizza/vegetablepizza
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_OVEN(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/xemeatpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/xemeatpie
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/xenomeatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/sliceable/xenomeatbread
	catalog_category = COOKBOOK_CATEGORY_MEAT
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
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/yakiimo
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/yakiimo
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/poppypretzel
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/poppypretzel
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/seeds/poppy),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/dionaroast
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/dionaroast
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/holder/diona),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("facid", 5),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/donkpocket
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_USE_OVEN(J_MED, 10 SECONDS),
	)

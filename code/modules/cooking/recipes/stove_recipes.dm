/datum/cooking/recipe/friedegg
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/friedegg
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/beanstew
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/beanstew
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/beans),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/beetsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/beetsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/whitebeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/bloodsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/bloodsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato/blood),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato/blood),
		PCWJ_ADD_REAGENT("blood", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/chicken_noodle_soup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/chicken_noodle_soup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/clownchili
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/clownchili
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/clothing/shoes/clown_shoes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/clownstears
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/clownstears
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/ore/bananium),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/coldchili
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/coldchili
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/icepepper),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cornchowder
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/cornchowder
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cullenskink
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/cullenskink
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("milk", 10),
		PCWJ_ADD_REAGENT("blackpepper", 4),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/eyesoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/eyesoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/organ/internal/eyes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/frenchonionsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/frenchonionsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hong_kong_borscht
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hong_kong_borscht
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hong_kong_macaroni
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hong_kong_macaroni
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hotchili
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hotchili
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatball_noodles
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/meatball_noodles
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatballsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/meatballsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/misosoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/misosoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mushroomsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/mushroomsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mysterysoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/mysterysoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/badrecipe),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/nettlesoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/nettlesoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/grown/nettle/basic),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/oatstew
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/oatstew
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/oat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/parsnip),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/red_porridge
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/red_porridge
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("yogurt", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/redbeetsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/redbeetsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/seedsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/seedsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/seeds/sunflower),
		PCWJ_ADD_ITEM(/obj/item/seeds/poppy/lily),
		PCWJ_ADD_ITEM(/obj/item/seeds/ambrosia),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("vinegar", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/slimesoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/slimesoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stew
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/stew
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sweetpotatosoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/sweetpotatosoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("milk", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/tomatosoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/tomatosoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/vegetablesoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/vegetablesoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/wishsoup
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/wishsoup
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_REAGENT("water", 20),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/zurek
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/zurek
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledegg),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/amanitajelly
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/amanitajelly
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("vodka", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/beans
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/beans
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("ketchup", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/benedict
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/benedict
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiled_shrimp
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiled_shrimp
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledegg
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledegg
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledrice
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledrice
	steps = list(
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("rice", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledslimeextract
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledslimecore
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspaghetti
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledspaghetti
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspiderleg
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledspiderleg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg, exclude_reagents = list("toxin")),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/candiedapple
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/candiedapple
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/chawanmushi
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/chawanmushi
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheese_balls
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheese_balls
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cheese_curds),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("flour", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheesyfries
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheesyfries
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/fries),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cubancarp
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cubancarp
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/dulce_de_batata
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/sliceable/dulce_de_batata
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/eggplantparm
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/eggplantparm
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/enchiladas
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/enchiladas
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/fishandchips
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/fishandchips
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/fries),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/friedbanana
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/friedbanana
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/macncheese
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/macncheese
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/macaroni),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mashedtaters
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/mashed_potatoes
	catalog_category = COOKBOOK_CATEGORY_SIDES
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("gravy", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatballspaggetti
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/meatballspaghetti
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatbun
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/meatbun
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/monkeysdelight
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/monkeysdelight
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monkeycube),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pastatomato
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/pastatomato
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/popcorn
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/popcorn
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/ricepudding
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/ricepudding
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("rice", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sashimi
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/sashimi
	catalog_category = COOKBOOK_CATEGORY_SUSHI
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidereggs),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/soylentgreen
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentgreen
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/soylentviridians
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentviridians
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spacylibertyduff
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spacylibertyduff
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("vodka", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spesslaw
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spesslaw
	catalog_category = COOKBOOK_CATEGORY_PIZZAS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spidereggsham
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spidereggsham
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidereggs),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidermeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stewedsoymeat
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stewedsoymeat
	catalog_category = COOKBOOK_CATEGORY_SOUPS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stuffing
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stuffing
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/bread),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancake
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berry_pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancake/berry_pancake
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/choc_chip_pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancake/choc_chip_pancake
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_ITEM(/obj/item/food/choc_pile),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

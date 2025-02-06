/datum/cooking/recipe/friedegg
	cooking_container = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/friedegg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_STOVE(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/beanstew
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/beanstew
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/beetsoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/whitebeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/bloodsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/bloodsoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato/blood),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato/blood),
		PCWJ_ADD_REAGENT("blood", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/chicken_noodle_soup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/chicken_noodle_soup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/clownchili
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/clownchili
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/clownstears
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/ore/bananium),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/coldchili
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/coldchili
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/icepepper),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cornchowder
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/cornchowder
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/cullenskink
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/eyesoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/organ/internal/eyes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/frenchonionsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/frenchonionsoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hong_kong_borscht
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hong_kong_borscht
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hong_kong_macaroni
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledspaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("cream", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/hotchili
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/hotchili
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatball_noodles
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/meatball_noodles
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/meatballsoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/misosoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/misosoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mushroomsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/mushroomsoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mysterysoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/mysterysoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/badrecipe),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/nettlesoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/nettlesoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_PRODUCE(/obj/item/grown/nettle/basic),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/oatstew
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/oatstew
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/oat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/parsnip),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/red_porridge
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/red_porridge
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("yogurt", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/redbeetsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/redbeetsoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/redbeet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/seedsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/seedsoup
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/seeds/sunflower),
		PCWJ_ADD_ITEM(/obj/item/seeds/poppy/lily),
		PCWJ_ADD_ITEM(/obj/item/seeds/ambrosia),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("vinegar", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/slimesoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/slimesoup
	steps = list(
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stew
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/stew
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sweetpotatosoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/sweetpotatosoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_ADD_REAGENT("milk", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/tomatosoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/tomatosoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/vegetablesoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/vegetablesoup
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/wishsoup
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/wishsoup
	steps = list(
		PCWJ_ADD_REAGENT("water", 20),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/zurek
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/zurek
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/amanitajelly
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("vodka", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/beans
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/beans
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("ketchup", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/benedict
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/benedict
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiled_shrimp
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiled_shrimp
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledegg
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledegg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledrice
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledrice
	steps = list(
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("rice", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledslimeextract
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledslimecore
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspaghetti
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledspaghetti
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspiderleg
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledspiderleg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg, exclude_reagents = list("toxin")),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/candiedapple
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/candiedapple
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/chawanmushi
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/chawanmushi
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheese_balls
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheese_balls
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cheese_curds),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("flour", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheesyfries
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheesyfries
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/fries),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cherrysandwich
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/jellysandwich/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cubancarp
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cubancarp
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/dulce_de_batata
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/sliceable/dulce_de_batata
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		PCWJ_ADD_REAGENT("vanilla", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/eggplantparm
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/eggplantparm
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/enchiladas
	cooking_container = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/enchiladas
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/fishandchips
	cooking_container = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/fishandchips
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/fries),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/friedbanana
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/friedbanana
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/macncheese
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/macncheese
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/macaroni),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mashedtaters
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/mashed_potatoes
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("gravy", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatballspaggetti
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/meatballspaghetti
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatbun
	cooking_container = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/meatbun
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/monkeysdelight
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/monkeysdelight
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monkeycube),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pastatomato
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/pastatomato
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/spaghetti),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/peanut_butter_jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/popcorn
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/popcorn
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/ricepudding
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/ricepudding
	steps = list(
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("rice", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sashimi
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/sashimi
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidereggs),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/slimesandwich
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/jellysandwich/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/slimetoast
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/jelliedtoast/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/soylentgreen
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentgreen
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/soylentviridians
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentviridians
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spacylibertyduff
	cooking_container = /obj/item/reagent_containers/cooking/pot
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spesslaw
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
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spidereggsham
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidereggs),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spidermeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stewedsoymeat
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stewedsoymeat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_ITEM(/obj/item/food/soydope),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stuffing
	cooking_container = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stuffing
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/bread),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_STOVE(J_MED, 20 SECONDS),
	)


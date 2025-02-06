/datum/cooking/recipe/apple_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/apple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/apple/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/apple/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/apple/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/blumpkin_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/blumpkin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("blumpkinjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/blumpkin/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("blumpkinjuice", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/blumpkin/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("blumpkinjuice", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/blumpkin/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("blumpkinjuice", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/bungo_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/bungo
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("bungojuice", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/bungo/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("bungojuice", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/bungo/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("bungojuice", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/bungo/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("bungojuice", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/caramel_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/caramel
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/caramel/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/caramel/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/caramel/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/chaosdonut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chaos
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_ADD_REAGENT("capsaicin", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/chocolate_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chocolate
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chocolate/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chocolate/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chocolate/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/sprinkles
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/sprinkles
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("sprinkles", 2),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jellydonut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/cherryjelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/matcha_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/matcha
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("teapowder", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/matcha/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("teapowder", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/matcha/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("teapowder", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/matcha/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("teapowder", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/meat_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/meat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_REAGENT("ketchup", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/pink_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/pink
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/pink/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/pink/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/pink/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/spaceman_donut
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/spaceman
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/spaceman/jelly
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/spaceman/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/spaceman/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/donut),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_USE_DEEP_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/banana
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/friedbanana
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/carrotfries
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/carrotfries
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot/wedges),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/chimichanga
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/chimichanga
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/burrito),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/corn_chips
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/cornchips
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/corn),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/fried_tofu
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_tofu
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/fries
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fries
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawsticks),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/onionrings
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/onionrings
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/potato_chips
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/chips
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato/wedges),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/shrimp
	cooking_container = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_shrimp
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_USE_DEEP_FRYER(10 SECONDS),
	)


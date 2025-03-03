/datum/cooking/recipe/bacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bbqribs
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bbqribs
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_REAGENT("bbqsauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birdsteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak/chicken
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/chicken),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cutlet
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/cutlet
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fish_skewer
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fish_skewer
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fishfingers
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fishfingers
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/goliath
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/goliath_steak
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/goliath),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/grilledcheese
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/grilledcheese
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/human_kebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/human/kebab
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/meatkeb
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatkebab
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatsteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/omelette
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/omelette
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/picoss_kebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/picoss_kebab
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("vinegar", 5),
		PCWJ_USE_GRILL(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/rofflewaffles
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/rofflewaffles
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("psilocybin", 5),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/salmonsteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/salmonsteak
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sausage
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sausage
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/shrimp_skewer
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/shrimp_skewer
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_USE_GRILL(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sushi_tamago
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_tamago
	catalog_category = COOKBOOK_CATEGORY_SUSHI
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_ADD_REAGENT("sake", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_unagi
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sushi_unagi
	catalog_category = COOKBOOK_CATEGORY_SUSHI
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/fish/electric_eel),
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_ADD_REAGENT("sake", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntikebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/syntikebab
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntisteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntitelebacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/assembly/signaler),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/telebacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/assembly/signaler),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofukebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/tofukebab
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/waffles
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/waffles
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/wingfangchu
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/wingfangchu
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)


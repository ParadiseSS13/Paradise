/datum/cooking/recipe/bacon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bbqribs
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bbqribs
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_REAGENT("bbqsauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birdsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak/chicken
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/chicken),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cutlet
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/cutlet
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fish_skewer
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fishfingers
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/goliath
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/goliath_steak
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/goliath),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/grilledcheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/grilledcheese
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/human_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/human/kebab
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/meatkeb
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatkebab
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_MEATHUNK(),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/omelette
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/salmonsteak
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sausage
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sausage
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/shrimp_skewer
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
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
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/syntikebab
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/telebacon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_MEATHUNK(),
		PCWJ_ADD_ITEM(/obj/item/assembly/signaler),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofukebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/tofukebab
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/waffles
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/waffles
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/wingfangchu
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/wingfangchu
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)


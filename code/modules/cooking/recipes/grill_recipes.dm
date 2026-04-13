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

/datum/cooking/recipe/fish_skewer_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fish_skewer/bone
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe_step/add_item/fried_vulp/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/organ/external/external = added_item
	if(!istype(external))
		return PCWJ_CHECK_INVALID

	if(istype(external.dna.species, /datum/species/vulpkanin))
		return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe/frankfurrter
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/frankfurrter
	steps = list(
		new /datum/cooking/recipe_step/add_item/fried_vulp(),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)
	appear_in_default_catalog = FALSE

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

/datum/cooking/recipe_step/add_item/fried_unathi/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/organ/external/external = added_item
	if(!istype(external))
		return PCWJ_CHECK_INVALID

	if(istype(external.dna.species, /datum/species/unathi))
		return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe/hiss_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/hiss_kebab
	steps = list(
		new /datum/cooking/recipe_step/add_item/fried_unathi(),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)
	appear_in_default_catalog = FALSE

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

/datum/cooking/recipe/human_kebab_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/human/kebab/bone
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe/meatkeb_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatkebab/bone
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe/picoss_kebab_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/picoss_kebab/bone
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe/shrimp_skewer_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/shrimp_skewer/bone
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe/syntikebab_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/syntikebab/bone
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

/datum/cooking/recipe/tofukebab_bone
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/tofukebab/bone
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/bone_rods),
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

// ----------- Grill recipes imported from Hispania!

//HISPANIA GRILL RECIPES
/datum/cooking/recipe/arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough/corn),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_cheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/cheese
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_ham
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ham
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/rawcutlet),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_ham_cheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ham_cheese
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/rawcutlet),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_plasma
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/plasma
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_REAGENT("plasma_dust", 10),
		PCWJ_USE_GRILL(J_LO, 10 SECONDS),
	)

/datum/cooking/recipe/ghost_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ghost
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/ectoplasm),
		PCWJ_ADD_REAGENT("enzyme", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/xeno_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/xeno
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("enzyme", 5),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/spider_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/spider
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/spiderleg),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
		PCWJ_ADD_REAGENT("charcoal", 1),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_life
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/life
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_REAGENT("lazarus_reagent", 5),
		PCWJ_ADD_REAGENT("holywater", 1),
		PCWJ_USE_GRILL(J_LO, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_slime
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/slime
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sweet_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/sweet
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/slime_extract),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_cheesier
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/cheesier
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/cheesewheel),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/fruit_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/fruit
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_salmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/salmon
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_industrial
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/industrial
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_ITEM(/obj/item/robot_parts/head),
		PCWJ_USE_GRILL(J_HI, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_infernal
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/infernal
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_REAGENT("capsaicin", 10),
		PCWJ_ADD_REAGENT("napalm", 1),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_ice
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ice
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_REAGENT("frostoil", 10),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_GRILL(J_LO, 10 SECONDS),
	)

/datum/cooking/recipe/arepa_plumphelmet
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/plumphelmet
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		PCWJ_ADD_REAGENT("enzyme", 5),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/arepa_magma
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/magma
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/arepa),
		PCWJ_ADD_REAGENT("capsaicin", 10),
		PCWJ_ADD_REAGENT("blood", 10),
		PCWJ_ADD_REAGENT("plasma_dust", 10),
		PCWJ_USE_GRILL(J_HI, 20 SECONDS),
	)

// Toast //
/datum/cooking/recipe/toast
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/toast
	catalog_category = COOKBOOK_CATEGORY_BREAD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_USE_GRILL(J_HI, 10 SECONDS),
	)

// CHULETA //
/datum/cooking/recipe/syntisteak_cactus
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/syntisteak_cactus
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh, exact = TRUE),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/prickly_pear),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

/datum/cooking/recipe/meatsteak_cactus
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak_cactus
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_MEATHUNK(exact = TRUE),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/prickly_pear),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 15 SECONDS),
	)

// SALMON STUFF //
/datum/cooking/recipe/smokedsalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/smokedsalmon
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_USE_GRILL(J_HI, 15 SECONDS),
	)

/datum/cooking/recipe/avocadosalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/avocadosalmon
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/avocado),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_HI, 15 SECONDS),
	)

/datum/cooking/recipe/citrussalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/citrussalmon
	catalog_category = COOKBOOK_CATEGORY_SEAFOOD
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_HI, 15 SECONDS),
	)

// ----------- END of recipe imports from Hispania!

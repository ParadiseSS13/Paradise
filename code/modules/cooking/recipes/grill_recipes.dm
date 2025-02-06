/datum/cooking/recipe/bacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bacon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/raw_bacon),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bbqribs
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bbqribs
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_REAGENT("bbqsauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berry_pancake
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/pancake/berry_pancake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/berries),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birdsteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak/chicken
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/chicken),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/choc_chip_pancake
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/pancake/choc_chip_pancake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_ADD_ITEM(/obj/item/food/choc_pile),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cutlet
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/cutlet
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/rawcutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fish_skewer
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fish_skewer
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
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/goliath
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/goliath_steak
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/goliath),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/grilledcheese
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/grilledcheese
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
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatsteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/omelette
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/omelette
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_USE_GRILL(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pancake
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/pancake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cookiedough),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/picoss_kebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/picoss_kebab
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
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sausage
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sausage
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/shrimp_skewer
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/shrimp_skewer
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/food/shrimp),
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_USE_GRILL(J_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sushi_ebi
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_ebi
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/boiled_shrimp),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_ikura
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_ikura
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/fish_eggs/salmon),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_inari
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_inari
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/fried_tofu),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_masago
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_masago
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/fish_eggs/goldfish),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_sake
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_sake
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/salmonmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_smoked_salmon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_smoked_salmon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/salmonsteak),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_tai
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_tai
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/food/catfishmeat),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_tamago
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_tamago
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_ADD_REAGENT("sake", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_tobiko
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_tobiko
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledrice),
		PCWJ_ADD_ITEM(/obj/item/fish_eggs/shark),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_tobiko_egg
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sliced/sushi_tobiko_egg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/sushi_tobiko),
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/stack/seaweed),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/sushi_unagi
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sushi_unagi
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
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntisteak
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_REAGENT("sodiumchloride", 1),
		PCWJ_ADD_REAGENT("blackpepper", 1),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntitelebacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/syntiflesh),
		PCWJ_ADD_ITEM(/obj/item/assembly/signaler),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/telebacon
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat),
		PCWJ_ADD_ITEM(/obj/item/assembly/signaler),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofukebab
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/tofukebab
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/stack/rods),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/waffles
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/waffles
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)

/datum/cooking/recipe/wingfangchu
	cooking_container = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/wingfangchu
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
		PCWJ_ADD_REAGENT("soysauce", 5),
		PCWJ_USE_GRILL(J_MED, 10 SECONDS),
	)


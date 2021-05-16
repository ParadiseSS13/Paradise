///HISPANIA GRILL RECIPES
/datum/recipe/grill/arepa
	reagents = list("sodiumchloride" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/arepa

/datum/recipe/grill/arepa_cheese
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/reagent_containers/food/snacks/arepa_cheese

/datum/recipe/grill/arepa_ham
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/rawcutlet)
	result = /obj/item/reagent_containers/food/snacks/arepa_ham

/datum/recipe/grill/arepa_ham_cheese
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/rawcutlet, /obj/item/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/reagent_containers/food/snacks/arepa_ham_cheese

/datum/recipe/grill/arepa_plasma
	reagents = list("plasma_dust" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_plasma

/datum/recipe/grill/ghost_arepa
	reagents = list("enzyme" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/ectoplasm
	)
	result = /obj/item/reagent_containers/food/snacks/ghost_arepa

/datum/recipe/grill/xeno_arepa
	reagents = list("sugar" = 5, "enzyme" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/reagent_containers/food/snacks/xeno_arepa

/datum/recipe/grill/spider_arepa
	reagents = list("sodiumchloride" = 5, "charcoal" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg,
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg,
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg,
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg,
	)
	result = /obj/item/reagent_containers/food/snacks/spider_arepa

/datum/recipe/grill/arepa_life
	reagents = list("strange_reagent" = 5, "holywater" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_life

/datum/recipe/grill/arepa_slime
	reagents = list("water" = 10)
	items = list(
	/obj/item/reagent_containers/food/snacks/arepa, /obj/item/slime_extract
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_slime

/datum/recipe/grill/sweet_arepa
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/slime_extract
	)
	result = /obj/item/reagent_containers/food/snacks/sweet_arepa

/datum/recipe/grill/cheese_arepa
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	)
	result = /obj/item/reagent_containers/food/snacks/cheese_arepa

/datum/recipe/grill/fruit_arepa
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/fruit_arepa

/datum/recipe/grill/arepa_salmon
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/salmonmeat
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_salmon

/datum/recipe/grill/arepa_industrial
	reagents = list("oil" = 5, "iron" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/robot_parts/head
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_industrial

/datum/recipe/grill/arepa_infernal
	reagents = list("capsaicin" = 10, "napalm" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_infernal

/datum/recipe/grill/arepa_ice
	reagents = list("frostoil" = 10, "water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_ice

/datum/recipe/grill/arepa_plumphelmet
	reagents = list("enzyme" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_plumphelmet

/datum/recipe/grill/arepa_magma
	reagents = list("capsaicin" = 10, "blood" = 10, "plasma_dust" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa_infernal
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_magma

//Toast//
/datum/recipe/grill/toast
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice
	)
	result = /obj/item/reagent_containers/food/snacks/toast

//Buttertoast//
/datum/recipe/grill/butter_toast
	reagents = list("butter" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/toast
	)
	result = /obj/item/reagent_containers/food/snacks/butter_toast
// CHULETA//

/datum/recipe/grill/syntisteak_cactus
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/grown/prickly_pear,
	)
	result = /obj/item/reagent_containers/food/snacks/syntisteak_cactus

/datum/recipe/grill/meatsteak_cactus
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/prickly_pear,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak_cactus

// BRONTOOOSAURIO//
/datum/recipe/grill/brontosaurio
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/drakeribs
	)
	result = /obj/item/reagent_containers/food/snacks/brontosaurio

// SALMON STUFF //
/datum/recipe/grill/smokedsalmon
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat
	)
	result = /obj/item/reagent_containers/food/snacks/smokedsalmon

/datum/recipe/grill/avocadosalmon
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/avocadoslice
	)
	result = /obj/item/reagent_containers/food/snacks/avocadosalmon

/datum/recipe/grill/citrussalmon
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	)
	result = /obj/item/reagent_containers/food/snacks/citrussalmon

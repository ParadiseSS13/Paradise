///HISPANIA GRILL RECIPES

/datum/recipe/grill/arepa
	reagents = list("sodiumchloride" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/arepa

/datum/recipe/grill/arepa_queso
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/reagent_containers/food/snacks/arepa_queso

/datum/recipe/grill/arepa_jamon
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/rawcutlet)
	result = /obj/item/reagent_containers/food/snacks/arepa_jamon

/datum/recipe/grill/arepa_jamon_queso
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/rawcutlet, /obj/item/reagent_containers/food/snacks/cheesewedge)
	result = /obj/item/reagent_containers/food/snacks/arepa_jamon_queso

/datum/recipe/grill/arepa_plasma
	reagents = list("plasma_dust" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_plasma

/datum/recipe/grill/arepa_fantasma_boo
	reagents = list("enzyme" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/ectoplasm
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_fantasma_boo

/datum/recipe/grill/xeno_arepa
	reagents = list("sugar" = 5, "enzyme" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/xenomeat
	)
	result = /obj/item/reagent_containers/food/snacks/xeno_arepa

/datum/recipe/grill/spider_arepa
	reagents = list("sodiumchloride" = 5, "charcoal" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/spiderleg,
		/obj/item/reagent_containers/food/snacks/spiderleg,
		/obj/item/reagent_containers/food/snacks/spiderleg,
		/obj/item/reagent_containers/food/snacks/spiderleg,
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

/datum/recipe/grill/arepa_dulce
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/slime_extract
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_dulce

/datum/recipe/grill/queso_arepa
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa, /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	)
	result = /obj/item/reagent_containers/food/snacks/queso_arepa

/datum/recipe/grill/arepa_frutal
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/arepa_frutal

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

/datum/recipe/grill/alma_venezolana
	reagents = list("gold" = 5, "holywater" = 5, "blood" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/arepa,
		/obj/item/reagent_containers/food/snacks/arepa_queso,
		/obj/item/reagent_containers/food/snacks/arepa_jamon,
		/obj/item/reagent_containers/food/snacks/arepa_jamon_queso,
	)
	result = /obj/item/reagent_containers/food/snacks/alma_venezolana

/datum/recipe/grill/verdadera_alma_venezola
	reagents = list("silver" = 10, "gold" = 10)
	items = list(
		 /obj/item/reagent_containers/food/snacks/alma_venezolana,
		 /obj/item/reagent_containers/food/snacks/arepa,
		 /obj/item/reagent_containers/food/snacks/arepa_queso,
		 /obj/item/reagent_containers/food/snacks/arepa_jamon,
		 /obj/item/reagent_containers/food/snacks/arepa_jamon_queso,
		 /obj/item/reagent_containers/food/snacks/arepa_plasma,
		 /obj/item/reagent_containers/food/snacks/arepa_fantasma_boo,
		 /obj/item/reagent_containers/food/snacks/xeno_arepa,
		 /obj/item/reagent_containers/food/snacks/spider_arepa,
		 /obj/item/reagent_containers/food/snacks/arepa_life,
		 /obj/item/reagent_containers/food/snacks/arepa_slime,
		 /obj/item/reagent_containers/food/snacks/arepa_dulce,
		 /obj/item/reagent_containers/food/snacks/queso_arepa,
		 /obj/item/reagent_containers/food/snacks/arepa_frutal,
		 /obj/item/reagent_containers/food/snacks/arepa_salmon,
		 /obj/item/reagent_containers/food/snacks/arepa_industrial,
		 /obj/item/reagent_containers/food/snacks/arepa_infernal,
		 /obj/item/reagent_containers/food/snacks/arepa_ice,
		 /obj/item/reagent_containers/food/snacks/arepa_plumphelmet,
		 /obj/item/reagent_containers/food/snacks/arepa_magma,
	)
	result = /obj/item/reagent_containers/food/snacks/verdadera_alma_venezolana



// /datum/recipe/grill

/datum/recipe/grill/bacon
	items = list(
		/obj/item/reagent_containers/food/snacks/raw_bacon,
	)
	result = /obj/item/reagent_containers/food/snacks/bacon

/datum/recipe/grill/telebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon


/datum/recipe/grill/syntitelebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon

/datum/recipe/grill/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg

/datum/recipe/grill/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/salmonsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat
	)
	result = /obj/item/reagent_containers/food/snacks/salmonsteak

/datum/recipe/grill/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/waffles
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/grill/rofflewaffles
	reagents = list("psilocybin" = 5, "sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/grill/grilledcheese
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/grilledcheese

/datum/recipe/grill/sausage
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/sausage

/datum/recipe/grill/fishfingers
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishfingers

/datum/recipe/grill/fishfingers/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/fishfingers/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/grill/cutlet
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result = /obj/item/reagent_containers/food/snacks/cutlet

/datum/recipe/grill/omelette
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/omelette

/datum/recipe/grill/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/wingfangchu

/datum/recipe/grill/human/kabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/reagent_containers/food/snacks/human/kabob

/datum/recipe/grill/monkeykabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/monkey,
		/obj/item/reagent_containers/food/snacks/meat/monkey,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/syntikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofukabob

/datum/recipe/grill/sushi_Tamago
	reagents = list("sake" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tamago

/datum/recipe/grill/sushi_Unagi
	reagents = list("sake" = 5)
	items = list(
		/obj/item/fish/electric_eel,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Unagi

/datum/recipe/grill/sushi_Ebi
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ebi

/datum/recipe/grill/sushi_Ikura
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/salmon,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ikura

/datum/recipe/grill/sushi_Inari
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/fried_tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Inari

/datum/recipe/grill/sushi_Sake
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Sake

/datum/recipe/grill/sushi_SmokedSalmon
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonsteak,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon

/datum/recipe/grill/sushi_Masago
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/goldfish,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Masago

/datum/recipe/grill/sushi_Tobiko
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/shark,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tobiko

/datum/recipe/grill/sushi_TobikoEgg
	items = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg

/datum/recipe/grill/sushi_Tai
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/catfishmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tai

/datum/recipe/grill/goliath
	items = list(
/obj/item/reagent_containers/food/snacks/goliath
	)
	result = /obj/item/reagent_containers/food/snacks/goliath_steak
	
/datum/recipe/grill/shrimp_skewer
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/shrimp_skewer

/datum/recipe/grill/fish_skewer
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/fish_skewer

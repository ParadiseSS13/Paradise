/datum/cooking/recipe/aesirsalad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/aesir
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
	)

/datum/cooking/recipe/antipasto_salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/antipasto
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/olive),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
	)

/datum/cooking/recipe/caesar_salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/caesar
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_REAGENT("oliveoil", 5),
	)

/datum/cooking/recipe/citrusdelight
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/citrusdelight
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/fruitsalad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/fruit
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
	)

/datum/cooking/recipe/greek_salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/greek
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/olive),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
		PCWJ_ADD_REAGENT("oliveoil", 5),
	)

/datum/cooking/recipe/herbsalad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/herb
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
	)

/datum/cooking/recipe/junglesalad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/jungle
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
	)

/datum/cooking/recipe/kale_salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/kale
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_REAGENT("oliveoil", 5),
	)

/datum/cooking/recipe/melonfruitbowl
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/melonfruitbowl
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/potato_salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/potato
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("mayonnaise", 5),
	)

/datum/cooking/recipe/salad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/validsalad
	cooking_container = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/valid
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
	)


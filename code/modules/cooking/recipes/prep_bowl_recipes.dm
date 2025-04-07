/datum/cooking/recipe/aesirsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/aesir
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
	)

/datum/cooking/recipe/antipasto_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/antipasto
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/olive),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/tomato),
	)

/datum/cooking/recipe/caesar_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/caesar
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_REAGENT("oliveoil", 5),
	)

/datum/cooking/recipe/citrusdelight
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/citrusdelight
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/fruitsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/fruit
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
	)

/datum/cooking/recipe/greek_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/greek
	catalog_category = COOKBOOK_CATEGORY_SALADS
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
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/herb
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
	)

/datum/cooking/recipe/junglesalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/jungle
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/grapes),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
	)

/datum/cooking/recipe/kale_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/kale
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice/red),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/carrot),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_REAGENT("oliveoil", 5),
	)

/datum/cooking/recipe/melonfruitbowl
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/melonfruitbowl
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/watermelon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/apple),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/potato_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/potato
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/boiledegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
		PCWJ_ADD_REAGENT("mayonnaise", 5),
	)

/datum/cooking/recipe/salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/validsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/valid
	catalog_category = COOKBOOK_CATEGORY_SALADS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatball),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris, exclude_reagents = list("toxin")),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/potato),
	)


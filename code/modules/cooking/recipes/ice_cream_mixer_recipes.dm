/datum/cooking/recipe/antpopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/ant
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("ants", 10),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/bananatopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/bananatop
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("banana", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berrycreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/berrycream
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("berryjuice", 4),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("vanilla", 2),
		PCWJ_ADD_REAGENT("cream", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berryicecreamsandwich
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/berryicecreamsandwich
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("ice", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berrytopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/berrytop
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cornuto
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/cornuto
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("sugar", 4),
		PCWJ_ADD_REAGENT("cream", 4),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/frozenpineapplepop
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/frozenpineapple
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/honkdae
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/honkdae
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/gas/clown_hat),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_ADD_REAGENT("ice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(20 SECONDS),
	)

/datum/cooking/recipe/icecreamsandwich
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/icecreamsandwich
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/frozen/icecream),
		PCWJ_ADD_REAGENT("ice", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jumboicecream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("vanilla", 3),
		PCWJ_ADD_REAGENT("cream", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/licoricecreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/licoricecream
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("blumpkinjuice", 4),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("vanilla", 2),
		PCWJ_ADD_REAGENT("cream", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/orangecreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/orangecream
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("orangejuice", 4),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("vanilla", 2),
		PCWJ_ADD_REAGENT("cream", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/peanutbuttermochi
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/peanutbuttermochi
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_ADD_REAGENT("rice", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/pineappletopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/pineappletop
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("pineapplejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/seasalticecream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/sea_salt
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 3),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/apple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/apple
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/berry
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/bluecherry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/bluecherry
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("bluecherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cherry_snowcone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/cherry
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cola
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/cola
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("cola", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/flavorless
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fruitsalad_snowcone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/fruitsalad
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("banana", 5),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_ADD_REAGENT("watermelonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/grape
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/grape
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("grapejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/honey
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/honey
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/lemon
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/lemon
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/lime
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/lime
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("limejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/mime
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/mime
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("nothing", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/orange
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/pineapple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/pineapple
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("pineapplejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/rainbow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/rainbow
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("colorful_reagent", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/spacemountainwind
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/spacemountain
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("spacemountainwind", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/spacefreezy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/spacefreezy
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/frozen/icecream),
		PCWJ_ADD_REAGENT("bluecherryjelly", 5),
		PCWJ_ADD_REAGENT("spacemountainwind", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/sundae
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/sundae
	catalog_category = COOKBOOK_CATEGORY_DESSERTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candycane
	container_type = /obj/item/reagent_containers/cooking/mould/cane
	product_type = /obj/item/food/candy/candycane
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/mint),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cash
	container_type = /obj/item/reagent_containers/cooking/mould/cash
	product_type = /obj/item/food/candy/cash
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/coin
	container_type = /obj/item/reagent_containers/cooking/mould/coin
	product_type = /obj/item/food/candy/coin
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/crunch
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/rice
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_REAGENT("rice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gummybear
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/candy/gummybear
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/candy/gummyworm
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jawbreaker
	container_type = /obj/item/reagent_containers/cooking/mould/ball
	product_type = /obj/item/food/candy/jawbreaker
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jellybean
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/candy/jellybean
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/malper
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/caramel
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/sucker
	container_type = /obj/item/reagent_containers/cooking/mould/loli
	product_type = /obj/item/food/candy/sucker
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toolerone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/nougat
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/nougat),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toxinstest
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/caramel_nougat
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_ITEM(/obj/item/food/candy/nougat),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/yumbaton
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/toffee
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/toffee),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candied_pineapple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/candied_pineapple
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("water", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candybar
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/candybar
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/caramel
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/caramel
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("soymilk", 2),
		PCWJ_ADD_REAGENT("cocoa", 2),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("milk", 2),
		PCWJ_ADD_REAGENT("cocoa", 2),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bunny
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_bunny
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_coin
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_coin
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/coin),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_orange
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/c_tube),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_blue
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/blue
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_green
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/green
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("limejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/orange
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_pink
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/pink
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("watermelonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_poison
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/poison
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("poisonberryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_purple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/purple
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("grapejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_rainbow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/rainbow
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/red),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/blue),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/green),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/yellow),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/orange),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/purple),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/pink),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_rainbow2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/bad_rainbow
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/red),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/poison),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/green),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/yellow),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/orange),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/purple),
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton/pink),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_red
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/red
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_yellow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/yellow
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_cherry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/cherry
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_cookies_n_cream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/cookies_n_cream
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/cookie),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_dice
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge_dice
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/dice),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_peanut
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/peanut
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_turtle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/turtle
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gum
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/gum
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/nougat
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/nougat
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/taffy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/taffy
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("salglu_solution", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toffee
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/toffee
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/wafflecone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/wafflecone
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("milk", 1),
		PCWJ_ADD_REAGENT("sugar", 1),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/mint
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/mint
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("toxin", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/mint_2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/mint
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolateegg
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolateegg
	catalog_category = COOKBOOK_CATEGORY_CANDY
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

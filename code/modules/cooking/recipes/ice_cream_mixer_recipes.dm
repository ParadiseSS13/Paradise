/datum/cooking/recipe/antpopsicle
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/ant
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("ants", 10),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/bananatopsicle
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/bananatop
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("banana", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berrycreamsicle
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/berrycream
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/berryicecreamsandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_REAGENT("ice", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berrytopsicle
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/berrytop
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cornuto
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/cornuto
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliceable/flatdough),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("ice", 2),
		PCWJ_ADD_REAGENT("sugar", 4),
		PCWJ_ADD_REAGENT("cream", 4),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/frozenpineapplepop
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/frozenpineapple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/honkdae
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/honkdae
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/icecreamsandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/frozen/icecream),
		PCWJ_ADD_REAGENT("ice", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jumboicecream
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/licoricecream
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/orangecream
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/peanutbuttermochi
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_ADD_REAGENT("rice", 5),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/pineappletopsicle
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/pineappletop
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("pineapplejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/seasalticecream
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/popsicle/sea_salt
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/popsicle_stick),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("sodiumchloride", 3),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/apple
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/apple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("applejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/berry
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/berry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/bluecherry
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/bluecherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("bluecherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cherry
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cola
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/cola
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("cola", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/flavorless
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fruitsalad
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/fruitsalad
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("banana", 5),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_ADD_REAGENT("watermelonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/grape
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/grape
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("grapejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/honey
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/honey
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("honey", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/lemon
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/lemon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/lime
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/lime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("limejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/mime
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/mime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("nothing", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/orange
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/orange
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/pineapple
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/pineapple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("pineapplejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/rainbow
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/rainbow
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("colorful_reagent", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/spacemountainwind
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/snowcone/spacemountain
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/reagent_containers/drinks/sillycup),
		PCWJ_ADD_REAGENT("ice", 15),
		PCWJ_ADD_REAGENT("spacemountainwind", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/spacefreezy
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/spacefreezy
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/frozen/icecream),
		PCWJ_ADD_REAGENT("bluecherryjelly", 5),
		PCWJ_ADD_REAGENT("spacemountainwind", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/sundae
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen/sundae
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/wafflecone),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cherries),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candycane
	cooking_container = /obj/item/reagent_containers/cooking/mould/cane
	product_type = /obj/item/food/candy/candycane
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/mint),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cash
	cooking_container = /obj/item/reagent_containers/cooking/mould/cash
	product_type = /obj/item/food/candy/cash
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/coin
	cooking_container = /obj/item/reagent_containers/cooking/mould/coin
	product_type = /obj/item/food/candy/coin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/crunch
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/rice
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_REAGENT("rice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gummybear
	cooking_container = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/candy/gummybear
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm
	cooking_container = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/candy/gummyworm
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jawbreaker
	cooking_container = /obj/item/reagent_containers/cooking/mould/ball
	product_type = /obj/item/food/candy/jawbreaker
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/jellybean
	cooking_container = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/candy/jellybean
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/malper
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/caramel
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/sucker
	cooking_container = /obj/item/reagent_containers/cooking/mould/loli
	product_type = /obj/item/food/candy/sucker
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 10),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toolerone
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/nougat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/nougat),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toxinstest
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/caramel_nougat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_ITEM(/obj/item/food/candy/nougat),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/yumbaton
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/confectionery/toffee
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/candybar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/toffee),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candied_pineapple
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/candied_pineapple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/pineapple),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_ADD_REAGENT("water", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/candybar
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/candybar
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/caramel
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/caramel
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	steps = list(
		PCWJ_ADD_REAGENT("soymilk", 2),
		PCWJ_ADD_REAGENT("cocoa", 2),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar2
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	steps = list(
		PCWJ_ADD_REAGENT("milk", 2),
		PCWJ_ADD_REAGENT("cocoa", 2),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bunny
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_bunny
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 2),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_coin
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_coin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/coin),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_orange
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/chocolate_orange
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/c_tube),
		PCWJ_ADD_REAGENT("sugar", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_blue
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/blue
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("berryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_green
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/green
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("limejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_orange
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/orange
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("orangejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_pink
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/pink
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("watermelonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_poison
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/poison
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("poisonberryjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_purple
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/purple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("grapejuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_rainbow
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/rainbow
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/bad_rainbow
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/red
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_yellow
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/cotton/yellow
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/candy/cotton),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_cherry
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/cherry
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/cookies_n_cream
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/cookie),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_ADD_REAGENT("cream", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_dice
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge_dice
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/dice),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/fudge_peanut
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/peanut
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
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/fudge/turtle
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_ADD_ITEM(/obj/item/food/candy/caramel),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/peanuts),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("milk", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/gum
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/gum
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("water", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/nougat
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/nougat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("cornoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/taffy
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/taffy
	steps = list(
		PCWJ_ADD_REAGENT("salglu_solution", 15),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/toffee
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy/toffee
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("flour", 10),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/wafflecone
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/wafflecone
	steps = list(
		PCWJ_ADD_REAGENT("milk", 1),
		PCWJ_ADD_REAGENT("sugar", 1),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/mint_2
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/mint
	steps = list(
		PCWJ_ADD_REAGENT("sugar", 5),
		PCWJ_ADD_REAGENT("frostoil", 5),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

/datum/cooking/recipe/chocolateegg
	cooking_container = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolateegg
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/egg),
		PCWJ_ADD_ITEM(/obj/item/food/chocolatebar),
		PCWJ_USE_ICE_CREAM_MIXER(10 SECONDS),
	)

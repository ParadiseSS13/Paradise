/datum/supply_packs/organic
	name = "HEADER"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer
	department_restrictions = list(DEPARTMENT_SERVICE)


/datum/supply_packs/organic/food
	name = "Food Crate"
	contains = list(/obj/item/reagent_containers/condiment/flour,
					/obj/item/reagent_containers/condiment/rice,
					/obj/item/reagent_containers/condiment/milk,
					/obj/item/reagent_containers/condiment/soymilk,
					/obj/item/reagent_containers/condiment/saltshaker,
					/obj/item/reagent_containers/condiment/peppermill,
					/obj/item/kitchen/rollingpin,
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/condiment/enzyme,
					/obj/item/reagent_containers/condiment/sugar,
					/obj/item/food/meat/monkey,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/banana)
	cost = 250
	containername = "food crate"
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_packs/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/pepperoni,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/hawaiian,
					/obj/item/kitchen/knife/pizza_cutter)
	cost = 500
	containername = "Pizza crate"

/datum/supply_packs/organic/fancyparty
	name = "Executive Party Crate"
	contains = list(/obj/item/food/sliceable/cheesewheel/edam,
					/obj/item/food/sliceable/cheesewheel/blue,
					/obj/item/food/sliceable/cheesewheel/camembert,
					/obj/item/food/sliceable/cheesewheel/camembert,
					/obj/item/food/sliceable/cheesewheel/smoked,
					/obj/item/reagent_containers/drinks/bottle/wine,
					/obj/item/food/caviar,
					/obj/item/food/caviar,
					/obj/item/reagent_containers/drinks/drinkingglass,
					/obj/item/reagent_containers/drinks/drinkingglass)
	cost = 1000
	containername = "Executive Party crate"
	containertype = /obj/structure/closet/crate/freezer/deluxe

/// its a bit hacky...
/datum/supply_packs/misc/randomised/ingredients
	num_contained = 25
	contains = list(/obj/item/food/grown/wheat,
					/obj/item/food/grown/tomato,
					/obj/item/food/grown/potato,
					/obj/item/food/grown/carrot,
					/obj/item/food/grown/pumpkin,
					/obj/item/food/grown/chili,
					/obj/item/food/grown/cocoapod,
					/obj/item/food/grown/corn,
					/obj/item/food/grown/eggplant,
					/obj/item/food/grown/apple,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/cherries)
	name = "Ingredient Crate"
	cost = 300
	containername = "ingredient crate"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/organic/condiments
	name = "Condiment Crate"
	contains = list(/obj/item/reagent_containers/condiment/ketchup,
					/obj/item/reagent_containers/condiment/bbqsauce,
					/obj/item/reagent_containers/condiment/soysauce,
					/obj/item/reagent_containers/condiment/mayonnaise,
					/obj/item/reagent_containers/condiment/cherryjelly,
					/obj/item/reagent_containers/condiment/peanutbutter,
					/obj/item/reagent_containers/condiment/honey,
					/obj/item/reagent_containers/condiment/oliveoil,
					/obj/item/reagent_containers/condiment/frostoil,
					/obj/item/reagent_containers/condiment/capsaicin,
					/obj/item/reagent_containers/condiment/wasabi,
					/obj/item/reagent_containers/condiment/vinegar)
	cost = 300
	containername = "condiment crate"

/datum/supply_packs/organic/seafood
	name = "Seafood Crate"
	contains = list(
		/obj/item/fish/salmon,
		/obj/item/fish/salmon,
		/obj/item/fish/salmon,
		/obj/item/fish/catfish,
		/obj/item/fish/catfish,
		/obj/item/fish/catfish,
		/obj/item/food/shrimp,
		/obj/item/food/shrimp,
		/obj/item/food/shrimp,
		/obj/item/food/shrimp
	)
	cost = 300
	containername = "seafood crate"

/datum/supply_packs/organic/donuts
	name = "Donuts Crate"
	contains = list(
		/obj/item/storage/fancy/donut_box,
		/obj/item/storage/fancy/donut_box,
		/obj/item/storage/fancy/donut_box,
		/obj/item/storage/fancy/donut_box,
		/obj/item/storage/fancy/donut_box
	)
	cost = 450
	containername = "donuts crate"

/datum/supply_packs/organic/donkpocket
	name = "Donk-Pockets Crate"
	contains = list(
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets
	)
	cost = 400
	containername = "donk-pockets crate"

/datum/supply_packs/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 200
	containername = "monkey crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/nian_worme
	name = "Nian Worme Crate"
	contains = list (/obj/item/storage/box/monkeycubes/nian_worme_cubes)
	cost = 200
	containername = "nian worme crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/farwa
	name = "Farwa Crate"
	contains = list (/obj/item/storage/box/monkeycubes/farwacubes)
	cost = 200
	containername = "farwa crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)


/datum/supply_packs/organic/wolpin
	name = "Wolpin Crate"
	contains = list (/obj/item/storage/box/monkeycubes/wolpincubes)
	cost = 200
	containername = "wolpin crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)


/datum/supply_packs/organic/skrell
	name = "Neaera Crate"
	contains = list (/obj/item/storage/box/monkeycubes/neaeracubes)
	cost = 200
	containername = "neaera crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/stok
	name = "Stok Crate"
	contains = list (/obj/item/storage/box/monkeycubes/stokcubes)
	cost = 200
	containername = "stok crate"
	department_restrictions = list(DEPARTMENT_SERVICE, DEPARTMENT_MEDICAL, DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/party
	name = "Party Equipment Crate"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/drinks/shaker,
					/obj/item/reagent_containers/drinks/bottle/patron,
					/obj/item/reagent_containers/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/drinks/bottle/ale,
					/obj/item/reagent_containers/drinks/bottle/ale,
					/obj/item/reagent_containers/drinks/bottle/beer,
					/obj/item/reagent_containers/drinks/bottle/beer,
					/obj/item/reagent_containers/drinks/bottle/beer,
					/obj/item/reagent_containers/drinks/bottle/beer,
					/obj/item/grenade/confetti,
					/obj/item/grenade/confetti)
	cost = 250
	containername = "party equipment"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/organic/bar
	name = "Bar Starter Kit"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/circuitboard/chem_dispenser/soda,
					/obj/item/circuitboard/chem_dispenser/beer,
					/obj/item/barsign_electronics)
	cost = 250
	containername = "beer starter kit"
	announce_beacons = list("Bar" = list("Bar"))

//////// livestock
/datum/supply_packs/organic/cow
	name = "Cow Crate"
	cost = 100
	contains_special = list(
		"Cow"
	)
	containertype = /obj/structure/closet/critter/cow
	containername = "cow crate"

/datum/supply_packs/organic/pig
	name = "Pig Crate"
	cost = 100
	contains_special = list(
		"Pig"
	)
	containertype = /obj/structure/closet/critter/pig
	containername = "pig crate"

/datum/supply_packs/organic/goat
	name = "Goat Crate"
	cost = 100
	contains_special = list(
		"Goat"
	)
	containertype = /obj/structure/closet/critter/goat
	containername = "goat crate"

/datum/supply_packs/organic/chicken
	name = "Chicken Crate"
	cost = 100
	contains_special = list(
		"4 to 6 chickens"
	)
	containertype = /obj/structure/closet/critter/chick
	containername = "chicken crate"

/datum/supply_packs/organic/turkey
	name = "Turkey Crate"
	cost = 100
	contains_special = list(
		"Turkey"
	)
	containertype = /obj/structure/closet/critter/turkey
	containername = "turkey crate"

/datum/supply_packs/organic/corgi
	name = "Corgi Crate"
	cost = 300
	contains_special = list(
		"Corgi"
	)
	containertype = /obj/structure/closet/critter/corgi
	contains = list(/obj/item/petcollar)
	containername = "corgi crate"

/datum/supply_packs/organic/cat
	name = "Cat Crate"
	cost = 300 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/critter/cat
	contains_special = list(
		"Cat"
	)
	contains = list(/obj/item/petcollar,
					/obj/item/toy/cattoy)
	containername = "cat crate"

/datum/supply_packs/organic/pug
	name = "Pug Crate"
	cost = 300
	contains_special = list(
		"Pug"
	)
	containertype = /obj/structure/closet/critter/pug
	contains = list(/obj/item/petcollar)
	containername = "pug crate"

/datum/supply_packs/organic/fox
	name = "Fox Crate"
	cost = 300 //Foxes are cool.
	contains_special = list(
		"Fox"
	)
	containertype = /obj/structure/closet/critter/fox
	contains = list(/obj/item/petcollar)
	containername = "fox crate"

/datum/supply_packs/organic/butterfly
	name = "Butterfly Crate"
	cost = 300
	contains_special = list(
		"Butterfly"
	)
	containertype = /obj/structure/closet/critter/butterfly
	containername = "butterfly crate"

/datum/supply_packs/organic/nian_caterpillar
	name = "Nian Caterpillar Crate"
	cost = 150
	contains_special = list(
		"Nian citterpillar"
	)
	containertype = /obj/structure/closet/critter/nian_caterpillar
	contains = list(/obj/item/petcollar)
	containername = "nian caterpillar crate"

/datum/supply_packs/organic/deer
	name = "Deer Crate"
	cost = 350 //Deer are best.
	contains_special = list(
		"Deer"
	)
	containertype = /obj/structure/closet/critter/deer
	containername = "deer crate"

/datum/supply_packs/organic/bunny
	name = "Bunny Crate"
	cost = 200
	contains_special = list(
		"Bunny"
	)
	containertype = /obj/structure/closet/critter/bunny
	contains = list(/obj/item/petcollar)
	containername = "bunny crate"

/datum/supply_packs/organic/gorilla
	name = "Gorilla Crate"
	cost = 1000
	contains_special = list(
		"Gorilla"
	)
	containertype = /obj/structure/closet/critter/gorilla
	containername = "gorilla crate"
	department_restrictions = list(DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/gorilla/cargo
	name = "Cargorilla Crate"
	cost = 250
	contains_special = list(
		"Cargorilla"
	)
	containertype = /obj/structure/closet/critter/gorilla/cargo
	containername = "cargorilla crate"
	department_restrictions = list(DEPARTMENT_SUPPLY)

////// hippy gear

/// -- Skie
/datum/supply_packs/organic/hydroponics
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 200
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/hydroponics/hydrotank
	name = "Hydroponics Watertank Crate"
	contains = list(/obj/item/watertank)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "hydroponics watertank crate"
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/hydroponics/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/seeds/tower,
					/obj/item/seeds/chili,
					/obj/item/seeds/cotton,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/lettuce,
					/obj/item/seeds/onion,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane)
	cost = 100
	containername = "seeds crate"

/datum/supply_packs/organic/vending/hydro_refills
	name = "Hydroponics Vending Machines Refills"
	cost = 50
	containertype = /obj/structure/closet/crate
	contains = list(/obj/item/vending_refill/hydroseeds,
					/obj/item/vending_refill/hydronutrients)
	containername = "hydroponics supply crate"

/datum/supply_packs/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/banana,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	containername = "exotic seeds crate"

/datum/supply_packs/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/melee/flyswatter)
	cost = 150
	containername = "beekeeping starter kit"

/datum/supply_packs/organic/hydroponics/beekeeping_suits
	name = "Beekeeper Suits"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 150
	containername = "beekeeper suits"

/datum/supply_packs/organic/bottler
	name = "Bottler Unit Crate"
	contains = list(/obj/machinery/bottler)
	cost = 150
	containertype = /obj/structure/largecrate
	containername = "Bottler Unit Crate"
	

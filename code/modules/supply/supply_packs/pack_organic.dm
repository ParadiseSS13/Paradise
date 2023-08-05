/datum/supply_packs/organic
	name = "HEADER"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer
	department_restrictions = list(DEPARTMENT_SERVICE)


/datum/supply_packs/organic/food
	name = "Food Crate"
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/kitchen/rollingpin,
					/obj/item/storage/fancy/egg_box,
					/obj/item/mixing_bowl,
					/obj/item/mixing_bowl,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/monkey,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana)
	cost = 250
	containername = "food crate"
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_packs/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/pepperoni,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/hawaiian)
	cost = 500
	containername = "Pizza crate"

/datum/supply_packs/misc/randomised/ingredients // its a bit hacky...
	num_contained = 25
	contains = list(/obj/item/reagent_containers/food/snacks/grown/wheat,
					/obj/item/reagent_containers/food/snacks/grown/tomato,
					/obj/item/reagent_containers/food/snacks/grown/potato,
					/obj/item/reagent_containers/food/snacks/grown/carrot,
					/obj/item/reagent_containers/food/snacks/grown/pumpkin,
					/obj/item/reagent_containers/food/snacks/grown/chili,
					/obj/item/reagent_containers/food/snacks/grown/cocoapod,
					/obj/item/reagent_containers/food/snacks/grown/corn,
					/obj/item/reagent_containers/food/snacks/grown/eggplant,
					/obj/item/reagent_containers/food/snacks/grown/apple,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/cherries)
	name = "Ingredient Crate"
	cost = 300
	containername = "ingredient crate"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 200
	containername = "monkey crate"
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
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/grenade/confetti,
					/obj/item/grenade/confetti)
	cost = 250
	containername = "party equipment"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/organic/bar
	name = "Bar Starter Kit"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/circuitboard/chem_dispenser/soda,
					/obj/item/circuitboard/chem_dispenser/beer)
	cost = 250
	containername = "beer starter kit"
	announce_beacons = list("Bar" = list("Bar"))

//////// livestock
/datum/supply_packs/organic/cow
	name = "Cow Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/cow
	containername = "cow crate"

/datum/supply_packs/organic/pig
	name = "Pig Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/pig
	containername = "pig crate"

/datum/supply_packs/organic/goat
	name = "Goat Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/goat
	containername = "goat crate"

/datum/supply_packs/organic/chicken
	name = "Chicken Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/chick
	containername = "chicken crate"

/datum/supply_packs/organic/turkey
	name = "Turkey Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/turkey
	containername = "turkey crate"

/datum/supply_packs/organic/corgi
	name = "Corgi Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/corgi
	contains = list(/obj/item/petcollar)
	containername = "corgi crate"

/datum/supply_packs/organic/cat
	name = "Cat Crate"
	cost = 300 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/critter/cat
	contains = list(/obj/item/petcollar,
					/obj/item/toy/cattoy)
	containername = "cat crate"

/datum/supply_packs/organic/pug
	name = "Pug Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/pug
	contains = list(/obj/item/petcollar)
	containername = "pug crate"

/datum/supply_packs/organic/fox
	name = "Fox Crate"
	cost = 300 //Foxes are cool.
	containertype = /obj/structure/closet/critter/fox
	contains = list(/obj/item/petcollar)
	containername = "fox crate"

/datum/supply_packs/organic/butterfly
	name = "Butterfly Crate"
	cost = 300
	containertype = /obj/structure/closet/critter/butterfly
	containername = "butterfly crate"

/datum/supply_packs/organic/deer
	name = "Deer Crate"
	cost = 350 //Deer are best.
	containertype = /obj/structure/closet/critter/deer
	containername = "deer crate"

/datum/supply_packs/organic/bunny
	name = "Bunny Crate"
	cost = 200
	containertype = /obj/structure/closet/critter/bunny
	contains = list(/obj/item/petcollar)
	containername = "bunny crate"

/datum/supply_packs/organic/gorilla
	name = "Gorilla Crate"
	cost = 1000
	containertype = /obj/structure/closet/critter/gorilla
	containername = "gorilla crate"
	department_restrictions = list(DEPARTMENT_SCIENCE)

/datum/supply_packs/organic/gorilla/cargo
	name = "Cargorilla Crate"
	cost = 250
	containertype = /obj/structure/closet/critter/gorilla/cargo
	containername = "cargorilla crate"
	department_restrictions = list(DEPARTMENT_SUPPLY)

////// hippy gear

/datum/supply_packs/organic/hydroponics // -- Skie
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
	contains = list(/obj/item/seeds/chili,
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
	cost = 200
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

/datum/supply_packs/vending
	name = "HEADER"
	group = SUPPLY_VEND
	cost = 50

/datum/supply_packs/vending/autodrobe
	name = "Autodrobe Supply Crate"
	contains = list(/obj/item/vending_refill/autodrobe)
	containername = "autodrobe supply crate"

/datum/supply_packs/vending/clothes
	name = "ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing)
	containername = "clothesmate supply crate"

/datum/supply_packs/vending/suit
	name = "Suitlord Supply Crate"
	contains = list(/obj/item/vending_refill/suitdispenser)
	containername = "suitlord supply crate"

/datum/supply_packs/vending/hat
	name = "Hatlord Supply Crate"
	contains = list(/obj/item/vending_refill/hatdispenser)
	containername = "hatlord supply crate"

/datum/supply_packs/vending/shoes
	name = "Shoelord Supply Crate"
	contains = list(/obj/item/vending_refill/shoedispenser)
	containername = "shoelord supply crate"

/datum/supply_packs/vending/pets
	name = "Pet Supply Crate"
	contains = list(/obj/item/vending_refill/crittercare)
	containername = "pet supply crate"

/datum/supply_packs/vending/bartending
	name = "Booze-o-mat and Coffee Supply Crate"
	contains = list(/obj/item/vending_refill/boozeomat,
					/obj/item/vending_refill/coffee)
	containername = "bartending supply crate"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/vending/cigarette
	name = "Cigarette Supply Crate"
	contains = list(/obj/item/vending_refill/cigarette)
	containername = "cigarette supply crate"

/datum/supply_packs/vending/dinnerware
	name = "Dinnerware Supply Crate"
	contains = list(/obj/item/vending_refill/dinnerware)
	containername = "dinnerware supply crate"

/datum/supply_packs/vending/imported
	name = "Imported Vending Machines"
	cost = 500
	contains = list(/obj/item/vending_refill/sustenance,
					/obj/item/vending_refill/robotics,
					/obj/item/vending_refill/sovietsoda,
					/obj/item/vending_refill/engineering)
	containername = "unlabeled supply crate"

/datum/supply_packs/vending/ptech
	name = "PTech Supply Crate"
	contains = list(/obj/item/vending_refill/cart)
	containername = "ptech supply crate"

/datum/supply_packs/vending/snack
	name = "Snack Supply Crate"
	contains = list(/obj/item/vending_refill/snack)
	containername = "snacks supply crate"

/datum/supply_packs/vending/cola
	name = "Softdrinks Supply Crate"
	contains = list(/obj/item/vending_refill/cola)
	containername = "softdrinks supply crate"

/datum/supply_packs/vending/vendomat
	name = "Vendomat Supply Crate"
	contains = list(/obj/item/vending_refill/assist)
	containername = "vendomat supply crate"

/datum/supply_packs/vending/chinese
	name = "Chinese Supply Crate"
	contains = list(/obj/item/vending_refill/chinese)
	containername = "chinese supply crate"

/datum/supply_packs/vending/trainer
	name = "TrainDrobe Supply Crate"
	contains = list(/obj/item/vending_refill/traindrobe)
	containername = "traindrobe supply crate"

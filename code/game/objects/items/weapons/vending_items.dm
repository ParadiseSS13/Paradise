/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	desc = "A vending machine restock cart."
	usesound = 'sound/items/deconstruct.ogg'
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)

	// Built automatically from the corresponding vending machine.
	// If null, considered to be full. Otherwise, is list(/typepath = amount).
	var/list/products
	var/list/contraband
	var/list/premium

/obj/item/vending_refill/Initialize(mapload)
	. = ..()
	name = "\improper [machine_name] restocking unit"

/obj/item/vending_refill/examine(mob/user)
	. = ..()
	var/num = get_part_rating()
	if (num == INFINITY)
		. += "It's sealed tight, completely full of supplies."
	else if (num == 0)
		. += "It's empty!"
	else
		. += "It can restock [num] item\s."

/obj/item/vending_refill/get_part_rating()
	if (!products || !contraband || !premium)
		return INFINITY
	. = 0
	for(var/key in products)
		. += products[key]
	for(var/key in contraband)
		. += contraband[key]
	for(var/key in premium)
		. += premium[key]

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"

/obj/item/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/item/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"

/obj/item/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"

/obj/item/vending_refill/hatdispenser
	machine_name = "hat"
	icon_state = "refill_costume"

/obj/item/vending_refill/suitdispenser
	machine_name = "suit"
	icon_state = "refill_costume"

/obj/item/vending_refill/shoedispenser
	machine_name = "shoe"
	icon_state = "refill_costume"

/obj/item/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"

/obj/item/vending_refill/crittercare
	machine_name = "CritterCare"
	icon_state = "refill_pet"

/obj/item/vending_refill/chinese
	machine_name = "MrChangs"

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"

/obj/item/vending_refill/assist
	machine_name = "Vendomat"
	icon_state = "refill_engi"

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

/obj/item/vending_refill/dinnerware
	machine_name = "Plasteel Chef's Dinnerware Vendor"
	icon_state = "refill_smoke"

/obj/item/vending_refill/engineering
	machine_name = "Robco Tool Maker"
	icon_state = "refill_engi"

/obj/item/vending_refill/engivend
	machine_name = "Engi-Vend"
	icon_state = "refill_engi"

/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/item/vending_refill/modularpc
	machine_name = "Deluxe Silicate Selections"
	icon_state = "refill_engi"

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"

/obj/item/vending_refill/security
	icon_state = "refill_sec"

/obj/item/vending_refill/sovietsoda
	machine_name = "BODA"
	icon_state = "refill_cola"

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"
	icon_state = "refill_snack"

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"

/obj/item/vending_refill/robotics
	machine_name = "Robotech Deluxe"
	icon_state = "refill_engi"

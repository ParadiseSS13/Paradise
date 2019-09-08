/*
	Vending machine refills can be found at /code/modules/vending/ within each vending machine's respective file
*/
/obj/item/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	desc = "A vending machine restock cart."
	flags = CONDUCT
	force = 7
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY

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
		to_chat(user, "It's sealed tight, completely full of supplies.")
	else if (num == 0)
		to_chat(user, "It's empty!")
	else
		to_chat(user, "It can restock [num] item\s.")

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
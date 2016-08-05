/obj/item/weapon/vending_refill
	name = "resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_snack"
	item_state = "restock_unit"
	flags = CONDUCT
	force = 7.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4

	var/charges = 0		//how many restocking "charges" the refill has

/obj/item/weapon/vending_refill/New(amt = -1)
	..()
	name = "\improper [machine_name] restocking unit"
	if(isnum(amt) && amt > -1)
		charges = amt

/obj/item/weapon/vending_refill/examine(mob/user)
	..(user)
	if(charges)
		to_chat(user, "It can restock [charges] item(s).")
	else
		to_chat(user, "It's empty!")

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = 46//of 138

/obj/item/weapon/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"
	charges = 28//of 85

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	charges = 16//of 48

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	charges = 21//of 65

/obj/item/weapon/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"
	charges = 9// of 30

/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = 19// of 58

/obj/item/weapon/vending_refill/hatdispenser
	machine_name = "hat"
	icon_state = "refill_costume"
	charges = 18// of 56

/obj/item/weapon/vending_refill/suitdispenser
	machine_name = "suit"
	icon_state = "refill_costume"
	charges = 68// of 206

/obj/item/weapon/vending_refill/shoedispenser
	machine_name = "shoe"
	icon_state = "refill_costume"
	charges = 30// of 91

/obj/item/weapon/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
	charges = 20// of 62

/obj/item/weapon/vending_refill/crittercare
	machine_name = "CritterCare"
	icon_state = "refill_pet"
	charges = 31// of 94

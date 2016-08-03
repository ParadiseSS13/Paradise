/obj/structure/closet/secure_closet/freezer

/obj/structure/closet/secure_closet/freezer/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
			if(welded)
				overlays += "welded"
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/freezer/ex_act(var/severity)
	// IF INDIANA JONES CAN DO IT SO CAN YOU

	// Bomb in here? (using same search as space transits searching for nuke disk)
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs)) // You're fucked.
		..(severity)

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(access_kitchen)

	New()
		..()
		for(var/i in 1 to 3)
			new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
		new /obj/item/weapon/reagent_containers/food/condiment/rice(src)
		new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)



/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()



/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		for(var/i in 1 to 4)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)



/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		for(var/i in 1 to 5)
			new /obj/item/weapon/reagent_containers/food/condiment/milk(src)
			new /obj/item/weapon/reagent_containers/food/condiment/soymilk(src)
		for(var/i in 1 to 2)
			new /obj/item/weapon/storage/fancy/egg_box(src)



/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)


	New()
		..()
		dispense_cash(6700, src)









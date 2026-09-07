/obj/structure/closet/secure_closet/freezer
	desc = "It's a card-locked refrigerative storage unit. This one is lead-lined."
	door_anim_squish = 0.22
	door_anim_angle = 123
	door_anim_time = 2.50

/obj/structure/closet/secure_closet/freezer/ex_act(severity)
	// IF INDIANA JONES CAN DO IT SO CAN YOU

	// Bomb in here? (using same search as space transits searching for nuke disk)
	var/list/bombs = search_contents_for(/obj/item/transfer_valve)
	if(!isemptylist(bombs)) // You're fucked.
		..(severity)

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	desc = "It's a card-locked cabinet for storing dry ingredients. It looks robust enough to withstand most explosions."
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/kitchen/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/condiment/flour(src)
	new /obj/item/reagent_containers/condiment/rice(src)
	new /obj/item/reagent_containers/condiment/sugar(src)


/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/populate_contents()
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	icon_state = "freezer"

/obj/structure/closet/secure_closet/freezer/meat/populate_contents()
	for(var/i in 1 to 4)
		new /obj/item/food/meat/monkey(src)

/obj/structure/closet/secure_closet/freezer/meat/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	icon_state = "freezer"

/obj/structure/closet/secure_closet/freezer/fridge/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/fridge/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/fridge/mixed/populate_contents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)
	for(var/i in 1 to 4)
		new /obj/item/food/meat/monkey(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	icon_state = "freezer"
	req_access = list(ACCESS_HEADS_VAULT)

/obj/structure/closet/secure_closet/freezer/money/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/stack/spacecash/c200(src)
	for(var/i in 1 to 5)
		new /obj/item/stack/spacecash/c100(src)
	for(var/i in 1 to 6)
		new /obj/item/stack/spacecash/c50(src)

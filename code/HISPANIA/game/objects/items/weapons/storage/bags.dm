// -----------------------------
//          Gadget Bag
// -----------------------------

/obj/item/storage/bag/gadgets
	icon = 'icons/hispania/obj/storage/storage.dmi'
	icon_state = "gadget_bag"
	slot_flags = SLOT_BELT
	name = "gadget bag"
	desc = "This bag can be used to store many machine components."
	storage_slots = 25
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list("/obj/item/stock_parts", "/obj/item/reagent_containers/glass/beaker")
	display_contents_with_number = TRUE

/obj/item/storage/bag/gadgets/mass_remove(atom/A)
	var/lowest_rating = INFINITY //Get the lowest rating, so only mass drop the lowest parts.
	for(var/obj/item/B in contents)
		if(B.get_rating() < lowest_rating)
			lowest_rating = B.get_rating()

	for(var/obj/item/B in contents) //Now that we have the lowest rating we can dump only parts at the lowest rating.
		if(B.get_rating() > lowest_rating)
			continue
		remove_from_storage(B, A)

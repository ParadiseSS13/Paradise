/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets
	w_class = WEIGHT_CLASS_NORMAL //we don't want these to be able to fit in their own pockets.

/obj/item/clothing/suit/storage/Initialize(mapload)
	. = ..()
	pockets = new/obj/item/storage/internal(src)
	pockets.storage_slots = 2	//two slots
	pockets.max_w_class = WEIGHT_CLASS_SMALL		//fit only pocket sized items
	pockets.max_combined_w_class = 4
	ADD_TRAIT(src, TRAIT_ADJACENCY_TRANSPARENT, ROUNDSTART_TRAIT)

/obj/item/clothing/suit/storage/Destroy()
	QDEL_NULL(pockets)
	return ..()

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	if(pockets?.handle_attack_hand(user))
		..(user)

/obj/item/clothing/suit/storage/MouseDrop(obj/over_object as obj)
	if(pockets?.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/suit/storage/equipped(mob/user, slot)
	..()
	pockets?.update_viewers()

/obj/item/clothing/suit/storage/Moved(atom/oldloc, dir, forced = FALSE)
	. = ..()
	pockets?.update_viewers()

/obj/item/clothing/suit/storage/AltClick(mob/user)
	..()
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE))
		pockets?.open(user)
		add_fingerprint(user)
		return
	if(isobserver(user))
		pockets?.show_to(user)

/obj/item/clothing/suit/storage/attack_ghost(mob/user)
	if(isobserver(user))
		// Revenants don't get to play with the toys.
		pockets.show_to(user)
	return ..()

/obj/item/clothing/suit/storage/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	// Inserts shouldn't be added into the inventory of the pockets if they're attaching.
	if(istype(W, /obj/item/smithed_item/insert) && length(inserts) != insert_max)
		return ..()
	..()
	return pockets?.attackby__legacy__attackchain(W, user, params)

/obj/item/clothing/suit/storage/emp_act(severity)
	..()
	pockets?.emp_act(severity)

/obj/item/clothing/suit/storage/hear_talk(mob/M, list/message_pieces)
	pockets?.hear_talk(M, message_pieces)
	..()

/obj/item/clothing/suit/storage/hear_message(mob/M, msg)
	pockets?.hear_message(M, msg)
	..()

/obj/item/clothing/suit/storage/proc/return_inv()

	var/list/L = list()


	for(var/obj/item/I in src.contents)
		if(!istype(I, /obj/item/smithed_item/insert)) // We don't want people to pull inserts out without calling the proper signals, so they shouldn't be displayed in storage.
			L += I
	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(isstorage(G.gift))
			L += G.gift:return_inv()
	return L

/obj/item/clothing/suit/storage/serialize()
	var/list/data = ..()
	data["pockets"] = pockets?.serialize()
	return data

/obj/item/clothing/suit/storage/deserialize(list/data)
	qdel(pockets)
	pockets = list_to_object(data["pockets"], src)

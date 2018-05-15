/obj/item/storage/hidden/implant
	name = "bluespace pocket"
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = WEIGHT_CLASS_GIGANTIC
	w_class = WEIGHT_CLASS_BULKY
	cant_hold = list(/obj/item/disk/nuclear)
	silent = 1


/obj/item/implant/storage
	name = "storage implant"
	desc = "Stores up to two big items in a bluespace pocket."
	icon_state = "storage"
	origin_tech = "materials=2;magnets=4;bluespace=5;syndicate=4"
	item_color = "r"
	var/obj/item/storage/hidden/implant/storage

/obj/item/implant/storage/New()
	..()
	storage = new /obj/item/storage/hidden/implant(src)

/obj/item/implant/storage/activate()
	storage.MouseDrop(imp_in)

/obj/item/implant/storage/removed(source)
	if(..())
		for(var/mob/M in range(1))
			if(M.s_active == storage)
				storage.close(M)
		for(var/obj/item/I in storage)
			storage.remove_from_storage(I, get_turf(source))
		return 1

/obj/item/implant/storage/implant(mob/source)
	var/obj/item/implant/storage/imp_e = locate(src.type) in source
	if(imp_e)
		imp_e.storage.storage_slots += storage.storage_slots
		imp_e.storage.max_combined_w_class += storage.max_combined_w_class
		imp_e.storage.contents += storage.contents

		for(var/mob/M in range(1))
			if(M.s_active == storage)
				storage.close(M)
		storage.show_to(source)

		qdel(src)
		return 1

	return ..()

/obj/item/implant/storage/proc/get_contents() //Used for swiftly returning a list of the implant's contents i.e. for checking a theft objective's completion.
	if(storage && storage.contents)
		return storage.contents

/obj/item/implanter/storage
	name = "implanter (storage)"

/obj/item/implanter/storage/New()
	imp = new /obj/item/implant/storage(src)
	..()

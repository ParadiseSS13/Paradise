/obj/item/storage/proc/mass_remove(var/atom/A)
	for(var/obj/item/O in contents)
		remove_from_storage(O, A)

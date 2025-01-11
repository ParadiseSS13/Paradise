/obj/machinery/smartfridge/load(obj/I, mob/user)
	var/item_loc_origin = I.loc
	if(!..())
		return FALSE

	if(istype(item_loc_origin, /obj/item/gripper))
		var/obj/item/gripper/gripper = item_loc_origin
		gripper.drop_gripped_item(silent = TRUE)
		I.forceMove(src)
	return TRUE

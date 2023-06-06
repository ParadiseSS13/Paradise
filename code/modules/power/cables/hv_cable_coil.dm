///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////


/obj/item/stack/cable_coil/high_voltage
	name = "high-voltage cable coil"
	icon_state = "hv_coil"
	item_state = "coil_red"
	merge_type = /obj/item/stack/cable_coil/high_voltage // This is here to let its children merge between themselves
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = 0
	toolspeed = 1

	cable_structure_type = /obj/structure/cable/high_voltage

/obj/item/stack/cable_coil/high_voltage/update_name()
	. = ..()
	if(amount > 2)
		name = "high-voltage cable coil"
	else
		name = "high-voltage cable coil piece"

/obj/item/stack/cable_coil/high_voltage/update_wclass()
	if(amount == 1)
		w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_BULKY

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/high_voltage/can_place(turf/T, mob/user, cable_direction)
	. = ..()
	if(!.)
		return FALSE
	return do_after_once(user, 0.5 SECONDS, target = T, attempt_cancel_message = "You stop laying the high voltage cable.")

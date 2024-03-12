/obj/obj_destruction(damage_flag)
	SEND_SIGNAL(src, COMSIG_OBJ_DESTRUCTION, damage_flag)
	. = ..()

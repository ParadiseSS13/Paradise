/obj/item/melee/saber
	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	icon = 'modular_ss220/objects/icons/melee.dmi'
	icon_state = "saber_classic"
	item_state = null

/obj/item/melee/saber/proc/reskin(new_skin)
	icon_state = "saber_[new_skin]"
	update_icon()

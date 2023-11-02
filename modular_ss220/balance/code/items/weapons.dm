/obj/item/melee/baton/cattleprod
	w_class = WEIGHT_CLASS_NORMAL
/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	if(sawn_state == SAWN_OFF)
		can_holster = TRUE
		w_class = WEAPON_MEDIUM

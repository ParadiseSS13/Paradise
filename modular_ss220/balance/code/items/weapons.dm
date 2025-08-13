/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	if(sawn_state == SAWN_OFF)
		can_holster = TRUE
		w_class = WEAPON_MEDIUM

// MARK: Energy
/obj/item/gun/energy/gun
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/immolator
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/gun/hos
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/gun/blueshield
	w_class = WEIGHT_CLASS_NORMAL

// MARK: Laser
/obj/item/gun/energy/laser
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/xray
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/laser/captain
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/laser/tag
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/laser/practice
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/laser/awaymission_aeg/rnd
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/melee/energy
	var/sharpening_allowed = FALSE

/obj/item/melee/energy/try_sharpen(obj/item/item, amount, max_amount)
	if(!sharpening_allowed)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	return ..()

/obj/item/melee/energy/cleaving_saw
	sharpening_allowed = TRUE

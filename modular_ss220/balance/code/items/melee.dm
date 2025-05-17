/obj/item/melee/energy
	var/sharpening_allowed = FALSE

/obj/item/melee/energy/try_sharpen(obj/item/item, amount, max_amount)
	if(!sharpening_allowed)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	return ..()

/obj/item/melee/energy/cleaving_saw
	sharpening_allowed = TRUE

/obj/item/melee/classic_baton/on_non_silicon_stun(mob/living/target, mob/living/user)
	target.apply_damage(stamina_damage, STAMINA, blocked = target.run_armor_check(attack_flag = ENERGY))

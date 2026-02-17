/obj/item/clothing/neck/towel/beach
	name = "\improper beach towel"
	desc = "A fluffy towel large enough for beachgoers."
	icon_state = "towel_palm"
	inhand_icon_state = "beach_towel"
	worn_icon_state = "towel_palm"
	new_attack_chain = TRUE

/obj/item/clothing/neck/towel/beach/Moved()
	. = ..()
	update_icon_state()

/obj/item/clothing/neck/towel/beach/update_icon_state()
	. = ..()
	icon_state = isturf(loc) ? initial(icon_state) : "[initial(icon_state)]_roll"

/obj/item/clothing/neck/towel/beach/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			user.drop_item_to_ground(src)
			forceMove(T)
		return ITEM_INTERACT_COMPLETE
	if(iscarbon(target))
		var/mob/living/carbon/drying_target = target
		if(drying_target.wetlevel == 0)
			to_chat(user, SPAN_NOTICE("[target] already seems dry!"))
		else
			to_chat(user, SPAN_NOTICE("You dry off [target] with [src]."))
			to_chat(target, SPAN_NOTICE("[user] dries you off with [src]."))
			drying_target.wetlevel = max(drying_target.wetlevel - 2, 0)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/clothing/neck/towel/beach/lava_waves
	icon_state = "towel_lavawaves"
	worn_icon_state = "towel_lavawaves"

/obj/item/clothing/neck/towel/beach/water_waves
	icon_state = "towel_waterwaves"
	worn_icon_state = "towel_waterwaves"

/obj/item/clothing/neck/towel/beach/striped_green
	icon_state = "towel_striped_green"
	worn_icon_state = "towel_striped_green"

/obj/item/clothing/neck/towel/beach/striped_red
	icon_state = "towel_striped_red"
	worn_icon_state = "towel_striped_red"

/obj/item/clothing/neck/towel/beach/striped_blue
	icon_state = "towel_striped_blue"
	worn_icon_state = "towel_striped_blue"

/obj/item/clothing/neck/towel/beach/ian
	icon_state = "towel_ian"
	worn_icon_state = "towel_ian"

/obj/item/clothing/neck/towel/beach/dolphin
	icon_state = "towel_dolphin"
	worn_icon_state = "towel_dolphin"

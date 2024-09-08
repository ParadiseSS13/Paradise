/obj/item/toy/plushie/macvulpix
	name = "Business Red Fox"
	desc = "Мягкая и приятная на ощупь игрушка важного рыжего лиса в пальто."
	icon = 'modular_ss220/objects/icons/plushies.dmi'
	icon_state = "macvulpix"
	item_state = "macvulpix"
	lefthand_file = 'modular_ss220/objects/icons/inhands/plushies_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/plushies_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// Static list of allowed glasses
	var/static/list/allowed_glasses = typesof(/obj/item/clothing/glasses/sunglasses) + typesof(/obj/item/clothing/glasses/sunglasses_fake)
	/// Equiped glasses on plushie
	var/obj/item/clothing/glasses/glasses

/obj/item/toy/plushie/macvulpix/Destroy()
	. = ..()
	QDEL_NULL(glasses)
	return ..()

/obj/item/toy/plushie/macvulpix/update_icon_state()
	if(glasses)
		icon_state = "[initial(icon_state)]_glasses"
		item_state = "[initial(item_state)]_glasses"
	else
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/toy/plushie/macvulpix/attackby(obj/item/clothing/glasses/sunglasses, mob/living/user, params)
	. = ..()
	if(is_type_in_list(sunglasses, allowed_glasses))
		user.drop_item()
		sunglasses.forceMove(src)
		glasses = sunglasses
		desc = "Мягкая и приятная на ощупь игрушка важного рыжего лиса в пальто и солнечных очках! Oh yeah!"
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/item/toy/plushie/macvulpix/AltClick(mob/user)
	if(!glasses)
		return

	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained())
		to_chat(user, span_warning("У вас нет возможности снять очки с [src]!"))
		return

	if(!user.get_active_hand() && Adjacent(user))
		user.put_in_hands(glasses)
	else
		glasses.forceMove(get_turf(user))

	glasses = null
	desc = initial(desc)
	update_icon(UPDATE_ICON_STATE)

/obj/item/toy/plushie/macvulpix/examine(mob/user)
	. = ..()
	if(glasses)
		. += span_notice("Нажмите <b>Alt-Click</b> на игрушку, чтобы снять очки.")
	else
		. += span_notice("На эту игрушку можно надеть солнцезащитные очки.")

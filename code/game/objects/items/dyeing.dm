/**
 * Updates an item's appearance to mimic the appearance of another item in the dye_registry's dictionary
 * what types of items (beanie, jumpsuit, shoes, etc) src is dyed into depends on the dye_key unless an
 * overidden dye_key is specified. For example if our dye_key is DYE_REGISTRY_UNDER and we specify to dye to
 * DYE_RED, our item's appearance would then mimic /obj/item/clothing/under/color/red; see [code/_globalvars/lists/dye_registry.dm] for this dictionary
 *
 * once everything is updated, the target type path that we dyed the item into is returned
 *
 * Arguments:
 * - dye_color: the DYE_COLOR specifies which dye color we look up to copy apearances from in the dye_registry; cannot be null
 * - dye_key_override: this overrides the items `dyeing_key` which allows you to force the proc to use a specific lookup key for the dye_registry; this can be null
 */
/obj/item/proc/dye_item(dye_color, dye_key_override)
	if(!dyeable || !dye_color)
		return
	var/dye_key_selector = dye_key_override ? dye_key_override : dyeing_key
	if(!dye_key_selector)
		return FALSE
	if(!GLOB.dye_registry[dye_key_selector])
		stack_trace("Item just tried to be dyed with an invalid registry key: [dye_key_selector]")
		return FALSE
	var/obj/item/target_type = GLOB.dye_registry[dye_key_selector][dye_color]
	if(!target_type)
		return FALSE
	var/obj/item/target_obj = new target_type
	// update icons
	icon = initial(target_obj.icon)
	icon_state = initial(target_obj.icon_state)
	worn_icon = initial(target_obj.worn_icon)
	worn_icon_state = initial(target_obj.worn_icon_state)
	inhand_icon_state = initial(target_obj.inhand_icon_state)
	sprite_sheets = target_obj.sprite_sheets
	desc = target_obj.desc
	base_icon_state = target_obj.base_icon_state

	// update inhand sprites
	lefthand_file = initial(target_obj.lefthand_file)
	righthand_file = initial(target_obj.righthand_file)
	inhand_x_dimension = initial(target_obj.inhand_x_dimension)
	inhand_y_dimension = initial(target_obj.inhand_y_dimension)

	// update the name/description
	name = initial(target_obj.name)
	desc += "\nThe colors look a little dodgy."
	qdel(target_obj)
	update_appearance(ALL)
	return target_type

/// Beanies use the color var for their appearance, we don't normally copy this over but we have to for beanies
/obj/item/clothing/head/beanie/dye_item(dye_color, dye_key_override)
	. = ..()
	if(.)
		var/obj/item/target_type = .
		color = initial(target_type.color)

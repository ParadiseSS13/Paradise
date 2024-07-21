
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
	// update icons
	icon = initial(target_type.icon)
	icon_state = initial(target_type.icon_state)
	item_state = initial(target_type.item_state)
	sprite_sheets = initial(target_type.sprite_sheets)

	// update inhand sprites
	lefthand_file = initial(target_type.lefthand_file)
	righthand_file = initial(target_type.righthand_file)
	inhand_x_dimension = initial(target_type.inhand_x_dimension)
	inhand_y_dimension = initial(target_type.inhand_y_dimension)

	// update the name/description
	name = initial(target_type.name)
	desc = "[initial(target_type.desc)] The colors look a little dodgy."
	update_appearance(ALL)
	return target_type

/obj/item/clothing/head/beanie/dye_item(dye_color, dye_key_override)
	. = ..()
	if(.)
		var/obj/item/target_type = .
		color = initial(target_type.color)

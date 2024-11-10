/datum/gear_tweak
	/// Displayed in TGUI name
	var/display_type
	/// Font Awesome icon
	var/fa_icon
	/// Explains what is this do in TGUI tooltip
	var/info

/datum/gear_tweak/proc/get_metadata(user, metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/tweak_gear_data(metadata, datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(obj/item/gear, metadata)
	return

// MARK: Color
/datum/gear_tweak/color
	display_type = "Color"
	fa_icon = "palette"
	info = "Recolorable"
	var/list/valid_colors

/datum/gear_tweak/color/New(list/colors)
	valid_colors = colors
	..()

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_GRAY

/datum/gear_tweak/color/get_metadata(user, metadata)
	if(valid_colors)
		return tgui_input_list(user, "Choose an item color.", "Recolor Gear", valid_colors, metadata)
	return tgui_input_color(user, "Choose an item color.", "Global Preference", metadata)

/datum/gear_tweak/color/tweak_item(obj/item/gear, metadata)
	if((valid_colors && !(metadata in valid_colors)) || !metadata)
		return

	gear.color = metadata

// MARK: Rename
/datum/gear_tweak/rename
	display_type = "Name"
	fa_icon = "edit"
	info = "Renameable"

/datum/gear_tweak/rename/get_default()
	return ""

/datum/gear_tweak/rename/get_metadata(user, metadata)
	var/new_name = tgui_input_text(user, "Rename an object. Enter empty line for stock name", "Rename Gear", metadata, MAX_NAME_LEN)
	if(isnull(new_name))
		return metadata
	return new_name

/datum/gear_tweak/rename/tweak_item(obj/item/gear, metadata)
	if(!metadata)
		return

	gear.name = metadata

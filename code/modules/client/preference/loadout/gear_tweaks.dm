/datum/gear_tweak
	var/display_type

/datum/gear_tweak/proc/get_metadata(user, metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/tweak_gear_data(metadata, datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(obj/item/I, metadata)
	return

/*
* Color adjustment
*/

/datum/gear_tweak/color
	display_type = "color"
	var/list/valid_colors

/datum/gear_tweak/color/New(list/colors)
	valid_colors = colors
	..()

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_GRAY

/datum/gear_tweak/color/get_metadata(user, metadata)
	if(valid_colors)
		return tgui_input_list(user, "Choose an item color.", "Character Preference", valid_colors, metadata)
	return input(user, "Choose an item color.", "Global Preference", metadata) as color|null

/datum/gear_tweak/color/tweak_item(obj/item/I, metadata)
	if((valid_colors && !(metadata in valid_colors)) || !metadata)
		return
	I.color = metadata

/*
* Rename
*/

/datum/gear_tweak/rename
	display_type = "edit"

/datum/gear_tweak/rename/get_default()
	return ""

/datum/gear_tweak/rename/get_metadata(user, metadata)
	var/new_name = tgui_input_text(user, "Rename an object. Enter empty line for stock name", "Global Preference", metadata, 20)
	if(isnull(new_name))
		return metadata
	return new_name

/datum/gear_tweak/rename/tweak_item(obj/item/I, metadata)
	if(!metadata)
		return
	I.name = metadata

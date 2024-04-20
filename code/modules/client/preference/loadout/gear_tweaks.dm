/datum/gear_tweak/proc/get_contents(metadata)
	return

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
	var/list/valid_colors

/datum/gear_tweak/color/New(list/colors)
	valid_colors = colors
	..()

/datum/gear_tweak/color/get_contents(metadata)
	return "Color: <font color='[metadata]'>&#9899;</font>"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_GRAY

/datum/gear_tweak/color/get_metadata(user, metadata)
	if(valid_colors)
		return input(user, "Choose an item color.", "Character Preference", metadata) as null|anything in valid_colors
	return input(user, "Choose an item color.", "Global Preference", metadata) as color|null

/datum/gear_tweak/color/tweak_item(obj/item/I, metadata)
	if(valid_colors && !(metadata in valid_colors))
		return
	I.color = metadata

/*
* Path adjustment
*/

/datum/gear_tweak/path
	var/list/valid_paths

/datum/gear_tweak/path/New(list/paths)
	valid_paths = paths
	..()

/datum/gear_tweak/path/get_contents(metadata)
	return "Type: [metadata]"

/datum/gear_tweak/path/get_default()
	return valid_paths[1]

/datum/gear_tweak/path/get_metadata(user, metadata)
	return input(user, "Choose a type.", "Character Preference", metadata) as null|anything in valid_paths

/datum/gear_tweak/path/tweak_gear_data(metadata, datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

/*
* Content adjustment
*/

/datum/gear_tweak/contents
	var/list/valid_contents

/datum/gear_tweak/contents/New()
	valid_contents = args.Copy()
	..()

/datum/gear_tweak/contents/get_contents(metadata)
	return "Contents: [english_list(metadata, and_text = ", ")]"

/datum/gear_tweak/contents/get_default()
	. = list()
	for(var/i = 1 to length(valid_contents))
		. += "Random"

/datum/gear_tweak/contents/get_metadata(user, list/metadata)
	. = list()
	for(var/i = length(metadata) to length(valid_contents))
		metadata += "Random"
	for(var/i = 1 to length(valid_contents))
		var/entry = input(user, "Choose an entry.", "Character Preference", metadata[i]) as null|anything in (valid_contents[i] + list("Random", "None"))
		if(entry)
			. += entry
		else
			return metadata

/datum/gear_tweak/contents/tweak_item(obj/item/I, list/metadata)
	if(length(metadata) != length(valid_contents))
		return
	for(var/i = 1 to length(valid_contents))
		var/path
		var/list/contents = valid_contents[i]
		if(metadata[i] == "Random")
			path = pick(contents)
			path = contents[path]
		else if(metadata[i] == "None")
			continue
		else
			path = 	contents[metadata[i]]
		new path(I)

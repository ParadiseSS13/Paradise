/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			hex2num & num2hex
 *			text2list & list2text
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 */

//Returns an integer given a hex input
/proc/hex2num(hex)
	if (!( istext(hex) ))
		return

	var/num = 0
	var/power = 0
	var/i = null
	i = length(hex)
	while(i > 0)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("0")
				//Apparently, switch works with empty statements, yay! If that doesn't work, blame me, though. -- Urist
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				return
		power++
		i--
	return num

//Returns the hex value of a number given a value assumed to be a base-ten value
/proc/num2hex(num, placeholder)

	if (placeholder == null)
		placeholder = 2
	if (!( isnum(num) ))
		return
	if (!( num ))
		return "0"
	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
				hex += text("[]", val)
			if(10.0)
				hex += "A"
			if(11.0)
				hex += "B"
			if(12.0)
				hex += "C"
			if(13.0)
				hex += "D"
			if(14.0)
				hex += "E"
			if(15.0)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = text("0[]", hex)
	return hex


// Concatenates a list of strings into a single string.  A seperator may optionally be provided.
/proc/list2text(list/ls, sep)
	if(ls.len <= 1) return ls.len ? ls[1] : ""
	. = ""
	var/l = ls.len
	var/i = 0

	if(sep)
		#define S1    ls[++i]
		#define S4    S1,  sep, S1,  sep, S1,  sep, S1
		#define S16   S4,  sep, S4,  sep, S4,  sep, S4
		#define S64   S16, sep, S16, sep, S16, sep, S16

		while(l-i >= 128)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, sep, S64)
		if(l-i >= 64)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		if(l-i >= 32)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, sep, S16)
		if(l-i >= 16)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i >= 8)
			. = text("[][][][][][][][][][][][][][][][]", ., S4, sep, S4)
		if(l-i >= 4)
			. = text("[][][][][][][][]", ., S4)
		if(l-i >= 2)
			. = text("[][][][]", ., S1, sep, S1)
		if(l > i)
			. = text("[][][]", ., sep, S1)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		while(l-i >= 128)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)
		if(l-i >= 64)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		if(l-i >= 32)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i >= 16)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i >= 8)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i >= 4)
			. = text("[][][][][]", ., S4)
		if(l-i >= 2)
			. = text("[][][]", ., S1, S1)
		if(l > i)
			. += S1

		#undef S64
		#undef S16
		#undef S4
		#undef S1


//slower then list2text, but correctly processes associative lists.
proc/tg_list2text(list/list, glue=",", assocglue=";")
	if(!istype(list) || !list.len)
		return
	var/output
	for(var/i=1 to list.len)
		if(!isnull(list["[list[i]]"]))
			output += (i!=1? glue : null)+ "[list[i]]"+(i!=1? assocglue : null)+"[list["[list[i]]"]]"
		else
			output += (i!=1? glue : null)+ "[list[i]]"
	return output

proc/tg_text2list(text, glue=",", assocglue=";")
	var/length = length(glue)
	if(length < 1) return list(text)
	. = list()
	var/lastglue_found = 1
	var/foundglue
	var/foundassocglue
	var/searchtext
	do
		foundglue = findtext(text, glue, lastglue_found, 0)
		searchtext = copytext(text, lastglue_found, foundglue)
		foundassocglue = findtext(searchtext, assocglue, 1, 0)
		if(foundassocglue)
			var/sublist = copytext(searchtext, 1, foundassocglue)
			sublist[1] = copytext(searchtext, foundassocglue, 0)
			. += sublist
		else
			. += copytext(text, lastglue_found, foundglue)
		lastglue_found = foundglue + length
	while(foundglue)


//Converts a string into a list by splitting the string at each delimiter found. (discarding the seperator)
/proc/text2list(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtext(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

//Case Sensitive!
/proc/text2listEx(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtextEx(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

//Splits the text of a file at seperator and returns them in a list.
/proc/file2list(filename, seperator="\n")
	return text2list(return_file_text(filename),seperator)


//Turns a direction into text

/proc/num2dir(direction)
	switch(direction)
		if(1.0) return NORTH
		if(2.0) return SOUTH
		if(4.0) return EAST
		if(8.0) return WEST
		else
			world.log << "UNKNOWN DIRECTION: [direction]"

/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

//Turns text into proper directions
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

//Converts an angle (degrees) into an ss13 direction
/proc/angle2dir(var/degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTHEAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTHEAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTHWEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2angle(var/D)
	switch(D)
		if(NORTH)		return 0
		if(SOUTH)		return 180
		if(EAST)		return 90
		if(WEST)		return 270
		if(NORTHEAST)	return 45
		if(SOUTHEAST)	return 135
		if(NORTHWEST)	return 315
		if(SOUTHWEST)	return 225
		else			return null

//Returns the angle in english
/proc/angle2text(var/degree)
	return dir2text(angle2dir(degree))

//Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY) return ICON_MULTIPLY
		if(BLEND_ADD)      return ICON_ADD
		if(BLEND_SUBTRACT) return ICON_SUBTRACT
		else               return ICON_OVERLAY

//Converts a rights bitfield into a string
/proc/rights2text(rights,seperator="")
	if(rights & R_BUILDMODE)	. += "[seperator]+BUILDMODE"
	if(rights & R_ADMIN)		. += "[seperator]+ADMIN"
	if(rights & R_BAN)			. += "[seperator]+BAN"
	if(rights & R_EVENT)		. += "[seperator]+EVENT"
	if(rights & R_SERVER)		. += "[seperator]+SERVER"
	if(rights & R_DEBUG)		. += "[seperator]+DEBUG"
	if(rights & R_POSSESS)		. += "[seperator]+POSSESS"
	if(rights & R_PERMISSIONS)	. += "[seperator]+PERMISSIONS"
	if(rights & R_STEALTH)		. += "[seperator]+STEALTH"
	if(rights & R_REJUVINATE)	. += "[seperator]+REJUVINATE"
	if(rights & R_VAREDIT)		. += "[seperator]+VAREDIT"
	if(rights & R_SOUNDS)		. += "[seperator]+SOUND"
	if(rights & R_SPAWN)		. += "[seperator]+SPAWN"
	if(rights & R_MOD)			. += "[seperator]+MODERATOR"
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("Midnight")  return 'icons/mob/screen1_Midnight.dmi'
		else      return 'icons/mob/screen1_White.dmi'

/proc/num2septext(var/theNum, var/sigFig = 7,var/sep=",") // default sigFig (1,000,000)
	var/finalNum = num2text(theNum, sigFig)

	// Start from the end, or from the decimal point
	var/end = findtextEx(finalNum, ".") || length(finalNum) + 1

	// Moving towards start of string, insert comma every 3 characters
	for(var/pos = end - 3, pos > 1, pos -= 3)
		finalNum = copytext(finalNum, 1, pos) + sep + copytext(finalNum, pos)

	return finalNum

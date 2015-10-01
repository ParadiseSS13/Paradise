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
	if(ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0 // Incremented every time a list index is accessed.

	if(sep != null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1    sep, ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if(l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if(l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if(l-1 & 0x01) // 'i' will always be 1 here.
			. += S1 // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if(l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

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

/proc/text2numlist(text, delimiter="\n")
	var/list/num_list = list()
	for(var/x in text2list(text, delimiter))
		num_list += text2num(x)
	return num_list

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
			log_to_dd("UNKNOWN DIRECTION: [direction]")

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
	if(rights & R_PROCCALL)		. += "[seperator]+PROCCALL"
	if(rights & R_MOD)			. += "[seperator]+MODERATOR"
	if(rights & R_MENTOR)		. += "[seperator]+MENTOR"
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("Midnight")  return 'icons/mob/screen1_Midnight.dmi'
		else      return 'icons/mob/screen1_White.dmi'
		
//colour formats
/proc/rgb2hsl(red, green, blue)
	red /= 255;green /= 255;blue /= 255;
	var/max = max(red,green,blue)
	var/min = min(red,green,blue)
	var/range = max-min

	var/hue=0;var/saturation=0;var/lightness=0;
	lightness = (max + min)/2
	if(range != 0)
		if(lightness < 0.5)	saturation = range/(max+min)
		else				saturation = range/(2-max-min)

		var/dred = ((max-red)/(6*max)) + 0.5
		var/dgreen = ((max-green)/(6*max)) + 0.5
		var/dblue = ((max-blue)/(6*max)) + 0.5

		if(max==red)		hue = dblue - dgreen
		else if(max==green)	hue = dred - dblue + (1/3)
		else				hue = dgreen - dred + (2/3)
		if(hue < 0)			hue++
		else if(hue > 1)	hue--

	return list(hue, saturation, lightness)

/proc/hsl2rgb(hue, saturation, lightness)
	var/red;var/green;var/blue;
	if(saturation == 0)
		red = lightness * 255
		green = red
		blue = red
	else
		var/a;var/b;
		if(lightness < 0.5)	b = lightness*(1+saturation)
		else				b = (lightness+saturation) - (saturation*lightness)
		a = 2*lightness - b

		red = round(255 * hue2rgb(a, b, hue+(1/3)))
		green = round(255 * hue2rgb(a, b, hue))
		blue = round(255 * hue2rgb(a, b, hue-(1/3)))

	return list(red, green, blue)

/proc/hue2rgb(a, b, hue)
	if(hue < 0)			hue++
	else if(hue > 1)	hue--
	if(6*hue < 1)	return (a+(b-a)*6*hue)
	if(2*hue < 1)	return b
	if(3*hue < 2)	return (a+(b-a)*((2/3)-hue)*6)
	return a

/proc/num2septext(var/theNum, var/sigFig = 7,var/sep=",") // default sigFig (1,000,000)
	var/finalNum = num2text(theNum, sigFig)

	// Start from the end, or from the decimal point
	var/end = findtextEx(finalNum, ".") || length(finalNum) + 1

	// Moving towards start of string, insert comma every 3 characters
	for(var/pos = end - 3, pos > 1, pos -= 3)
		finalNum = copytext(finalNum, 1, pos) + sep + copytext(finalNum, pos)

	return finalNum


// heat2color functions. Adapted from: http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
/proc/heat2color(temp)
	return rgb(heat2color_r(temp), heat2color_g(temp), heat2color_b(temp))

/proc/heat2color_r(temp)
	temp /= 100
	if(temp <= 66)
		. = 255
	else
		. = max(0, min(255, 329.698727446 * (temp - 60) ** -0.1332047592))

/proc/heat2color_g(temp)
	temp /= 100
	if(temp <= 66)
		. = max(0, min(255, 99.4708025861 * log(temp) - 161.1195681661))
	else
		. = max(0, min(255, 288.1221695283 * ((temp - 60) ** -0.0755148492)))

/proc/heat2color_b(temp)
	temp /= 100
	if(temp >= 66)
		. = 255
	else
		if(temp <= 16)
			. = 0
		else
			. = max(0, min(255, 138.5177312231 * log(temp - 10) - 305.0447927307))
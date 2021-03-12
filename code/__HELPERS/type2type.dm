/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			hex2num & num2hex
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 */

//Returns an integer given a hex input
/proc/hex2num(hex)
	if(!(istext(hex)))
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
	if(!isnum(num)) return
	if(placeholder == null) placeholder = 2

	var/hex = ""
	while(num)
		var/val = num % 16
		num = round(num / 16)

		if(val > 9)
			val = ascii2text(55 + val) // 65 - 70 correspond to "A" - "F"
		hex = "[val][hex]"
	while(length(hex) < placeholder)
		hex = "0[hex]"
	return hex || "0"

//Returns an integer value for R of R/G/B given a hex color input.
/proc/color2R(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 2, 4)) //Returning R

//Returns an integer value for G of R/G/B given a hex color input.
/proc/color2G(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 4, 6)) //Returning G

//Returns an integer value for B of R/G/B given a hex color input.
/proc/color2B(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 6, 8)) //Returning B

/proc/text2numlist(text, delimiter="\n")
	var/list/num_list = list()
	for(var/x in splittext(text, delimiter))
		num_list += text2num(x)
	return num_list

//Splits the text of a file at seperator and returns them in a list.
/proc/file2list(filename, seperator="\n")
	return splittext(return_file_text(filename),seperator)


//Turns a direction into text

/proc/num2dir(direction)
	switch(direction)
		if(1.0) return NORTH
		if(2.0) return SOUTH
		if(4.0) return EAST
		if(8.0) return WEST
		else
			log_runtime(EXCEPTION("UNKNOWN DIRECTION: [direction]"))

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
/proc/angle2dir(degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTHEAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTHEAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTHWEST
	if(degree < 315)	return WEST
	return NORTH|WEST

/proc/angle2dir_cardinal(angle)
	switch(round(angle, 0.1))
		if(315.5 to 360, 0 to 45.5)
			return NORTH
		if(45.6 to 135.5)
			return EAST
		if(135.6 to 225.5)
			return SOUTH
		if(225.6 to 315.5)
			return WEST

//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2angle(D)
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
/proc/angle2text(degree)
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
	if(rights & R_VIEWRUNTIMES)	. += "[seperator]+VIEWRUNTIMES"
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("Retro")
			return 'icons/mob/screen_retro.dmi'
		if("Plasmafire")
			return 'icons/mob/screen_plasmafire.dmi'
		if("Slimecore")
			return 'icons/mob/screen_slimecore.dmi'
		if("Operative")
			return 'icons/mob/screen_operative.dmi'
		if("White")
			return 'icons/mob/screen_white.dmi'
		else
			return 'icons/mob/screen_midnight.dmi'

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

/proc/num2septext(theNum, sigFig = 7, sep=",") // default sigFig (1,000,000)
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

//Argument: Give this a space-separated string consisting of 6 numbers. Returns null if you don't
/proc/text2matrix(matrixtext)
	var/list/matrixtext_list = splittext(matrixtext, " ")
	var/list/matrix_list = list()
	for(var/item in matrixtext_list)
		var/entry = text2num(item)
		if(entry == null)
			return null
		matrix_list += entry
	if(matrix_list.len < 6)
		return null
	var/a = matrix_list[1]
	var/b = matrix_list[2]
	var/c = matrix_list[3]
	var/d = matrix_list[4]
	var/e = matrix_list[5]
	var/f = matrix_list[6]
	return matrix(a, b, c, d, e, f)


//This is a weird one:
//It returns a list of all var names found in the string
//These vars must be in the [var_name] format
//It's only a proc because it's used in more than one place

//Takes a string and a datum
//The string is well, obviously the string being checked
//The datum is used as a source for var names, to check validity
//Otherwise every single word could technically be a variable!
/proc/string2listofvars(t_string, datum/var_source)
	if(!t_string || !var_source)
		return list()

	. = list()

	var/var_found = findtext(t_string, "\[") //Not the actual variables, just a generic "should we even bother" check
	if(var_found)
		//Find var names

		// "A dog said hi [name]!"
		// splittext() --> list("A dog said hi ","name]!"
		// jointext() --> "A dog said hi name]!"
		// splittext() --> list("A","dog","said","hi","name]!")

		t_string = replacetext(t_string, "\[", "\[ ")//Necessary to resolve "word[var_name]" scenarios
		var/list/list_value = splittext(t_string, "\[")
		var/intermediate_stage = jointext(list_value, null)

		list_value = splittext(intermediate_stage, " ")
		for(var/value in list_value)
			if(findtext(value, "]"))
				value = splittext(value, "]") //"name]!" --> list("name","!")
				for(var/A in value)
					if(var_source.vars.Find(A))
						. += A

/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			if(/obj || /mob)
				return /atom/movable
			if(/area || /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))

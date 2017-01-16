//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)	return value
	if(default)			return default
	if(List && List.len)return pick(List)



//more specialised stuff
/proc/sanitize_gender(gender,neuter=0,plural=0, default="male")
	switch(gender)
		if(MALE, FEMALE)return gender
		if(NEUTER)
			if(neuter)	return gender
			else		return default
		if(PLURAL)
			if(plural)	return gender
			else		return default
	return default

/proc/sanitize_hexcolor(color, default="#000000")
	if(!istext(color)) return default
	var/len = length(color)
	if(len != 7 && len !=4) return default
	if(text2ascii(color,1) != 35) return default	//35 is the ascii code for "#"
	. = "#"
	for(var/i=2,i<=len,i++)
		var/ascii = text2ascii(color,i)
		switch(ascii)
			if(48 to 57)	. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)	. += ascii2text(ascii)		//letters a to f
			if(65 to 70)	. += ascii2text(ascii+32)	//letters A to F - translates to lowercase
			else			return default
	return .

/proc/sanitize_ooccolor(color)
	var/list/HSL = rgb2hsl(hex2num(copytext(color,2,4)),hex2num(copytext(color,4,6)),hex2num(copytext(color,6,8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"

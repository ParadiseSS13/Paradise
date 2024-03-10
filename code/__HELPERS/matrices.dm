/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT


/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = 1, segments = 3, parallel = TRUE)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loops , flags = ANIMATION_PARALLEL)
	else
		animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional

//Dumps the matrix data in format a-f
/matrix/proc/tolist()
	. = list()
	. += a
	. += b
	. += c
	. += d
	. += e
	. += f

//Dumps the matrix data in a matrix-grid format
/*
 * a d 0
 * b e 0
 * c f 1
 **/
/matrix/proc/togrid()
	. = list()
	. += a
	. += d
	. += 0
	. += b
	. += e
	. += 0
	. += c
	. += f
	. += 1

//The X pixel offset of this matrix
/matrix/proc/get_x_shift()
	. = c

//The Y pixel offset of this matrix
/matrix/proc/get_y_shift()
	. = f

/datum/ColorMatrix
	var/list/matrix
	var/combined = 1
	var/const/lumR = 0.3086 //  or  0.2125
	var/const/lumG = 0.6094 //  or  0.7154
	var/const/lumB = 0.0820 //  or  0.0721

/datum/ColorMatrix/New(mat, contrast = 1, brightness = null)
	..()

	if(istext(mat))
		SetPreset(mat)
		if(!matrix)
			SetColor(mat, contrast, brightness)
	else if(isnum(mat))
		SetSaturation(mat, contrast, brightness)
	else
		matrix = mat

/datum/ColorMatrix/proc/Reset()
	matrix = list(1,0,0,
								0,1,0,
								0,0,1)

/datum/ColorMatrix/proc/Get(contrast = 1)
	var/list/mat = matrix
	mat = mat.Copy()

	for(var/i = 1 to min(mat.len, 12))
		mat[i] *= contrast
	return mat

/datum/ColorMatrix/proc/SetSaturation(s, c = 1, b = null)
	var/sr = (1 - s) * lumR
	var/sg = (1 - s) * lumG
	var/sb = (1 - s) * lumB

	matrix = list(c * (sr + s), c * (sr),     c * (sr),
								c * (sg),     c * (sg + s), c * (sg),
								c * (sb),     c * (sb),     c * (sb + s))
	SetBrightness(b)

/datum/ColorMatrix/proc/SetBrightness(brightness)
	if(brightness == null) return

	if(!matrix)
		Reset()

	if(matrix.len == 9 || matrix.len == 16)
		matrix += brightness
		matrix += brightness
		matrix += brightness

		if(matrix.len == 16)
			matrix += 0

	else if(matrix.len == 12)
		for(var/i = matrix.len to matrix.len - 3 step -1)
			matrix[i] = brightness

	else if(matrix.len == 3)
		for(var/i = matrix.len - 1 to matrix.len - 4 step -1)
			matrix[i] = brightness

/datum/ColorMatrix/proc/hex2value(hex)
	var/num1 = copytext(hex, 1, 2)
	var/num2 = copytext(hex, 2)
	if(isnum(text2num(num1)))
		num1 = text2num(num1)
	else
		num1 = text2ascii(lowertext(num1)) - 87
	if(isnum(text2num(num1)))
		num2 = text2num(num1)
	else
		num2 = text2ascii(lowertext(num2)) - 87
	return num1 * 16 + num2

/datum/ColorMatrix/proc/SetColor(color, contrast = 1, brightness = null)
	var/rr = hex2value(copytext(color, 2, 4)) / 255
	var/gg = hex2value(copytext(color, 4, 6)) / 255
	var/bb = hex2value(copytext(color, 6, 8)) / 255

	rr = round(rr * 1000) / 1000 * contrast
	gg = round(gg * 1000) / 1000 * contrast
	bb = round(bb * 1000) / 1000 * contrast

	matrix = list(rr, gg, bb,
								rr, gg, bb,
								rr, gg, bb)

	SetBrightness(brightness)

/datum/ColorMatrix/proc/SetPreset(preset)
	switch(lowertext(preset))
		if("invert")
			matrix = list(-1,0,0,
										0,-1,0,
										0,0,-1,
										1,1,1)
		if("nightsight")
			matrix = list(1,1,1,
										0,0,0,
										0,0,0,
										0.3,0.3,0.3)
		if("nightsight_glasses")
			matrix = list(1,1,1,
										0,0,0,
										0,0,0,
										0.2,0.2,0.2)
		if("thermal")
			matrix = list(1.1, 0, 0,
										0, 1, 0,
										0, 0, 1,
										0, 0, 0)
		if("hos")
			matrix = list(1.2, 0.1, 0,
										0, 1, 0,
										0, 0, 1,
										0, 0, 0)
		if("nvg")
			matrix = list(1,0,0,
										0,1.1,0,
										0,0,1,
										0,0,0)
		if("meson")
			matrix = list(1, 0, 0,
										0, 1.1, 0,
										0, 0, 1,
										-0.05, -0.05, -0.05)
		if("sci")
			matrix = list(1, 0, 0.05,
										0.05, 0.95, 0.05,
										0.05, 0, 1,
										0, 0, 0)
		if("greyscale")
			matrix =  list(0.33, 0.33, 0.33,
										0.33, 0.33, 0.33,
										0.33, 0.33, 0.33,
										0, 0, 0)
		if("sepia")
			matrix = list(0.393,0.349,0.272,
										0.769,0.686,0.534,
										0.189,0.168,0.131,
										0,0,0)
		if("black & white")
			matrix = list(1.5,1.5,1.5,
										1.5,1.5,1.5,
										1.5,1.5,1.5,
										-1,-1,-1)
		if("polaroid")
			matrix = list(1.438,-0.062,-0.062,
										0.122,1.378,-0.122,
										0.016,-0.016,1.483,
										-0.03,0.05,-0.02)
		if("bgr_d")
			matrix = list(0,0,1,
										0,1,0,
										1,0,0,
										0,0,-0.5)
		if("brg_d")
			matrix = list(0,0,1,
										1,0,0,
										0,1,0,
										0,-0.5,0)
		if("gbr_d")
			matrix = list(0,1,0,
										0,0,1,
										1,0,0,
										0,0,-0.5)
		if("grb_d")
			matrix = list(0,1,0,
										1,0,0,
										0,0,1,
										0,-0.5,0)
		if("rbg_d")
			matrix = list(1,0,0,
										0,0,1,
										0,1,0,
										-0.5,0,0)
		if("rgb_d")
			matrix = list(1,0,0,
										0,1,0,
										0,0,1,
										-0.3,-0.3,-0.3)
		if("rgb")
			matrix = list(1,0,0,
										0,1,0,
										0,0,1,
										0,0,0)

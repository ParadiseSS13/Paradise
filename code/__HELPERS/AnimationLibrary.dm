/*
 * A file intended to store various animation procs for re-use.
 * A fair majority of these are copy-pasted from Goon and may not function as expected without tweaking.
 * The spin from being thrown will interrupt most of these animations as will grabs, account for that accordingly.
 */

/proc/animate_fade_grayscale(var/atom/A, var/time = 5)
	if(!istype(A) && !istype(A, /client))
		return
	A.color = null
	animate(A, color = MATRIX_GREYSCALE, time = time, easing = SINE_EASING)

/proc/animate_melt_pixel(var/atom/A)
	if(!istype(A))
		return
	animate(A, pixel_y = 0, time = 50 - A.pixel_y, alpha = 175, easing = BOUNCE_EASING)
	animate(alpha = 0, easing = LINEAR_EASING)

/proc/animate_explode_pixel(var/atom/A)
	if(!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = pick(-1, 1)
	animate(A, pixel_x = rand(-64, 64), pixel_y = rand(-64, 64), transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = 10, alpha = 0, easing = SINE_EASING)

/proc/animate_float(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if(!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side)
		side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 32, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)

/proc/animate_levitate(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if(!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side)
		side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 8, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = null, time = floatspeed, loop = loopnum, easing = SINE_EASING)

/proc/animate_ghostly_presence(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if(!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side)
		side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 8, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)

/proc/animate_fading_leap_up(var/atom/A)
	if(!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	while(do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z + 12, alpha = A.alpha - 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(1.2,1.2)
		sleep(1)
	A.alpha = 0

/proc/animate_fading_leap_down(var/atom/A)
	if(!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	M.Scale(18,18)
	while(do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z - 12, alpha = A.alpha + 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(0.8,0.8)
		sleep(1)
	animate(A, transform = M, pixel_z = 0, alpha = 255, time = 1, loop = 1, easing = LINEAR_EASING)

/proc/animate_shake(var/atom/A, var/amount = 5, var/x_severity = 2, var/y_severity = 2)
	// Wiggles the sprite around on its tile then returns it to normal
	if(!istype(A))
		return
	if(!isnum(amount) || !isnum(x_severity) || !isnum(y_severity))
		return
	amount = max(1,min(amount,50))
	x_severity = max(-32,min(x_severity,32))
	y_severity = max(-32,min(y_severity,32))

	var/x_severity_inverse = 0 - x_severity
	var/y_severity_inverse = 0 - y_severity

	animate(A, transform = null, pixel_y = rand(y_severity_inverse,y_severity), pixel_x = rand(x_severity_inverse,x_severity),time = 1,loop = amount, easing = ELASTIC_EASING)
	spawn(amount)
		animate(A, transform = null, pixel_y = 0, pixel_x = 0,time = 1,loop = 1, easing = LINEAR_EASING)

/proc/animate_teleport(var/atom/A)
	if(!istype(A))
		return
	var/matrix/M = matrix(1, 3, MATRIX_SCALE)
	animate(A, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(transform = null, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

/proc/animate_teleport_wiz(var/atom/A)
	if(!istype(A))
		return
	var/matrix/M = matrix(0, 4, MATRIX_SCALE)
	animate(A, color = "#ddddff", time = 20, alpha = 70, easing = LINEAR_EASING)
	animate(transform = M, pixel_y = 32, time = 20, color = "#2222ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(time = 8, transform = M, alpha = 5) //Do nothing, essentially
	animate(transform = null, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

/proc/animate_rainbow_glow_old(var/atom/A)
	if(!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)

/proc/animate_rainbow_glow(var/atom/A)
	if(!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FFFF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FFFF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FF00FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)

/proc/animate_fade_to_color_fill(var/atom/A, var/the_color, var/time)
	if(!istype(A) || !the_color || !time)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING)

/proc/animate_flash_color_fill(var/atom/A, var/the_color, var/loops, var/time)
	if(!istype(A) || !the_color || !time || !loops)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING)
	animate(color = "#FFFFFF", time = 5, loop = loops, easing = LINEAR_EASING)

/proc/animate_flash_color_fill_inherit(var/atom/A, var/the_color, var/loops, var/time)
	if(!istype(A) || !the_color || !time || !loops)
		return
	var/color_old = A.color
	animate(A, color = the_color, time = time, loop = loops, easing = LINEAR_EASING)
	animate(A, color = color_old, time = time, loop = loops, easing = LINEAR_EASING)

/proc/animate_clownspell(var/atom/A)
	if(!istype(A))
		return
	animate(A, transform = matrix(1.3, MATRIX_SCALE), time = 5, color = "#00ff00", easing = BACK_EASING)
	animate(transform = null, time = 5, color = "#ffffff", easing = ELASTIC_EASING)

/proc/animate_wiggle_then_reset(var/atom/A, var/loops = 5, var/speed = 5, var/x_var = 3, var/y_var = 3)
	if(!istype(A) || !loops || !speed)
		return
	animate(A, pixel_x = rand(-x_var, x_var), pixel_y = rand(-y_var, y_var), time = speed * 2,loop = loops, easing = rand(2,7))
	animate(pixel_x = 0, pixel_y = 0, time = speed, easing = rand(2,7))

/proc/animate_spin(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1)
	if(!istype(A))
		return

	var/matrix/M = A.transform
	var/turn = -90
	if(dir == "R")
		turn = 90

	animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)

/proc/animate_shockwave(var/atom/A)
	if(!istype(A))
		return
	var/punchstr = rand(10, 20)
	var/original_y = A.pixel_y
	animate(A, transform = matrix(punchstr, MATRIX_ROTATE), pixel_y = 16, time = 2, color = "#eeeeee", easing = BOUNCE_EASING)
	animate(transform = matrix(-punchstr, MATRIX_ROTATE), pixel_y = original_y, time = 2, color = "#ffffff", easing = BOUNCE_EASING)
	animate(transform = null, time = 3, easing = BOUNCE_EASING)
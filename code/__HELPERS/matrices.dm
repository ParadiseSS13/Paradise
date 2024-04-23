/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT

/*
Rotates the atom's sprite around by the given angle, by default it's a full 360 degree spin.

speed - How long the animation should last overall, should be a number followed by SECONDS define like 1 SECONDS
loops - How many times the rotation should happen, Loops infinitely by default
clockwise - True if rotating clockwise, False if counter-clockwise
segements - How many steps of animation the rotation will take
parallel - If it should run parallel to other animations
angle - The amount of degrees to rotate the sprite
easing_effects - Any easing defines you want the animate() proc to use, keep in mind it will apply to all the segments individually
*/
/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = TRUE, segments = 3, parallel = TRUE, angle = FULL_TURN, easing_effects = LINEAR_EASING)
	if(!segments)
		return
	var/segment = angle/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loops , flags = ANIMATION_PARALLEL, easing = easing_effects)
	else
		animate(src, transform = matrices[1], time = speed, loops, easing = easing_effects)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed, easing = easing_effects)
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

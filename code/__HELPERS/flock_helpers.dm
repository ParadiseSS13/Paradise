/// A copy of is_blocked_turf(), ignoring flock mobs
/turf/proc/can_flock_occupy(atom/source_atom)
	if(density)
		return FALSE

	for(var/atom/movable/movable_content as anything in contents)
		// We don't want to block ourselves or consider any ignored atoms.
		if((movable_content == source_atom) || isflockmob(movable_content))
			continue
		// If the thing is dense AND we're including mobs or the thing isn't a mob AND if there's a source atom and
		// it cannot pass through the thing on the turf,  we consider the turf blocked.
		if(movable_content.density)
			if(source_atom && movable_content.CanPass(source_atom, get_dir(src, source_atom)))
				continue
			return FALSE

	return TRUE

/proc/flock_pointer(atom/from, atom/towards)
	var/image/pointer = image(icon = 'icons/hud/screen1.dmi', icon_state = "arrow_greyscale", loc = from)

	pointer.plane = HUD_PLANE
	pointer.appearance_flags |= RESET_COLOR
	pointer.color = "#00ff9dff"

	var/angle = 180 + get_angle(from, towards)
	var/matrix/final_matrix = pointer.transform.Scale(2,2)
	final_matrix = final_matrix.Turn(angle)
	pointer.transform = final_matrix

	pointer.pixel_x = sin(angle) * -48
	pointer.pixel_y = cos(angle) * -48
	return pointer

/proc/flock_realname(flock_type)
	var/attempts = 0
	var/name = ""
	do
		attempts++

		switch(flock_type)
			if(FLOCK_TYPE_OVERMIND)
				name = "\proper[pick(GLOB.consonants_lower)][pick(GLOB.vowels_lower)].[pick(GLOB.consonants_lower)][pick(GLOB.vowels_lower)]"
			if(FLOCK_TYPE_TRACE)
				name = "[pick(GLOB.consonants_upper)][pick(GLOB.vowels_lower)].[pick(GLOB.vowels_lower)]"
			if(FLOCK_TYPE_DRONE)
				name = "\proper[pick(GLOB.consonants_lower)][pick(GLOB.vowels_lower)].[pick(GLOB.consonants_lower)][pick(GLOB.vowels_lower)].[pick(GLOB.consonants_lower)][pick(GLOB.vowels_lower)]"
			if(FLOCK_TYPE_BIT)
				name = "[pick(GLOB.consonants_upper)].[rand(10,99)].[rand(10,99)]"

	while(attempts <= 10 && findname(name))

	return name

/proc/flock_name(flock_type)
	var/attempts = 0
	var/name = ""
	do
		attempts++

		switch(flock_type)
			if(FLOCK_TYPE_DRONE)
				name = "[pick(GLOB.flockdrone_name_adjectives)] [pick(GLOB.flockdrone_name_nouns)]"
			if(FLOCK_TYPE_BIT)
				name = "[pick(GLOB.consonants_upper)].[rand(10,99)].[rand(10,99)]"

	while(attempts <= 10 && findname(name))

	return name

/proc/animate_flockpass(atom/thing)
	var/list/color_matrix = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/shrink = thing.transform.Scale(0.4)
	var/old_transform = thing.transform

	animate(thing, color = color_matrix, transform = shrink, time = 3, easing=BOUNCE_EASING)
	animate(color = null, transform = old_transform, time = 3, easing=BOUNCE_EASING)

/// Make a color a repeating gradient between two colors. Note: This is inaccurate because its a linear transformation, but human eyes do not perceive color this way.
/proc/gradient_text(message, color_1, color_2)
	var/list/color_list_1 = rgb2num(color_1)
	var/list/color_list_2 = rgb2num(color_2)

	var/r1 = color_list_1[1]
	var/g1 = color_list_1[2]
	var/b1 = color_list_1[3]

	// The difference in value between each color part
	var/delta_r = color_list_2[1] - r1
	var/delta_g = color_list_2[2] - g1
	var/delta_b = color_list_2[3] - b1

	var/list/result = list()

	// Start at a random point between the two, in increments of 0.1
	var/coeff = rand(0,10) / 10.0
	var/dir = prob(50) ? -1 : 1

	for(var/i in 1 to length(message) step 3)
		coeff += dir * 0.2
		// 20% chance to start going in the opposite direction
		if(prob(20))
			dir = -dir

		// Wrap back around
		if(coeff < 0)
			coeff = 0
			dir = 1

		else if(coeff > 1)
			coeff = 1
			dir = -1

		var/col = rgb(r1 + delta_r*coeff, g1 + delta_g*coeff, b1 + delta_b*coeff)
		var/chars = copytext(message, i, i + 3)
		result += "<span style='color:[col]'>[chars]</span>"

	. = jointext(result, "")

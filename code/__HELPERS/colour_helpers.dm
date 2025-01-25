/proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = rgb2num(rgb1)
	var/list/RGB2 = rgb2num(rgb2)

	// add missing alpha if needed
	if(length(RGB1) < length(RGB2)) RGB1 += 255
	else if(length(RGB2) < length(RGB1)) RGB2 += 255
	var/usealpha = length(RGB1) > 3

	var/r = round(RGB1[1] + (RGB2[1] - RGB1[1]) * amount, 1)
	var/g = round(RGB1[2] + (RGB2[2] - RGB1[2]) * amount, 1)
	var/b = round(RGB1[3] + (RGB2[3] - RGB1[3]) * amount, 1)
	var/alpha = usealpha ? round(RGB1[4] + (RGB2[4] - RGB1[4]) * amount, 1) : null

	return isnull(alpha) ? rgb(r, g, b) : rgb(r, g, b, alpha)

/proc/rand_hex_color()
	var/list/colours = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")
	var/list/output_colour = list()

	for(var/i = 0; i < 6; i++)
		output_colour += pick(colours)

	return "#[output_colour.Join("")]"


// Change grayscale color to black->tone->white range
/proc/ColorTone(rgb, tone)
	var/list/RGB = rgb2num(rgb)
	var/list/TONE = rgb2num(tone)

	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	var/tone_gray = TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11

	if(gray <= tone_gray) return BlendRGB("#000000", tone, gray/(tone_gray || 1))
	else return BlendRGB(tone, "#ffffff", (gray-tone_gray)/((255-tone_gray) || 1))


/proc/adjust_brightness(color, value)
	if(!color) return "#FFFFFF"
	if(!value) return color

	var/list/RGB = rgb2num(color)
	RGB[1] = clamp(RGB[1]+value,0,255)
	RGB[2] = clamp(RGB[2]+value,0,255)
	RGB[3] = clamp(RGB[3]+value,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])

//PACS related code

/proc/color_transition_filter(new_color, saturation_behavior = SATURATION_MULTIPLY)
	if(islist(new_color))
		new_color = rgb(new_color[1], new_color[2], new_color[3])
	new_color = rgb2num(new_color, COLORSPACE_HSL)
	var/hue = new_color[1] / 360
	var/saturation = new_color[2] / 100
	var/added_saturation = 0
	var/deducted_light = 0
	if(saturation_behavior == SATURATION_OVERRIDE)
		added_saturation = saturation * 0.75
		deducted_light = saturation * 0.5
		saturation = min(saturation, 1 - added_saturation)

	var/list/new_matrix = list(
		0, 0, 0, 0, // Ignore original hue
		0, saturation, 0, 0, // Multiply the saturation by ours
		0, 0, 1 - deducted_light, 0, // If we're highly saturated then remove a bit of lightness to keep some color in
		0, 0, 0, 1, // Preserve alpha
		hue, added_saturation, 0, 0, // And apply our preferred hue and some saturation if we're oversaturated
	)
	return color_matrix_filter(new_matrix, FILTER_COLOR_HSL)

/// Applies a color filter to a hex/RGB list color
/proc/apply_matrix_to_color(color, list/matrix, colorspace = COLORSPACE_HSL)
	if(islist(color))
		color = rgb(color[1], color[2], color[3], color[4])
	color = rgb2num(color, colorspace)
	// Pad alpha if we're lacking it
	if(length(color) < 4)
		color += 255

	// Do we have a constants row?
	var/has_constants = FALSE
	// Do we have an alpha row/parameters?
	var/has_alpha = FALSE

	switch(length(matrix))
		if(9)
			has_constants = FALSE
			has_alpha = FALSE
		if(12)
			has_constants = TRUE
			has_alpha = FALSE
		if(16)
			has_constants = FALSE
			has_alpha = TRUE
		if(20)
			has_constants = TRUE
			has_alpha = TRUE
		else
			CRASH("Matrix of invalid length [length(matrix)] was passed into apply_matrix_to_color!")

	var/list/new_color = list(0, 0, 0, 0)
	var/row_length = 3
	if(has_alpha)
		row_length = 4
	else
		new_color[4] = 255

	for(var/row_index in 1 to length(matrix) / row_length)
		for(var/row_elem in 1 to row_length)
			var/elem = matrix[(row_index - 1) * row_length + row_elem]
			if(!has_constants || row_index != (length(matrix) / row_length))
				new_color[row_index] += color[row_elem] * elem
				continue

			// Constant values at the end of the list (if we have such)
			if(colorspace != COLORSPACE_HSV && colorspace != COLORSPACE_HCY && colorspace != COLORSPACE_HSL)
				new_color[row_elem] += elem * 255
				continue

			// HSV/HSL/HCY have non-255 maximums for their values
			var/multiplier = 255
			switch(row_elem)
				// Hue goes from 0 to 360
				if(1)
					multiplier = 360
				// Value, luminance, chroma, etc go from 0 to 100
				if(2 to 3)
					multiplier = 100
					// Alpha still goes from 0 to 255
				if(4)
					multiplier = 255
			new_color[row_elem] += elem * multiplier

	var/rgbcolor = rgb(new_color[1], new_color[2], new_color[3], new_color[4], space = colorspace)
	return rgbcolor

/// Recursively applies a filter to a passed in static appearance, returns the modified appearance
/proc/filter_appearance_recursive(mutable_appearance/filter, filter_to_apply)
	var/mutable_appearance/modify = new(filter)
	var/list/existing_filters = modify.filters.Copy()
	modify.filters = list(filter_to_apply) + existing_filters

	// Ideally this should be recursive to check for KEEP_APART elements that need this applied to it
	// and RESET_COLOR flags but this is much simpler, and hopefully we don't have that point of layering here
	if(modify.appearance_flags & KEEP_TOGETHER)
		return modify

	for(var/overlay_index in 1 to length(modify.overlays))
		modify.overlays[overlay_index] = filter_appearance_recursive(modify.overlays[overlay_index], filter_to_apply)

	for(var/underlay_index in 1 to length(modify.underlays))
		modify.underlays[underlay_index] = filter_appearance_recursive(modify.underlays[underlay_index], filter_to_apply)

	return modify

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
	return rgb(RGB[1], RGB[2], RGB[3])

// Change one RGB color to match the hue of another RGB color (but not saturation or lightness)
/proc/match_hue(color, color_to_match)
	var/list/RGB = rgb2num(color, COLORSPACE_HSL)
	var/list/TARGET = rgb2num(color_to_match, COLORSPACE_HSL)
	RGB[1] = TARGET[1] //change hue to target hue
	return rgb(RGB[1], RGB[2], RGB[3], space = COLORSPACE_HSL)

// Change one RGB color to match the saturation of another RGB color (but not hue or lightness)
/proc/match_saturation(color, color_to_match)
	var/list/RGB = rgb2num(color, COLORSPACE_HSL)
	var/list/TARGET = rgb2num(color_to_match, COLORSPACE_HSL)
	RGB[2] = TARGET[2] //change saturation to target saturation
	return rgb(RGB[1], RGB[2], RGB[3], space = COLORSPACE_HSL)

// Change one RGB color to match the lightness of another RGB color (but not saturation or hue)
/proc/match_lightness(color, color_to_match)
	var/list/RGB = rgb2num(color, COLORSPACE_HSL)
	var/list/TARGET = rgb2num(color_to_match, COLORSPACE_HSL)
	RGB[3] = TARGET[3] //change lightness to target lightness
	return rgb(RGB[1], RGB[2], RGB[3], space = COLORSPACE_HSL)

/// Returns a purely random tint for specific color
/proc/tint_color(color, range = 25)
	if(!is_color_text(color)) // if it's not a hex color
		return color // just leave it as it is

	var/R = clamp(color2R(color) + rand(-range, range), 0, 255)
	var/G = clamp(color2G(color) + rand(-range, range), 0, 255)
	var/B = clamp(color2B(color) + rand(-range, range), 0, 255)

	return rgb(R, G, B)

/// Returns a random tint for a specific color in HSL space.
/proc/tint_color_hsl(color, range = 10)
	var/list/HSL = rgb2num(color, COLORSPACE_HSL)
	HSL[1] = clamp(HSL[1] + rand(-range, range), 0, 100)
	HSL[2] = clamp(HSL[2] + rand(-range, range), 0, 100)
	HSL[3] = clamp(HSL[3] + rand(-range, range), 0, 100)
	return rgb(HSL[1], HSL[2], HSL[3], space = COLORSPACE_HSL)

/// Returns the index of the closest color in the list.
/proc/pick_closest_list_color(list/colors, color)
	var/list/color_rgb
	if(is_color_text(color))
		color_rgb = rgb2num(color)
	else if(is_color_rgb(color))
		color_rgb = color
	else
		return FALSE

	var/distance = 255
	var/picked_color = COLOR_BLACK
	for(var/possible_color in colors)
		var/possible_rgb
		if(is_color_text(possible_color))
			possible_rgb = rgb2num(possible_color)
		else if(is_color_rgb(possible_color))
			possible_rgb = possible_color
		else
			return FALSE
		if(possible_rgb[1] == color_rgb[1] && possible_rgb[2] == color_rgb[2] && possible_rgb[2] == color_rgb[2])
			return colors.Find(possible_color)
		var/possible_distance = sqrt( \
			(color_rgb[1] - possible_rgb[1]) ** 2 + \
			(color_rgb[2] - possible_rgb[2]) ** 2 + \
			(color_rgb[3] - possible_rgb[3]) ** 2)
		if(possible_distance < distance)
			distance = possible_distance
			picked_color = possible_color
	return picked_color

/proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = rgb2num(rgb1)
	var/list/RGB2 = rgb2num(rgb2)

	// add missing alpha if needed
	if(RGB1.len < RGB2.len) RGB1 += 255
	else if(RGB2.len < RGB1.len) RGB2 += 255
	var/usealpha = RGB1.len > 3

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

/// Ensures that the lightness value of a colour must be greater than the provided
/// minimum.
/proc/color_lightness_max(colour, min_lightness)
	var/list/rgb = rgb2num(colour)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	// Ensure high lightness (Minimum of 90%)
	hsl[3] = max(hsl[3], min_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])

/// Ensures that the lightness value of a colour must be less than the provided
/// maximum.
/proc/color_lightness_min(colour, max_lightness)
	var/list/rgb = rgb2num(colour)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	// Ensure high lightness (Minimum of 90%)
	hsl[3] = min(hsl[3], max_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])

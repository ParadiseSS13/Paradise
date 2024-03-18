/proc/get_rune_cult(word)
	var/animated

	if(word && !(SSticker.cultdat.theme == "fire" || SSticker.cultdat.theme == "death"))
		animated = 1
	else
		animated = 0

	var/bits = make_bit_triplet()

	return get_rune(bits, animated)


GLOBAL_LIST_EMPTY(cult_rune_cache)
GLOBAL_VAR_INIT(cult_rune_style, "rune") // Style of run the cult is using (fire, death, regular, etc)

/proc/get_rune(symbol_bits, animated = 0)
	var/lookup = "[symbol_bits]-[animated]"


	if(!SSticker.mode)//work around for maps with runes and cultdat is not loaded all the way
		GLOB.cult_rune_style = "rune"
	else if(SSticker.cultdat.theme == "fire")
		GLOB.cult_rune_style = "fire-rune"
	else if(SSticker.cultdat.theme == "death")
		GLOB.cult_rune_style = "death-rune"


	if(lookup in GLOB.cult_rune_cache)
		return GLOB.cult_rune_cache[lookup]

	var/icon/I = icon('icons/effects/uristrunes.dmi', "[GLOB.cult_rune_style]-179")

	for(var/i = 0, i < 10, i++)
		if(symbol_bits & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "[GLOB.cult_rune_style]-[1 << i]"), ICON_OVERLAY)


	I.SwapColor(rgb(0, 0, 0, 100), rgb(100, 0, 0, 200))//TO DO COMMENT:NEED TO ADJUST FOR DIFFRNET CULTS
	I.SwapColor(rgb(0, 0, 0, 50), rgb(150, 0, 0, 200))

	for(var/x = 1, x <= 32, x++)
		for(var/y = 1, y <= 32, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)

				if(n == "#000000" || s == "#000000" || e == "#000000" || w == "#000000")
					I.DrawBox(rgb(200, 0, 0, 200), x, y)

				else
					var/ne = I.GetPixel(x + 1, y + 1)
					var/se = I.GetPixel(x + 1, y - 1)
					var/nw = I.GetPixel(x - 1, y + 1)
					var/sw = I.GetPixel(x - 1, y - 1)

					if(ne == "#000000" || se == "#000000" || nw == "#000000" || sw == "#000000")
						I.DrawBox(rgb(200, 0, 0, 100), x, y)

	var/icon/result = icon(I, "")

	result.Insert(I,  "", frame = 1, delay = 10)

	if(animated == 1)
		var/icon/I2 = icon(I, "")
		I2.MapColors(rgb(0xff,0x0c,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I2.SetIntensity(1.04)

		var/icon/I3 = icon(I, "")
		I3.MapColors(rgb(0xff,0x18,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I3.SetIntensity(1.08)

		var/icon/I4 = icon(I, "")
		I4.MapColors(rgb(0xff,0x24,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I4.SetIntensity(1.12)

		var/icon/I5 = icon(I, "")
		I5.MapColors(rgb(0xff,0x30,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I5.SetIntensity(1.16)

		result.Insert(I2, "", frame = 2, delay = 4)
		result.Insert(I3, "", frame = 3, delay = 3)
		result.Insert(I4, "", frame = 4, delay = 2)
		result.Insert(I5, "", frame = 5, delay = 6)
		result.Insert(I4, "", frame = 6, delay = 2)
		result.Insert(I3, "", frame = 7, delay = 2)
		result.Insert(I2, "", frame = 8, delay = 2)

	GLOB.cult_rune_cache[lookup] = result

	return result

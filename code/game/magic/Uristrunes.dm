/proc/make_bit_triplet()
  var/list/num_sample  = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
  var/result = 0
  for(var/i = 0, i < 3, i++)
    var/num = pick(num_sample)
    num_sample -= num
    result += (1 << num)
  return result

/proc/get_uristrune_cult(word)
	var/animated

	if(word)
		animated = 1
	else
		animated = 0

	var/bits = make_bit_triplet()

	return get_uristrune(bits, animated)


var/list/uristrune_cache = list()

/proc/get_uristrune(symbol_bits, animated = 0)
	var/lookup = "[symbol_bits]-[animated]"

	if(lookup in uristrune_cache)
		return uristrune_cache[lookup]

	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

	for(var/i = 0, i < 10, i++)
		if(symbol_bits & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)


	I.SwapColor(rgb(0, 0, 0, 100), rgb(100, 0, 0, 200))
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

	uristrune_cache[lookup] = result

	return result

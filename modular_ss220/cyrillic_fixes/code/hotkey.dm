GLOBAL_LIST_INIT(ru_key_to_en_key, list(
	"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
	"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
	"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."
))

/proc/convert_ru_key_to_en_key(_key)
	var/new_key = lowertext(_key)
	new_key = GLOB.ru_key_to_en_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

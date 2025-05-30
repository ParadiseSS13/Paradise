GLOBAL_LIST_INIT(ru_key_to_en_key, list(
	"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
	"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
	"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."
))

GLOBAL_LIST_INIT(en_key_to_ru_key, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н", "u" = "г", "i" = "ш", "o" = "щ", "p" = "з", "\[" = "х", "]" = "ъ",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р", "j"= "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э",
	"z" = "я", "x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь", "," = "б", "." = "ю"
))

/proc/convert_ru_key_to_en_key(_key)
	var/new_key = lowertext(_key)
	new_key = GLOB.ru_key_to_en_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

/proc/convert_en_key_to_ru_key(_key)
	var/new_key = lowertext(_key)
	new_key = GLOB.en_key_to_ru_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

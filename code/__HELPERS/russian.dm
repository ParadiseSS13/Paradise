GLOBAL_LIST_INIT(enkeys, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н",
	"u" = "г", "i" = "ш", "o" = "щ", "p" = "з",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р",
	"j" = "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э", "z" = "я",
	"x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь",
	"," = "б", "." = "ю",
))
GLOBAL_LIST_INIT(rukeys, list(
	"Й" = "Q", "Ц" = "W", "У" = "E", "К" = "R", "Е" = "T", "Н" = "Y",
	"Г" = "U", "Ш" = "I", "Щ" = "O", "З" = "P",
	"Ф" = "A", "Ы" = "S", "В" = "D", "А" = "F", "П" = "G", "Р" = "H",
	"О" = "J", "Л" = "K", "Д" = "L", "Ж" = ";", "Э" = "'", "Я" = "Z",
	"Ч" = "X", "С" = "C", "М" = "V", "И" = "B", "Т" = "N", "Ь" = "M",
	"Б" = ",", "Ю" = ".",
))


/proc/sanitize_english_key_to_russian(char)
	var/new_char = GLOB.enkeys[lowertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_russian_key_to_english(char)
	var/new_char = GLOB.rukeys[uppertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_english_string_to_russian(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_english_key_to_russian(copytext_char(text, i, i+1))

GLOBAL_LIST_INIT(specsymbols, list(
	"!" = "1", "\"" = "2", "@" = "2", "№" = "3", "#" = "3",
	";" = "4", "$" = "4", "%" = "5", "^" = "6", ":" = "6",
	"&" = "7", "?" = "7", "*" = "8", "(" = "9", ")" = "0", "_" = "-",
))

/proc/sanitize_specsymbols_key_to_numbers(char) // for keybindings
	var/new_char = GLOB.specsymbols[uppertext(char)]
	return (new_char != null) ? new_char : char

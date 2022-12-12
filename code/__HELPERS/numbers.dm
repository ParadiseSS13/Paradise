/proc/num_in_words(n)
	var/static/datum/number/num
	if(!num)
		num = new /datum/number
	n = text2num(n, 10)
	if(ISINTEGER(n))
		return " [num.int2words(n)] "
	return ""

/datum/number
	var/static/list/units = list(
		"ноль",

		list("один", "одна"),
		list("два", "две"),

		"три", "четыре", "пять",
		"шесть", "семь", "восемь", "девять"
		)

	var/static/list/teens = list(
		"десять", "одиннадцать",
		"двенадцать", "тринадцать",
		"четырнадцать", "пятнадцать",
		"шестнадцать", "семнадцать",
		"восемнадцать", "девятнадцать"
		)

	var/static/list/tens = list(
		"десять",
		"двадцать", "тридцать",
		"сорок", "пятьдесят",
		"шестьдесят", "семьдесят",
		"восемьдесят", "девяносто"
		)

	var/static/list/hundreds = list(
		"сто", "двести",
		"триста", "четыреста",
		"пятьсот", "шестьсот",
		"семьсот", "восемьсот",
		"девятьсот"
		)

	var/static/list/orders = list(
		list(list("тысяча", "тысячи", "тысяч"), "f"),
		list(list("миллион", "миллиона", "миллионов"), "m"),
		list(list("миллиард", "миллиарда", "миллиардов"), "m"),
		list(list("триллион", "триллиона", "триллионов"), "m"),
		list(list("квадриллион", "квадриллиона", "квадриллионов"), "m"),
		list(list("квинтиллион", "квинтиллиона", "квинтиллионов"), "m"),
	)

	var/static/minus = "минус"

	var/static/cache = list()

/datum/number/proc/thousand(rest, sex)
//	"""Converts numbers from 19 to 999"""
	var/prev = 0
	var/plural = 3
	var/list/name = list()
	var/use_teens = (rest % 100 >= 10) && (rest % 100 <= 19)
	var/list/data = list()

	if(!use_teens)
		data = list( list(units, 10), list(tens, 100), list(hundreds, 1000) )
	else
		data = list( list(teens, 10), list(hundreds, 1000) )
	for(var/list in data)

		var/names = list[1]
		var/x = list[2]

		var/cur = round(((rest - prev) % x) * 10 / x) + 1
		prev = rest % x

		if(x == 10 && use_teens)
			plural = 3
			name += teens[cur]
		else if(cur == 1)
			continue
		else if(x == 10)
			var/name_ = names[cur]
			if(islist(name_))
				name_ = name_[sex == "m" ? 1 : 2]
			name += name_
			if(cur >= 3 && cur <= 5)
				plural = 2
			else if(cur == 2)
				plural = 1
			else
				plural = 3
		else
			name += names[cur-1]

	return list(plural, name)

/datum/number/proc/int2words(num, list/main_units = list(list("", "", ""), "m"))
//	http://ru.wikipedia.org/wiki/Gettext#.D0.9C.D0.BD.D0.BE.D0.B6.D0.B5.D1.81.D1.82.D0.B2.D0.B5.D0.BD.D0.BD.D1.8B.D0.B5_.D1.87.D0.B8.D1.81.D0.BB.D0.B0_2

	if(cache["[num]"])
		return cache["[num]"]

	var/list/_orders = list(main_units) + orders
	if(num == 0)
		return trim(jointext(list(units[1], _orders[1][1][3]), " "))

	var/rest = abs(num)
	var/ord = 1
	var/list/name = list()

	while(rest > 0)
		var/list/thousand_result = thousand((rest % 1000), _orders[ord][2])
		var/plural = thousand_result[1]
		var/list/nme = thousand_result[2]

		if(length(nme) || ord == 1)
			name += _orders[ord][1][plural]

		name += nme
		rest = round(rest / 1000)
		ord += 1
	if(num < 0)
		name += minus

	var/temp_name = name
	name = list()
	for(var/i = length_char(temp_name), i >= 1, i--)
		name += temp_name[i]

	var/result = trim(jointext(name, " "))
	cache["[num]"] = result
	return result

/datum/number/proc/decimal2words(value, places = 2, int_units=list(list("целых", "целых", "целых"), "m"), exp_units=list(list("", "", ""), "m"))
	if(cache["[value]"])
		return cache["[value]"]

	var/q = 10 ** -places

	var/pieces = splittext("[round(value, q)]", ".")
	var/integral = pieces[1]
	var/exp = pieces[2]

	var/result = trim("[int2words(integral, int_units)] [int2words(exp, exp_units)]")
	cache["[value]"] = result
	return result

//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/dna/gene/disability/mute
	name = "Mute"
	desc = "Completely shuts down the speech center of the subject's brain."
	activation_message   = "You feel unable to express yourself at all."
	deactivation_message = "You feel able to speak freely again."
	instability = -GENE_INSTABILITY_MODERATE
	mutation = MUTE

/datum/dna/gene/disability/mute/New()
	..()
	block = GLOB.muteblock

/datum/dna/gene/disability/mute/OnSay(mob/M, message)
	return ""

////////////////////////////////////////
// Harmful to others as well as self
////////////////////////////////////////

/datum/dna/gene/disability/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	activation_message = "You feel a strange sickness permeate your whole body."
	deactivation_message = "You no longer feel awful and sick all over."
	instability = -GENE_INSTABILITY_MAJOR
	mutation = RADIOACTIVE

/datum/dna/gene/disability/radioactive/New()
	..()
	block = GLOB.radblock


/datum/dna/gene/disability/radioactive/can_activate(mob/M, flags)
	if(!..())
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((RADIMMUNE in H.dna.species.species_traits) && !(flags & MUTCHK_FORCED))
			return FALSE
	return TRUE

/datum/dna/gene/disability/radioactive/OnMobLife(mob/living/carbon/human/H)
	var/radiation_amount = abs(min(H.radiation - 20,0))
	H.apply_effect(radiation_amount, IRRADIATE)
	for(var/mob/living/L in range(1, H))
		if(L == H)
			continue
		to_chat(L, "<span class='danger'>You are enveloped by a soft green glow emanating from [H].</span>")
		L.apply_effect(5, IRRADIATE)

/datum/dna/gene/disability/radioactive/OnDrawUnderlays(mob/M, g)
	return "rads_s"

////////////////////////////////////////
// Other disabilities
////////////////////////////////////////

// WAS: /datum/bioEffect/fat
/datum/dna/gene/disability/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	activation_message = "You feel blubbery and lethargic!"
	deactivation_message = "You feel fit!"
	instability = -GENE_INSTABILITY_MINOR
	mutation = OBESITY

/datum/dna/gene/disability/fat/New()
	..()
	block = GLOB.fatblock

// WAS: /datum/bioEffect/chav
// WAS: /datum/dna/gene/disability/speech/chav
/datum/dna/gene/disability/speech/auld_imperial
	name = "Староимпѣрская рѣчь"
	desc = "Заставляет языковой центра мозга субъекта произносить слова на староимперский манер."
	activation_message = "Охъ, где бы отвѣдать мягкихъ ѳранцузскихъ булокъ, да выпить ароматнаго чаю глоточекъ?"
	deactivation_message = "Изысканность вашей речи улетучивается, как запах дорогих духов… Блядь."
	mutation = AULD_IMPERIAL
	// Слова для замены
	var/static/list/low_cultural_words = list(
		"бля"="ох", "блядь"="ох", "башка"="голова", "башке"="голове", "башку"="голову", "бошка"="голова", "бошке"="голове", "бошку"="голову", "дебил"="остолоп", "ёбаный"="проклятый", "ёбаные"="проклятые", "ёбаных"="проклятых", "ёбаная"="проклятая", "ёбаное"="проклятое", "ебаный"="проклятый", "ебаные"="проклятые", "ебаных"="проклятых", "ебаная"="проклятая", "ебаное"="проклятое", "ебучий"="проклятый", "ебучие"="проклятые", "ебучих"="проклятых", "ебучая"="проклятая", "ебучее"="проклятое", "до пизды"="всё равно", "до жопы"="много", "дохуя"="очень много", "дура"="глупышка", "дуре"="глупышке", "дурой"="глупышкой", "дуру"="глупышку", "дурак"="болван", "жопа"="попа", "жопы"="попы", "идиот"="шельмец", "мразь"="мерзавец", "мудак"="подлец", "нахуй"="к чёрту", "нахуя"="зачем", "наёбщик"="плут", "наёбывать"="плутовать", "нихуя"="ничего", "охуел"="поражён", "охуела"="поражена", "охуевать"="поражаться", "охуеваю"="поражаюсь", "охуеваешь"="поражаетесь", "охуеваете"="поражаетесь", "охуевает"="поражается", "охуевают"="поражаются", "пидарас"="безобразник", "пидараса"="безобразника", "пидарасе"="безобразнике", "пидарасу"="безобразнику", "пидарасом"="безобразником", "пидарасы"="безобразники", "пидор"="безобразник", "пидора"="безобразника", "пидоре"="безобразнике", "пидору"="безобразнику", "пидором"="безобразником", "пидоры"="безобразники", "пидар"="безобразник", "пидара"="безобразника", "пидаре"="безобразнике", "пидару"="безобразнику", "пидаром"="безобразником", "пидары"="безобразники", "пиздец"="провал", "срочник"="недотёпа", "срочники"="недотёпы", "срочникам"="недотёпам", "срочников"="недотёп", "пиздеца"="провала", "пиздеце"="провале", "пиздецом"="провалом", "писец"="провал", "сдох"="погиб", "сдыхать"="погибать", "сдыхаю"="гибну", "сдыхает"="гибнет", "сдыхают"="гибнут", "сдохну"="погибну", "сдохнуть"="погибнуть", "сдохла"="погибла", "сдохло"="погибло", "сдохли"="погибли", "говно"="дрянь", "похуй"="жаль", "СБ"="охрана", "АВД"="агент", "ПНТ"="представитель", "НТР"="представитель", "варден"="смотритель", "КМ"="квартирмейстер", "кэп"="капитан", "кэпа"="капитана", "кэпе"="капитане", "кэпу"="капитану", "кэпом"="капитаном", "сука"="шельма", "суке"="шельме", "суки"="шельмы", "сукой"="шельмой", "схуяли"="почему", "твое"="Ваше", "твои"="Ваши", "твоими"="Вашими", "твоих"="Ваших", "твой"="Ваш", "твоя"="Ваша", "твоё"="Ваше", "тебе"="Вам", "тебя"="Вас", "тобой"="Вами", "тупой"="недоумок", "тупого"="недоумка", "тупому"="недоумку", "тупом"="недоумке", "тупым"="недоумком", "ты"="Вы", "урод"="голубчик", "урода"="голубчика", "уроду"="голубчику", "уроде"="голубчике", "уродом"="голубчиком", "хуй там"="отнюдь", "срочно"="поскорее", "отпиздить"="побить", "пиздить"="избивать", "пиздят"="избивают", "ебут"="избивают", "ебать"="бить", "заебало"="опротивело", "чел"="сударь", "чела"="сударя", "челе"="сударе", "челу"="сударю", "челом"="сударем", "челам"="сударям", "челы"="судари", "челик"="сударь", "челика"="сударя", "челике"="сударе", "челику"="сударю", "челиком"="сударем", "челикам"="сударям", "челики"="судари", "мужик"="мещанин", "мужика"="мещанина", "мужике"="мещанине", "мужику"="мещанину", "мужиком"="мещанином", "мужикам"="мещанам", "мужики"="мещане", "бомж"="юродивый", "бомжа"="юродивого", "бомже"="юродивом", "бомжу"="юродивому", "бомжом"="юродивым", "бомжам"="юродивым", "бомжи"="юродивые", "шлюха"="куртизанка", "даун"="глупыш",
	)
	var/static/regex/low_cultural_words_regex = regex("(^|\\s|-)([low_cultural_words.Join("|")])(?=($|\\s|\\.|,|:|!|\\?|-))", "g")
	// Список слов для добавления словоерса
	var/static/list/word_for_slovoers = list("ну","да","вот","так","помогите","представитель","шеф","прошу","смотритель","варден","офицер","детектив","капитан","магистрат","вы")
	var/static/regex/slovoers_regex = regex("(^|\\s|-)([word_for_slovoers.Join("|")])", "ig")
	// Согласные буквы. Буква «й» считалась гласной
	var/static/list/consonant = list("б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ш","щ")
	var/static/list/consonant_big = list("Б","В","Г","Д","Ж","З","К","Л","М","Н","П","Р","С","Т","Ф","Х","Ш","Щ")
	var/static/regex/consonant_regexp = regex("([consonant.Join("|")])(?=\\s|,|-|!|\\?|$)", "g")
	var/static/regex/consonant_big_regexp = regex("([consonant_big.Join("|")])(?=\\s|,|-|!|\\?|$)", "g")

// /datum/dna/gene/disability/speech/auld_imperial/New()
/datum/dna/gene/disability/speech/auld_imperial/New()
	..()
	block = GLOB.auld_imperial_block

// /datum/dna/gene/disability/speech/auld_imperial/OnSay(mob/M, message)
/datum/dna/gene/disability/speech/auld_imperial/OnSay(mob/M, message)
	if(!M.is_muzzled())
		// Замены слов
		message = low_cultural_words_regex.Replace_char(message, /datum/dna/gene/disability/speech/auld_imperial/proc/replace_speech)

		// словоерс
		if(prob(50))
			message = slovoers_regex.Replace_char(message, /datum/dna/gene/disability/speech/auld_imperial/proc/add_slovoers)

		// Добавлять «ъ» в конце слов на согласный
		message = consonant_regexp.Replace_char(message, /datum/dna/gene/disability/speech/auld_imperial/proc/add_er)
		message = consonant_big_regexp.Replace_char(message, /datum/dna/gene/disability/speech/auld_imperial/proc/add_er)

		// Прилагательные на -ый, -ій, в родительном падеже оканчиваются на -аго, -яго.
		message = replacetextEx_char(message,"ого ","аго ")
		message = replacetextEx_char(message,"его ","яго ")
		message = replacetextEx_char(message,"ОГО ","АГО ")
		message = replacetextEx_char(message,"ЕГО ","ЯГО ")

		// Прилагательные на -ые, -ие оканчиваются на ‑ыя, -ія.
		message = replacetextEx_char(message,"ые ","ыя ")
		message = replacetextEx_char(message,"ие ","ія ")
		message = replacetextEx_char(message,"ЫЕ ","ЫЯ ")
		message = replacetextEx_char(message,"ИЕ ","ІЯ ")

		// Заменять «и» на «i», если после него гласная (в том числе «й»)
		message = replacetextEx_char(message,"иа","iа")
		message = replacetextEx_char(message,"ие","iе")
		message = replacetextEx_char(message,"иё","iё")
		message = replacetextEx_char(message,"ии","iи")
		message = replacetextEx_char(message,"ий","iй")
		message = replacetextEx_char(message,"ио","iо")
		message = replacetextEx_char(message,"иу","iу")
		message = replacetextEx_char(message,"иэ","iэ")
		message = replacetextEx_char(message,"ию","iю")
		message = replacetextEx_char(message,"ия","iя")
		message = replacetextEx_char(message,"ИА","IА")
		message = replacetextEx_char(message,"ИЕ","IЕ")
		message = replacetextEx_char(message,"ИЁ","IЁ")
		message = replacetextEx_char(message,"ИИ","IИ")
		message = replacetextEx_char(message,"ИЙ","IЙ")
		message = replacetextEx_char(message,"ИО","IО")
		message = replacetextEx_char(message,"ИУ","IУ")
		message = replacetextEx_char(message,"ИЭ","IЭ")
		message = replacetextEx_char(message,"ИЮ","IЮ")
		message = replacetextEx_char(message,"ИЯ","IЯ")

		// Местоимение «её» → «ея»
		message = replacetextEx_char(message," её"," ея")
		message = replacetextEx_char(message," ЕЁ"," ЕЯ")
		message = replacetextEx_char(message,"её ","ея ")
		message = replacetextEx_char(message,"ЕЁ ","ЕЯ ")

		// заменять «ё» на «їо»
		message = replacetextEx_char(message,"ё","їо")
		message = replacetextEx_char(message,"Ё","Їо")

		if(prob(50))
			// Периодически заменять «е» на ять «ѣ»
			message = replacetextEx_char(message,"е","ѣ")

		if(prob(5))
			// редко заменять «ф» на фиту «ѳ»
			message = replacetextEx_char(message,"ф","ѳ")
			message = replacetextEx_char(message,"Ф","Ѳ")

	return message

/datum/dna/gene/disability/speech/auld_imperial/proc/add_slovoers(matched)
	return "[matched]-съ"
/datum/dna/gene/disability/speech/auld_imperial/proc/add_er(matched)
	return "[matched]ъ"
/datum/dna/gene/disability/speech/auld_imperial/proc/replace_speech(matched, first, second)
	return "[first][low_cultural_words[second]]"

// WAS: /datum/bioEffect/swedish
/datum/dna/gene/disability/speech/swedish
	name = "Шведский акцент"
	desc = "Заставляет языковой центра мозга субъекта произносить слова на скандинавский манер."
	activation_message = "Вы ощущаете внутреннюю шведскость. Кажется, сработало."
	deactivation_message = "Внутреннее ощущение шведскости проходит."
	mutation = SWEDISH

/datum/dna/gene/disability/speech/swedish/New()
	..()
	block = GLOB.swedeblock

/datum/dna/gene/disability/speech/swedish/OnSay(mob/M, message)
	// svedish
	message = replacetextEx(message,"W","V")
	message = replacetextEx(message,"w","v")
	message = replacetextEx(message,"J","Y")
	message = replacetextEx(message,"j","y")
	message = replacetextEx(message,"A",pick("Å","Ä","Æ","A"))
	message = replacetextEx(message,"a",pick("å","ä","æ","a"))
	message = replacetextEx(message,"BO","BJO")
	message = replacetextEx(message,"Bo","Bjo")
	message = replacetextEx(message,"bo","bjo")
	message = replacetextEx(message,"O",pick("Ö","Ø","O"))
	message = replacetextEx(message,"o",pick("ö","ø","o"))

	message = replacetextEx_char(message,"А",pick("Å","Ä","А"))
	message = replacetextEx_char(message,"а",pick("å","ä","а"))

	message = replacetextEx_char(message,"О",pick("Ö","Ø","О"))
	message = replacetextEx_char(message,"о",pick("ö","ø","о"))

	message = replacetextEx_char(message," и ",pick(" & "," и "))
	message = replacetextEx_char(message," И ",pick(" & "," и "))

	message = replacetextEx_char(message,"АЕ","Æ")
	message = replacetextEx_char(message,"ае","æ")

	message = replacetextEx_char(message,"ОЕ","Œ")
	message = replacetextEx_char(message,"ое","œ")

	message = replacetextEx_char(message,"АУ","Ꜽ")
	message = replacetextEx_char(message,"ау","ꜽ")

	message = replacetextEx_char(message,"ОО","Ꝏ")
	message = replacetextEx_char(message,"оо","ꝏ")

	if(prob(30) && !M.is_muzzled())
		message += " Bork[pick("",", bork",", bork, bork")]!"
	return message

// WAS: /datum/bioEffect/unintelligable
/datum/dna/gene/disability/unintelligable
	name = "Unintelligable"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	activation_message = "You can't seem to form any coherent thoughts!"
	deactivation_message = "Your mind feels more clear."
	instability = -GENE_INSTABILITY_MINOR
	mutation = SCRAMBLED

/datum/dna/gene/disability/unintelligable/New()
	..()
	block = GLOB.scrambleblock

/datum/dna/gene/disability/unintelligable/OnSay(mob/M, message)
	var/prefix = copytext(message,1,2)
	if(prefix == ";")
		message = copytext(message,2)
	else if(prefix in list(":","#"))
		prefix += copytext(message,2,3)
		message = copytext(message,3)
	else
		prefix=""

	var/list/words = splittext(message," ")
	var/list/rearranged = list()
	for(var/i=1;i<=words.len;i++)
		var/cword = pick(words)
		words.Remove(cword)
		var/suffix = copytext(cword,length(cword)-1,length(cword))
		while(length(cword)>0 && (suffix in list(".",",",";","!",":","?")))
			cword  = copytext(cword,1              ,length(cword)-1)
			suffix = copytext(cword,length(cword)-1,length(cword)  )
		if(length(cword))
			rearranged += cword
	return "[prefix][uppertext(jointext(rearranged," "))]!!"

//////////////////
// USELESS SHIT //
//////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/disability/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_message = "You feel buff!"
	deactivation_message = "You feel wimpy and weak."
	mutation = STRONG

/datum/dna/gene/disability/strong/New()
	..()
	block = GLOB.strongblock

// WAS: /datum/bioEffect/horns
/datum/dna/gene/disability/horns
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_message = "A pair of horns erupt from your head."
	deactivation_message = "Your horns crumble away into nothing."
	mutation = HORNS

/datum/dna/gene/disability/horns/New()
	..()
	block = GLOB.hornsblock

/datum/dna/gene/disability/horns/OnDrawUnderlays(mob/M, g)
	return "horns_s"

////////////////////////////////////////////////////////////////////////
// WAS: /datum/bioEffect/immolate
/datum/dna/gene/basic/grant_spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	activation_messages = list("You suddenly feel rather hot.")
	deactivation_messages = list("You no longer feel uncomfortably hot.")
	mutation = IMMOLATE

	spelltype = /obj/effect/proc_holder/spell/targeted/immolate

/datum/dna/gene/basic/grant_spell/immolate/New()
	..()
	block = GLOB.immolateblock

/obj/effect/proc_holder/spell/targeted/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	panel = "Abilities"

	charge_type = "recharge"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -1
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human)
	include_user = 1

	action_icon_state = "genetic_incendiary"

/obj/effect/proc_holder/spell/targeted/immolate/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/L = user
	L.adjust_fire_stacks(0.5)
	L.visible_message("<span class='danger'>[L.name]</b> suddenly bursts into flames!</span>")
	L.IgniteMob()
	playsound(L.loc, 'sound/effects/bamf.ogg', 50, 0)

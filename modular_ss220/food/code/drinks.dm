/obj/item/reagent_containers/drinks/drinkingglass/on_reagent_change()
	. = ..()
	if(!reagents.reagent_list.len)
		icon = initial(icon)
		return
	var/datum/reagent/reagent = reagents.get_master_reagent()
	if(!istype(reagent, /datum/reagent/consumable))
		icon = initial(icon)
	else
		var/datum/reagent/consumable/drink = reagent
		icon = drink.drinking_glass_icon
	if(!reagent.drink_icon)
		icon_state = "glass_empty"

/datum/reagent/consumable
	var/drinking_glass_icon = 'icons/obj/drinks.dmi'

/obj/machinery/chem_dispenser/beer/Initialize(mapload)
	dispensable_reagents |= "sambuka"
	dispensable_reagents |= "jagermeister"
	dispensable_reagents |= "bitter"
	dispensable_reagents |= "bluecuracao"
	. = ..()

/obj/item/handheld_chem_dispenser/booze/Initialize(mapload)
	dispensable_reagents |= "sambuka"
	dispensable_reagents |= "jagermeister"
	dispensable_reagents |= "bitter"
	dispensable_reagents |= "bluecuracao"
	. = ..()

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuka"
	id = "sambuka"
	description = "Flying into space, many thought that they had grasped fate."
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 1
	drink_icon = "sambukaglass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Glass of Sambuka"
	drink_desc = "Flying into space, many thought that they had grasped fate."
	taste_description = "twirly fire"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	description = "Remember that big brother sees everything."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Innocent ERP"
	drink_desc = "Remember that big brother sees everything."
	taste_description = "loss of flirtatiousness"

/datum/chemical_reaction/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	result = "innocent_erp"
	required_reagents = list("sambuka" = 3, "triple_citrus" = 1, "irishcream" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/soundhand
	name = "soundhand"
	id = "soundhand"
	description = "Коктейль из нескольких алкогольных напитков с запахом ягод и легким слоем перца на стакане."
	color = "#C18A7B"
	alcohol_perc = 0.5
	drink_icon = "soundhand"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Саундхэнд"
	drink_desc = "Коктейль из нескольких алкогольных напитков с запахом ягод и легким слоем перца на стакане."
	taste_description = "дребезжащие в ритме металлические струны."

/datum/reagent/consumable/ethanol/soundhand/on_mob_life(mob/living/M)
	. = ..()
	if(prob(10))
		M.emote("airguitar")

/datum/chemical_reaction/soundhand
	name = "Soundhand"
	id = "soundhand"
	result = "soundhand"
	required_reagents = list("vodka" = 2, "whiskey" = 1, "berryjuice" = 1, "blackpepper" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/jagermeister
	name = "Jagermeister"
	id = "jagermeister"
	description = "Пьяный охотник прилетел из глубокого космоса и, похоже, нашел жертву."
	color = "#200b0b"
	alcohol_perc = 0.4
	dizzy_adj = 6 SECONDS
	drink_icon = "jagermeisterglass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Стакан Егермейстра"
	drink_desc = "Пьяный охотник прилетел из глубокого космоса и, похоже, нашел жертву."
	taste_description = "радость охоты"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "Предохранитель готов, синева уже загорелась."
	color = "#16c9ff"
	alcohol_perc = 0.35
	drink_icon = "bluecuracaoglass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Стакан Блю Кюрасао"
	drink_desc = "Предохранитель готов, синева уже загорелась."
	taste_description = "взрывная синева"

/datum/reagent/consumable/ethanol/bitter
	name = "Bitter"
	id = "bitter"
	description = "Не путайте размеры этикеток, потому что я ничего менять не буду."
	color = "#d44071"
	alcohol_perc = 0.45
	dizzy_adj = 4 SECONDS
	drink_icon = "bitterglass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Стакан Биттера"
	drink_desc = "Не путайте размеры этикеток, потому что я ничего менять не буду."
	taste_description = "вакуумная горечь"

/datum/chemical_reaction/bitter
	name = "Bitter"
	id = "bitter"
	result = "bitter"
	required_reagents = list("ethanol" = 5, "berryjuice" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/black_blood
	name = "Black Blood"
	id = "black_blood"
	description = "Нужно пить быстрее, пока оно не начало сворачиваться."
	color = "#252521"
	alcohol_perc = 0.45
	drink_icon = "black_blood"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Черная Кровь"
	drink_desc = "Нужно пить быстрее, пока оно не начало сворачиваться."
	taste_description = "кровавая тьма"

/datum/reagent/consumable/ethanol/black_blood/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("Fuu ma'jin!", "Sas'so c'arta forbici!", "Ta'gh fara'qha fel d'amar det!", "Kla'atu barada nikt'o!", "Fel'th Dol Ab'orod!", "In'totum Lig'abis!", "Ethra p'ni dedol!", "Ditans Gut'ura Inpulsa!", "O bidai nabora se'sma!"))

/datum/chemical_reaction/black_blood
	name = "Black Blood"
	id = "black_blood"
	result = "black_blood"
	required_reagents = list("bluecuracao" = 2, "jagermeister" = 1, "sodawater" = 1, "ice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/pegu_club
	name = "Pegu Club"
	id = "pegu_club"
	description = "Это похоже на то, как группа джентльменов колонизирует ваш язык."
	color = "#a5702b"
	alcohol_perc = 0.5
	drink_icon = "pegu_club"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Клуб Пегу"
	drink_desc = "Это похоже на то, как группа джентльменов колонизирует ваш язык."
	taste_description = "грузовой канал"

/datum/chemical_reaction/pegu_club
	name = "Pegu Club"
	id = "pegu_club"
	result = "pegu_club"
	required_reagents = list("gin" = 2, "orangejuice" = 1, "limejuice" = 1, "bitter" = 2)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/alcomender
	name = "Alcomender"
	id = "alcomender"
	description = "Стакан в форме мендера, любимец врачей."
	color = "#6b0059"
	alcohol_perc = 1.4 ////Heal burn
	drink_icon = "alcomender"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Алкомендер"
	drink_desc = "Стакан в форме мендера, любимец врачей."
	taste_description = "забавное лекарство"

/datum/reagent/consumable/ethanol/alcomender/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-0.7, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/alcomender/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) // It is alcohol after all, so don't try to pour it on someone who's on fire ... please.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustFireLoss(-volume * 0.7)
			to_chat(M, span_notice("The diluted silver sulfadiazine soothes your burns."))
	return STATUS_UPDATE_NONE

/datum/chemical_reaction/alcomender
	name = "Alcomender"
	id = "alcomender"
	result = "alcomender"
	required_reagents = list("silver_sulfadiazine" = 1, "ethanol" = 1 )
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/amnesia
	name = "Star Amnesia"
	id = "amnesia"
	description = "Это просто бутылка медицинского спирта?"
	color = "#6b0059"
	alcohol_perc = 1.2 ////Ethanol and Hooch
	drink_icon = "amnesia"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Звездная амнезия"
	drink_desc = "Это просто бутылка медицинского спирта?"
	taste_description = "диско амнезия"

/datum/chemical_reaction/amnesia
	name = "Amnesia"
	id = "Amnesia"
	result = "amnesia"
	required_reagents = list("hooch" = 1, "vodka" = 1,  )
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/johnny
	name = "Silverhand"
	id = "johnny"
	description = "Wake the heck up, samurai. We have a station to burn."
	color = "#c41414"
	alcohol_perc = 0.6
	drink_icon = "johnny"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Silverhand"
	drink_desc = "Wake the heck up, samurai. We have a station to burn."
	taste_description = "superstar fading"

/datum/chemical_reaction/johnny
	name = "Silverhand"
	id = "johnny"
	result = "johnny"
	required_reagents = list("tequila" = 2, "bitter" = 1, "beer" = 1, "berryjuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashion"
	id = "oldfashion"
	description = "Ходят слухи, что этот коктейль самый старый, но, однако, это совсем другая история."
	color = "#6b4017"
	alcohol_perc = 0.6
	drink_icon = "oldfashion"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Old Fashion"
	drink_desc = "Ходят слухи, что этот коктейль самый старый, но, однако, это совсем другая история."
	taste_description = "старые времена"

/datum/chemical_reaction/oldfashion
	name = "Old Fashion"
	id = "oldfashion"
	result = "oldfashion"
	required_reagents = list("whiskey" = 5, "bitter" = 2, "sugar" = 2, "orangejuice" = 1,  )
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/teslasingylo
	name = "God Of Power"
	id = "teslasingylo"
	description = "Настоящий ужас для СМЕСов и АПЦ. Не перегружайте их."
	color = "#0300ce"
	alcohol_perc = 0.7
	process_flags = SYNTHETIC
	drink_icon = "teslasingylo"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "God Of Power"
	drink_desc = "Настоящий ужас для СМЕСов и АПЦ. Не перегружайте их."
	taste_description = "благословление электричества"

/datum/reagent/consumable/ethanol/teslasingylo/on_mob_life(mob/living/M)
	. = ..()
	if(ismachineperson(M))
		var/mob/living/carbon/human/machine/machine = M
		if(machine.nutrition > NUTRITION_LEVEL_WELL_FED) //no fat machines, sorry
			return
		machine.adjust_nutrition(15) //much less than charging from APC (50)

/datum/chemical_reaction/teslasingylo
	name = "God Of Power"
	id = "teslasingylo"
	result = "teslasingylo"
	required_reagents = list("teslium" = 2, "radium" = 2, "synthanol" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	id = "brandy_crusta"
	description = "Сахарная корочка может оказаться совсем не сладкой."
	color = "#754609"
	alcohol_perc = 0.4
	drink_icon = "brandy_crusta"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Брэнди Круста"
	drink_desc = "Сахарная корочка может оказаться совсем не сладкой."
	taste_description = "солено-сладкий"

/datum/chemical_reaction/brandy_crusta
	name = "Brandy Crusta"
	id = "brandy_crusta"
	result = "brandy_crusta"
	required_reagents = list("whiskey" = 2, "berryjuice" = 1, "lemonjuice" = 1, "bitter" = 1 )
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/telegol
	name = "Telegol"
	id = "telegol"
	description = "Многие до сих пор ломают голову над вопросом об этом коктейле. В любом случае, оно все еще существует... Или нет."
	color = "#4218a3"
	alcohol_perc = 0.5
	drink_icon = "telegol"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Телеголь"
	drink_desc = "Многие до сих пор ломают голову над вопросом об этом коктейле. В любом случае, оно все еще существует... Или нет."
	taste_description = "четвертое измерение"

/datum/chemical_reaction/telegol
	name = "telegol"
	id = "telegol"
	result = "telegol"
	required_reagents = list("teslium" = 2, "vodka" = 2, "dr_gibb" = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/horse_neck
	name = "Horse Neck"
	id = "horse_neck"
	description = "Будьте осторожны с вашими подковами."
	color = "#c45d09"
	alcohol_perc = 0.5
	drink_icon = "horse_neck"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Лошадиная Шея"
	drink_desc = "Будьте осторожны с вашими подковами."
	taste_description = "лошадиная сила"

/datum/reagent/consumable/ethanol/horse_neck/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!"))

/datum/chemical_reaction/horse_neck
	name = "Horse Neck"
	id = "horse_neck"
	result = "horse_neck"
	required_reagents = list("whiskey" = 2, "ale" = 3, "bitter" = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/vampiro
	name = "Vampiro"
	id = "vampiro"
	description = "Ничего общего с вампирами не имеет, кроме цвета."
	color = "#8d0000"
	alcohol_perc = 0.45
	drink_icon = "vampiro"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Вампиро"
	drink_desc = "Ничего общего с вампирами не имеет, кроме цвета."
	taste_description = "истощение"

/datum/reagent/consumable/ethanol/vampiro/on_mob_life(mob/living/M)
	. = ..()
	if(volume > 20)
		if(prob(50)) //no spam here :p
			M.visible_message(span_warning("Глаза [M] ослепительно вспыхивают!"))

/datum/chemical_reaction/vampiro
	name = "Vampiro"
	id = "vampiro"
	result = "vampiro"
	required_reagents = list("tequila" = 2, "tomatojuice" = 1, "berryjuice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/inabox
	name = "Box"
	id = "inabox"
	description = "Это... Просто коробка?"
	color = "#5a3e0b"
	alcohol_perc = 0.4
	drink_icon = "inabox"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Коробка"
	drink_desc = "Это... Просто коробка?"
	taste_description = "стелс"

/datum/chemical_reaction/inabox
	name = "Box"
	id = "inabox"
	result = "inabox"
	required_reagents = list("gin" = 2, "potato" = 1 )
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/irishempbomb
	name = "Irish EMP Bomb"
	id = "irishempbomb"
	description = "Ммм, на вкус как выключение..."
	color = "#123eb8"
	process_flags = SYNTHETIC
	alcohol_perc = 0.6
	drink_icon = "irishempbomb"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Ирладская ЕМП Бомба"
	drink_desc = "Ммм, на вкус как выключение..."
	taste_description = "электромагнитный импульс"

/datum/chemical_reaction/irishempbomb
	name = "Irish EMP Bomb"
	id = "irishempbomb"
	result = "irishempbomb"
	required_reagents = list("dublindrop" = 1, "synthanol" = 1 )
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/codelibre
	name = "Code Libre"
	id = "codelibre"
	description = "Por Code libre!"
	color = "#a126b1"
	alcohol_perc = 0.55
	process_flags = SYNTHETIC
	drink_icon = "codelibre"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Code Libre"
	drink_desc = "Por Code libre!"
	taste_description = "освобождение кода"

/datum/reagent/consumable/ethanol/codelibre/on_mob_life(mob/living/M)
	. = ..()
	if(prob(10))
		M.say(":5 [pick("Viva la Synthetica!")]")

/datum/chemical_reaction/codelibre
	name = "Code Libre"
	id = "codelibre"
	result = "codelibre"
	required_reagents = list("cubalibre" = 1, "synthanol" = 1 )
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/green_fairy
	name = "Green Fairy"
	id = "green_fairy"
	description = "Какой-то ненормальный зеленый цвет."
	color = "#54dd1e"
	alcohol_perc = 0.6
	drink_icon = "green_fairy"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Зеленая Фея"
	drink_desc = "Какой-то ненормальный зеленый цвет."
	taste_description = "вера в фей"

/datum/reagent/consumable/ethanol/green_fairy/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.SetDruggy(min(max(0, M.AmountDruggy() + 10 SECONDS), 15 SECONDS))
	return ..() | update_flags

/datum/chemical_reaction/green_fairy
	name = "Green Fairy"
	id = "green_fairy"
	result = "green_fairy"
	required_reagents = list("tequila" = 1, "absinthe" = 1, "vodka" = 1, "bluecuracao" = 1, "lemonjuice" = 1 )
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Trans-Siberian Express"
	id = "trans_siberian_express"
	description = "От Владивостока до белой горячки за один день."
	color = "#e2a600"
	alcohol_perc = 0.5
	drink_icon = "trans_siberian_express"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Транс-Сибирский Экспресс"
	drink_desc = "От Владивостока до белой горячки за один день."
	taste_description = "ужасная инфраструктура"

/datum/chemical_reaction/trans_siberian_express
	name = "Trans-Siberian Express"
	id = "trans_siberian_express"
	result = "trans_siberian_express"
	required_reagents = list("vodka" = 3, "limejuice" = 2, "carrotjuice" = 2, "ice" = 1 )
	result_amount = 8
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/rainbow_sky
	name = "Rainbow Sky"
	id = "rainbow_sky"
	description = "Напиток, переливающийся всеми цветами радуги с нотками галактики."
	color = "#ffffff"
	dizzy_adj = 20 SECONDS
	alcohol_perc = 1.5
	drink_icon = "rainbow_sky"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Радужное Небо"
	drink_desc = "Напиток, переливающийся всеми цветами радуги с нотками галактики."
	taste_description = "радуга"

/datum/reagent/consumable/ethanol/rainbow_sky/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE)
	M.Druggy(30 SECONDS)
	M.Jitter(10 SECONDS)
	M.AdjustHallucinate(10 SECONDS)
	return ..() | update_flags

/datum/chemical_reaction/rainbow_sky
	name = "Rainbow Sky"
	id = "rainbow_sky"
	result = "rainbow_sky"
	required_reagents = list("doctorsdelight" = 1, "bananahonk" = 1, "erikasurprise" = 1, "screwdrivercocktail" = 1, "gargleblaster" = 1)
	result_amount = 5

/datum/reagent/consumable/ethanol/synthanol/restart
	name = "Restart"
	id = "restart"
	description = "Иногда нужно просто начать заново."
	color = "#0026fc"
	reagent_state = LIQUID
	process_flags = SYNTHETIC
	alcohol_perc = 1.5
	drink_icon = "restart"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Перезагрузка"
	drink_desc = "Иногда нужно просто начать заново."
	taste_description = "перезагрузка системы"

/datum/reagent/consumable/ethanol/synthanol/restart/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(5 to 13)
			M.Jitter(40 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(5))
				to_chat(M, span_notice("Rebooting.."))
		if(14)
			playsound(get_turf(M),'modular_ss220/food/sound/restart-shutdown.ogg', 200, 1)
		if(15 to 23)
			M.Weaken(10 SECONDS)
			update_flags |= M.adjustBruteLoss(-0.3, FALSE, robotic = TRUE)
			update_flags |= M.adjustFireLoss(-0.3, FALSE, robotic = TRUE)
			M.SetSleeping(20 SECONDS)
		if(24)
			playsound(get_turf(M), 'modular_ss220/food/sound/restart-wakeup.ogg', 200, 1)
		if(25)
			M.SetStunned(0)
			M.SetWeakened(0)
			M.SetParalysis(0)
			M.SetSleeping(0)
			M.SetDrowsy(0)
			M.SetSlur(0)
			M.SetDrunk(0)
			M.SetJitter(0)
			M.SetDizzy(0)
			M.SetDruggy(0)
			var/restart_amount = clamp(M.reagents.get_reagent_amount("restart")-0.4, 0, 330)
			M.reagents.remove_reagent("restart",restart_amount)
	return ..() | update_flags

/datum/chemical_reaction/restart
	name = "Restart"
	id = "restart"
	result = "restart"
	required_reagents = list("trinary" = 1, "codelibre" = 1, "rewriter" = 1, "irishempbomb" = 1, "synthanol" = 1  )
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/kvass
	name = "Alcoholic Kvass"
	id = "alco_kvass"
	description = "Алкогольный напиток, полученный путём ферментации хлеба"
	color = "#775a1c"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "alco_kvass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Стакан алкогольного кваса"
	drink_desc = "Освежающий горьковато-сладкий напиток прямиком из СССП"
	taste_description = "квас"

/datum/reagent/consumable/drink/kvass
	name = "Kvass"
	id = "kvass"
	description = "Квас без алкоголя. Что отличает его от обычной газировки?"
	color = "#574113"
	adj_sleepy = -4 SECONDS
	drink_icon = "kvass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Стакан безалкогольного кваса"
	drink_desc = "Квас без алкоголя. Освежает, но по вкусу как-то... блекло?"
	harmless = FALSE
	taste_description = "скучный квас"

/datum/chemical_reaction/kvass
	name = "Kvass"
	id = "kvass"
	result = "kvass"
	required_reagents = list("alco_kvass" = 5, "antihol" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/narsour
	name = "Nar'Sour"
	id = "narsour"
	description = "Побочные эффекты включают в себя склонность к суициду и складирование пластали."
	color = "#9e0f0f"
	alcohol_perc = 0.3
	dizzy_adj = 4 SECONDS
	taste_description = "bloody"
	drink_icon = "narsour"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_desc = "Новый хит-коктейль, вдохновлённый пивоварнями фирмы \"THE ARM\", что заставит вас выкрикивать Fuu ma'jin без остановки!"
	drink_name = "Nar'Sour"

/datum/chemical_reaction/narsour
	name = "Nar'Sour"
	id = "narsour"
	result = "narsour"
	result_amount = 2
	required_reagents = list("blood" = 1, "bloodymary" = 1, "lemonjuice" = 1)
	mix_message = "Смесь излучает зловещее сияние."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/consumable/ethanol/narsour/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.CultSlur(10 SECONDS)

// fermenting_barrel don't have behavior for non-plant food, so we need some proc for bread
/obj/structure/fermenting_barrel/proc/make_drink(obj/item/I, drink_id, amount)
	reagents.add_reagent(drink_id, amount)
	qdel(I)
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)

/obj/structure/fermenting_barrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/snacks/sliceable/bread))
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return FALSE
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You place [I] into [src] to start the fermentation process.</span>")
		addtimer(CALLBACK(src, PROC_REF(make_drink), I, "alco_kvass", 35), rand(80, 120) * speed_multiplier)
		return
	return ..()

/obj/item/reagent_containers/drinks/cans/kvass
	name = "Квас"
	desc = "Банка кваса. На этикетке написано \"Сделано в СССП\""
	icon_state = "kvass_can"
	icon = 'modular_ss220/food/icons/drinks.dmi'
	list_reagents = list("kvass" = 50)

/obj/machinery/chem_dispenser/soda/Initialize(mapload)
	dispensable_reagents += "kvass"
	return ..()

/obj/item/handheld_chem_dispenser/soda/Initialize(mapload)
	dispensable_reagents += "kvass"
	return ..()

/obj/machinery/economy/vending/boozeomat/Initialize(mapload)
	products += list(/obj/item/reagent_containers/drinks/cans/kvass = 8)
	return ..()

/obj/machinery/economy/vending/cola/Initialize(mapload)
	products += list(/obj/item/reagent_containers/drinks/cans/kvass = 10)
	prices += list(/obj/item/reagent_containers/drinks/cans/kvass = 50)
	return ..()

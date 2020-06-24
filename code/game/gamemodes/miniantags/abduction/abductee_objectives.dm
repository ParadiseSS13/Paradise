/datum/objective/abductee
	completed = 1

/datum/objective/abductee/steal
	explanation_text = "Украдите"

/datum/objective/abductee/steal/New()
	var/target = pick(list("всех питомцев","все лампочки","всех мартышек","все фрукты","все ботинки","всё мыло", "всё оружие", "все компьютеры", "все органы"))
	explanation_text+=" [target]."

/datum/objective/abductee/paint
	explanation_text = "Эта станция просто ужасна. Вы должны покрасить её"

/datum/objective/abductee/paint/New()
	var/color = pick(list("в красный цвет", "в синий цвет", "в зеленый цвет", "в желтый цвет", "в оранжевый цвет", "в фиолетовый цвет", "в черный цвет", "в цвета радуги", "кровью"))
	explanation_text+= " [color]!"

/datum/objective/abductee/speech
	explanation_text = "Ваш мозг сломан... Вы можете общаться только"

/datum/objective/abductee/speech/New()
	var/style = pick(list("на языке жестов", "стихами", "хокку", "частушками", "длинными метафорами", "загадками", "при помощи чрезвычайно буквальных терминов", "звуками", "военным жаргоном"))
	explanation_text+= " [style]."

/datum/objective/abductee/capture
	explanation_text = "Захватите в плен"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjobs.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title]."
	else
		explanation_text += " кого-нибудь."

/datum/objective/abductee/shuttle
	explanation_text = "Вам нужно сбежать со станции! Вызовите шаттл!"

/datum/objective/abductee/noclone
	explanation_text = "Не позвольте никого клонировать."

/datum/objective/abductee/oxygen
	explanation_text = "Кислород убивает их всех, даже если они этого еще не знают. Удостоверьтесь что бы на станции не было никакого кислорода."

/datum/objective/abductee/blazeit
	explanation_text = "Ваше тело нужно улучшить. Примите столько лекарств, сколько сможете."

/datum/objective/abductee/yumyum
	explanation_text = "Вы голодны. Сьешьте столько еды, сколько сможете найти."

/datum/objective/abductee/insane
	explanation_text = "ты видишь ты видишь что не можешь видеть открытая дверь ты видиШЬ ты ВиДИшЬ тЫ вИДиШЬ ПОКАЖИ ИМ ВСЁ"

/datum/objective/abductee/cannotmove
	explanation_text = "Убедите команду в том, что вы паралитик."

/datum/objective/abductee/deadbodies
	explanation_text = "Создайте коллекцию трупов. Не убивайте людей, что бы их получить."

/datum/objective/abductee/floors
	explanation_text = "Замените всю плитку на ковры, траву, дерево или драгоцености."

/datum/objective/abductee/POWERUNLIMITED
	explanation_text = "Заполните электросеть станции как можно большим количеством электричества."

/datum/objective/abductee/pristine
	explanation_text = "Генеральный директор Нанотрейзен вот-вот приедет! Убедитесь что станция находится в идеальном состоянии."

/datum/objective/abductee/nowalls
	explanation_text = "Экипажу не помешает лучше узнать друг друга. Разрушьте стены внутри станции!"

/datum/objective/abductee/nations
	explanation_text = "Убедитесь, что ваш отдел более успешный, чем остальные."

/datum/objective/abductee/abductception
	explanation_text = "Вас изменили навсегда. Найдите тех, кто это сделал и отплатите им той же монетой."

/datum/objective/abductee/summon
	explanation_text = "Древние боги голодны. Соберите культ и проведите ритуал, что бы вызвать одного из них."

/datum/objective/abductee/machine
	explanation_text = "На самом деле вы андройд под прикрытием. Наберитесь могущества, взаимодействуя с как можно большим количеством машин, что бы ИИ наконец-то признал вас."

/datum/objective/abductee/calling
	explanation_text = "Призовите дух из потустороннего мира."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(GLOB.dead_mob_list)
	if(D)
		explanation_text = "Вы знаете, что [D] больше нет с нами. Проведите спиритический сеанс, что бы вызвать духа из царства мертвых."

/datum/objective/abductee/social_experiment
	explanation_text = "Это секретный социальный эксперемент, проводимый Нанотрейзен. Убедите команду, что это правда."

/datum/objective/abductee/vr
	explanation_text = "Это всё симуляция, проводимая в подземном бункере. Убедите в этом команду и сбросьте с себя оковы виртуальной реальности."

/datum/objective/abductee/pets
	explanation_text = "Нанотрейзен издевается над животными! Спасите как можно больше!"

/datum/objective/abductee/defect
	explanation_text = "Нахуй систему! Дезертируйте со станции и оснуйте независимую колонию в космосе или на шахтерском аванпосте. Наберите сторонников, если можете."

/datum/objective/abductee/promote
	explanation_text = "Поднимитесь по карьерной лестнице до самого верха!"

/datum/objective/abductee/science
	explanation_text = "Столько лжи еще не раскрыто. Нужно вглядеться поглубже в происки вселенной."

/datum/objective/abductee/build
	explanation_text = "Расширьте станцию."

/datum/objective/abductee/pragnant
	explanation_text = "Вы беременны и скоро должны дать жизнь ребенку. Найдите для этого подходящее место."

/datum/objective/abductee/engine
	explanation_text = "Иди и поговори по душам с сингулярностью/теслой/суперматерией. Бонусные очки, если они ответят."

/datum/objective/abductee/music
	explanation_text = "Внутри вас пылает страсть к музыке. Поделитесь этим с другими. Если кто-то ненавидит музыку, бей его по голове своим инструментом!"

/datum/objective/abductee/clown
	explanation_text = "Клоун не смешной. Вы можете лучше! Украдите его аудиторию и заставьте команду смеяться!"

/datum/objective/abductee/party
	explanation_text = "Вы закатывайте огромную вечеринку. Сделайте так, что бы пришла вся команда... А ИНАЧЕ!"

/datum/objective/abductee/pets
	explanation_text = "Все питомцы в округе - полный отстой. Нужно их прокачать. Замените их экзотическими тварями!"

/datum/objective/abductee/conspiracy
	explanation_text = "Руководители этой станции скрывают грандиозный злой заговор. Только вы можете узнать в чем дело и раскрыть его команде!"

/datum/objective/abductee/stalker
	explanation_text = "Синдикат нанял вас, что бы составить досье на всех важных членов команды. Убедитесь, что они не заподозрят вас в этом."

/datum/objective/abductee/narrator
	explanation_text = "Вы рассказчик этой повести. Следуйте за главными героями, что бы поведать их историю."

/datum/objective/abductee/lurve
	explanation_text = "Вы обречены что бы всегда быть несчастным... пока вы не найдете свою истинную любовь на этой станции. Она ждет тебя!"

/datum/objective/abductee/sixthsense
	explanation_text = "Ты умер и попал на небеса... это рай или ад? Кажется, здесь никто не знает, что они мертвы. Убедите их в этом и возможно вы сможете сбежать из этого лимба."

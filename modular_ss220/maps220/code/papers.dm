/obj/item/paper/scp/status_report
	name = "Отчет о состоянии"
	info = "<b><center><I>Сдерживание Аномальных Объектов</I></center></b><br> <b><center>Объект 21</center></b><br> <center>Отчет о состоянии на 11.8.2489 в 8:09 утра по Лавалендскому времени</b><br><br> Ничего необычного. Система сейсмического предупреждения сообщает о скором землетрясении, но Скотт сказал мне, что исправит это к выходным. Нам пришлось перенести некоторые эксперименты на следующую среду из-за поломки оборудования, но ничего серьезного, чтобы беспокоиться. <br><br><br><center>Подпись: Доктор Джеймс Уокер</center>"


/obj/item/paper/scp/seismic_warning
	name = "СЕЙСМИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ"
	info = "ЭТО АВТОМАТИЧЕСКОЕ СООБЩЕНИЕ, ГЕНЕРИРУЕМОЕ СИСТЕМОЙ ПРЕДУПРЕЖДЕНИЯ О СЕЙСМИЧЕСКИХ ЯВЛЕНИЯХ (c). <br><br> К ЮГО-ВОСТОКУ БЫЛИ ЗАФИКСИРОВАНЫ СЛАБЫЕ ТОЛЧКИ. СОГЛАСНО НАШЕМУ ТЕКУЩЕМУ АЛГОРИТМУ, СЕЙСМИЧЕСКАЯ НЕСТАБИЛЬНОСТЬ РАСПРОСТРАНИТСЯ ДО ВАШЕГО ТЕКУЩЕГО МЕСТОПОЛОЖЕНИЯ. <br><br> МЫ ПРОГНОЗИРУЕМ 67,2% ВЕРОЯТНОСТЬ ВОЗНИКНОВЕНИЯ ЗНАЧИТЕЛЬНОГО ЗЕМЛЕТРЯСЕНИЯ В ВАШЕМ ТЕКУЩЕМ МЕСТОПОЛОЖЕНИИ ЧЕРЕЗ 6-12 ЧАСОВ. ПОЖАЛУЙСТА, ДЕЙСТВУЙТЕ В СООТВЕТСТВИИ С ПРОТОКОЛОМ УГРОЗЫ ЗЕМЛЕТРЯСЕНИЯ, КАК УКАЗАНО НА СТРАНИЦЕ 515 РАЗДЕЛА 61-X РУКОВОДСТВА ПО ЭКСПЛУАТАЦИИ ОБЪЕКТА САО."

/obj/item/paper/scp/research_notes
	name = "Заметки об исследованиях: Объекты 15-25"
	info = "<b>AO-15:</b><br><br>Охрана: Высокая <br>Информация: Странное существо, извлеченное из старого шахтерского астероида. Темная кожа, пронзительные красные глаза. Очень агрессивное. Кажется разумным. <br> <br><b>AO-16:</b><br><br>Защита: Средняя <br>Информация: Капюшон и мантия. Красный цвет. Испускает поле темной энергии, которое гравирует все материалы вблизи на нем нерасшифрованные узоры. Предполагается, что он связан с культом <b>УДАЛЕНО</b> <br> <br><b>AO-17:</b><br><br>Охрана: Аполлион <br> Информация: <b>УДАЛЕНО</b> связано с <b>УДАЛЕНО</b>, которое нельзя размещать ни при каких обстоятельствах, включая <b>УДАЛЕНО</b>. <i>Примечание ЦК: Зона 21 отсутствует. Необходимы меры безопасности.Перенос в зону 11-Х запланирован на <b>УДАЛЕНО</b>.<br> <br><i>Несколько абзацев выделены черным маркером...</i> <br> <br> <b>AO-21:</b><br><br>Безопасность: низкая <br>Информация: Глазная железа, извлеченная из АО-6 во время эксперимента EX-56b. Очень агрессивна. После нарушения 91-А субъект был нейтрализован с помощью раствора ядов. Субъекту необходимо вводить раствор каждые полчаса, чтобы поддерживать его в полукоматозном состоянии. Рецепт раствора хранится в архивах Зоны 11-X. <br> <br><i>Остальная часть бумаги покрыта каракулями странных символов, сделанных из засохшей крови.</i>"

/obj/item/paper/caves/pacman
	name = "Напоминание главного техника"
	info = "Стажёрчик, последний, мать твою, раз тебе объясняю. Генератор <b>НАСТРОЕН!!!</b> Ты просто заправляешь его топливом, ждешь пока СМЕС прогреется и <b>ВСЕ!!!</b> Еще раз я увижу как ты ковыряешься в проводке - с треском вылетишь к паукам."

/*Black Mesa*/
//Tapes (Переводик бы. UPD.Че то перевел даже)
/obj/item/tape/black_mesa/first_eas	//First EAS record, the local disaster.
	icon_state = "tape_blue"
	desc = "Старая компакт-кассета. Видимо, использовалась начинающим радиолюбителем."

	used_capacity = 240
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>объявляет, \"<span class=' '>Следующее сообщение передается по запросу местных властей.</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>сообщает, \"<span class=' '>В 9:47 утра по стандартному времени в исследовательском центре Black Mesa произошла катастрофа неизвестного типа, вызвавшая значительный ущерб и сбой в работе различных систем электроснабжения и связи в прилегающих районах.</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>утверждает, \"<span class=' '>Местными властями отдан приказ о немедленной эвакуации всех жителей в радиусе 75 миль от объекта, на место были направлены силы самообороны для оказания помощи.</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>Убедитесь, что при вас имеются аварийный запас еды, воды, одежды, аптечка первой помощи, фонарики с дополнительными батарейками и радиоприемники на батарейках.</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>оповещает, \"<span class=' '>Следуйте местным маршрутам эвакуации, обозначенным местными властями. Используйте только одно транспортное средство.</span>\"</span></span>",
		7 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>предупреждает, \"<span class=' '>НЕ возвращайтесь в карантинную зону, пока властями не будет отданой прямой приказ об обратном.</span>\"</span></span>",
		8 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>сообщает, \"<span class=' '>Если вы не находитесь в зоне эвакуации, оставайтесь на месте.</span>\"</span></span>",
		9 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>сообщает, \"<span class=' '>Если вы находитесь в зоне эвакуации и у вас нет транспорта, проследуйте в ближайшее отделение местного правопорядка.</span>\"</span></span>",
		10 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>сообщает, \"<span class=' '>Не используйте никаких средств связи, за исключением радиоприемника.</span>\"</span></span>",
		11 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>aсообщает, \"<span class=' '>Следите за новостями местных СМИ для получения дополнительной информации о текущей ситуации...</span>\"</span></span>",
		12 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 20,
		3 = 40,
		4 = 80,
		5 = 100,
		6 = 120,
		7 = 140,
		8 = 160,
		9 = 180,
		10 = 200,
		11 = 220,
		12 = 240,
	)

/obj/item/tape/black_mesa/second_eas	//Second EAS record, the local disaster.
	icon_state = "tape_white"
	desc = "Компакт-кассета со следами крови. Видимо, использовалась начинающим радиолюбителем (ныне покойным)."

	used_capacity = 240
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>громко оповещает, \"<span class=' '>Следующее сообщение передается по запросу депортамента экстренных служб сектора Нова.</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>В 9:47 утра по стандартному времени в исследовательском центре Black Mesa произошла катастрофа неизвестного типа, вызвавшая значительный ущерб и сбой в работе различных систем электроснабжения и связи в прилегающих районах.</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>уточняет, \"<span class=' '>Сегодняшнее сообщение заменяет предыдущее, вышедшее вчера в 22:01 по стандартному времени.</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>повторяет, \"<span class=' '>В районе Black Mesa объявлен полный карантин. В интересах общественной безопасности всем жителям сектора Нова, проживающим в радиусе 150 миль от Black Mesa рекомендуется немедленно эвакуироваться.</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>Возьмите с собой только предметы первой необходимости и радиоприемник на батарейках. Не используйте для поездок более одного транспортного средства.</span>\"</span></span>",
		7 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>предупреждает, \"<span class=' '>Следуйте местным маршрутам эвакуации, которые были обозначены властями.</span>\"</span></span>",
		8 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>объявляет, \"<span class=' '>Если вы находитесь в зоне эвакуации и у вас нет транспорта, проследуйте в ближайшее отделение местного правопорядка.</span>\"</span></span>",
		9 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>Если вы отмечаете у себя лихорадку, кашель, тошноту, рвоту, головокружение, мышечные боли, выпадение волос или любые иные недуги... </span>\"</span></span>",
		10 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>громко оповещает, \"<span class=' '>..пожалуйста, немедленно обратитесь в ближайший центр контроля заболеваний, так как эти симптомы могут быть связаны с произошедшей катастрофой	.</span>\"</span></span>",
		11 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>объявляет, \"<span class=' '>Следите за новостями местных СМИ для получения дополнительной информации о текущей ситуации.</span>\"</span></span>",
		12 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 20,
		3 = 40,
		4 = 80,
		5 = 100,
		6 = 120,
		7 = 140,
		8 = 160,
		9 = 180,
		10 = 200,
		11 = 220,
		12 = 240,
	)

/obj/item/tape/black_mesa/third_eas	//Third EAS record, the global disaster.
	icon_state = "tape_purple"
	desc = "Компакт-кассета со следами... странной лозы, прорастающей внутрь. Видимо, использовалась каким то ксеносом."

	used_capacity = 260
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>объявляет, \"<span class=' '>Следующее сообщение передается по запросу Министерства Самообороны планеты Рикс-6. Это не учебная тревога.</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>Сегодня, в 16:16 по стандартному времени, Высший Управитель Рикс-6 объявил чрезвычайное положение.</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>уточняет, \"<span class=' '>Неизвестные враждебно настроенные силы были обнаружены в исследовательском центре Black Mesa, а так же в нескольких соседних секторах, прилегающих к сектору Нова.</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>громко оповещает, \"<span class=' '>По состоянию на 17:42 по стандартному времени, Верховный Управитель издал указ о мобилизации всех наземных сил самообороны...</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>громко оповещает, \"<span class=' '>....и начать немедленные авиаудары по исследовательскому центру Black Mesa и прилегающим секторам, начиная не позднее 18:42 этим вечером.</span>\"</span></span>",
		7 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>предупреждает, \"<span class=' '>Для вашей собственной безопасности был отдан приказ о немедленной эвакуации по всему сектору Нова.</span>\"</span></span>",
		8 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>заявляет, \"<span class=' '>Всем жителям сектора Нова и прилегающих районов, просьба оставить все свои личные вещи. Возьмите с собой радиоприемник на батарейках и только самые необходимые бытовые принадлежности.</span>\"</span></span>",
		9 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>предупреждает, \"<span class=' '>Не оставайтесь в своих домах! Найдите убежище в ближайшей к вам зоне сил самообороны за пределами сектора Нова и ждите дальнейших указаний.</span>\"</span></span>",
		10 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>оповещает, \"<span class=' '>Если вы не можете найти ближайший маршрут эвакуации, немедленно обратитесь за помощью к местным властям.</span>\"</span></span>",
		11 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>echoes, \"<span class=' '>Если у вас имеются навыки военной подготовки, навыки стрельбы из огнестрельного или энергетического оружия - немедленно обратитесь к ближайшему офицеру сил самообороны..</span>\"</span></span>",
		12 = "<span class='game say'><span class='name'>Оповещение EAS</span> <span class='message'>уточняет, \"<span class=' '>Оставайтесь на частоте 740 для получения дополнительной информации.</span>\"</span></span>",
		13 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 20,
		3 = 40,
		4 = 80,
		5 = 100,
		6 = 120,
		7 = 140,
		8 = 160,
		9 = 180,
		10 = 200,
		11 = 220,
		12 = 240,
		13 = 260,
	)

/obj/item/tape/black_mesa/first_hecu	//First HECU record, the "You are abandoned" kinda one; meant to be added to SL so they're, you know, informed. And depressed.
	icon_state = "tape_purple"
	desc = "Свежезаписанная компакт-кассета, еще даже не подписанная."

	used_capacity = 100
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Штаб сил самообороны</span> <span class='message'>спрашивает, \"<span class=' '>Прием, офицер, вы меня слышите? Офицер, вы меня слышите!?</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Штаб сил самообороны</span> <span class='message'>сообщает, \"<span class=' '>Забудьте о ███████! Мы покидаем базу!</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Штаб сил самообороны</span> <span class='message'>сообщает, \"<span class=' '>Мы сокращаем наши потери и уходим! Все, кто остался там, внизу, сейчас предоставлены сами себе!</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Штаб сил самообороны</span> <span class='message'>громко оповещает, \"<span class=' '>Повторяю, если вас еще не эвакуировались, то вы предоставлены сами себе!</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 20,
		3 = 40,
		4 = 60,
		5 = 80,
		6 = 100,
	)

/obj/item/tape/black_mesa/second_hecu	//Second HECU record, for Vanguard to know that there's military nearby.
	icon_state = "tape_red"
	desc = "Относительно свежая компакт-кассета, подписанная как \"радиопередача от XX XX.XX.25XX\". Дата и серийные номера были поцарапаны до неузнаваемости. Как удобно."

	used_capacity = 140
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Эхо-5 Браво</span> <span class='message'>громко сообщает, \"<span class=' '>Любой станции, любой станции, это Эхо-5 Браво! Поблизости есть хоть какие то наземные силы, способные поддержать в 8 районе?</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Эхо-5 Браво</span> <span class='message'>повторно сообщает, \"<span class=' '>Любой станции, любой станции, это Эхо-5 Браво! Поблизости есть хоть какие то наземные силы, способные поддержать в 8 районе? Хоть кто ниубдь слышит нас?!</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Эхо-5 Зетта</span> <span class='message'>заявляет, \"<span class=' '>Это Эхо-5 Зетта! Больше не в состоянии вести боевые действия. Мы сворачиваемся в сторону сектора Дельта!</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Эхо-5 Браво</span> <span class='message'>громко спрашивает, \"<span class=' '>Что, черт возьми, ты несешь?! Нас здесь давят в окружении!!!</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Эхо-5 Зетта</span> <span class='message'>сообщает, \"<span class=' '>Прорывайтесь к ближайшей трассе и ждите указаний, как слышали?!</span>\"</span></span>",
		7 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 20,
		3 = 40,
		4 = 80,
		5 = 100,
		6 = 120,
		7 = 140,
	)

/obj/item/tape/black_mesa/third_hecu	//Third HECU record, because it's  s a d .
	icon_state = "tape_blue"
	desc = "Окровавленная компакт-кассета. Это уже слишком..."

	used_capacity = 120
	storedinfo = list(
		1 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Начало записи.</span>\"</span></span>",
		2 = "<span class='game say'><span class='name'>Эхо-5 Джульетта</span> <span class='message'>громко сообщает, \"<span class=' '>Любой станции, любой станции, это Эхо-5 Джульетта... Мой отряд попал в засаду... Меня ранили... Я здесь истекаю кровью... Левая.. Левая нога.</span>\"</span></span>",
		3 = "<span class='game say'><span class='name'>Эхо-5 Ромео</span> <span class='message'>сообщает, \"<span class=' '>Эхо-5 Джульетта, это Эхо-5 Ромео. Мне нужно что бы ты наложил жгут выше раны, на расстоянии ладони. Живо доставай его из своего ИПП!</span>\"</span></span>",
		4 = "<span class='game say'><span class='name'>Эхо-5 Джульетта</span> <span class='message'>заявляет, \"<span class=' '>ИПП больше нету.</span>\"</span></span>",
		5 = "<span class='game say'><span class='name'>Эхо-5 Ромео</span> <span class='message'>спрашивает, \"<span class=' '>Повтори?</span>\"</span></span>",
		6 = "<span class='game say'><span class='name'>Эхо-5 Джульетта</span> <span class='message'>уточняет, \"<span class=' '>Мой ИПП закончился... Я..эээ... *отчетливый звук падения*</span>\"</span></span>",
		7 = "<span class='game say'><span class='name'>Эхо-5 Ромео</span> <span class='message'>сообщает, \"<span class=' '>Так, тебе срочно нужно найти другой и достать из него жгут. </span>\"</span></span>",
		8 = "<span class='game say'><span class='name'>Эхо-5 Ромео</span> <span class='message'>громко спрашивает, \"<span class=' '>Ты еще на короткой? Эхо-5 Джульетта, ты меня слышишь?!</span>\"</span></span>",
		9 = "<span class='game say'><span class='name'>Универсальный диктофон</span> <span class='message'>воспроизводит, \"<span class='tape_recorder '>Конец записи.</span>\"</span></span>",
	)
	timestamp = list(
		1 = 0,
		2 = 10,
		3 = 30,
		4 = 40,
		5 = 50,
		6 = 70,
		7 = 90,
		8 = 110,
		9 = 120,
	)

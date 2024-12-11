/datum/job/donor/administrator
	title = "Administrator"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_ADMINISTRATOR
	total_positions = 1
	spawn_positions = 1
	ru_title = "Сервис-Администратор"
	alt_titles = list("Сервис-Администратор", "Сервис-Управитель", "Помпадур", "Сервис-Менеджер")
	relate_job = "Bar"
	access = list(ACCESS_THEATRE, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_MINERAL_STOREROOM, ACCESS_JANITOR)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/administrator
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы АДМИНИСТРАТОР. Данная роль нацелена для налаживания работы в Отделе Обслуживания. Наладьте производство, \
	помогите главе персонала пока он занимается бумагами, убедитесь что каждый работник выполняет свою работу и делает это КАЧЕСТВЕННО! \
	А если всё замечательно, значит устройте новое развлечение или событие для экипажа. Довольный экипаж - работоспособный экипаж. \
	\nВы не являетесь заменой главы персонала и подчиняетесь ему напрямую. Вы не являетесь главой сервисного отдела. \
	Вы помощник, ассистент, консультант, наблюдатель, организатор."

/datum/outfit/job/donor/administrator
	name = "Administrator"
	jobtype = /datum/job/donor/administrator

	uniform = /obj/item/clothing/under/rank/procedure/iaa
	suit = /obj/item/clothing/suit/storage/iaa/blackjacket
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/fez
	gloves = /obj/item/clothing/gloves/color/white
	belt = /obj/item/storage/belt/fannypack/black
	glasses = /obj/item/clothing/glasses/regular
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/librarian
	id = /obj/item/card/id/administrator
	backpack_contents = list(
		/obj/item/clothing/under/rank/procedure/iaa/formal/black = 1,
		/obj/item/clothing/under/misc/waiter = 1,
		/obj/item/eftpos = 1,
		/obj/item/clipboard = 1,
		/obj/item/reagent_containers/glass/rag = 1,
	)


/datum/job/donor/tourist_tsf
	title = "Tourist TSF"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_TOURIST_TSF
	ru_title = "Турист ТСФ"
	alt_titles = list("Турист ТСФ", "Посетитель ТСФ")
	relate_job = "Assistant"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/tourist_tsf
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ТУРИСТ ТСФ. Вы прибыли сюда для отдыха и возможно для подработок. На вас по прежнему действует КЗ НТ, не смотря на то \
	что вы являетесь гражданином ТСФ. ТСФ и СССП недоброжелательно относятся друг к другу, но это по прежнему не дает нарушать правила сервера.	\
	"

/datum/outfit/job/donor/tourist_tsf
	name = "Tourist TSF"
	jobtype = /datum/job/donor/tourist_tsf

	uniform = /obj/item/clothing/under/solgov
	suit = /obj/item/clothing/suit/hooded/hoodie/blue
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/soft/solgov/marines
	belt = /obj/item/storage/belt/fannypack/black
	gloves = /obj/item/clothing/gloves/fingerless
	id = /obj/item/card/id/tourist_tsf
	backpack_contents = list(
		/obj/item/clothing/under/pants/shorts/blue  = 1,
	)

/datum/outfit/job/donor/tourist_tsf/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	H.add_language("Tradeband")


/datum/job/donor/tourist_ussp
	title = "Tourist USSP"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_TOURIST_USSP
	ru_title = "Турист СССП"
	alt_titles = list("Турист СССП", "Посетитель СССП")
	relate_job = "Assistant"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/tourist_ussp
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ТУРИСТ СССП. Вы прибыли сюда для отдыха и возможно для подработок. На вас по прежнему действует КЗ НТ, не смотря на то \
	что вы являетесь гражданином СССП. ТСФ и СССП недоброжелательно относятся друг к другу, но это по прежнему не дает нарушать правила сервера. \
	"


/datum/outfit/job/donor/tourist_ussp
	name = "Tourist USSP"
	jobtype = /datum/job/donor/tourist_ussp

	uniform = /obj/item/clothing/under/new_soviet
	suit = /obj/item/clothing/suit/sovietcoat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/sovietsidecap
	belt = /obj/item/storage/belt/fannypack/red
	gloves = /obj/item/clothing/gloves/fingerless
	glasses = /obj/item/clothing/glasses/sunglasses/big
	id = /obj/item/card/id/tourist_ussp
	backpack_contents = list(
		/obj/item/clothing/under/pants/shorts/red = 1,
		/obj/item/clothing/head/ushanka = 1,
	)

/datum/outfit/job/donor/tourist_ussp/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	H.add_language("Neo-Russkiya")


/datum/job/donor/cleaning_manager
	title = "Cleaning Manager"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_MANAGER_JANITOR
	total_positions = 2
	spawn_positions = 2
	ru_title = "Менеджер по Клинингу"
	alt_titles = list("Менеджер по Клинингу", "Ловец Крыс", "Уборщик I-разряда", "Уборщик II-разряда", "Уборщик III-разряда", "Уборщик IV-разряда", "Уборщик V-разряда",
		"Подмастерье", "Ассистент-Механик", "Ассистент I-го разряда", "Ассистент II-го разряда", "Ассистент III-го разряда", "Ассистент IV-го разряда", "Ассистент V-го разряда")
	relate_job = "Janitor"
	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/cleaning_manager
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы Менеджер по Клинингу. Вы уборщик этой станции и должны следить за чистотой на ней. Вы давно на этой работе и снабжены лучшим снаряжением для идеальной работы. \
	Вы тот кто отделяет станцию от хаоса и обеспечивает порядок. Вы - настоящая действующая сила на этой станции."

/datum/outfit/job/donor/cleaning_manager
	name = "Cleaning Manager"
	jobtype = /datum/job/donor/cleaning_manager

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	suit = /obj/item/clothing/suit/apron/overalls
	shoes = /obj/item/clothing/shoes/galoshes/dry/lightweight
	gloves = /obj/item/clothing/gloves/color/purple
	mask = /obj/item/clothing/mask/bandana/purple
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor/full/donor
	r_pocket = /obj/item/door_remote/janikeyring
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/janitor
	id = /obj/item/card/id/cleaning_manager
	backpack_contents = list(
		/obj/item/clothing/head/beret/purple_normal = 1,
		/obj/item/clothing/suit/storage/iaa/purplejacket = 1,
		/obj/item/clipboard = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
	)


/datum/outfit/job/donor/cleaning_manager/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Подмастерье", "Ассистент-Механик", "Ассистент I-го разряда", "Ассистент II-го разряда", "Ассистент III-го разряда", "Ассистент IV-го разряда", "Ассистент V-го разряда")
				uniform = /obj/item/clothing/under/color/grey
				suit = /obj/item/clothing/suit/apron/overalls
				back = /obj/item/storage/backpack
				shoes = /obj/item/clothing/shoes/workboots
				mask = /obj/item/clothing/mask/gas
				head = /obj/item/clothing/head/soft
				belt = /obj/item/storage/belt/fannypack/white
				gloves = /obj/item/clothing/gloves/color/grey
				l_hand = /obj/item/storage/toolbox/mechanical
				r_hand = /obj/item/flag/grey
				id = /obj/item/card/id/apprentice
				backpack_contents = list(
					/obj/item/clothing/head/welding = 1,
					/obj/item/flashlight = 1,
					/obj/item/clothing/under/pants/shorts/grey = 1,
					/obj/item/clothing/under/misc/assistantformal = 1,
				)
/*
/datum/job/donor/apprentice
	title = "Apprentice"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_APPRENTICE
	total_positions = 3
	spawn_positions = 3
	ru_title = "Подмастерье"
	alt_titles = list("Подмастерье", "Ассистент-Механик", "Ассистент I-го разряда", "Ассистент II-го разряда", "Ассистент III-го разряда", "Ассистент IV-го разряда", "Ассистент V-го разряда")
	relate_job = "Assistant"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/apprentice
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ПОДМАСТЕРЬЕ. Вы ассистент с полномочиями для работы на станции. Построить свою мастерскую или заняться другим полезным для станции и вас делом - ваша стезя. \
	Но серые комбинезоны и тулбоксы так и манят вас..."

*/
/datum/outfit/job/donor/apprentice
	name = "Apprentice"
	//jobtype = /datum/job/donor/apprentice

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/apron/overalls
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/workboots
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/soft
	belt = /obj/item/storage/belt/fannypack/white
	gloves = /obj/item/clothing/gloves/color/grey
	l_hand = /obj/item/storage/toolbox/mechanical
	r_hand = /obj/item/flag/grey
	id = /obj/item/card/id/apprentice
	backpack_contents = list(
		/obj/item/clothing/head/welding = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/under/pants/shorts/grey = 1,
		/obj/item/clothing/under/misc/assistantformal = 1,
	)

/datum/job/donor/guard
	title = "Guard"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_GUARD
	total_positions = 1
	spawn_positions = 1
	ru_title = "Охранник"
	alt_titles = list("Охранник", "Сторож Сервиса", "Охранник Сервиса", "Вышибала Сервиса")
	relate_job = "Bar"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LIBRARY)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/guard
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ОХРАННИК. Данная роль нацелена на обеспечение порядка в баре и на кухне. Вы то что отдаляет кухню от хаоса и пьяных ассистентов. \
	Вы уполномочены вышвыривать из бара каждого, кто нарушает порядок. \
	\nВы НЕ являетесь службой безопасности, данная роль не дает вам полномочия охотиться за антагонистами."

/datum/outfit/job/donor/guard
	name = "Guard"
	jobtype = /datum/job/donor/guard

	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest/old	// с замедлением
	belt = /obj/item/melee/classic_baton
	shoes = /obj/item/clothing/shoes/jackboots/noisy
	head = /obj/item/clothing/head/bowlerhat
	glasses = /obj/item/clothing/glasses/sunglasses/big
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/bar
	id = /obj/item/card/id/guard
	backpack_contents = list(
		/obj/item/clothing/suit/jacket/leather = 1,
		/obj/item/reagent_containers/spray/pepper = 1,
		)


/datum/job/donor/migrant
	title = "Migrant"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_MIGRANT
	ru_title = "Мигрант"
	alt_titles = list("Мигрант")
	relate_job = "Assistant"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/migrant
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы МИГРАНТ. Сами вы прибыли на эту станцию или так вынудили обстоятельства, но вы теперь тут. \
	Присмотритесь к этой корпорации. Возможно здесь вы захотите жить и работать?"

/datum/outfit/job/donor/migrant
	name = "Migrant"
	jobtype = /datum/job/donor/migrant

	uniform = /obj/item/clothing/under/costume/pirate_rags
	suit = /obj/item/clothing/suit/poncho
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/sombrero
	mask = /obj/item/clothing/mask/fakemoustache
	belt = /obj/item/storage/belt/fannypack/orange
	id = /obj/item/card/id/migrant
	backpack_contents = list(
		/obj/item/reagent_containers/drinks/bottle/tequila = 1,
		/obj/item/food/taco = 6,
		/obj/item/food/nachos = 3,
		/obj/item/food/cheesenachos = 3,
		/obj/item/food/cubannachos = 3,
		/obj/item/clothing/suit/poncho/red = 1,
		/obj/item/clothing/suit/poncho/green = 1,
		)


/datum/job/donor/uncertain
	title = "Uncertain"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_UNCERTAIN
	ru_title = "Безработный"
	alt_titles = list("Безработный", "Безработный Ассистент", "Свободный Ассистент", "Отрабатыващий Ассистент", "Ассистент Технических Тоннелей")
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION)
	selection_color = "#63979a"
	hidden_from_job_prefs = FALSE
	donator_tier = 3
	outfit = /datum/outfit/job/donor/uncertain
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы БЕЗРАБОТНЫЙ. Данная роль нацелена на бездумное брождение по техническим тоннелям. Вас когда-то оставили без работы, \
	возможно эвакуационный шаттл улетел без вас, возможно технологии заменили вашу работу, причины могут быть разные. \
	Но суть всего этого одна - вы были брошены и занимаетесь собственным выживанием."

/datum/outfit/job/donor/uncertain
	name = "Uncertain"
	jobtype = /datum/job/donor/uncertain

	uniform = /obj/item/clothing/under/costume/kilt
	suit = /obj/item/clothing/suit/unathi/mantle
	shoes = /obj/item/clothing/shoes/footwraps
	head = /obj/item/clothing/head/beanie/yellow
	glasses = /obj/item/clothing/glasses/eyepatch
	belt = /obj/item/storage/belt/fannypack/black
	mask = /obj/item/clothing/mask/cigarette/pipe/cobpipe
	pda = /obj/item/pda/librarian
	id = /obj/item/card/id/uncertain
	backpack_contents = list(
		/obj/item/reagent_containers/drinks/bottle/vodka = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 2,
		/obj/item/food/fancy/doshik = 3,
		/obj/item/food/fancy/doshik_spicy = 3,
		/obj/item/clothing/suit/mantle/old = 1,
		/obj/item/clothing/head/flatcap = 1,
		/obj/item/clothing/suit/browntrenchcoat = 1,
		/obj/item/clothing/accessory/horrible = 1,
		/obj/item/clothing/under/costume/pirate_rags = 1,
		/obj/item/clothing/head/cowboyhat = 1,
		/obj/item/clothing/shoes/sandal = 1,
		)

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	dufflebag = /obj/item/storage/backpack/duffel

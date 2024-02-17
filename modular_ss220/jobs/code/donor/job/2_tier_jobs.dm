/datum/job/donor/barber
	title = "Barber"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_BARBER
	total_positions = 1
	spawn_positions = 1
	ru_title = "Парикмахер"
	alt_titles = list("Парикмахер", "Стилист", "Хозяин Студии Красоты", "Визажист", "Куафёр", "Цирюльник", "Брадобрей")
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/barber
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ПАРИКМАХЕР. Данная роль нацелена для наведения красоты на головах людей через добровольные начинания."

/datum/outfit/job/donor/barber
	name = "Barber"
	jobtype = /datum/job/donor/barber

	uniform = /obj/item/clothing/under/rank/civilian/barber
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/boaterhat
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/barber
	backpack_contents = list(
		/obj/item/storage/box/barber = 1,
	)


/datum/job/donor/bath
	title = "Bath"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_BATH
	total_positions = 1
	spawn_positions = 1
	ru_title = "Банщик"
	alt_titles = list("Банщик", "Хозяин Бани", "Парильщик", "Пармейстер")
	relate_job = "Bath"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/bath
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы БАНЩИК. Данная роль нацелена для создания душной атмосферы в замкнутых помещениях, РП-разговоров, встреч."

/datum/outfit/job/donor/bath
	name = "Bath"
	jobtype = /datum/job/donor/bath

	uniform = /obj/item/clothing/under/costume/pirate_rags
	suit = /obj/item/clothing/suit/mantle
	shoes = /obj/item/clothing/shoes/sandal
	glasses = /obj/item/clothing/glasses/goggles
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/bath
	backpack_contents = list(
		/obj/item/clothing/under/pants/white = 5,
		/obj/item/clothing/head/beanie = 1,
		/obj/item/clothing/head/beanie/black = 1,
		/obj/item/clothing/head/beanie/red = 1,
		/obj/item/clothing/head/beanie/green = 1,
		/obj/item/clothing/head/beanie/darkblue = 1,
		/obj/item/clothing/head/beanie/purple = 1,
		/obj/item/clothing/head/beanie/yellow = 1,
		/obj/item/clothing/head/beanie/cyan = 1,
		/obj/item/clothing/head/beanie/orange = 5,
	)


/datum/job/donor/casino
	title = "Casino"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_CASINO
	total_positions = 3
	spawn_positions = 3
	ru_title = "Крупье"
	relate_job = "Bar"
	alt_titles = list("Крупье", "Дилер", "Слот-Ассистент", "Пит-Босс", )
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_HYDROPONICS, ACCESS_BAR)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/casino
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы КРУПЬЕ. Данная роль нацелена на отыгрыш работника казино. Раздача карт, азарт - всё это ваша стезя. Организуйте свое лучшее казино."

/datum/outfit/job/donor/casino
	name = "Casino"
	jobtype = /datum/job/donor/casino

	uniform = /obj/item/clothing/under/rank/procedure/iaa/purple
	suit = /obj/item/clothing/suit/storage/iaa/purplejacket
	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/storage/belt/fannypack/purple
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/bar
	id = /obj/item/card/id/casino
	backpack_contents = list(
		/obj/item/storage/bag/money = 1,
		/obj/item/coin/twoheaded = 1,
		/obj/item/coin/gold = 2,
		/obj/item/coin/silver = 4,
		/obj/item/coin/iron = 8,
		/obj/item/eftpos = 1,
	)

/datum/job/donor/waiter
	title = "Waiter"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_WAITER
	total_positions = 2
	spawn_positions = 2
	ru_title = "Официант"
	relate_job = "Bar"
	alt_titles = list("Официант", "Хост Сервиса")
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/waiter
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ОФИЦИАНТ. Данная роль нацелена на принеси-подай-иди-не мешай. Обеспечьте атмосферу настоящего ресторана."

/datum/outfit/job/donor/waiter
	name = "Waiter"
	jobtype = /datum/job/donor/waiter

	uniform = /obj/item/clothing/under/misc/waiter
	suit = /obj/item/clothing/suit/storage/iaa/blackjacket
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/fez
	belt = /obj/item/storage/belt/fannypack/blue
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chef
	id = /obj/item/card/id/waiter
	backpack_contents = list(
		/obj/item/eftpos = 1,
		/obj/item/clipboard = 1,
		/obj/item/reagent_containers/glass/rag = 1,
	)


/datum/job/donor/acolyte
	title = "Acolyte"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_ACOLYTE
	total_positions = 5
	spawn_positions = 5
	ru_title = "Послушник"
	alt_titles = list("Послушник", "Монах", "Приспешник", "Последователь", "Обрядчик")
	relate_job = "Chaplain"
	access = list(ACCESS_CHAPEL_OFFICE, ACCESS_MAINT_TUNNELS)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/acolyte
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ПОСЛУШНИК. Данная роль нацелена на богослужение и помощь священнику. Несите слово священника, он ваш пастырь. \
	Вы не обладаете такими же способностями как священник, вы не можете освящать воду, но вы можете помочь тому, кто наделен этим даром!"

/datum/outfit/job/donor/acolyte
	name = "Acolyte"
	jobtype = /datum/job/donor/acolyte

	uniform = /obj/item/clothing/under/suit/victsuit
	suit = /obj/item/clothing/suit/hooded/monk
	shoes = /obj/item/clothing/shoes/sandal
	r_hand = /obj/item/storage/bag/garment/chaplain
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chaplain
	id = /obj/item/card/id/acolyte

/*
/datum/job/donor/deliverer
	title = "Deliverer"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_DELIVERER
	total_positions = 1
	spawn_positions = 1
	ru_title = "Доставщик"
	alt_titles = list("Доставщик", "Почтальон", "Переносчик")
	relate_job = "Cargo Technician"
	supervisors = "главой персонала и квартирмейстером"
	department_head = list("Head of Personnel", "Quartermaster")
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINT, ACCESS_MINERAL_STOREROOM)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/deliverer
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ДОСТАВЩИК. Данная роль нацелена на доставку товаров от одного отдела до другого. Ваше призвание - доставлять ресурсы от отдела до отдела или еду от самого ШЕФа."
*/
/datum/outfit/job/donor/deliverer
	name = "Deliverer"
	//jobtype = /datum/job/donor/deliverer

	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/soft
	r_hand = /obj/item/mail_scanner
	belt = /obj/item/storage/belt/fannypack/orange
	r_pocket = /obj/item/storage/bag/mail
	l_ear = /obj/item/radio/headset/headset_service
	r_ear = /obj/item/radio/headset/headset_cargo
	pda = /obj/item/pda/cargo
	id = /obj/item/card/id/courier
	backpack_contents = list(
		/obj/item/eftpos = 1,
		/obj/item/clipboard = 1,
		/obj/item/reagent_containers/spray/pepper = 1,
		/obj/item/reagent_containers/spray/pestspray = 1,
		/obj/item/reagent_containers/spray/plantbgone = 1,
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering


/datum/outfit/job/donor/deliverer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Почтальон")
				uniform = /obj/item/clothing/under/misc/mailman
				shoes = /obj/item/clothing/shoes/laceup
				head = /obj/item/clothing/head/mailman
			if("Доставщик")
				uniform = /obj/item/clothing/under/rank/cargo/deliveryboy
				head = /obj/item/clothing/head/soft/deliverysoft


/datum/job/donor/wrestler
	title = "Wrestler"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_BOXER
	total_positions = 4
	spawn_positions = 4
	ru_title = "Борец"
	alt_titles = list("Борец", "Рефери", "Тренер", "Боксёр", "Спортсмен")
	relate_job = "Art"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_RC_ANNOUNCE)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/wrestler
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы БОРЕЦ. Данная роль нацелена на дружественные соревнования. Найдите этот дух соревнования среди экипажа и обеспечьте зрелища!"

/datum/outfit/job/donor/wrestler
	name = "Wrestler"
	jobtype = /datum/job/donor/wrestler

	uniform = /obj/item/clothing/under/pants/classicjeans
	suit = /obj/item/clothing/suit/hooded/hoodie/blue
	shoes = /obj/item/clothing/shoes/sandal
	belt = /obj/item/storage/belt/fannypack/blue
	gloves = /obj/item/clothing/gloves/fingerless
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/librarian
	id = /obj/item/card/id/wrestler
	backpack_contents = list(
		/obj/item/clothing/gloves/boxing = 1,
		/obj/item/clothing/gloves/boxing/green = 1,
		/obj/item/clothing/gloves/boxing/blue = 1,
		/obj/item/clothing/gloves/boxing/yellow = 1,
		/obj/item/clothing/mask/luchador = 1,
		/obj/item/clothing/mask/luchador/tecnicos = 1,
		/obj/item/clothing/mask/luchador/rudos = 1,
		/obj/item/clothing/under/pants/shorts/red = 1,
		/obj/item/clothing/under/pants/shorts/green = 1,
		/obj/item/clothing/under/pants/shorts/blue = 1,
		/obj/item/clothing/under/pants/shorts/black = 1,
		/obj/item/clothing/under/pants/shorts/grey = 1,
		/obj/item/storage/belt/fannypack/blue = 1,
		/obj/item/storage/belt/fannypack/red = 1,
	)

/*
/datum/job/donor/painter
	title = "Painter"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_PAINTER
	total_positions = 1
	spawn_positions = 1
	ru_title = "Художник"
	alt_titles = list("Художник", "Творец", "Искусствовед", "Пейзажист", "Фотореалист", "Перфоманс-Артист")
	relate_job = "Art"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/painter
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ХУДОЖНИК. Данная роль нацелена на демонстрацию вашей тонкой натуры. Найдите себе красильщик полов, создайте искусство! \
	Возможно вы захотите наложить инсталляцию посреди мостика?"
*/

/datum/outfit/job/donor/painter
	name = "Painter"
	//jobtype = /datum/job/donor/painter

	uniform = /obj/item/clothing/under/misc/sl_suit
	suit = /obj/item/clothing/suit/apron
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/beret/white
	glasses = /obj/item/clothing/glasses/regular/hipster
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/painter
	backpack_contents = list(
		/obj/item/stack/cable_coil/random = 1,
		/obj/item/camera = 1,
		/obj/item/camera_film = 2,
		/obj/item/storage/photo_album = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/stack/tape_roll = 1,
		/obj/item/paper = 4,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/pen/fancy = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/painter = 1,
	)

/datum/job/donor/musican
	title = "Musician"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_MUSICIAN
	total_positions = 1
	spawn_positions = 1
	ru_title = "Музыкант"
	alt_titles = list("Музыкант", "Маэстро", "Гитарист", "Барабанщик", "Пианист", "Волынщик", "Скрипач", "Скоморох", "Саксофонист", "Солист", "Певец", "Гастролер")
	relate_job = "Art"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/musican
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы МУЗЫКАНТ. Данная роль нацелена на создание музыкальной атмосферы. Приласкайте уши экипажа."

/datum/outfit/job/donor/musican
	name = "Musician"
	jobtype = /datum/job/donor/musican

	uniform = /obj/item/clothing/under/costume/singerb
	shoes = /obj/item/clothing/shoes/singerb
	gloves = /obj/item/clothing/gloves/color/white
	l_ear = /obj/item/radio/headset/headset_service
	r_ear = /obj/item/clothing/ears/headphones
	glasses = /obj/item/clothing/glasses/regular/hipster
	id = /obj/item/card/id/musican
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/instrument/violin = 1,
		/obj/item/instrument/piano_synth = 1,
		/obj/item/instrument/guitar = 1,
		/obj/item/instrument/eguitar = 1,
		/obj/item/instrument/accordion = 1,
		/obj/item/instrument/saxophone = 1,
		/obj/item/instrument/trombone = 1,
		/obj/item/instrument/harmonica = 1
	)


/datum/job/donor/actor
	title = "Actor"
	department_flag = JOBCAT_MEDSCI
	flag = JOB_ACTOR
	total_positions = 5
	spawn_positions = 5
	ru_title = "Актер"
	alt_titles = list("Актер", "Артист", "Стендапер", "Комедиант", "Эстрадный Артист", "Художник", "Творец", "Искусствовед", "Пейзажист", "Фотореалист", "Перфоманс-Артист")
	relate_job = "Art"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	selection_color = "#558758"
	hidden_from_job_prefs = FALSE
	donator_tier = 2
	outfit = /datum/outfit/job/donor/actor
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы АКТЕР. Данная роль нацелена на ваше актерское мастерство. Сами вы им стали или ваши родители вас на это натолкнули, \
	но вы связаны со сценой. Устройте шоу, пригласите гостей! Попробуйте устроить совместное представление с другими актерами, клоуном и мимом."

/datum/outfit/job/donor/actor
	name = "Actor"
	jobtype = /datum/job/donor/actor

	uniform = /obj/item/clothing/under/rank/procedure/lawyer/red
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowlerhat
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/actor
	backpack_contents = list(
		/obj/item/clothing/under/rank/procedure/iaa/purple = 1,
		/obj/item/clothing/suit/storage/iaa/purplejacket = 1,
		/obj/item/clothing/under/suit/really_black = 1,
		/obj/item/clothing/under/costume/cuban_suit = 1,
		/obj/item/clothing/head/cuban_hat = 1,
	)

/datum/outfit/job/donor/actor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/procedure/lawyer/red/skirt

	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Артист")
				uniform = /obj/item/clothing/under/suit/victsuit/red
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/dress/victdress/red
					suit = /obj/item/clothing/suit/victcoat/red
			if("Комедиант")
				uniform = /obj/item/clothing/under/costume/jester
				head = /obj/item/clothing/head/jester
			if("Эстрадный Артист")
				uniform = /obj/item/clothing/under/suit/victsuit/redblk
				suit = /obj/item/clothing/suit/draculacoat
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/dress/redeveninggown

			if("Художник", "Творец", "Искусствовед", "Пейзажист", "Фотореалист", "Перфоманс-Артист")
				uniform = /obj/item/clothing/under/misc/sl_suit
				suit = /obj/item/clothing/suit/apron
				shoes = /obj/item/clothing/shoes/white
				head = /obj/item/clothing/head/beret/white
				glasses = /obj/item/clothing/glasses/regular/hipster
				l_ear = /obj/item/radio/headset/headset_service
				id = /obj/item/card/id/painter
				backpack_contents = list(
					/obj/item/stack/cable_coil/random = 1,
					/obj/item/camera = 1,
					/obj/item/camera_film = 2,
					/obj/item/storage/photo_album = 1,
					/obj/item/hand_labeler = 1,
					/obj/item/stack/tape_roll = 1,
					/obj/item/paper = 4,
					/obj/item/storage/fancy/crayons = 1,
					/obj/item/pen/fancy = 1,
					/obj/item/toy/crayon/rainbow = 1,
					/obj/item/painter = 1,
				)

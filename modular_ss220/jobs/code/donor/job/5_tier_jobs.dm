/datum/job/donor/vip_guest
	title = "VIP Corporate Guest"
	department_flag = JOBCAT_ENGSEC
	flag = JOB_VIP_GUEST
	ru_title = "VIP Гость"
	alt_titles = list("VIP Гость", "VIP Персона", "VIP Гость NT", "VIP Персона NT", "Гость Корпорации NT")
	relate_job = "Vip"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_EVA)
	selection_color = "#9d679d"
	hidden_from_job_prefs = FALSE
	donator_tier = 5
	outfit = /datum/outfit/job/donor/vip_guest
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ВИП ПЕРСОНА. Данная роль нацелена на ваше пребывания на станции в качестве особого гостя. К вам особое отношение, \
	вы являетесь одним из любимцев корпорации Нанотрейзен. Чем вы занимаетесь? А какая разница. Вы очень важная персона."

/datum/outfit/job/donor/vip_guest
	name = "VIP Corporate Guest"
	jobtype = /datum/job/donor/vip_guest

	uniform = /obj/item/clothing/under/suit/really_black
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/that
	l_hand = /obj/item/cane
	l_pocket = /obj/item/melee/classic_baton/telescopic
	box = /obj/item/storage/box/engineer
	id = /obj/item/card/id/vip_guest
	backpack_contents = list(
		/obj/item/stack/spacecash/c1000 = 2,
		/obj/item/bio_chip_implanter/death_alarm = 1,
		/obj/item/lighter/zippo/engraved = 1,
		/obj/item/clothing/mask/cigarette/cigar/havana = 6,
	)

	bio_chips = list(/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/death_alarm
	)


/datum/job/donor/banker
	title = "Banker"
	department_flag = JOBCAT_ENGSEC
	flag = JOB_BANKER
	total_positions = 2
	spawn_positions = 2
	ru_title = "Банкир"
	alt_titles = list("Банкир", "Независимый Банкир", "Корпорат", "Бизнесмен", "Банкир NT", "Корпорат NT", "Бизнесмен NT")
	relate_job = "Vip"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_EVA)
	selection_color = "#9d679d"
	hidden_from_job_prefs = FALSE
	donator_tier = 5
	outfit = /datum/outfit/job/donor/banker
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы БАНКИР. Вы крайне богаты и нацелены открыть здесь свое дело. Банк, мастерские, возможно нанять собственных работников. \
	Корпорация Нанотрейзен не против, ведь вы приносите для неё деньги. Так за работу!"

/datum/outfit/job/donor/banker
	name = "Banker"
	jobtype = /datum/job/donor/banker

	uniform = /obj/item/clothing/under/suit/really_black
	suit = /obj/item/clothing/suit/victcoat
	glasses = /obj/item/clothing/glasses/monocle
	mask = /obj/item/clothing/mask/cigarette/pipe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/fedora
	l_hand = /obj/item/cane
	l_pocket = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/radio/headset/headset_service
	box = /obj/item/storage/box/engineer
	id = /obj/item/card/id/banker
	backpack_contents = list(
		/obj/item/stack/spacecash/c1000 = 5,

		/obj/item/bio_chip_implanter/death_alarm = 1,
		/obj/item/lighter/zippo/engraved = 1,
		/obj/item/clothing/under/rank/procedure/lawyer/black = 1,
		/obj/item/clothing/mask/cigarette/cigar/havana = 6,
	)

	bio_chips = list(/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/death_alarm
	)


/datum/job/donor/seclown
	title = "Security Clown"
	department_flag = JOBCAT_ENGSEC
	flag = JOB_SECURITY_CLOWN
	total_positions = 1
	spawn_positions = 1
	ru_title = "Клоун Службы Безопасности"
	alt_titles = list("Клоун Службы Безопасности", "Клоун-Детектив", "Клоун-Смотритель", "Хонкектив", "Клоун Кадет")
	relate_job = "Security Officer"
	supervisors = "главой службы безопасности"
	department_head = list("Head of Security")
	job_department_flags = DEP_FLAG_SECURITY
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT)
	selection_color = "#9d679d"
	hidden_from_job_prefs = FALSE
	donator_tier = 5
	outfit = /datum/outfit/job/donor/seclown
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы КЛОУН СЛУЖБЫ БЕЗОПАСНОСТИ. Данная роль нацелена на обеспечения сотрудников службы безопасности ментальным здоровьем и \
	поддерживать моральный облик вашего отдела. Вы не имеете права выступать против вашего отдела, ведь вас тренировали для этого. \
	Корпорация NT вложило много денег чтобы сделать из клоуна... вас. Так не подведите её. Вы то, что можно назвать корпоративным клоуном. \
	Ваша душа принадлежит NT, но ваше сердце по прежнему верно Хонкомаме. \
	\nВ вас присутствует ген клоуна. Не занимайтесь охотой антагонистов если есть действующие сотрудники службы безопасности. \
	Вы не являетесь офицером. Вы по прежнему клоун с полномочиями и гигантскими обязанностями. Это непростая роль, ведь вы из-за своего положения \
	не можете творить множество вещей и действий нарушающие Космический Закон."

/datum/outfit/job/donor/seclown
	name = "Security Clown"
	jobtype = /datum/job/donor/seclown

	uniform = /obj/item/clothing/under/rank/security/officer/clown
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/clown_shoes
	head = /obj/item/clothing/head/helmet
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/color/red
	l_pocket = /obj/item/bikehorn
	suit_store = /obj/item/gun/energy/clown/security
	l_ear = /obj/item/radio/headset/headset_service
	r_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	pda = /obj/item/pda/clown
	id = /obj/item/card/id/seclown
	backpack_contents = list(
		/obj/item/food/snacks/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/drinks/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/flash = 1,
		/obj/item/restraints/handcuffs/toy = 1,
	)

	bio_chips = list(/obj/item/bio_chip/sad_trombone, /obj/item/bio_chip/mindshield)

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	dufflebag = /obj/item/storage/backpack/duffel/clown

/datum/outfit/job/donor/seclown/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(!H.mind)
		return
	if(H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Клоун-Детектив", "Хонкектив")
				suit = /obj/item/clothing/suit/storage/det_suit
				head = /obj/item/clothing/head/det_hat
			if("Клоун-Смотритель")
				suit = /obj/item/clothing/suit/armor/vest/warden
				head = /obj/item/clothing/head/officer
				suit_store = /obj/item/gun/energy/clown/security/warden
			if("Клоун Кадет")
				head = /obj/item/clothing/head/soft/sec

/datum/outfit/job/donor/seclown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(ismachineperson(H))
		var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant = new
		implant.insert(H)

	H.dna.SetSEState(GLOB.clumsyblock, TRUE)
	singlemutcheck(H, GLOB.clumsyblock, MUTCHK_FORCED)
	H.dna.default_blocks.Add(GLOB.clumsyblock)
	if(!ismachineperson(H))
		H.dna.SetSEState(GLOB.comicblock, TRUE)
		singlemutcheck(H, GLOB.comicblock, MUTCHK_FORCED)
		H.dna.default_blocks.Add(GLOB.comicblock)
	H.check_mutations = TRUE
	H.add_language("Clownish")
	H.AddComponent(/datum/component/slippery, H, 8 SECONDS, 100, 0, FALSE, TRUE, "slip", TRUE)

	var/clown_name = pick(GLOB.clown_names)
	var/newname = clean_input("Выберите имя для вашего Клоуна Службы Безопасности.", "Изменение Имени", clown_name, H)
	if(newname)
		H.rename_character(H.real_name, newname)
	else
		H.rename_character(H.real_name, clown_name)


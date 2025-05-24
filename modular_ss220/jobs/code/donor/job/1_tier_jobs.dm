/datum/job/donor/prisoner
	title = "Prisoner"
	department_flag = JOBCAT_SUPPORT
	flag = JOB_PRISON
	total_positions = 5
	spawn_positions = 3
	ru_title = "Заключенный"
	alt_titles = list("Заключенный", "Уголовник", "Законопреступник", "Пермазаключенный", "Нелегальный Мигрант", "Нелегальный Работник",
		"Пожизненно-Заключенный", "Политический Заключенный", "Заключенный Преступник", "Заключенный Бандит", "Заключенный Мошенник",
		"Заключенный Вор", "Заключенный Убийца", "Заключенный Наркоторговец", "Заключенный Рецидивист", "Заключенный Саботер",
		"Заключенный Мучитель", "Заключенный Жулик", "Заключенный Негодяй", "Заключенный Хулиган", "Заключенный Враг-NT",
		"Заключенный Мафиози", "Заключенный Коррупционер", "Заключенный Психопат", "Заключенный Фальшивокредитчик",
		"Заключенный Работорговец",
		)
	important_information = "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера. \
	\nВы ЗАКЛЮЧЕННЫЙ. Вы не являетесь антагонистом на сервере и данная роль не позволяет вам нарушать правила сервера. \
	Вы находитесь на временном содержании в бриге станции принадлежащей Нанотрейзен за преступление против корпорации и теперь отбываете свой срок. \
	Вы заинтересованы в том чтобы попасть на волю за хорошее поведение, но если выдастся случай для побега - вам никто не запретит этим воспользоваться, верно? \
	Избегайте любых действий которые могут привести к вашей гибели. Вы не служите Синдикату и не заинтересованы помогать им, если не являетесь антагонистом, но если они помогут вам - то почему бы и да."
	supervisors = "смотрителем"
	department_head = list("Warden")
	selection_color = "#bb7a41"
	hidden_from_job_prefs = FALSE
	donator_tier = 1
	outfit = /datum/outfit/job/donor/prisoner

/datum/outfit/job/donor/prisoner
	name = "Prisoner"
	jobtype = /datum/job/donor/prisoner

	uniform = /obj/item/clothing/under/color/orange/prison
	shoes = /obj/item/clothing/shoes/orange
	id = /obj/item/card/id/prisoner
	pda = null
	box = null
	backpack = null
	satchel = null
	dufflebag = null

/datum/outfit/job/donor/prisoner/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(prob(20))
		uniform = /obj/item/clothing/under/misc/pj/red
		if(prob(30))
			uniform = /obj/item/clothing/under/misc/pj/blue

/datum/job/donor/prisoner/after_spawn(mob/living/carbon/human/H, joined_late = FALSE)
	if(!joined_late || !H)
		return ..()

	for(var/obj/effect/landmark/spawner/prisoner/landmark_loc in GLOB.landmarks_list)
		H.forceMove(get_turf(landmark_loc))
		break

	. = ..()

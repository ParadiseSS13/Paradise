// Будь прокляты те кто вставлял списки прямо в код. Это не ТОГЭ. Поэтому оставь здравомыслие всяк сюда входящий.
/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)

		if("Security Cadet")
			O = new /datum/outfit/plasmaman/security

		if("Medical Intern")
			O = new /datum/outfit/plasmaman/medical

		if("Student Scientist")
			O = new /datum/outfit/plasmaman/science

		if("Trainee Engineer")
			O = new /datum/outfit/plasmaman/engineering

	H.equipOutfit(O, visualsOnly)
	H.internal = H.r_hand
	H.update_action_buttons_icon()
	return FALSE

/datum/character_save
	var/extra_jobs_check = FALSE

// OFFICIAL parameters: 17 / HOS, Bart / 400 / 700
/datum/character_save/SetChoices(mob/user, limit = 18, list/splitJobs = list("Head of Security", "Bartender"), widthPerColumn = 450, height = 700)
	. = ..()

/datum/character_save/proc/get_split_extra_jobs()
	return list("Administrator", "Adjutant", "VIP Corporate Guest")

/datum/preferences/process_link(mob/user, list/href_list)
	if(!user)
		return

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("extra_job")
				active_character.extra_jobs_check = !active_character.extra_jobs_check
				active_character.SetChoices(user)
				return TRUE
	. = ..()

// В /SetChoices() определяем нужно ли пользователю создавать дополнительную кнопку
/datum/character_save/proc/check_available_extra_job_prefs(client/C)
	if(C?.donator_level)
		return TRUE
	return FALSE

// это копипаст мерзопакости. Я не буду рефакторить это в модуле, я шо, ебанутый?
// Оно работает и ладно. И я не буду этот комментарий на английский переводить.
// Эту хуйню должен видеть каждый кто сюда зайдет и полезет посмотреть какой в родителе оригинальный код на 1000 строчек.
/datum/character_save/update_preview_icon(for_observer=0)
	. = ..()

	var/icon/clothes_s = get_clothes_icon()

	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)

	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(clothes_s)


/datum/character_save/proc/get_clothes_icon()
	var/icon/clothes_s = null

	var/g = ""
	if(gender == FEMALE)
		g = "f"

	if(job_medsci_high)
		switch(job_medsci_high)
			if(JOB_STUDENT)
				clothes_s = new /icon('modular_ss220/jobs/icons/clothing/mob/uniform.dmi', "student[g]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "metroid"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_INTERN)
				clothes_s = new /icon('modular_ss220/jobs/icons/clothing/mob/uniform.dmi', "intern[g]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_ACTOR, JOB_ADMINISTRATOR, JOB_TOURIST_TSF, JOB_TOURIST_USSP, JOB_MANAGER_JANITOR, JOB_GUARD, JOB_MIGRANT, JOB_UNCERTAIN /* JOB_APPRENTICE, */)
				if(prob(50))
					clothes_s = new /icon('icons/mob/clothing/under/procedure.dmi', "iaa_s")
				else
					clothes_s = new /icon('icons/mob/clothing/under/misc.dmi', "waiter_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "fez"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)


			if(JOB_ADJUTANT, /* JOB_BUTLER, JOB_MAID */)
				clothes_s = new /icon('icons/mob/clothing/under/procedure.dmi', "lawyer_black[g ? "_skirt" : ""]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				if(prob(10))
					clothes_s.Blend(new /icon('icons/mob/clothing/eyes.dmi', "monocle"), ICON_OVERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beaver_hat"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)


	else if(job_engsec_high)
		switch(job_engsec_high)
			if(JOB_CADET)
				clothes_s = new /icon('modular_ss220/jobs/icons/clothing/mob/uniform.dmi', "cadet[g]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "justice_up"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "secsoft"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_TRAINEE)
				clothes_s = new /icon('modular_ss220/jobs/icons/clothing/mob/uniform.dmi', "trainee[g]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_orange"), ICON_OVERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "orangegloves"), ICON_OVERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "hazard"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_REPRESENTATIVE_TSF, JOB_REPRESENTATIVE_USSP, JOB_DEALER)
				clothes_s = new /icon('icons/mob/clothing/under/procedure.dmi', "lawyer_black[g ? "_skirt" : ""]_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				if(prob(10))
					clothes_s.Blend(new /icon('icons/mob/clothing/eyes.dmi', "monocle"), ICON_OVERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beaver_hat"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_VIP_GUEST, JOB_BANKER)
				clothes_s = new /icon('icons/mob/clothing/under/procedure.dmi', "ntrep[g ? "_skirt" : ""]_s")
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "suitjacket_black_open"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/eyes.dmi', "monocle"), ICON_OVERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "tophat"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_SECURITY_CLOWN)
				clothes_s = new /icon('modular_ss220/jobs/icons/clothing/mob/uniform.dmi', "security_clown_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "clown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "clown"), ICON_UNDERLAY)
				if(prob(25))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "detective"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "detective"), ICON_OVERLAY)
				else if(prob(25))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "warden_jacket"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "sechat"), ICON_OVERLAY)
				else if(prob(50))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "armor"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "redsoft"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "clownpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-clown"), ICON_OVERLAY)


	else if(job_support_high)
		switch(job_support_high)
			if(JOB_PRISON)
				if(prob(95))
					clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "prisoner_s")
				else
					clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "prisoner_d_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)

			if(JOB_BARBER, JOB_BATH, JOB_CASINO, JOB_WAITER, JOB_ACOLYTE, JOB_BOXER, JOB_MUSICIAN /* JOB_DELIVERER, JOB_PAINTER, */)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "barber_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				if(prob(70))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "boater_hat"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

// Костыли с датумами для выставления должностей
/datum/character_save/proc/get_datum_last_support()
	return JOBCAT_LAST_SUPPORT

/datum/character_save/proc/get_datum_last_engsec()
	return JOBCAT_LAST_ENGSEC

/datum/character_save/proc/get_datum_last_medsci()
	return JOBCAT_LAST_MEDSCI

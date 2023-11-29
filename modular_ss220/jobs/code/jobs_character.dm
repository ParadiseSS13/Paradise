// Будь прокляты те кто вставлял списки прямо в код. Это не ТОГЭ. Поэтому оставь здравомыслие всяк сюда входящий.
/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)

		if("Security Cadet")
			O = new /datum/outfit/plasmaman/security

		if("Intern")
			O = new /datum/outfit/plasmaman/medical

		if("Student Scientist")
			O = new /datum/outfit/plasmaman/science

		if("Trainee Engineer")
			O = new /datum/outfit/plasmaman/engineering

	H.equipOutfit(O, visualsOnly)
	H.internal = H.r_hand
	H.update_action_buttons_icon()
	return FALSE


// это копипаст мерзопакости. Я не буду рефакторить это в модуле, я шо, ебанутый?
// Оно работает и ладно. И я не буду этот комментарий на английский переводить.
// Эту хуйню должен видеть каждый кто сюда зайдет и полезет посмотреть какой в родителе оригинальный код на 1000 строчек.
/datum/character_save/update_preview_icon(for_observer=0)
	. = ..()

	// qdel(preview_icon_front)
	// qdel(preview_icon_side)
	// qdel(preview_icon)

	var/g = ""
	if(gender == FEMALE)
		g = "f"

	var/icon/clothes_s = null

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

	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)

	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(clothes_s)

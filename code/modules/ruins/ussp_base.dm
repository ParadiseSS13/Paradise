/obj/effect/mob_spawn/human/ussp_general
	name = "Генерал СССП"
	mob_name = "Генерал СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Генерал СССП"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_s"
	important_info = "Вы - не антагонист! Ваша задача наладить контакт со станцией."
	description = "Вы - генерал СССП станции! Руководите оставшимся членами экипажа, и по возможности обустройте станцию и установите контакт с неизвестной станцией, которая находитья неподалёку от вас."
	flavour_text = "Вы являетесь единственным выжившим главнокомандующим на разрушенной станции СССП. Вы должны отдавать приказы оставшемуся  персоналу и не дать ему умереть. Вашей первостепенной задачей будет попытка наладить контакт с неизвестной станцией, которая находится в бижайшем секторе от вас."
	outfit = /datum/outfit/ussp_general
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_general
	name = "ussp general ID card"
	desc = "An ID straight from Ussp."
	icon_state = "centcom"
	item_state = "centcomm-id"
	registered_name = "Central Command"
	assignment = "General"
	access = list(USSP_BAR, USSP_SECURITY, USSP_COMAND)

/datum/outfit/ussp_general/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_general
	name = "Генерал СССП"
	r_hand = /obj/item/melee/energy/sword/saber
	uniform = /obj/item/clothing/under/sovietofficer
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/ussp_general
	implants = list(/obj/item/implant/weapons_auth)

/obj/effect/mob_spawn/human/ussp_engineer
	name = "Инженер СССП"
	mob_name = "Инженер СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Инженер СССП"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_s"
	important_info = "Вы - не антагонист! Ваша задача наладить контакт со станцией."
	description = "Вы - инженер СССП станции!Постарайтесь держать станцию на плаву!"
	flavour_text = "Вы один из немногих выживших на разрушенной станции СССП. Вы лишь отрывками вспоминаете, как убегали от чего-то ужасного. Вашей задачей будет исполнять приказы адмирала. А также привести станцию в хоть какой-то порядок."
	outfit = /datum/outfit/ussp_engineer
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_engineer
	name = "ussp engineer ID card"
	desc = "An ID straight from Ussp."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Central Command"
	assignment = "General"
	access = list(USSP_ENGINEERING)

/datum/outfit/ussp_engineer/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_engineer
	name = "Инженер СССП"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/ussp_engineer
	belt = /obj/item/storage/belt/utility/full/multitool
	glasses = /obj/item/clothing/glasses/welding

/obj/effect/mob_spawn/human/ussp_security
	name = "Сотрудник безопасности СССП"
	mob_name = "Сотрудник безопасности СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Сотрудник безопасности СССП"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_s"
	important_info = "Вы - не антагонист! Ваша задача наладить контакт со станцией."
	description = "Вы - сотрудник безопасности СССП станции!Постарайтесь держать станцию на плаву!"
	flavour_text = "Ранее вы следили за порядком на этой станции... Ранее. Вы смутно припоминаете, как вместе с другим офицером напились до отключки и впали в криосон. Теперь вашей задачей будет защита адмирала, а также починка станции."
	outfit = /datum/outfit/ussp_security
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_security
	name = "ussp security ID card"
	desc = "An ID straight from Ussp."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Central Command"
	assignment = "General"
	access = list(USSP_BAR,USSP_SECURITY)

/datum/outfit/ussp_security/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_security
	name = "Сотрудник безопасности СССП"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/ussp_security

/obj/effect/mob_spawn/human/ussp_scientist
	name = "Учённый СССП"
	mob_name = "Учённый СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Учённый СССП"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_s"
	important_info = "Вы - не антагонист! Ваша задача наладить контакт со станцией."
	description = "Вы - Учённый СССП станции! Постарайтесь выжить!"
	flavour_text = "Вы смутно что то припоминаете. Ваша задача попытаться выжить."
	outfit = /datum/outfit/ussp_scientist
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/datum/outfit/ussp_scientist
	name = "Учённый СССП"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/stack/medical/bruise_pack
	id = /obj/item/card/id/ussp_scientist

/datum/outfit/ussp_scientist/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet


/obj/item/card/id/ussp_scientist
	name = "ussp scientist ID card"
	desc = "An ID straight from Ussp."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Central Command"
	assignment = "General"
	access = list(USSP_ENGINEERING)

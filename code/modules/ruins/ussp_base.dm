/obj/effect/mob_spawn/human/ussp
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"

/obj/effect/mob_spawn/human/ussp/general
	name = "Генерал СССП"
	mob_name = "Генерал СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Soviet General"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	important_info = "Вы - не антагонист! Ваша задача управлять остатками экипажа и не дать станции окончательно развалиться."
	description = "Вы - командующий станцией СССП! Руководите оставшимся членами экипажа, и по возможности восстановите станцию. Защищайте имущество СССП и научные наработки, возможно ЦК СССП ещё вспомнит про вас. Соблюдайте субординацию."
	flavour_text = "Вы являетесь единственным выжившим командующим на повреждённой станции СССП. В вашей памяти мелькают спутанные воспоминания того, что случилось до того как Вы уснули... Отдавайте приказы выжившему персоналу и не дайте ему умереть. Вашей первостепенной задачей будет попытка восстановить целостность станции и завершить научные эксперементы, после - можете попытаться связаться с ЦК СССП и доложить о произошедшем."
	outfit = /datum/outfit/ussp_general
	faction = list("ussp")
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_general
	name = "USSP general ID card"
	desc = "An ID straight from USSP."
	icon_state = "centcom"
	item_state = "centcomm-id"
	registered_name = "Soviet General"
	assignment = "Soviet General"
	rank = "Soviet General"
	access = list(ACCESS_USSP_SECURITY, ACCESS_USSP_SCIENTIST, ACCESS_USSP_ENGINEERING, ACCESS_USSP_COMAND)

/datum/outfit/ussp_general/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_general
	name = "Генерал СССП"
	uniform = /obj/item/clothing/under/sovietofficer
	head = /obj/item/clothing/head/sovietofficerhat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	belt = /obj/item/gun/projectile/automatic/pistol/APS
	l_pocket = /obj/item/melee/classic_baton/telescopic
	r_pocket = /obj/item/ammo_box/magazine/pistolm9mm
	id = /obj/item/card/id/ussp_general
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/ussp_general/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.rename_character(null, "[pick("Полковник", "Генерал майор", "Генерал лейтенант", "Генерал полковник")] [H.real_name]")
	H.add_language("Neo-Russkiya")
	H.set_default_language(GLOB.all_languages["Neo-Russkiya"])
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		H.sec_hud_set_ID()

/obj/effect/mob_spawn/human/ussp/engineer
	name = "Инженер СССП"
	mob_name = "Инженер СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Soviet Engineer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	important_info = "Вы - не антагонист! Ваша задача восстановить полученные повреждения и нормализовать функционирование станции."
	description = "Вы - инженер на станции СССП! Постарайтесь удержать станцию на плаву!"
	flavour_text = "Вы один из немногих выживших на повреждённой станции СССП. Вы лишь отрывками вспоминаете, что пошло не так перед тем как Вы уснули. Вашей задачей будет исполнение приказов командующего и поддержание работоспособности станции. Соблюдайте субординацию."
	outfit = /datum/outfit/ussp_engineer
	faction = list("ussp")
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_engineer
	name = "USSP engineer ID card"
	desc = "An ID straight from USSP."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Soviet Engineer"
	assignment = "Soviet Engineer"
	rank = "Soviet Engineer"
	access = list(ACCESS_USSP_ENGINEERING)

/datum/outfit/ussp_engineer/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_engineer
	name = "Инженер СССП"
	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/sovietsidecap
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/ussp_engineer
	belt = /obj/item/storage/belt/utility/full/multitool
	glasses = /obj/item/clothing/glasses/welding

/datum/outfit/ussp_engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.rename_character(null, "[pick("Старший сержант", "Старшина", "Прапорщик", "Старший прапорщик")] [H.real_name]")
	H.add_language("Neo-Russkiya")
	H.remove_language("Galactic Common")
	H.set_default_language(GLOB.all_languages["Neo-Russkiya"])
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		H.sec_hud_set_ID()

/obj/effect/mob_spawn/human/ussp/security
	name = "Сотрудник безопасности СССП"
	mob_name = "Сотрудник безопасности СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Soviet Soldier"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	important_info = "Вы - не антагонист! Ваша задача защищать территорию СССП от враждебных форм жизни и интервентов."
	description = "Вы - сотрудник безопасности на станции СССП! Ваша работа, помимо поддержания порядка на станции, выполнение поручений старших по званию. Готовьте пищу, собирайте разбросанные ресурсы, а главное соблюдайте субординацию."
	flavour_text = "Ранее вы следили за порядком на этой станции... Ранее. Вы смутно припоминаете, как вместе с товарищем напились до отключки и упали в криосон. Выполняйте приказы и не дайте станции окончательно развалиться."
	outfit = /datum/outfit/ussp_security
	faction = list("ussp")
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/item/card/id/ussp_security
	name = "USSP security ID card"
	desc = "An ID straight from USSP."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Soviet Soldier"
	assignment = "Soviet Soldier"
	rank = "Soviet Soldier"
	access = list(ACCESS_USSP_SECURITY)

/datum/outfit/ussp_security/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_security
	name = "Сотрудник безопасности СССП"
	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/soviethelmet
	belt = /obj/item/storage/belt/security
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	l_pocket = /obj/item/melee/classic_baton/telescopic
	id = /obj/item/card/id/ussp_security

/datum/outfit/ussp_security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.rename_character(null, "[pick("Сержант", "Старший сержант", "Младший лейтенант")] [H.real_name]")
	H.add_language("Neo-Russkiya")
	H.remove_language("Galactic Common")
	H.set_default_language(GLOB.all_languages["Neo-Russkiya"])
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		H.sec_hud_set_ID()

/obj/effect/mob_spawn/human/ussp/scientist
	name = "Учёный СССП"
	mob_name = "Учёный СССП"
	roundstart = FALSE
	death = FALSE
	id_job = "Soviet Scientist"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	important_info = "Вы - не антагонист! Ваша задача восстановить потерянные научные данные и следить за здоровьем экипажа."
	description = "Вы - Учёный на станции СССП! Постарайтесь выжить! А также попытайтесь восстановить потерянные научные данные и проследите, чтобы остатки экипажа не умерли. Соблюдайте субординацию."
	flavour_text = "Вы смутно что то припоминаете. Ваша задача попытаться выжить и не дать умереть остальным."
	outfit = /datum/outfit/ussp_scientist
	faction = list("ussp")
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	mob_species = /datum/species/human
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/datum/outfit/ussp_scientist/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Human")
				box = /obj/item/storage/box/soviet

/datum/outfit/ussp_scientist
	name = "Учёный СССП"
	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/sovietsidecap
	shoes = /obj/item/clothing/shoes/combat
	r_ear = /obj/item/radio/headset/alt/soviet // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/stack/medical/bruise_pack
	id = /obj/item/card/id/ussp_scientist

/datum/outfit/ussp_scientist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.rename_character(null, "[pick("Прапорщик", "Старший прапорщик", "Младший лейтенант", "Лейтенант")] [H.real_name]")
	H.add_language("Neo-Russkiya")
	H.remove_language("Galactic Common")
	H.set_default_language(GLOB.all_languages["Neo-Russkiya"])
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		H.sec_hud_set_ID()

/obj/item/card/id/ussp_scientist
	name = "USSP scientist ID card"
	desc = "An ID straight from USSP."
	icon_state = "ussp"
	item_state = "ussp"
	registered_name = "Central Command"
	assignment = "Soviet Scientist"
	rank = "Soviet Scientist"
	access = list(ACCESS_USSP_SCIENTIST)

/obj/effect/mob_spawn/human/ussp/Destroy()
	var/obj/structure/fluff/empty_cryostasis_sleeper/empty = new(drop_location())

	empty.dir = WEST
	return ..()


// Wall safe with areaeditor
/obj/item/storage/secure/safe/ussp_blueprints
	name = "Emergency blueprints"

/obj/item/storage/secure/safe/ussp_blueprints/Initialize(mapload)
	. = ..()
	l_code = "[GLOB.sc_safecode1][GLOB.sc_safecode2][GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]"
	l_set = 1

/obj/item/storage/secure/safe/ussp_blueprints/populate_contents()
	new /obj/item/areaeditor/ussp(src)
	new /obj/item/megaphone(src)

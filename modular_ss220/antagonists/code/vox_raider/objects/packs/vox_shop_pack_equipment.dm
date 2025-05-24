/datum/vox_pack/equipment
	name = "DEBUG Equipment Vox Pack"
	category = VOX_PACK_EQUIPMENT


// ============== Misc ==============
/datum/vox_pack/equipment/card
	name = "Идентификационная Карта"
	desc = "Карта для идентификации, смены образов и воровства доступов."
	reference = "E_CARD"
	cost = 150
	contains = list(/obj/item/card/id/syndicate/vox)

/datum/vox_pack/equipment/hand_valuer
	name = "Оценщик"
	desc = "Позволяет узнать ценность товаров. Не забудьте его активировать о Расчичетчикик."
	reference = "E_VALUER"
	cost = 100
	contains = list(/obj/item/hand_valuer)

/datum/vox_pack/equipment/mask
	name = "Дыхательная Маска"
	desc = "С встроенной трубкой для дыхания"
	reference = "E_MASK"
	cost = 25
	contains = list(/obj/item/clothing/mask/breath/vox)

/datum/vox_pack/equipment/nitrogen
	name = "Дыхательный Балон"
	desc = "Сдвоенный дыхательный балон наполненный нитрогеном."
	reference = "E_NITR"
	cost = 50
	contains = list(/obj/item/tank/internals/emergency_oxygen/double/vox)

/datum/vox_pack/equipment/flag
	name = "Флаг"
	desc = "С ним ценности еще ценнее."
	reference = "E_FLAG"
	cost = 100
	contains = list(/obj/item/flag/vox_raider)

// TECH

/datum/vox_pack/equipment/jammer
	name = "Глушилка"
	desc = "Глушитель связи."
	reference = "E_JAM"
	cost = 500
	contains = list(/obj/item/jammer)

/datum/vox_pack/equipment/jammer
	name = "Глушилка"
	desc = "Глушитель связи."
	reference = "E_JAM"
	cost = 500
	contains = list(/obj/item/jammer)

/datum/vox_pack/equipment/ai_detector
	name = "Детектор"
	desc = "Детектор искусственного интеллекта замаскированного под мультиметр."
	reference = "E_AI"
	cost = 250
	contains = list(/obj/item/multitool/ai_detect)

/datum/vox_pack/equipment/stealth
	name = "Имплантер Маскировки"
	desc = "Имплантер для скрытых операций и краж."
	reference = "E_BCI_S"
	cost = 2000
	contains = list(/obj/item/bio_chip_implanter/stealth)

/datum/vox_pack/equipment/freedom
	name = "Имплантер Свободы"
	desc = "Имплантер скоротечно изменяющий структуру костей для освобождения от сдерживающих факторов."
	reference = "E_BCI_F"
	cost = 1500
	contains = list(/obj/item/bio_chip_implanter/freedom)

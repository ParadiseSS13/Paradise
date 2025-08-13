/datum/vox_pack/medicine
	name = "DEBUG Medicine Vox Pack"
	category = VOX_PACK_MEDICINE

/datum/vox_pack/medicine/blood
	name = "Кровь"
	desc = "Кровь предназначенная для переливания Воксам."
	reference = "MED_BLOOD"
	cost = 200
	contains = list(/obj/item/reagent_containers/iv_bag/blood/vox)

/datum/vox_pack/medicine/dart
	name = "Медицинский дротик"
	desc = "Дротик наполненный медикаментами от слабых повреждений."
	reference = "MED_DART"
	cost = 25
	contains = list(/obj/item/reagent_containers/syringe/dart/medical)

// 1 уровень
/datum/vox_pack/medicine/dart/tainted
	name = "Медицинский дротик - Просрочен"
	desc = "Просроченный и списанный медицинский дротик."
	reference = "MED_DART_TA"
	cost = 10
	contains = list(/obj/item/reagent_containers/syringe/dart/medical/tainted)

// 2 уровень
/datum/vox_pack/medicine/dart/heal
	name = "Медицинский дротик - Лечебный"
	desc = "Медицинский дротик для лечения тяжелых травм."
	reference = "MED_DART_HE"
	cost = 60
	contains = list(/obj/item/reagent_containers/syringe/dart/medical/heal)

/datum/vox_pack/medicine/dart/stabilizing
	name = "Медицинский дротик - Стабилизирующий"
	desc = "Медицинский дротик для стабилизации пациента."
	reference = "MED_DART_ST"
	cost = 80
	contains = list(/obj/item/reagent_containers/syringe/dart/medical/stabilizing)

// 3 уровень (1 час)
/datum/vox_pack/medicine/dart/advanced
	name = "Медицинский дротик - Продвинутый регенеративный"
	desc = "Медицинский дротик стимулирующий быструю регенерацию."
	reference = "MED_DART_AD"
	time_until_available = 60
	cost = 200
	contains = list(/obj/item/reagent_containers/syringe/dart/medical/advanced)

// 4 уровень (2 час)
/datum/vox_pack/medicine/dart/combat
	name = "Медицинский дротик - Боевой стимулянт"
	desc = "передовой дротик с эксперементальными стимулянтами."
	reference = "MED_DART_CO"
	cost = 450
	time_until_available = 120
	contains = list(/obj/item/reagent_containers/syringe/dart/medical/combat)

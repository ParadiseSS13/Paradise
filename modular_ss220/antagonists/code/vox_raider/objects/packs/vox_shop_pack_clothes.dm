/datum/vox_pack/clothes
	name = "DEBUG Clothes Vox Pack"
	category = VOX_PACK_CLOTHES


// ============== JUMSUIT ==============

/datum/vox_pack/clothes/jumpsuit
	name = "Рабочая одежда"
	desc = "Одежда воксов предназначенная только для них."
	reference = "C_J"
	cost = 15
	contains = list(/obj/item/clothing/under/vox/jumpsuit)

/datum/vox_pack/clothes/jumpsuit/red
	name = "Рабочая одежда - Красная"
	reference = "C_JR"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/red)

/datum/vox_pack/clothes/jumpsuit/teal
	name = "Рабочая одежда - Бирюза"
	reference = "C_JT"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/teal)

/datum/vox_pack/clothes/jumpsuit/blue
	name = "Рабочая одежда - Синий"
	reference = "C_JB"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/blue)

/datum/vox_pack/clothes/jumpsuit/green
	name = "Рабочая одежда - Зеленый"
	reference = "C_JG"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/green)

/datum/vox_pack/clothes/jumpsuit/yellow
	name = "Рабочая одежда - Желтый"
	reference = "C_JY"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/yellow)

/datum/vox_pack/clothes/jumpsuit/purple
	name = "Рабочая одежда - Фиолетовый"
	reference = "C_JP"
	contains = list(/obj/item/clothing/under/vox/jumpsuit/purple)


// ============== SHOES ==============

/datum/vox_pack/clothes/shoes
	name = "Обувка"
	desc = "Синтетические обертки подходящие для большинства типов ног."
	reference = "C_SH"
	cost = 15
	contains = list(/obj/item/clothing/shoes/roman/vox)


// ============== MAGBOOTS ==============
/datum/vox_pack/clothes/magboots
	name = "Магнитные Налапочники"
	desc = "Когтистые плотные налапочники с небольшой защитой для лап."
	reference = "C_SH_M"
	cost = 200
	contains = list(/obj/item/clothing/shoes/magboots/vox)

/datum/vox_pack/clothes/magboots/scout
	name = "Магнитные Налапочники Разведки"
	desc = "Легкие когтистые налапочники с продвинутым сцеплением с поверхностью для ускорение передвижения."
	reference = "C_SH_MS"
	cost = 1000
	contains = list(/obj/item/clothing/shoes/magboots/vox/scout)

/datum/vox_pack/clothes/magboots/combat
	name = "Боевые Магнитные Налапочники"
	desc = "Боевые бронированные когтистые налапочники с улучшенным сцеплением с поверхностью."
	reference = "C_SH_MC"
	cost = 2000
	time_until_available = 45
	contains = list(/obj/item/clothing/shoes/magboots/vox/combat)

/datum/vox_pack/clothes/magboots/heavy
	name = "Тяжелые Магнитные Налапочники"
	desc = "Тяжелые бронированные когтистые налапочники для ведения боевых действий и защит нижних конечностей от всевозможных угроз."
	reference = "C_SH_MH"
	cost = 4000
	time_until_available = 60
	contains = list(/obj/item/clothing/shoes/magboots/vox/heavy)


// ============== GLOVES ==============
/datum/vox_pack/clothes/gloves
	name = "Рукавицы"
	desc = "Плотные рукавицы с когтями с защитой кистей."
	reference = "C_GL"
	cost = 400
	contains = list(/obj/item/clothing/gloves/vox)

/datum/vox_pack/clothes/gloves/insulated
	name = "Изоляционные Рукавицы"
	desc = "Плотные изоляционные рукавицы с когтями."
	reference = "C_GL_I"
	cost = 2000
	contains = list(/obj/item/clothing/gloves/color/yellow/vox)


// ============== GLASSES ==============

/datum/vox_pack/clothes/eye_night
	name = "Очки Ночного Видения"
	desc = "Очки позволяющие видеть в кромешной темноте."
	reference = "C_EYE_NI"
	cost = 300
	contains = list(/obj/item/clothing/glasses/night)

/datum/vox_pack/clothes/eye_meson
	name = "Мезонный Глаз"
	desc = "Мезонный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
	ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера - не позволяет надевать прочие приблуды на глаза, заменяя очки."
	reference = "C_EYE_ME"
	cost = 1000
	contains = list(/obj/item/clothing/glasses/meson/cyber/vox)

/datum/vox_pack/clothes/eye_thermal
	name = "Термальный Глаз"
	desc = "Термальный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
	ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера - не позволяет надевать прочие приблуды на глаза, заменяя очки."
	reference = "C_EYE_TH"
	cost = 4500
	time_until_available = 45
	contains = list(/obj/item/clothing/glasses/thermal/cyber/vox)

/datum/vox_pack/clothes/sechud
	name = "Дисплей Службы Безопасности"
	desc = "Очки с защитой для глаз и с доступом в системы базы данных службы безопасности."
	reference = "C_EYE_SEC"
	cost = 3500
	time_until_available = 45
	contains = list(/obj/item/clothing/glasses/hud/security/sunglasses/fluff/voxxyhud)

/datum/vox_pack/clothes/healthhud
	name = "Медицинский Дисплей"
	desc = "Очки для контроля жизненных показателей."
	reference = "C_EYE_HEALTH"
	cost = 1000
	time_until_available = 45
	contains = list(/obj/item/clothing/glasses/hud/health)


// ============== EARS ==============

/datum/vox_pack/clothes/radio
	name = "Наушники"
	desc = "Наушник дальней связи для поддержания связи со стаей."
	reference = "C_RAD"
	cost = 100
	contains = list(/obj/item/radio/headset/vox)

/datum/vox_pack/clothes/radio/alt
	name = "Защитные наушники"
	desc = "Наушник дальней связи для поддержания связи со стаей. Защищает ушные раковины от громких звуков"
	reference = "C_RAD_ALT"
	cost = 500
	time_until_available = 60
	contains = list(/obj/item/radio/headset/vox/alt)


// ============== Space Suits ==============
/datum/vox_pack/clothes/pressure
	name = "Скафандр"
	desc = "Защитный костюм для работы во враждебной атмосфере с приемлимыми защитными свойствами и полной защитой от давления."
	reference = "C_PR"
	cost = 100
	contains = list(
		/obj/item/clothing/suit/space/vox/pressure,
		/obj/item/clothing/head/helmet/space/vox/pressure
		)


// ============== STORAGE ==============

/datum/vox_pack/clothes/backpack
	name = "Рюкзак"
	desc = "Рюкзак из плотно переплетенного синтетического волокна. Хорошо защищает спину носителя при побегах и вмещает достаточно добра."
	reference = "C_BP"
	cost = 200
	contains = list(/obj/item/storage/backpack/vox)

/datum/vox_pack/clothes/backpack/duffel
	name = "Сумка"
	desc = "Сумка из синтетического волокна. Емкий, вмещает много добра."
	reference = "C_BPD"
	cost = 300
	contains = list(/obj/item/storage/backpack/duffel/vox)

/datum/vox_pack/clothes/backpack/satchel
	name = "Ранец"
	desc = "Ранец из синтетического волокна. Компактный, из-за чего его можно отлично прятать."
	reference = "C_BPS"
	cost = 150
	contains = list(/obj/item/storage/backpack/satchel_flat/vox)


/datum/vox_pack/clothes/belt
	name = "Пояс Рейдера"
	desc = "Пояс вмещающий в себя инструменты и запасные батареи. Вмещает 7 предметов."
	reference = "C_BELT"
	cost = 1000
	contains = list(/obj/item/storage/belt/vox)

/datum/vox_pack/clothes/belt/bio
	name = "Пояс Био-Рейдера"
	desc = "Пояс вмещающий в себя биоядра, дротики и взрывчатку. Вмещает 21 тяжелых предметов."
	reference = "C_BELT_BIO"
	cost = 1300
	contains = list(/obj/item/storage/belt/vox/bio)

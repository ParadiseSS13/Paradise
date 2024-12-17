/datum/vox_pack/dart
	name = "DEBUG Dart Vox Pack"
	category = VOX_PACK_DART

// ============== GUNS ==============

/datum/vox_pack/dart/gun
	name = "Дротикомет"
	desc = "Компактный метатель дротиков для доставки химических коктейлей. Вмещает 5(+1) дротиков. Никто кроме Воксов не сможет взять его в руки."
	reference = "D_G"
	cost = 500
	contains = list(/obj/item/gun/syringe/dart_gun)

/datum/vox_pack/dart/gun/ext
	name = "Расширенный Дротикомет"
	desc = "Расширенный метатель дротиков и шприцов для доставки химических коктейлей. Вмещает 5(+1) дротиков и шприцов. Никто кроме Воксов не сможет взять его в руки."
	reference = "D_GE"
	cost = 2000
	contains = list(/obj/item/gun/syringe/dart_gun/extended)

/datum/vox_pack/dart/gun/big
	name = "Вместительный Дротикомет"
	desc = "Вместительный метатель дротиков для доставки химических коктейлей. Вмещает 10(+1) дротиков. Никто кроме Воксов не сможет взять его в руки."
	reference = "D_GB"
	cost = 3000
	contains = list(/obj/item/gun/syringe/dart_gun/big)


// ============== AMMO ==============

/datum/vox_pack/dart/cartridge
	name = "Картридж (5+1)"
	desc = "Подставка для дротиков. Пустая."
	reference = "D_C"
	cost = 25
	contains = list(/obj/item/storage/dart_cartridge)

/datum/vox_pack/dart/cartridge/extended
	name = "Картридж (5+1)"
	desc = "Расширенная подставка для дротиков и шприцов. Пустая."
	reference = "D_C_EXT"
	cost = 50
	contains = list(/obj/item/storage/dart_cartridge/extended)

/datum/vox_pack/dart/cartridge/big
	name = "Картридж (10+1)"
	desc = "Увеличенная подставка для дротиков. Пустая."
	reference = "D_C_BIG"
	cost = 100
	contains = list(/obj/item/storage/dart_cartridge/big)

/datum/vox_pack/dart/cartridge/combat
	name = "Картридж (5+1) - Боевой"
	desc = "Подставка с боевыми дротиками для нанесения повреждений."
	reference = "D_C_COM"
	cost = 400
	time_until_available = 45
	contains = list(/obj/item/storage/dart_cartridge/combat)

/datum/vox_pack/dart/cartridge/medical
	name = "Картридж (5+1) - Медицинский"
	desc = "Подставка с полезными дротиками для восстановления телесных повреждений."
	reference = "D_C_MED"
	cost = 300
	contains = list(/obj/item/storage/dart_cartridge/medical)

/datum/vox_pack/dart/cartridge/pain
	name = "Картридж (5+1) - Болевой"
	desc = "Подставка с вредными дротиками, приносящие боль и страдания."
	reference = "D_C_PAIN"
	cost = 400
	time_until_available = 30
	contains = list(/obj/item/storage/dart_cartridge/pain)

/datum/vox_pack/dart/cartridge/drugs
	name = "Картридж (5+1) - Наркотический"
	desc = "Подставка для вредных дротиков-наркотиков."
	reference = "D_C_DRUG"
	cost = 300
	time_until_available = 30
	contains = list(/obj/item/storage/dart_cartridge/drugs)

/datum/vox_pack/dart/cartridge/random
	name = "Картридж (10+1) - ???"
	desc = "Случайный набор дротиков с химикатами."
	reference = "D_C_RAND"
	cost = 1000
	time_until_available = 60
	contains = list(/obj/item/storage/dart_cartridge/big/random)

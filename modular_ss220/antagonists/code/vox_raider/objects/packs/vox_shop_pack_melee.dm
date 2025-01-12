
/datum/vox_pack/melee
	name = "DEBUG Melee Vox Pack"
	category = VOX_PACK_MELEE

// ============== Гарпун ==============

/datum/vox_pack/melee/harpoon
	name = "Гарпун"
	desc = "Инструмент для охоты на космических китов."
	reference = "MEL_HARP"
	cost = 100
	contains = list(/obj/item/harpoon)

// ============== Щиты ==============

/datum/vox_pack/melee/shield
	name = "Энергощит"
	desc = "Энергетический компактный ручной щит, пособный отражать энергетические снаряды, но не может блокировать прямые воздействия."
	reference = "MEL_SH"
	cost = 4000
	contains = list(/obj/item/shield/energy)


// ============== Мечи ==============

/datum/vox_pack/melee/sword
	name = "Энергосабля"
	desc = "Энергетическая сабля для абордажей кораблей."
	reference = "MEL_SW"
	cost = 4000
	time_until_available = 45
	contains = list(/obj/item/melee/energy/sword/pirate)

/datum/vox_pack/melee/sword/purple
	name = "Энергомеч (Фиолетовый)"
	desc = "Энергетический меч для прижигания ран отрубленных конечностей неприятеля. Цвет решительности, цвет Рейдеров. Классика Воксов."
	reference = "MEL_SWP"
	cost = 8000
	time_until_available = 120
	contains = list(/obj/item/melee/energy/sword/saber/purple)

/datum/vox_pack/melee/sword/blue
	name = "Энергомеч (Синий)"
	desc = "Энергетический меч для прижигания ран отрубленных конечностей неприятеля. Цвет силы и стойкости. Его носят бастионы мира Воксов."
	reference = "MEL_SWB"
	cost = 10000
	time_until_available = 120
	contains = list(/obj/item/melee/energy/sword/saber/blue)

/datum/vox_pack/melee/sword/green
	name = "Энергомеч (Зелёный)"
	desc = "Энергетический меч для прижигания ран отрубленных конечностей неприятеля. Цвет миротворцев, тех, кто не любит насилие и причиняет его с большой неохотой. С этим мечом причиняют добро и наносят радость."
	reference = "MEL_SWG"
	cost = 10000
	time_until_available = 120
	contains = list(/obj/item/melee/energy/sword/saber/green)

/datum/vox_pack/melee/sword/red
	name = "Энергомеч (Красный)"
	desc = "Энергетический меч для прижигания ран отрубленных конечностей неприятеля. Цвет ненависти, гнева и злого злодейства злыхх злыдней. Безвкусица."
	reference = "MEL_SWR"
	cost = 12000
	time_until_available = 120
	contains = list(/obj/item/melee/energy/sword/saber/red)

/datum/vox_pack/melee/fly
	name = "Уничтожитель насекомых"
	desc = "Всеми признанный лучший уничтожитель нианов и киданов."
	reference = "MEL_FLY"
	cost = 150
	contains = list(/obj/item/melee/flyswatter)


// ============== Раскладываемое ==============

/datum/vox_pack/melee/dropwall
	name = "Генератор щита"
	desc = "Щитовой развертываемый генератор, активирующий временное укрытие, которое блокирует снаряды и взрывы с определенного направления, в то же время позволяя остальным снарядам свободно проходить сзади."
	reference = "MEL_DW"
	cost = 500
	contains = list(/obj/item/grenade/barrier/dropwall)

/datum/vox_pack/melee/inflatable
	name = "Надувной Набор"
	desc = "Развертываемый надувной набор для заделывания разгерметизаций."
	reference = "MEL_IFL"
	cost = 200
	contains = list(/obj/item/storage/briefcase/inflatable)

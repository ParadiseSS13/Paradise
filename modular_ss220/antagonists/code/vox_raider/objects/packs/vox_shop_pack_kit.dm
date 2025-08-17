// Цельные наборы
/datum/vox_pack/kit
	name = "DEBUG Kit Vox Pack"
	category = VOX_PACK_KIT
	is_need_trader_cost = FALSE
	discount_div = 0.85	// Процент скидки на паки за покупку набора
	var/list/packs_list = list() // Паки которые мы используем для инициализации текущего пака и его цены
	var/list/contains_addition = list() // Дополнительные предметы в наборе

/datum/vox_pack/kit/update_pack()
	if(discount_div <= 0)
		return FALSE
	var/temp_cost = initial(cost)
	contains.Cut()
	if(length(contains_addition))
		contains |= contains_addition

	for(var/i in packs_list)
		var/datum/vox_pack/pack = new i
		temp_cost += pack.cost
		contains |= pack.contains.Copy()
		if(pack.limited_stock >= 0)
			limited_stock = min(limited_stock, pack.limited_stock)
		if(!time_until_available && pack.time_until_available)
			time_until_available = max(time_until_available, pack.time_until_available)

	cost = round(temp_cost * discount_div)
	return TRUE

// ============== Дешевые Наборы ==============

/datum/vox_pack/kit/lamilar
	name = "Лёгкий Набор"
	desc = "Дешевый и лёгкий набор снаряжения, производящийся в промышленных масштабах и рекомендуемый каждому начинающему и опытному воксу при отсутствии средств."
	reference = "K_LAM"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/lamilar,
		/datum/vox_pack/clothes/magboots,
		/datum/vox_pack/clothes/gloves,
		)
	discount_div = 0.65

	// !!!!!!!!! TEST
	contains_addition = list(
		/obj/item/roller/holo,
		/obj/item/roller/holo,
		/obj/item/roller/holo,
	)

/datum/vox_pack/kit/pressure
	name = "Космический Набор"
	desc = "Дешевый набор для перемещения в космосе. Отличное дополнение к полевым наборам."
	reference = "K_PRES"
	cost = 100
	packs_list = list(
		/datum/vox_pack/clothes/pressure,
		/datum/vox_pack/equipment/mask,
		/datum/vox_pack/equipment/nitrogen,
		)

// ============== Наборы Наемников ==============

/datum/vox_pack/kit/stormtrooper
	name = "Штурмовой Набор"
	desc = "Набор штурмовика для сражения при нормальной атмосфере."
	reference = "K_STR"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/stormtrooper,
		/datum/vox_pack/clothes/magboots/combat,
		/datum/vox_pack/clothes/gloves,
		/datum/vox_pack/clothes/sechud,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/belt,
		/datum/vox_pack/spike/gun,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/bio/core/taran,
		)

/datum/vox_pack/kit/fieldmedic
	name = "Набор Полевого Медика"
	desc = "Всё для оказания первой помощи, хирургического вмешательства и защиты самого медика."
	reference = "K_FM"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/fieldmedic,
		/datum/vox_pack/clothes/magboots,
		/datum/vox_pack/clothes/gloves,
		/datum/vox_pack/clothes/healthhud,
		/datum/vox_pack/medicine/blood,
		/datum/vox_pack/medicine/blood,
		/datum/vox_pack/medicine/blood,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/stabilizing,
		/datum/vox_pack/medicine/dart/stabilizing,
		)
	contains_addition = list(
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/surgery,
		/obj/item/roller/holo,
	)
	discount_div = 0.65

/datum/vox_pack/kit/field_scout
	name = "Набор Полевого Разведчика"
	desc = "Набор для разведывательных действий в благоприятных условиях."
	reference = "K_FSCT"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/lamilar/scout,
		/datum/vox_pack/clothes/magboots/scout,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/equipment/ai_detector,
		/datum/vox_pack/equipment/stealth,
		/datum/vox_pack/consumables/t4,
		/datum/vox_pack/consumables/t4,
		)
	discount_div = 0.65

/datum/vox_pack/kit/bomber
	name = "Набор Подрывника"
	desc = "Набор медвежатника для собственной защиты и вскрытия защищенного."
	reference = "K_BOM"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/bomber,
		/datum/vox_pack/clothes/magboots/heavy,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/belt/bio,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/x4,
		/datum/vox_pack/consumables/x4,
		/datum/vox_pack/consumables/t4,
		/datum/vox_pack/consumables/t4,
		/datum/vox_pack/melee/inflatable,
		/datum/vox_pack/melee/inflatable,
		/datum/vox_pack/melee/inflatable,
		)
	contains_addition = list(
		/obj/item/clothing/glasses/hud/diagnostic/sunglasses,
	)
	discount_div = 0.5


// ============== Наборы Рейдеров ==============

/datum/vox_pack/kit/trooper
	name = "Набор Космического Штурмовика"
	desc = "Набор для штурма космических кораблей и станций."
	reference = "K_TROOP"
	cost = 100
	packs_list = list(
		/datum/vox_pack/raider/trooper,
		/datum/vox_pack/clothes/magboots/combat,
		/datum/vox_pack/clothes/gloves,
		/datum/vox_pack/clothes/sechud,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/spike/gun/long,
		/datum/vox_pack/clothes/belt,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		/datum/vox_pack/consumables/c4,
		)
	contains_addition = list(
		/obj/item/clothing/mask/breath/vox/respirator,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
	)

/datum/vox_pack/kit/scout
	name = "Набор Космического Разведчика"
	desc = "Набор для проведения разведки в неблагоприятных условиях."
	reference = "K_SSCT"
	cost = 100
	packs_list = list(
		/datum/vox_pack/raider/scout,
		/datum/vox_pack/clothes/magboots/scout,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/equipment/ai_detector,
		/datum/vox_pack/equipment/jammer,
		)
	contains_addition = list(
		/obj/item/clothing/mask/breath/vox/respirator,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
	)
	discount_div = 0.65

/datum/vox_pack/kit/medic
	name = "Набор Космического Медика"
	desc = "Набор для скорого оказания помощи в неблагоприятных условиях и защиты носителя."
	reference = "K_MEDIC"
	cost = 100
	packs_list = list(
		/datum/vox_pack/raider/medic,
		/datum/vox_pack/clothes/magboots,
		/datum/vox_pack/clothes/gloves,
		/datum/vox_pack/clothes/healthhud,
		/datum/vox_pack/dart/gun,
		/datum/vox_pack/clothes/belt/bio,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/dart/cartridge/medical,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/heal,
		/datum/vox_pack/medicine/dart/stabilizing,
		/datum/vox_pack/medicine/dart/stabilizing,
		)
	discount_div = 0.65
	contains_addition = list(
		/obj/item/clothing/mask/breath/vox,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
		/obj/item/roller/holo,
	)

/datum/vox_pack/kit/mechanic
	name = "Набор Механика"
	desc = "Набор первичного необходимого для ремонта вышедшего из строя оборудования в условиях боя."
	reference = "K_MECH"
	cost = 100
	packs_list = list(
		/datum/vox_pack/raider/mechanic,
		/datum/vox_pack/clothes/magboots/heavy,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/equipment/jammer,
		/datum/vox_pack/equipment/ai_detector,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/melee/inflatable,
		/datum/vox_pack/melee/inflatable,
		/datum/vox_pack/melee/inflatable,
		)
	contains_addition = list(
		/obj/item/clothing/glasses/hud/diagnostic/night,
		/obj/item/clothing/mask/breath/vox,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/firstaid/machine,
		/obj/item/clothing/glasses/welding,
	)
	discount_div = 0.65

/datum/vox_pack/kit/heavy
	name = "Тяжелый Набор"
	desc = "Полный набор тяжелого костюма для работы в условиях переизбыточной опасности."
	reference = "K_HEAVY"
	cost = 100
	packs_list = list(
		/datum/vox_pack/raider/heavy,
		/datum/vox_pack/clothes/magboots/heavy,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/clothes/sechud,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/belt
		)
	contains_addition = list(
		/obj/item/clothing/mask/breath/vox/respirator,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
		/obj/item/clothing/glasses/thermal/monocle,
	)

// ============== Наборы Киг-Йар ==============
// Наборы с щитами и "полезными невостребованными вещами" для востребования покупки.

/datum/vox_pack/kit/kigyar
	name = "Набор Киг-Йар"
	desc = "Набор стрелка Киг-Йар для ведения боевых действий на средних дистанциях."
	time_until_available = 30
	discount_div = 0.5
	reference = "K_KIG"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/lamilar,
		/datum/vox_pack/clothes/magboots/scout,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/melee/dropwall,
		/datum/vox_pack/melee/dropwall,
		/datum/vox_pack/melee/shield,
		/datum/vox_pack/spike/gun,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/clothes/eye_night,
		)

/datum/vox_pack/kit/kigyar/long
	name = "Набор Киг-Йар Пронзателя"
	desc = "Набор Киг-Йар для ведения боевых действий сквозь укрытия."
	reference = "K_KIG_LONG"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/lamilar/scout,
		/datum/vox_pack/clothes/magboots/scout,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/melee/dropwall,
		/datum/vox_pack/melee/shield,
		/datum/vox_pack/spike/gun/long,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		/datum/vox_pack/spike/cell,
		)
	contains_addition = list(
		/obj/item/clothing/glasses/thermal/monocle,
	)

/datum/vox_pack/kit/kigyar/bio
	name = "Набор Киг-Йар Биоштурмовика"
	desc = "Набор Киг-Йар для ведения боевых действий в ближнем бою"
	reference = "K_KIG_BIO"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/bomber,
		/datum/vox_pack/clothes/magboots/combat,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/melee/shield,
		/datum/vox_pack/spike/gun/bio,
		/datum/vox_pack/consumables/food,
		/datum/vox_pack/consumables/food,
		/datum/vox_pack/consumables/food,
		/datum/vox_pack/consumables/food,
		/datum/vox_pack/consumables/food,
		/datum/vox_pack/consumables/food,
		)
	contains_addition = list(
		/obj/item/clothing/glasses/sunglasses/big,
	)

/datum/vox_pack/kit/kigyar/biotech
	name = "Набор Киг-Йар Биотехника"
	desc = "Набор Киг-Йар хозяина биоядер."
	reference = "K_KIG_BIOTECH"
	cost = 100
	packs_list = list(
		/datum/vox_pack/mercenary/fieldmedic,
		/datum/vox_pack/clothes/magboots/scout,
		/datum/vox_pack/clothes/radio/alt,
		/datum/vox_pack/clothes/gloves/insulated,
		/datum/vox_pack/melee/shield,
		/datum/vox_pack/bio/gun,
		/datum/vox_pack/clothes/belt/bio,
		/datum/vox_pack/bio/core/kusaka,
		/datum/vox_pack/bio/core/kusaka,
		/datum/vox_pack/bio/core/kusaka,
		/datum/vox_pack/bio/core/kusaka,
		/datum/vox_pack/bio/core/taran,
		/datum/vox_pack/bio/core/tox,
		/datum/vox_pack/bio/core/tox,
		/datum/vox_pack/bio/core/acid,
		/datum/vox_pack/bio/core/acid,
		)
	contains_addition = list(
		/obj/item/clothing/glasses/sunglasses/big,
	)

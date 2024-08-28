/obj/item/storage/dart_cartridge
	name = "dart cartridge"
	desc = "Подставка для дротиков."
	icon = 'modular_ss220/antagonists/icons/guns/ammo.dmi'
	icon_state = "darts-0"
	var/icon_state_base = "darts"
	var/overlay_state = "darts_overlay"
	var/overlay_state_color
	item_state = "rcdammo"
	origin_tech = "materials=2"
	storage_slots = 5
	can_hold = list(
		/obj/item/reagent_containers/syringe/dart
	)
	var/list/dart_fill_types = list()	// Каким дротиком заполним?
	var/dart_fill_num = 5	// Сколько дротиков заполним
	var/dart_overlay_num = 5 // Максимальное отображение дротиков на оверлее

/obj/item/storage/dart_cartridge/update_icon()
	. = ..()
	var/num = length(contents)
	if(!num)
		icon_state = "[icon_state_base]-0"
	else if(num > dart_overlay_num)
		icon_state = "[icon_state_base]-[dart_overlay_num]"
	else
		icon_state = "[icon_state_base]-[num]"
	return TRUE

/obj/item/storage/dart_cartridge/update_overlays()
	. = ..()
	if(overlay_state_color)
		. += "[overlay_state]_[overlay_state_color]"

/obj/item/storage/dart_cartridge/populate_contents()
	if(length(dart_fill_types))
		for(var/i in 1 to dart_fill_num+1) //На один больше чтобы фулл заряжался + 1 внутрь
			var/dart_type = length(dart_fill_types) == 1? dart_fill_types[1] : pick(dart_fill_types)
			new dart_type(src)
	update_icon()


/obj/item/reagent_containers/syringe/dart
	name = "dart"
	desc = "Дротик содержащий химические коктейли."
	icon = 'modular_ss220/antagonists/icons/objects/dart.dmi'
	amount_per_transfer_from_this = 15
	volume = 15


// ============= Картриджи =============

/obj/item/storage/dart_cartridge/extended
	name = "extended dart cartridge"
	desc = "Расширенная подставка для дротиков и шприцов."
	overlay_state_color = "ext"
	can_hold = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe/dart
	)

/obj/item/storage/dart_cartridge/big
	name = "capacious dart cartridge"
	desc = "Увеличенная подставка для дротиков."
	overlay_state_color = "big"
	storage_slots = 10
	dart_fill_num = 10

/obj/item/storage/dart_cartridge/combat
	name = "combat dart cartridge"
	desc = "Подставка для боевых дротиков для нанесения повреждений."
	overlay_state_color = "red"
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/combat)

/obj/item/storage/dart_cartridge/medical
	name = "medical dart cartridge"
	overlay_state_color = "teal"
	desc = "Подставка для полезных дротиков для восстановления."
	dart_fill_types = list(
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical/tainted,
		/obj/item/reagent_containers/syringe/dart/medical/tainted,
		/obj/item/reagent_containers/syringe/dart/medical/heal,
	)

/obj/item/storage/dart_cartridge/pain
	name = "pain dart cartridge"
	overlay_state_color = "yellow"
	desc = "Подставка для вредных дротиков, приносящих боль и страдания."
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/pain)

/obj/item/storage/dart_cartridge/drugs
	name = "drugs dart cartridge"
	overlay_state_color = "purple"
	desc = "Подставка для вредных дротиков-наркотиков."
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/drugs)

/obj/item/storage/dart_cartridge/big/random
	name = "big random dart cartridge"
	desc = "Случайный набор дротиков с химикатами."
	dart_fill_types = list(
		/obj/item/reagent_containers/syringe/dart/combat,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/pain,
		/obj/item/reagent_containers/syringe/dart/drugs,
		/obj/item/reagent_containers/syringe/dart/pancuronium,
		/obj/item/reagent_containers/syringe/dart/sarin,
		/obj/item/reagent_containers/syringe/dart/capulettium,
		/obj/item/reagent_containers/syringe/dart/bioterror,
		/obj/item/reagent_containers/syringe/dart/heparin,
		/obj/item/reagent_containers/syringe/dart/calomel,
		/obj/item/reagent_containers/syringe/dart/epinephrine,
		/obj/item/reagent_containers/syringe/dart/charcoal,
		/obj/item/reagent_containers/syringe/dart/antiviral
		)

// ============= Шприцы =============

/obj/item/reagent_containers/syringe/dart/combat
	name = "combat dart"
	desc = "Боевой дротик, заставляющий цель потерять равновесие и впоследствии обездвижиться."
	list_reagents = list("space_drugs" = 5, "ether" = 5, "haloperidol" = 5)

/obj/item/reagent_containers/syringe/dart/pain
	name = "pain dart"
	desc = "Зудящий порошок с примесью гистамина для страданий."
	list_reagents = list("itching_powder" = 10, "histamine" = 5)

/obj/item/reagent_containers/syringe/dart/drugs
	name = "pain dart"
	desc = "Отвратительная смесь наркотиков, вызывающая галлюцинации, потерю координации и рассудка."
	list_reagents = list(
		"space_drugs" = 5, "lsd" = 5, "fliptonium" = 2, "jenkem" = 2, "happiness" = 1)

/obj/item/reagent_containers/syringe/dart/antiviral
	name = "dart (spaceacillin)"
	desc = "Содержит противовирусные вещества."
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_containers/syringe/dart/charcoal
	name = "dart (charcoal)"
	desc = "Содержит древесный уголь для лечения токсинов и повреждений от них."
	list_reagents = list("charcoal" = 15)

/obj/item/reagent_containers/syringe/dart/epinephrine
	name = "dart (Epinephrine)"
	desc = "Содержит адреналин для стабилизации пациентов."
	list_reagents = list("epinephrine" = 15)

/obj/item/reagent_containers/syringe/dart/calomel
	name = "dart (calomel)"
	desc = "Содержит токсичный каломель для очистки от других веществ в организме."
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/syringe/dart/heparin
	name = "dart (heparin)"
	desc = "Содержит гепарин, антикоагулянт крови."
	list_reagents = list("heparin" = 15)

/obj/item/reagent_containers/syringe/dart/bioterror
	name = "bioterror dart"
	desc = "Содержит несколько парализующих реагентов."
	list_reagents = list("neurotoxin" = 5, "capulettium" = 5, "sodium_thiopental" = 5)

/obj/item/reagent_containers/syringe/dart/capulettium
	name = "capulettium dart"
	desc = "Для упокоения целей."
	list_reagents = list("capulettium" = 15)

/obj/item/reagent_containers/syringe/dart/sarin
	name = "toxin dart"
	desc = "Смертельный нейротоксин в малых дозах."
	list_reagents = list("sarin" = 15)

/obj/item/reagent_containers/syringe/dart/pancuronium
	name = "pancuronium dart"
	desc = "Мощный парализующий яд"
	list_reagents = list("pancuronium" = 15)


// ============= Шприцы - Медицинские =============

/obj/item/reagent_containers/syringe/dart/medical
	name = "medical dart"
	desc = "Медицинский дротик для восстановления большинства повреждений."
	list_reagents = list("silver_sulfadiazine" = 5, "styptic_powder" = 5, "charcoal" = 5)

// 1 уровень
/obj/item/reagent_containers/syringe/dart/medical/tainted
	name = "tainted medical dart"
	desc = "На вид будто этой капсулой зачерпнули из первичного бульона. Непонятно кто это сделал, но кажется оно должно лечить. Пахнет мерзко."
	list_reagents = list("menthol" = 3, "doctorsdelight" = 3, "synthnsoda" = 3, "tomatojuice" = 3, "milk" = 3)

// 2 уровень
/obj/item/reagent_containers/syringe/dart/medical/heal
	name = "heal medical dart"
	desc = "Медицинский дротик для лечения тяжелых травм."
	list_reagents = list("silver_sulfadiazine" = 5, "styptic_powder" = 5, "synthflesh" = 5)

/obj/item/reagent_containers/syringe/dart/medical/stabilizing
	name = "stabilizing medical dart"
	desc = "Медицинский дротик для стабилизации пациента."
	list_reagents = list("epinephrine" = 5, "salineglucosevirusfood" = 5, "weak_omnizine" = 5)

// 3 уровень (1 час)
/obj/item/reagent_containers/syringe/dart/medical/advanced
	name = "advanced medical dart"
	desc = "Медицинский дротик стимулирующий быструю регенерацию."
	list_reagents = list("bicaridine" = 5, "kelotane" = 5, "omnizine" = 5)

// 4 уровень (2 час)
/obj/item/reagent_containers/syringe/dart/medical/combat
	name = "combat medical dart"
	desc = "передовой дротик с эксперементальными стимулянтами."
	list_reagents = list("combatlube" = 5, "surge_plus" = 5, "syndicate_nanites" = 5)

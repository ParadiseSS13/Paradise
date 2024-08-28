// Броня ВОКСов.
// Дает хорошие защитные свойства, но не позволяет держать давление космоса.

/obj/item/clothing/suit/armor/vox_merc
	name = "vox mercenary vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением."
	icon_state = "vox-merc"
	item_color = "vox-merc"
	item_state = "armor"
	blood_overlay_type = "armor"
	species_restricted = list("Vox")
	icon = 'modular_ss220/antagonists/icons/clothing/obj_suit.dmi'
	icon_override = 'modular_ss220/antagonists/icons/clothing/mob/vox/suit.dmi'
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/suit.dmi'
		)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton,
		/obj/item/melee/energy/sword, /obj/item/shield/energy,
		/obj/item/restraints/handcuffs, /obj/item/tank/internals)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 20, BOMB = 25, RAD = 80, FIRE = 50, ACID = 50)
	strip_delay = 8 SECONDS
	put_on_delay = 6 SECONDS

/obj/item/clothing/head/helmet/vox_merc
	name = "vox mercenary helmet"
	desc = "Специализированный шлем воксов-наемников."
	icon_state = "vox-merc"
	item_color = "vox-merc"
	species_restricted = list("Vox")
	icon = 'modular_ss220/antagonists/icons/clothing/obj_head.dmi'
	icon_override = 'modular_ss220/antagonists/icons/clothing/mob/vox/head.dmi'
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/head.dmi'
		)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 20, BOMB = 25, RAD = 80, FIRE = 50, ACID = 50)
	flags = HEADBANGPROTECT | BLOCKHEADHAIR
	flags_inv =  HIDEMASK | HIDEEARS
	flags_cover = HEADCOVERSEYES
	cold_protection = HEAD
	heat_protection = HEAD
	dog_fashion = null


// Storm Trooper

/obj/item/clothing/suit/armor/vox_merc/stormtrooper
	name = "vox mercenary storm vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
	\nШтурмовой бронекостюм воксов разработан под их структуру тела и прикрывает наиболее уязвимые места, превосходно защищает носителя от огнестрельного вооружения и ближних атак."
	icon_state = "vox-merc-stormtrooper"
	item_color = "vox-merc-stormtrooper"
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 30, BOMB = 15, RAD = 80, FIRE = 50, ACID = 50)
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1

/obj/item/clothing/head/helmet/vox_merc/stormtrooper
	name = "vox mercenary helmet"
	icon_state = "vox-merc-stormtrooper"
	item_color = "vox-merc-stormtrooper"
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 30, BOMB = 15, RAD = 80, FIRE = 50, ACID = 50)


// Field Medic

/obj/item/clothing/suit/armor/vox_merc/fieldmedic
	name = "vox mercenary field medic vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
	\nМедицинский полевой костюм предназначен для защиты владельца от биологических угроз, радиации и кислотной атмосферы. Дает слабую защиту от внешне поступаемых энергетических снарядов, равномерно рассеивая остаточную энергию. Костюм абсолютно не предназначен для защиты в ближнем бою или от взрывчатых веществ за счет свое внутреннего строения, повреждающий носителя от осколков костюма при нарушении целостности. Имеет хранилище для ношения аптечек и контейнеров с химикатами."
	icon_state = "vox-merc-fieldmedic"
	item_color = "vox-merc-fieldmedic"
	armor = list(MELEE = -15, BULLET = 20, LASER = 50, ENERGY = 40, BOMB = -15, RAD = INFINITY, FIRE = 80, ACID = INFINITY)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	allowed = list(/obj/item/flashlight, /obj/item/storage/firstaid,
		/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton,
		/obj/item/melee/energy/sword, /obj/item/shield/energy,
		/obj/item/restraints/handcuffs, /obj/item/tank/internals,
		/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/robotanalyzer)

/obj/item/clothing/head/helmet/vox_merc/fieldmedic
	name = "vox mercenary field medic helmet"
	icon_state = "vox-merc-fieldmedic"
	item_color = "vox-merc-fieldmedic"
	armor = list(MELEE = -15, BULLET = 20, LASER = 50, ENERGY = 40, BOMB = -15, RAD = INFINITY, FIRE = 80, ACID = INFINITY)
	flags_inv =  HIDEMASK
	flags = HEADBANGPROTECT

// Bomber

/obj/item/clothing/suit/armor/vox_merc/bomber
	name = "vox mercenary bomber vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
	\nОсобый разработанный штурмовой тяжелый костюм для действий в условиях крайне взрывоопасной атмосферы. Абсолютная жаростойкость, повышенная стойкость к кислотным жидкостям и лазерному воздействию делают эту броню основной для воксов действующих внутри активно разрушающихся комплексов и кораблей."
	icon_state = "vox-merc-bomber"
	item_color = "vox-merc-bomber"
	armor = list(MELEE = 80, BULLET = 20, LASER = 115, ENERGY = 75, BOMB = 200, RAD = 115, FIRE = INFINITY, ACID = 150)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1.5

/obj/item/clothing/head/helmet/vox_merc/bomber
	name = "vox mercenary bomber helmet"
	icon_state = "vox-merc-bomber"
	item_color = "vox-merc-bomber"
	armor = list(MELEE = 80, BULLET = 20, LASER = 115, ENERGY = 75, BOMB = 200, RAD = 115, FIRE = INFINITY, ACID = 150)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT


// Laminar

/obj/item/clothing/suit/armor/vox_merc/laminar
	name = "vox mercenary laminar vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
	\nКомпактный и мобильный костюм отлично помещается в рюкзаке, сформирован из легких пластин позволяющий получить хорошие защитные свойства в совокупности с удобством для носителя, не мешающий его передвижению. Но, в отличии от других моделей, не дает приемлимых защитных параметров от воздействий внешней агрессивной среды и не защищает руки."
	icon_state = "vox-merc-laminar"
	item_color = "vox-merc-laminar"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET	// Руки уязвимые зоны.
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET
	armor = list(MELEE = 20, BULLET = 20, LASER = 40, ENERGY = 40, BOMB = 15, RAD = 20, FIRE = 20, ACID = 20)
	strip_delay = 2 SECONDS
	put_on_delay = 1 SECONDS

/obj/item/clothing/head/helmet/vox_merc/laminar
	name = "vox mercenary laminar helmet"
	icon_state = "vox-merc-laminar"
	item_color = "vox-merc-laminar"
	w_class = WEIGHT_CLASS_SMALL
	armor = list(MELEE = 20, BULLET = 20, LASER = 40, ENERGY = 40, BOMB = 15, RAD = 20, FIRE = 20, ACID = 20)
	flags_inv =  HIDEEARS|HIDEEYES

/obj/item/clothing/suit/armor/vox_merc/laminar/scout
	name = "vox mercenary laminar scout vest"
	desc = "Компактный и мобильный костюм сформированный из лёгких пластин и за счет их особого размещения, увеличивает погашение импульсов перенаправляя их в ускорение носителя, но взамен теряя значимые защитные свойства. "
	armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 40, BOMB = 40, RAD = 20, FIRE = 20, ACID = 20)
	slowdown = -0.35


// Stealth

// Crew Steath Suit
/obj/item/clothing/suit/armor/vox_merc/stealth
	name = "vox mercenary stealth suit"
	desc = "Специализированный маскировочный костюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
		Костюм с маскировочной системой, напрямую связанная с телом носителя. При снимании костюма возможно ощущение легкого недомогания."
	icon_state = "vox-merc-stealth"
	item_color = "vox-merc-stealth"
	blood_overlay_type = "suit"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = 80)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	var/datum/spell/disguise_self/vox/disguise_spell

/datum/spell/disguise_self/vox
	name = "Маскировка"
	desc = "Замаскируйтесь под члена экипажа с его голосом в текущей зоне. \
		Внимательный осмотр выдаст вас. Если повредить маскировку - она сбросится."
	invocation = "none"
	invocation_type = "none"

/obj/item/clothing/suit/armor/vox_merc/stealth/equipped(mob/living/user, slot)
	..()
	if(isvox(user) && slot == SLOT_HUD_OUTER_SUIT)
		disguise_spell = new(null)
		user.AddSpell(disguise_spell)

/obj/item/clothing/suit/armor/vox_merc/stealth/dropped(mob/user)
	. = ..()
	if(user && disguise_spell)
		user.RemoveSpell(disguise_spell)
		QDEL_NULL(disguise_spell)
		// сбрасываем спел нанеся чутка урон
		SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, 5, BRUTE)

/obj/item/clothing/suit/armor/vox_merc/stealth/Destroy()
	. = ..()
	if(disguise_spell)
		QDEL_NULL(disguise_spell)

// Smoke Helmet
/obj/item/clothing/head/helmet/vox_merc/stealth
	name = "vox mercenary stealth helmet"
	desc = "Специализированный шлем воксов-наемников со встроенной системой дымогенератора."
	icon_state = "vox-merc-stealth"
	item_color = "vox-merc-stealth"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = 80)
	flags = HEADBANGPROTECT
	flags_inv =  HIDEMASK|HIDEEARS|HIDEEYES
	var/datum/spell/smoke/smoke_spell

/datum/spell/smoke
	name = "Дымовой занавес"
	desc = "Выпустить дымовую занавесу скрывающее поле зрение всех находящихся в нём в ближайшей зоне."

/obj/item/clothing/head/helmet/vox_merc/stealth/equipped(mob/living/user, slot)
	..()
	if(isvox(user) && slot == SLOT_HUD_HEAD)
		smoke_spell = new(null)
		user.AddSpell(smoke_spell)

/obj/item/clothing/head/helmet/vox_merc/stealth/dropped(mob/user)
	. = ..()
	if(user && smoke_spell)
		user.RemoveSpell(smoke_spell)
		QDEL_NULL(smoke_spell)

/obj/item/clothing/head/helmet/vox_merc/stealth/Destroy()
	. = ..()
	if(smoke_spell)
		QDEL_NULL(smoke_spell)

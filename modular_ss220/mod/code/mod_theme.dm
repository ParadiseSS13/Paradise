// MARK: MODsuit Theme
/datum/mod_theme
	/// Which species are allowed to deploy MODsuit. Consider empty list as no restriction.
	var/list/species_allowed = list()

/datum/mod_theme/proc/is_species_allowed(datum/species/species)
	if(!length(species_allowed))
		return TRUE
	if(!(species.name in species_allowed))
		return FALSE
	return TRUE

/mob/living/carbon/human/change_dna(datum/dna/new_dna, include_species_change)
	if(istype(back, /obj/item/mod/control))
		INVOKE_ASYNC(back, TYPE_PROC_REF(/obj/item/mod/control, pre_species_gain), new_dna.species)
	return ..()

/mob/living/carbon/human/set_species(datum/species/new_species, use_default_color = FALSE, delay_icon_update = FALSE, skip_same_check = FALSE, retain_damage = FALSE, transformation = FALSE, keep_missing_bodyparts = FALSE)
	if(istype(back, /obj/item/mod/control))
		INVOKE_ASYNC(back, TYPE_PROC_REF(/obj/item/mod/control, pre_species_gain), new_species)
	return ..()

// MARK: Skrell elite MODsuit - Raskinta
/datum/mod_theme/skrell_raskinta
	name = "\improper raskinta"
	desc = "Боевая броня с функцией костюма для ВКД, созданная для воинов Раскинта Ме'керр-Кэтиш."
	extended_desc = "Массивный бронекостюм, выполненный в черно-синих цветах, является отличительной чертой  \
		военных формирований Раскинта-Кэтиш. Защитные пластины состоят из укрепленной керамики, в то время как \
		каркасные пластины выполнены из сплавов вороной пластали, позволяющей эффективно поглощать и рассеивать энергию \
		через радиаторные отводы на \"хвостовых\" окончаниях шлема. \
		Этот костюм является самым часто встречаемым в штурмовых отрядах Оборонительных Сил Скреллов."
	default_skin = "skrell_elite"
	armor_type_1 = /obj/item/mod/armor/mod_theme_skrell_raskinta
	flag_2_flags = RAD_PROTECT_CONTENTS_2
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
		/obj/item/melee/vibroblade,
	)
	species_allowed = list("Skrell")
	skins = list(
		"skrell_elite" = list(
			MOD_ICON_OVERRIDE = 'modular_ss220/mod/icons/object/mod_clothing.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_skrell_raskinta
	armor = list(MELEE = 40, BULLET = 25, LASER = 25, ENERGY = 20, BOMB = 25, RAD = INFINITY, FIRE = 200, ACID = 200)

// MARK: Skrell elite MODsuit - Sardaukars
/datum/mod_theme/skrell_sardaukars
	name = "\improper emperor guard"
	desc = "Элитная боевая броня гвардейцев Скреллианской империи."
	extended_desc = "Благодаря высшим технологическим достижениям скреллов этот костюм сочетает в себе \
		невероятные показатели защищенности и мобильности, являясь незаменимой вещью на вооружении свирепых Куи'кверр-Кэтиш. \
		Носящие его воины являются личной гвардией Императора и выполняют самые сложные задачи по его воле. \
		Кроваво-белоснежные цвета, отождествляющие кровь врагов и власть Его Величества, скорее всего последнее \
		что вы увидите в своей жизни."
	default_skin = "skrell_white"
	armor_type_1 = /obj/item/mod/armor/mod_theme_skrell_sardaukars
	resistance_flags = FIRE_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
		/obj/item/melee/vibroblade,
	)
	species_allowed = list("Skrell")
	skins = list(
		"skrell_white" = list(
			MOD_ICON_OVERRIDE = 'modular_ss220/mod/icons/object/mod_clothing.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_skrell_sardaukars
	armor = list(MELEE = 120, BULLET = 120, LASER = 100, ENERGY = 50, BOMB = 100, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)

//MARK: Corporate MODsuit
/datum/mod_theme/corporate/New()
	. = ..()
	skins["corporate"][MOD_ICON_OVERRIDE] = 'modular_ss220/mod/icons/object/mod_clothing.dmi'

//MARK: ERT Red MODsuit
/datum/mod_theme/responsory/red
	name = "\improper 'Rhino' responsory"
	desc = "Высокотехнологичный боевой MODsuit 'Носорог', разработанный и произведенный Нанотрейзен. Хорошо бронированный, герметичный и оснащенный всевозможными полезными приспособлениями. \
		Лучшее корпоративное оборудование для обеспечения безопасности."
	extended_desc = "Костюм быстрого реагирования NS-20 'Носорог' - один из самых лучших в категории 'цена и качество' из всех боевых костюмов на рынке. \
		Внутри NS-20 установлена система NTOS-11, что позволяет использовать несравненные возможности настройки в сочетании с \
		необычайно щедрыми техническими характеристиками 'Носорога'. NS-20 можно встретить только в отряде быстрого реагирования Нанотрейзен."
	default_skin = "rhino"
	armor_type_1 = /obj/item/mod/armor/mod_theme_responsory/red
	resistance_flags = FIRE_PROOF
	flag_2_flags = RAD_PROTECT_CONTENTS_2
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	species_allowed = list("Human")
	skins = list(
		"rhino" = list(
			MOD_ICON_OVERRIDE = 'modular_ss220/mod/icons/object/mod_clothing.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEEARS | HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"inquisitory" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE | HIDEMASK | HIDEEARS | HIDEEYES,
				UNSEALED_COVER = HEADCOVERSMOUTH | HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT | HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_responsory/red
	armor = list(MELEE = 30, BULLET = 25, LASER = 25, ENERGY = 15, BOMB = 40, RAD = 25, FIRE = INFINITY, ACID = 150)


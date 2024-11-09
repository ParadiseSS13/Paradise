// MARK: MODsuit clothes
/obj/item/clothing/head/mod/exclusive
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	item_state = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	sprite_sheets = list(
		"Skrell" = 'modular_ss220/clothing/icons/mob/species/skrell/mod_clothing.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/mod_clothing.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/mod_clothing.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/species/tajaran/mod_clothing.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/mod_clothing.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/mod_clothing.dmi',
		)

/obj/item/clothing/suit/mod/exclusive
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	item_state = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	sprite_sheets = list(
		"Skrell" = 'modular_ss220/clothing/icons/mob/species/skrell/mod_clothing.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/mod_clothing.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/mod_clothing.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/species/tajaran/mod_clothing.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/mod_clothing.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/mod_clothing.dmi',
		)

/obj/item/clothing/gloves/mod/exclusive
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	item_state = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	sprite_sheets = list(
		"Skrell" = 'modular_ss220/clothing/icons/mob/species/skrell/mod_clothing.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/mod_clothing.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/mod_clothing.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/species/tajaran/mod_clothing.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/mod_clothing.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/mod_clothing.dmi',
		)

/obj/item/clothing/shoes/mod/exclusive
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	item_state = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'
	sprite_sheets = list(
		"Skrell" = 'modular_ss220/clothing/icons/mob/species/skrell/mod_clothing.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/mod_clothing.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/mod_clothing.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/species/tajaran/mod_clothing.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/mod_clothing.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/mod_clothing.dmi',
		)

// MARK: MODsuit control
/obj/item/mod/control/proc/build_head()
	return new /obj/item/clothing/head/mod(src)

/obj/item/mod/control/proc/build_suit()
	return new /obj/item/clothing/suit/mod(src)

/obj/item/mod/control/proc/build_gloves()
	return new /obj/item/clothing/gloves/mod(src)

/obj/item/mod/control/proc/build_shoes()
	return new /obj/item/clothing/shoes/mod(src)

/obj/item/mod/control/proc/is_any_part_deployed()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			return TRUE
	return FALSE

// This is kinda sick but we need to retract it before the actual species change.
/obj/item/mod/control/proc/pre_species_gain(datum/species/new_species)
	if(!wearer)
		return
	if(is_any_part_deployed() && !theme.is_species_allowed(new_species))
		// Deactivate MODsuit to respect the species allowed.
		to_chat(wearer, span_warning("Ошибка видовой принадлежности! Деактивация."))
		if(active)
			var/old_activation_step_time = activation_step_time
			activation_step_time = 0.1 SECONDS // gotta go fast
			toggle_activate(wearer, force_deactivate = TRUE)
			activation_step_time = old_activation_step_time
		quick_deploy(wearer)

/obj/item/mod/control/quick_deploy(mob/user)
	user = user || loc // why the fuck this is nullable
	if(!is_any_part_deployed() && !theme.is_species_allowed(user.dna.species))
		to_chat(user, span_warning("Ошибка видовой принадлежности! Развертывание недоступно."))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	return ..()

/obj/item/mod/control/deploy(mob/user, obj/item/part, mass)
	user = user || loc // why the fuck this is nullable
	if(!mass && part.loc != user && !theme.is_species_allowed(user.dna.species))
		to_chat(user, span_warning("Ошибка видовой принадлежности! Развертывание недоступно."))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	return ..()

/obj/item/mod/control/pre_equipped/exclusive
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'

/obj/item/mod/control/pre_equipped/exclusive/build_head()
	return new /obj/item/clothing/head/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_suit()
	return new /obj/item/clothing/suit/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_gloves()
	return new /obj/item/clothing/gloves/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/exclusive/build_shoes()
	return new /obj/item/clothing/shoes/mod/exclusive(src)

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
			MOD_ICON_OVERRIDE = 'modular_ss220/clothing/icons/object/mod_clothing.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
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

/obj/item/mod/control/pre_equipped/exclusive/skrell_raskinta
	theme = /datum/mod_theme/skrell_raskinta
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
	)

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
			MOD_ICON_OVERRIDE = 'modular_ss220/clothing/icons/object/mod_clothing.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL | STOPSPRESSUREDMAGE | BLOCK_GAS_SMOKE_EFFECT | BLOCKHAIR,
				UNSEALED_INVISIBILITY = HIDEFACE,
				SEALED_INVISIBILITY = HIDEMASK | HIDEEYES | HIDEFACE,
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

/obj/item/mod/control/pre_equipped/exclusive/skrell_sardaukars
	theme = /datum/mod_theme/skrell_sardaukars
	applied_cell = /obj/item/stock_parts/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/visor/thermal
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/visor/thermal
	)

/obj/item/mod/control/pre_equipped/exclusive/skrell_sardaukars/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

// MARK: Corporate MODsuit
/obj/item/mod/control/pre_equipped/corporate
	icon = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mod_clothing.dmi'

/datum/mod_theme/corporate/New()
	. = ..()
	skins["corporate"][MOD_ICON_OVERRIDE] = 'modular_ss220/clothing/icons/object/mod_clothing.dmi'

/obj/item/mod/control/pre_equipped/corporate/build_head()
	return new /obj/item/clothing/head/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_suit()
	return new /obj/item/clothing/suit/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_gloves()
	return new /obj/item/clothing/gloves/mod/exclusive(src)

/obj/item/mod/control/pre_equipped/corporate/build_shoes()
	return new /obj/item/clothing/shoes/mod/exclusive(src)

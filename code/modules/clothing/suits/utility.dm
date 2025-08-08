/*
 * Contains:
 *		Fire protection
 *		Bomb protection
 *		Radiation protection
 */

/*
 * Fire protection
 */

/obj/item/clothing/suit/fire
	name = "emergency firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	inhand_icon_state = "fire_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/extinguisher)
	slowdown = 1
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 10, FIRE = INFINITY, ACID = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 60
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/fire/firefighter
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	icon_state = "firefighter"
	inhand_icon_state = null
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suits/utility.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suits/utility.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suits/utility.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suits/utility.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/utility.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/utility.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/utility.dmi'
	)

/obj/item/clothing/suit/fire/firefighter/atmos
	name = "firesuit"
	desc = "An expensive firesuit that protects against even the most deadly of station fires. Designed to protect even if the wearer is set aflame."
	icon_state = "firefighter_atmos"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/*
 * Bomb protection
 */
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bombsuit"
	flags = BLOCKHAIR | THICKMATERIAL
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 5, BOMB = INFINITY, RAD = 0, FIRE = 200, ACID = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
		)

/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 5, BOMB = INFINITY, RAD = 0, FIRE = 200, ACID = 50)
	flags_inv = HIDEJUMPSUIT|HIDETAIL
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = NONE
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"


/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	allowed = list(/obj/item/gun/energy,/obj/item/melee/baton,/obj/item/restraints/handcuffs)

/*
 * Radiation protection
 */
/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon = 'icons/obj/clothing/head/utility.dmi'
	icon_state = "radhood"
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	flags = BLOCKHAIR|THICKMATERIAL
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = INFINITY, FIRE = 20, ACID = 20)
	strip_delay = 60
	put_on_delay = 60
	resistance_flags = NONE
	flags_2 = RAD_PROTECT_CONTENTS_2
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/utility.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head/utility.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head/utility.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head/utility.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head/utility.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/utility.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head/utility.dmi'
	)
	rad_insulation_alpha = RAD_FULL_INSULATION
	rad_insulation_beta = RAD_FULL_INSULATION
	rad_insulation_gamma = RAD_FULL_INSULATION

/obj/item/clothing/suit/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon = 'icons/obj/clothing/suits/utility.dmi'
	icon_state = "radsuit"
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen, /obj/item/geiger_counter)
	slowdown = 0.75
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = INFINITY, FIRE = 20, ACID = 20)
	flags_inv = HIDEJUMPSUIT|HIDETAIL
	strip_delay = 60
	put_on_delay = 60
	resistance_flags = NONE
	flags_2 = RAD_PROTECT_CONTENTS_2
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suits/utility.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suits/utility.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suits/utility.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suits/utility.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/utility.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/utility.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/utility.dmi'
	)
	rad_insulation_alpha = RAD_FULL_INSULATION
	rad_insulation_beta = RAD_FULL_INSULATION
	rad_insulation_gamma = RAD_FULL_INSULATION

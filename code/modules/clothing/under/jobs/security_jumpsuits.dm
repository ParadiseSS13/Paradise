/obj/item/clothing/under/rank/security
	icon = 'icons/obj/clothing/under/security.dmi'
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	strip_delay = 50
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/security.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/security.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/security.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/security.dmi'
		)


/obj/item/clothing/under/rank/security/warden
	name = "warden's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	icon_state = "warden"
	item_state = "r_suit"
	item_color = "warden"

/obj/item/clothing/under/rank/security/warden/skirt
	name = "warden's jumpskirt"
	desc = "Standard feminine fashion for a Warden. It is made of sturdier material than standard jumpskirts. It has the word \"Warden\" written on the shoulders."
	icon_state = "warden_skirt"
	item_state = "r_suit"
	item_color = "warden_skirt"

/obj/item/clothing/under/rank/security/warden/skirt/corporate
	icon_state = "warden_corporate_skirt"
	item_state = "warden_corporate_skirt"
	item_color = "warden_corporate_skirt"

/obj/item/clothing/under/rank/security/officer
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "security"
	item_state = "r_suit"
	item_color = "security"

/obj/item/clothing/under/rank/security/officer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/officer/skirt
	name = "security officer's jumpskirt"
	desc = "Standard feminine fashion for Security Officers.  It's made of sturdier material than the standard jumpskirts."
	icon_state = "security_skirt"
	item_state = "r_suit"
	item_color = "security_skirt"

/obj/item/clothing/under/rank/security/officer/skirt/corporate
	name = "corporate security jumpskirt"
	icon_state = "sec_corporate_skirt"
	item_state = "sec_corporate_skirt"
	item_color = "sec_corporate_skirt"

/obj/item/clothing/under/rank/security/officer/fancy
	name = "security dress shirt"
	desc = "A red dress shirt paired with a pair of black trousers, for the more formal Security Officer."
	icon_state = "sec_shirt"
	item_state = "sec_shirt"
	item_color = "sec_shirt"

/obj/item/clothing/under/rank/security/officer/skirt/fancy
	name = "security dress skirt"
	desc = "A red blouse paired with a black skirt, for the more formal Security Officer."
	icon_state = "sec_shirt_skirt"
	item_state = "sec_shirt_skirt"
	item_color = "sec_shirt_skirt"

/obj/item/clothing/under/rank/security/officer/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon_state = "dispatch"
	item_state = "dispatch"
	item_color = "dispatch"

/obj/item/clothing/under/rank/security/officer/uniform
	name = "security officer's uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon_state = "redshirt" //pants, actually
	item_state = "r_suit"
	item_color = "redshirt"

/obj/item/clothing/under/rank/security/officer/corporate
	name = "corporate security jumpsuit"
	icon_state = "sec_corporate"
	item_state = "sec_corporate"
	item_color = "sec_corporate"

/obj/item/clothing/under/rank/security/warden/corporate
	icon_state = "warden_corporate"
	item_state = "warden_corporate"
	item_color = "warden_corporate"

/*
 * Detective
 */
/obj/item/clothing/under/rank/security/detective
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	item_color = "detective"
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/security.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/security.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/security.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/security.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/security.dmi'
		)

/obj/item/clothing/under/rank/security/detective/skirt
	name = "detective's jumpskirt"
	icon_state = "det_skirt"
	item_color = "det_skirt"

/obj/item/clothing/under/rank/security/detective/black
	name = "forensics jumpsuit"
	desc = "A black forensics technician jumpsuit."
	icon_state = "det_black"
	item_color = "det_black"


/*
 * Head of Security
 */
/obj/item/clothing/under/rank/security/head_of_security
	name = "head of security's jumpsuit"
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	icon_state = "hos"
	item_state = "r_suit"
	item_color = "hos"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60

/obj/item/clothing/under/rank/security/head_of_security/skirt
	name = "head of security's jumpskirt"
	desc = "It's a fashionable jumpskirt worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	icon_state = "hos_skirt"
	item_state = "r_suit"
	item_color = "hos_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/security/head_of_security/corporate
	icon_state = "hos_corporate"
	item_state = "hos_corporate"
	item_color = "hos_corporate"

/obj/item/clothing/under/rank/security/head_of_security/skirt/corporate
	icon_state = "hos_corporate_skirt"
	item_state = "hos_corporate_skirt"
	item_color = "hos_corporate_skirt"

/obj/item/clothing/under/rank/security/formal
	name = "security suit"
	desc = "A formal security suit for officers complete with nanotrasen belt buckle."
	icon_state = "sec_formal"
	item_state = "gy_suit"
	item_color = "sec_formal"

/obj/item/clothing/under/rank/security/formal/warden
	name = "warden's suit"
	desc = "A formal security suit for the warden with blue desginations and '/Warden/' stiched into the shoulders."
	icon_state = "warden_formal"
	item_state = "gy_suit"
	item_color = "warden_formal"

/obj/item/clothing/under/rank/security/formal/head_of_security
	name = "head of security's suit"
	desc = "A security suit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "hos_formal"
	item_state = "gy_suit"
	item_color = "hos_formal"


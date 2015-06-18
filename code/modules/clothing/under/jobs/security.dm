/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */
/obj/item/clothing/under/rank/warden
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "warden"
	item_state = "r_suit"
	_color = "warden"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "security"
	item_state = "r_suit"
	_color = "secred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon_state = "dispatch"
	item_state = "dispatch"
	_color = "dispatch"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security2
	name = "security officer's uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon_state = "redshirt2"
	item_state = "r_suit"
	_color = "redshirt2"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security/corp
	icon_state = "sec_corporate"
	item_state = "sec_corporate"
	_color = "sec_corporate"

/obj/item/clothing/under/rank/warden/corp
	icon_state = "warden_corporate"
	item_state = "warden_corporate"
	_color = "warden_corporate"

/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	_color = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hos"
	item_state = "r_suit"
	_color = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/head_of_security/corp
	icon_state = "hos_corporate"
	item_state = "hos_corporate"
	_color = "hos_corporate"

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state = "jensen"
	_color = "jensen"
	siemens_coefficient = 0.6
	flags = ONESIZEFITSALL

//Paradise Station

/obj/item/clothing/suit/armor/hos/hosnavyjacket
	name = "head of security navy jacket"
	icon_state = "hosdnavyjacket"
	item_state = "hosdnavyjacket"

/obj/item/clothing/suit/armor/hos/hosbluejacket
	name = "head of security blue jacket"
	icon_state = "hosbluejacket"
	item_state = "hosbluejacket"

/obj/item/clothing/suit/armor/hos/officernavyjacket
	name = "officer's navy jacket"
	icon_state = "officernavyjacket"
	item_state = "officernavyjacket"

/obj/item/clothing/suit/armor/hos/officerbluejacket
	name = "officer's blue jacket"
	icon_state = "officerbluejacket"
	item_state = "officerbluejacket"

//TG Station

/obj/item/clothing/under/rank/security/formal
	name = "security suit"
	desc = "A formal security suit for officers complete with nanotrasen belt buckle."
	icon_state = "security_formal"
	item_state = "gy_suit"
	_color = "security_formal"

/obj/item/clothing/under/rank/warden/formal
	name = "warden's suit"
	desc = "A formal security suit for the warden with blue desginations and '/Warden/' stiched into the shoulders."
	icon_state = "warden_formal"
	item_state = "gy_suit"
	_color = "warden_formal"

/obj/item/clothing/under/rank/head_of_security/formal
	name = "head of security's suit"
	desc = "A security suit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "hos_formal"
	item_state = "gy_suit"
	_color = "hos_formal"


//Brig Physician
/obj/item/clothing/under/rank/security/brigphys
	desc = "Jumpsuit for Brig Physician it has both medical and security protection."
	name = "brig physician's jumpsuit"
	icon_state = "brig_phys"
	item_state = "brig_phys"
	_color = "brig_phys"
	permeability_coefficient = 0.50
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	flags = ONESIZEFITSALL
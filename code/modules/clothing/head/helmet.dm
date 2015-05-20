/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = HEADCOVERSEYES | HEADBANGPROTECT
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	siemens_coefficient = 0.7
	loose = 4 // generally well seated

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "swat"
	item_state = "swat-alt"
	armor = list(melee = 25, bullet = 80, laser = 10, energy = 10, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | HEADBANGPROTECT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = HEADCOVERSEYES
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	siemens_coefficient = 0.5

/obj/item/clothing/head/helmet/swat/syndicate
	name = "blood-red helmet"
	desc = "An extremely robust, space-worthy helmet without a visor to allow for goggle usage underneath. Property of Gorlex Marauders."
	icon_state = "helmetsyndi"
	item_state = "helmet"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags = HEADCOVERSEYES
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = HEADCOVERSEYES | BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	siemens_coefficient = 1
	loose = 0 // full head, won't fall off

obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags = HEADCOVERSEYES
	item_state = "redtaghelm"
	armor = list(melee = 30, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES

obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags = HEADCOVERSEYES
	item_state = "bluetaghelm"
	armor = list(melee = 30, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES

obj/item/clothing/head/blob
	name = "blob hat"
	desc = "A collectible hat handed out at the latest Blob Family Reunion."
	icon_state = "blobhat"
	item_state = "blobhat"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

//Commander
/obj/item/clothing/head/helmet/ert/command
	name = "emergency response team commander helmet"
	desc = "An in-atmosphere helmet worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "emergency response team security helmet"
	desc = "An in-atmosphere helmet worn by security members of the NanoTrasen Emergency Response Team. Has red highlights."
	icon_state = "erthelmet_sec"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "An in-atmosphere helmet worn by engineering members of the NanoTrasen Emergency Response Team. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "emergency response team medical helmet"
	desc = "A set of armor worn by medical members of the NanoTrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_med"

//Medical
/obj/item/clothing/head/helmet/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A set of armor worn by janitorial members of the NanoTrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_jan"
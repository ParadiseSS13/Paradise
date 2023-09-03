/obj/item/clothing/under/rank/centcom
	name = "\improper CentComm officer's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm Officers."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"

	icon = 'icons/obj/clothing/under/centcom.dmi'
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/centcom.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/centcom.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/centcom.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/centcom.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/centcom.dmi'
		)

/obj/item/clothing/under/rank/centcom/ert
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom/deathsquad
	name = "\improper Deathsquad jumpsuit"
	desc = "It's decorative jumpsuit worn by the Deathsquad. A small tag at the bottom reads \"Not associated with Nanotrasen\". "
	icon_state = "deathsquad"
	item_state = "deathsquad"
	item_color = "deathsquad"
	sensor_mode = SENSOR_OFF // You think the Deathsquad wants to be seen?
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom/ert/chaplain
	name = "response team inquisitor uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to an inquisitor."
	icon_state = "ert_chaplain"
	item_state = "ert_chaplain"
	item_color = "ert_chaplain"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/commander
	name = "response team commander uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to the command officer."
	icon_state = "ert_commander"
	item_state = "ert_commander"
	item_color = "ert_commander"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/engineer
	name = "response team engineer uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to an engineer."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"
	item_color = "ert_engineer"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/janitor
	name = "response team janitor uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a janitor."
	icon_state = "ert_janitor"
	item_state = "ert_janitor"
	item_color = "ert_janitor"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/medical
	name = "response team medic uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a medic."
	icon_state = "ert_medic"
	item_state = "ert_medic"
	item_color = "ert_medic"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/security
	name = "response team security uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a security officer."
	icon_state = "ert_security"
	item_state = "ert_security"
	item_color = "ert_security"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentComm commander's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm's highest-tier Commanders."
	icon_state = "centcom"
	item_state = "dg_suit"
	item_color = "centcom"

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper Nanotrasen naval officer's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant-Commander\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain
	name = "\improper Nanotrasen naval captain's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain/solgov
	name = "\improper Trans-Solar Federation commander's uniform"
	desc = "Gold trim on space-black cloth, this uniform is worn by generals of the Trans-Solar Federation. It has exotic materials for protection."

/obj/item/clothing/under/rank/centcom/representative
	name = "\improper Nanotrasen representative's uniform"
	desc = "Fine black cotton pants and white shirt with blue and gold trim."
	icon_state = "ntrep"
	item_state = "ntrep"
	item_color = "ntrep"

/obj/item/clothing/under/rank/centcom/representative/skirt
	name = "\improper Nanotrasen representative's skirt"
	desc = "A silky black skirt and white shirt with blue and gold trim."
	icon_state = "ntrep_skirt"
	item_state = "ntrep_skirt"
	item_color = "ntrep_skirt"

/obj/item/clothing/under/rank/centcom/representative/formal
	name = "formal Nanotrasen representative's uniform"
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "ntrep_formal"
	item_state = "ntrep_formal"
	item_color = "ntrep_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/representative/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a blue tie, this uniform bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/centcom/magistrate
	name = "magistrate's uniform"
	desc = "Fine black cotton pants and white shirt with a black tie and gold trim."
	icon_state = "magistrate"
	item_state = "magistrate"
	item_color = "magistrate"

/obj/item/clothing/under/rank/centcom/magistrate/skirt
	name = "magistrate's skirt"
	desc = "A silky black skirt and white shirt with a black tie and gold trim."
	icon_state = "magistrate_skirt"
	item_state = "magistrate_skirt"
	item_color = "magistrate_skirt"

/obj/item/clothing/under/rank/centcom/magistrate/formal
	name = "formal magistrate's uniform"
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "magistrate_formal"
	item_state = "magistrate_formal"
	item_color = "magistrate_formal"
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/magistrate/formal/Initialize(mapload)
	. = ..()
	desc = "A formal black suit with gold trim and a snazzy red tie, this uniform displays the rank of \"Magistrate\" and bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/centcom/diplomatic
	name = "\improper Nanotrasen diplomatic uniform"
	desc = "A very gaudy and official looking uniform of the Nanotrasen Diplomatic Corps."
	icon_state = "presidente"
	item_state = "g_suit"
	item_color = "presidente"
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/blueshield
	name = "blueshield's uniform"
	desc = "A short-sleeved black uniform, paired with grey armored cargo pants, all made out of a sturdy material. Blueshield standard issue."
	icon_state = "blueshield"
	item_state = "blueshield"
	item_color = "blueshield"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/blueshield/skirt
	name = "blueshield's skirt"
	desc = "A short, black and grey with blue markings skirted uniform. For the feminine Blueshield."
	icon_state = "blueshield_skirt"
	item_state = "blueshield_skirt"
	item_color = "blueshield_skirt"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/blueshield/formal
	name = "formal blueshield's uniform"
	desc = "A formal black suit with blue trim and tie, this uniform bears \"Close Protection\" on the left shoulder. It's got exotic materials for protection."
	icon_state = "blueshield_formal"
	item_state = "blueshield_formal"
	item_color = "blueshield_formal"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

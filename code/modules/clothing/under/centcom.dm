/obj/item/clothing/under/rank/centcom
	name = "\improper CentComm officer's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm Officers."
	icon = 'icons/obj/clothing/under/centcom.dmi'
	icon_state = "officer"
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'
	inhand_icon_state = "g_suit"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/centcom.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/centcom.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/centcom.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/centcom.dmi'
	)

/obj/item/clothing/under/rank/centcom/ert
	inhand_icon_state = "bl_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom/deathsquad
	name = "\improper Deathsquad jumpsuit"
	desc = "It's decorative jumpsuit worn by the Deathsquad. A small tag at the bottom reads \"Not associated with Nanotrasen\". "
	icon_state = "deathsquad"
	inhand_icon_state = "bl_suit"
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom/ert/chaplain
	name = "response team chaplain uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a chaplain."
	icon_state = "ert_chaplain"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/commander
	name = "response team commander uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to the command officer."
	icon_state = "ert_commander"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/engineer
	name = "response team engineer uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to an engineer."
	icon_state = "ert_engineer"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/janitor
	name = "response team janitor uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a janitor."
	icon_state = "ert_janitor"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/medical
	name = "response team medic uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a medic."
	icon_state = "ert_medic"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/ert/security
	name = "response team security uniform"
	desc = "An armoured uniform designed for emergency response teams. This one belongs to a security officer."
	icon_state = "ert_security"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentComm commander's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm's highest-tier Commanders."
	icon_state = "centcom"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper Nanotrasen naval officer's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant-Commander\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	inhand_icon_state = null
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain
	name = "\improper Nanotrasen naval captain's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	inhand_icon_state = null
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain/solgov
	name = "\improper TSF staff officer's uniform"
	desc = "Gold trim on space-black cloth, this uniform is worn by high-ranking officers of the Trans-Solar Federation. It has exotic materials for protection."

/obj/item/clothing/under/rank/centcom/diplomatic
	name = "\improper Nanotrasen diplomatic uniform"
	desc = "A very gaudy and official looking uniform of the Nanotrasen Diplomatic Corps."
	icon_state = "presidente"
	displays_id = FALSE

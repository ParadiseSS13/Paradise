//Base items
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artist's favorite headwear."
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret"
	item_state = 'icons/mob/clothing/head/beret.dmi'
	icon_override = 'icons/mob/clothing/head/beret.dmi'
	dog_fashion = /datum/dog_fashion/head/beret

	sprite_sheets = list(
		"Kidan" = 'icons/mob/clothing/species/kidan/head/beret.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi'
		)

/obj/item/clothing/head/beret/blue
	icon_state = "beret_blue"

/obj/item/clothing/head/beret/black
	icon_state = "beret_black"

/obj/item/clothing/head/beret/white
	icon_state = "beret_white"

/obj/item/clothing/head/beret/purple_normal
	icon_state = "beret_purple_normal"

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc = "A beret made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "beret_durathread"
	item_color = null
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = 20, ACID = 5)

//Central Command
/obj/item/clothing/head/beret/centcom/officer
	name = "officer beret"
	desc = "A black beret adorned with the shield—a silver kite shield with an engraved sword—of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "beret_centcom_officer"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/centcom/officer/navy
	name = "navy blue officer beret"
	desc = "A navy blue beret adorned with the shield—a silver kite shield with an engraved sword—of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "beret_centcom_officer_navy"

/obj/item/clothing/head/beret/centcom/captain
	name = "naval captain's beret"
	desc = "A white beret adorned with the shield—a cobalt kite shield with an engraved sword—of the Nanotrasen security forces, worn only by those captaining a vessel of the Nanotrasen Navy."
	icon_state = "beret_centcom_captain"

//Captain
/obj/item/clothing/head/beret/captain
	name = "captain's beret"
	desc = "For Captains that are more inclined towards style."
	icon_state = "beret_captain"
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi',
		)

/obj/item/clothing/head/beret/captain/white
	name = "captain's white beret"
	desc = "For Captains that are more inclined towards style, and for the color white."
	icon_state = "beret_captain_white"

//Security
/obj/item/clothing/head/beret/hos
	name = "head of security's beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "beret_hos_black"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	strip_delay = 80
	dog_fashion = /datum/dog_fashion/head/hos

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_officer"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/beret/sec

/obj/item/clothing/head/beret/warden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "beret_warden"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 20, ACID = 50)

//Engineering
/obj/item/clothing/head/beret/ce
	name = "chief engineer's beret"
	desc = "A white beret with the engineering insignia emblazoned on it. Its owner knows what they're doing. Probably."
	icon_state = "beret_ce"

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "beret_engineering"

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "A beret for those who have shown immaculate proficienty in piping. Or plumbing."
	icon_state = "beret_atmospherics"

//Science
/obj/item/clothing/head/beret/sci
	name = "science beret"
	desc = "A white beret with a purple science insignia emblazoned on it. It has that authentic smell of burning plasma."
	icon_state = "beret_science"

/obj/item/clothing/head/beret/robowhite
	name = "robotics beret"
	desc = "A white beret with a brown robotics insignia emblazoned on it. It smells distinctly like oil."
	icon_state = "beret_roboticswhite"

/obj/item/clothing/head/beret/roboblack
	name = "bioengineer beret"
	desc = "A black beret with a brown robotics insignia emblazoned on it. It smells distinctly like oil."
	icon_state = "beret_roboticsblack"

//Service
/obj/item/clothing/head/beret/hop
	name = "head of personnel's beret"
	desc = "For doing paperwork with style."
	icon_state = "beret_hop"
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/hop
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi',
		)

/obj/item/clothing/head/beret/janitor
	name = "janitorial beret"
	desc = "A purple beret with a mint service insignia emblazoned on it. It smells squeaky clean."
	icon_state = "beret_janitor"

//Medical
/obj/item/clothing/head/beret/med
	name = "medical beret"
	desc = "A white beret with a green cross finely threaded into it. It has that sterile smell about it."
	icon_state = "beret_med"

//Cargo
/obj/item/clothing/head/beret/qm
	name = "quartermaster's beret"
	desc = "A brown beret with a golden cargo insignia emblazoned on it. Rule over Cargonia in style."
	icon_state = "beret_qm"
	dog_fashion = /datum/dog_fashion/head/qm
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi'
	)

/obj/item/clothing/head/beret/cargo
	name = "cargo beret"
	desc = "A brown beret with a grey cargo insignia emblazoned on it. Haul crates with style."
	icon_state = "beret_cargo"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi'
	)

/obj/item/clothing/head/beret/expedition
	name = "expedition beret"
	desc = "A brown beret with a blue Nanotrasen insignia emblazoned on it. Not much good for space protection, but stylish all the same."
	icon_state = "beret_expedition"
	item_color = "beret_expedition"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 6 SECONDS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi'
		)

//NT Career Trainer
/obj/item/clothing/head/beret/nct/black
	name = "\improper NT Career Trainer's beret"
	desc = "A beret worn by the mentors and trainers of the Career Training Team. This one is black!"
	icon_state = "beret_trainerblack"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head/beret.dmi'
	)

/obj/item/clothing/head/beret/nct/green
	name = "\improper NT Career Trainer's beret"
	desc = "A beret worn by the mentors and trainers of the Career Training Team. This one is green!"
	icon_state = "beret_trainergreen"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/beret.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head/beret.dmi'
	)

//Special Roles
/obj/item/clothing/head/beret/solgov
	name = "\improper TSF Lieutenant's beret"
	desc = "A beret worn by marines of the Trans-Solar Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "beret_solgovc"
	item_color = "solgovc"
	dog_fashion = null
	armor = list(MELEE = 10, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	strip_delay = 80

/obj/item/clothing/head/beret/solgov/elite
	name = "\improper MARSOC Lieutenant's beret"
	desc = "A beret worn by junior officers of the Trans-Solar Federation's Marine Special Operations Command. The insignia signifies the wearer bears the rank of a Lieutenant."
	armor = list(MELEE = 25, BULLET = 75, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	icon_state = "beret_solgovcelite"
	item_color = "solgovcelite"
	resistance_flags = FIRE_PROOF

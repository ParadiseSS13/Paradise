/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/rnd.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/skkulakin/under/rnd.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/rnd.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/rnd.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/rnd.dmi'
	)

/obj/item/clothing/under/rank/rnd/rd
	name = "research director's uniform"
	desc = "It's a purple dress shirt and black slacks worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/clothing/under/rank/rnd/rd/whimsy
	name = "research director's historical uniform"
	desc = "Corduroy slacks, just as they should be."
	icon_state = "rd_whimsy"
	dyeable = TRUE

/obj/item/clothing/under/rank/rnd/rd/skirt
	name = "research director's skirt"
	desc = "It's a purple dress shirt and black skirt worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "rd_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/rd/skirt/whimsy
	name = "research director's historical dress"
	desc = "Pleated skirt and sweater for the style conscious RD."
	icon_state = "rd_whimsy_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/rd/turtleneck
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold research lobby. Due to budget cuts, the material does not offer any external protection."
	icon_state = "rd_turtle"

/obj/item/clothing/under/rank/rnd/scientist
	name = "scientist's jumpsuit"
	desc = "A breathable purple jumpsuit with light markings, designating the wearer a scientist."
	icon_state = "science"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "A breathable purple jumpskirt with light markings, designating the wearer a scientist."
	icon_state = "science_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/scientist/corporate
	name = "scientist's corporate uniform"
	desc = "A sterile white uniform with purple markings, for the mad scientist who favors style."
	icon_state = "sci_corporate"

/obj/item/clothing/under/rank/rnd/scientist/skirt/corporate
	name = "scientist's corporate skirt"
	desc = "A sterile white skirt with purple markings, for the mad scientist who favors style."
	icon_state = "sci_corp_skirt"

/obj/item/clothing/under/rank/rnd/roboticist
	name = "roboticist's jumpsuit"
	desc = "A slimming black jumpsuit with reinforced seams; great for industrial work."
	icon_state = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "A slimming black jumpskirt with reinforced seams; a great look for industrial work."
	icon_state = "robotics_skirt"

/obj/item/clothing/under/rank/rnd/roboticist/corporate
	name = "bioengineer's jumpsuit"
	desc = "A sterile white jumpsuit with reinforced seams; a great look for surgical work."
	icon_state = "bioengineer"

/obj/item/clothing/under/rank/rnd/roboticist/skirt/corporate
	name = "bioengineer's jumpskirt"
	desc = "A sterile white jumpskirt with reinforced seams; a great look for surgical work."
	icon_state = "bioengineer_skirt"

/obj/item/clothing/under/rank/rnd/roboticist/corporate/alt
	name = "roboticist's coveralls"
	desc = "A mechanic's red coveralls with black markings and chest pockets, for those who aren't afraid to get covered in oil and blood."
	icon_state = "robo_corporate"

/obj/item/clothing/under/rank/rnd/roboticist/overalls
	name = "roboticist's overalls"
	desc = "A red set of overalls over a black turtleneck, for those who aren't afraid to get covered in oil and blood."
	icon_state = "robo_overalls"

/obj/item/clothing/under/rank/rnd/geneticist
	name = "geneticist's jumpsuit"
	desc = "A tear-proof purple jumpsuit with wine colored markings, designating the wearer a geneticist."
	icon_state = "genetics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	desc = "A tear-proof purple jumpskirt with wine colored markings, designating the wearer a geneticist."
	icon_state = "genetics_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/geneticist/corporate
	name = "geneticist's corporate uniform"
	desc = "A tear-proof sterile white uniform with wine colored markings, for those who prefer a clean look while scrambling their genetic code."
	icon_state = "gen_corporate"

/obj/item/clothing/under/rank/rnd/geneticist/skirt/corporate
	name = "geneticist's corporate skirt"
	desc = "A tear-proof sterile white skirt with wine colored markings, for those who prefer a clean look while scrambling their genetic code."
	icon_state = "gen_corp_skirt"

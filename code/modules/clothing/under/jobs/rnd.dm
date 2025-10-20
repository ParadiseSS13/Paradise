/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/rnd.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/rnd.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/rnd.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/rnd.dmi'
	)

/obj/item/clothing/under/rank/rnd/rd
	name = "research director's uniform"
	desc = "It's a purple dress shirt and black slacks worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/clothing/under/rank/rnd/rd/skirt
	name = "research director's skirt"
	desc = "It's a purple dress shirt and black skirt worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "rd_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/rd/dress
	name = "research director's dress uniform"
	desc = "Feminine fashion for the style conscious RD."
	icon_state = "dress_rd"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/rd/turtleneck
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold research lobby. Due to budget cuts, the material does not offer any external protection."
	icon_state = "rd_turtle"

/obj/item/clothing/under/rank/rnd/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	icon_state = "science"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "sciencewhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/roboticist
	name = "roboticist's jumpsuit"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	icon_state = "roboticsf"

/obj/item/clothing/under/rank/rnd/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "geneticswhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

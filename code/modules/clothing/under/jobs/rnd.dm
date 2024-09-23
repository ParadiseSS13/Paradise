/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/rnd.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/rnd.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/rnd.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/rnd.dmi'
		)

/obj/item/clothing/under/rank/rnd/research_director
	name = "research director's jumpsuit"
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/clothing/under/rank/rnd/research_director/dress
	name = "research director's dress uniform"
	desc = "Feminine fashion for the style conscious RD."
	icon_state = "dress_rd"
	item_color = "dress_rd"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	icon_state = "science"
	item_state = "science"
	item_color = "science"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "sciencewhitef"
	item_color = "sciencewhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/rnd/roboticist
	name = "roboticist's jumpsuit"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "robotics"
	item_state = "robotics"
	item_color = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	icon_state = "roboticsf"
	item_color = "roboticsf"

/obj/item/clothing/under/rank/rnd/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	item_state = "genetics"
	item_color = "genetics"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "geneticswhitef"
	item_color = "geneticswhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

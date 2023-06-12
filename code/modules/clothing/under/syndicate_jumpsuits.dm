/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	has_sensor = FALSE
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 35)

	icon = 'icons/obj/clothing/under/syndicate.dmi'
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/syndicate.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/syndicate.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/syndicate.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/syndicate.dmi'
		)

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"
	item_color = "syndicate_combat"

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	item_color = "tactifool"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 35)

/obj/item/clothing/under/syndicate/sniper
	name = "tactical suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "tactical_suit"
	item_state = "bl_suit"
	item_color = "tactical_suit"

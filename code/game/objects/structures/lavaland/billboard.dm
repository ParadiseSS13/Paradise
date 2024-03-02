/obj/structure/lavaland_billboard
	name = "lavaland billboard"
	icon = 'icons/obj/billboard.dmi'
	icon_state = "billboard"
	anchored = TRUE
	density = TRUE
	max_integrity = 400
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/list/billboard_overlay=list("overlay0","ovelay1","overlay2")
	blocks_emissive = FALSE


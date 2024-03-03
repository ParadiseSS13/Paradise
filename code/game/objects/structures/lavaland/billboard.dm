/obj/structure/lavaland_billboard
	name = "lavaland billboard"
	icon = 'icons/obj/lavaland/billboard.dmi'
	icon_state = "billboard"
	bound_width = 64
	bound_height = 32
	pixel_x = -2
	anchored = TRUE
	density = TRUE
	max_integrity = 400
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/static/list/billboard_overlay = list("chasmland", "incompatible", "feed", "warm", "adventure", "plasmaland", "gate", "ufo", "notfriendly", "gps", "service", "protection", "diamonds", "step")
	layer = EDGED_TURF_LAYER
	resistance_flags = FIRE_PROOF
	blocks_emissive = FALSE

/obj/structure/lavaland_billboard/Initialize()
	. = ..()
	add_overlay(mutable_appearance(/obj/structure/lavaland_billboard, pick(billboard_overlay)))
	underlays += emissive_appearance(icon, "billboard_lightmask")


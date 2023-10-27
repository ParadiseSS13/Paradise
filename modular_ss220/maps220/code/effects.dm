/* Awaymission - Gate Lizard */
// Firefly
/obj/effect/firefly
	name = "firefly"
	desc = ""
	icon = 'modular_ss220/maps220/icons/effects.dmi'
	icon_state = "fire_fly1"
	light_color = "#F8F6E6"
	light_power = 4
	light_range = 2
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/firefly/blue
	icon_state = "fire_fly3"
	light_color = "#4169E1"

/obj/effect/firefly/green
	icon_state = "fire_fly2"
	light_color = "#228B22"

/* Syndicate Base - Mothership */
// Decals
/obj/effect/decal/syndie_logo
	name = "Syndicate logo"
	icon = 'modular_ss220/maps220/icons/syndie_logo.dmi'
	icon_state = "logo1"
	layer = TURF_LAYER
	desc = "Death to Nanotrasen."

// Turf decals
/obj/effect/turf_decal/miscellaneous
	icon_state = null

/obj/effect/turf_decal/miscellaneous/plumbing
	icon = 'modular_ss220/maps220/icons/decals.dmi'
	icon_state = "plumbing"

/obj/effect/turf_decal/miscellaneous/goldensiding
	icon = 'modular_ss220/maps220/icons/decals.dmi'
	icon_state = "golden_stripes"

/obj/effect/turf_decal/miscellaneous/goldensiding/corner
	icon_state = "golden_stripes_corner"

/obj/effect/turf_decal/siding/black
	icon = 'modular_ss220/maps220/icons/decals.dmi'
	icon_state = "bs_line"

/obj/effect/turf_decal/siding/black/corner
	icon_state = "bs_deadlock"

/obj/effect/turf_decal/siding/black/full
	icon_state = "bs_full"

/* Awaymission - Caves */
//Decals
/obj/effect/decal/solgov_logo
	name = "SolGov logo"
	icon = 'modular_ss220/maps220/icons/syndie_logo.dmi'
	icon_state = "sol_logo1"
	layer = TURF_LAYER
	desc = "Glory to humanity!"

/* Beach */
/obj/item/toy/seashell
	name = "ракушка"
	desc = "Пусть у вас всегда будет ракушка в кармане и песок в ботинках. Что бы это ни значило."
	icon = 'modular_ss220/maps220/icons/decals.dmi'
	icon_state = "shell1"
	var/static/list/possible_colors = list("" = 2, COLOR_PURPLE_GRAY = 1, COLOR_OLIVE = 1, COLOR_PALE_BLUE_GRAY = 1, COLOR_RED_GRAY = 1)

/obj/item/toy/seashell/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	icon_state = "shell[rand(1,3)]"
	color = pickweight(possible_colors)
	setDir(pick(GLOB.cardinal))

/* Central Command */
// Decals
/obj/effect/decal/nanotrasen_logo_circle
	name = "Nanotrasen logo"
	icon = 'modular_ss220/maps220/icons/nanotrasen_logo.dmi'
	icon_state = "ntlogo"
	layer = TURF_LAYER
	desc = "Glory to Nanotrasen."

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

/* Awaymission - Caves */
// Decals
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

/*Black Mesa*/
//Lamda
/datum/looping_sound/lambda
	mid_sounds = list('modular_ss220/aesthetics_sounds/sound/lc_mainbeam.ogg' = 1)
	mid_length = 8.1 SECONDS
	volume = 100

GLOBAL_LIST_EMPTY(bump_teleporters)

/obj/effect/bump_teleporter
	name = "bump-teleporter"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/id = null			//id of this bump_teleporter.
	var/id_target = null	//id of bump_teleporter which this moves you to.
	invisibility = 101 		//nope, can't see this
	density = TRUE
	opacity = FALSE

/obj/effect/bump_teleporter/New()
	..()
	GLOB.bump_teleporters += src

/obj/effect/bump_teleporter/Destroy()
	GLOB.bump_teleporters -= src
	return ..()

/obj/effect/bump_teleporter/singularity_act()
	return

/obj/effect/bump_teleporter/singularity_pull()
	return

/obj/effect/bump_teleporter/Bumped(atom/movable/user)
	if(!ismob(user))
		//user.loc = src.loc	//Stop at teleporter location
		return

	if(!id_target)
		//user.loc = src.loc	//Stop at teleporter location, there is nowhere to teleport to.
		return

	for(var/obj/effect/bump_teleporter/BT in GLOB.bump_teleporters)
		if(BT.id == src.id_target)
			user.loc = BT.loc	//Teleport to location with correct id.
			return

/obj/effect/bump_teleporter/lambda
	name = "\improper Lambda телепорт"
	desc = "Сверхмощный портал, способный пронести вас сквозь миры."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	invisibility = 0
	light_range = 6
	color = COLOR_CYAN
	var/datum/looping_sound/lambda/looping_sound
	var/atom/movable/effect

/obj/effect/bump_teleporter/lambda/Initialize(mapload)
	. = ..()
	looping_sound = new(src, TRUE)
	effect = new(src)
	vis_contents += effect

/obj/effect/bump_teleporter/lambda/Destroy()
	QDEL_NULL(looping_sound)
	vis_contents -= effect
	QDEL_NULL(effect)
	return ..()

/obj/effect/bump_teleporter/lambda/Bumped(atom/user)
	// Play sound before moving.
	playsound(src, 'modular_ss220/aesthetics_sounds/sound/lc_teleport.ogg', 100)

	. = ..()

	if(isliving(user))
		var/mob/living/teleporting_mob = user
		teleporting_mob.flash_eyes(10, 1, 1, /atom/movable/screen/fullscreen/flash/lambda, 3 SECONDS)
		teleporting_mob.Confused(15 SECONDS)

/atom/movable/screen/fullscreen/flash/lambda
	color = COLOR_GREEN

//Paper fluff
/obj/structure/fluff/paper
	name = "dense lining of papers"
	desc = "A lining of paper scattered across the bottom of a wall."
	icon = 'modular_ss220/maps220/icons/misc_objects.dmi'
	icon_state = "paper"
	deconstructible = FALSE

/obj/structure/fluff/paper/corner
	icon_state = "papercorner"

/obj/structure/fluff/paper/stack
	name = "dense stack of papers"
	desc = "A stack of various papers, childish scribbles scattered across each page."
	icon_state = "paperstack"

//Train
/obj/structure/fluff/tram_rail
	name = "tram rail"
	desc = "Great for trams, not so great for skating."
	icon = 'modular_ss220/maps220/icons/misc_objects.dmi'
	icon_state = "rail"
	layer = GAS_PIPE_VISIBLE_LAYER
	plane = FLOOR_PLANE
	deconstructible = FALSE

/obj/structure/fluff/tram_rail/floor
	icon_state = "rail_floor"

/obj/structure/fluff/tram_rail/end
	icon_state = "railend"

/obj/structure/fluff/tram_rail/anchor
	name = "tram rail anchor"
	icon_state = "anchor"

//Light emitter
/obj/effect/light_emitter/colored
	set_cap = 1
	icon = 'modular_ss220/maps220/icons/mapping_helpers.dmi'
	icon_state = "sunlight_helper"
	layer = 10

/obj/effect/light_emitter/colored/dark_purple
	light_color = "#53254d"

/obj/effect/light_emitter/colored/lime
	light_color = "#6AFF00"

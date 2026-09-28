/turf/simulated/floor/wood
	name = "wooden floor"
	desc = "Flooring constructed from interlocking planks of wood fastened with screws."
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW

/turf/simulated/floor/wood/examine(mob/user, infix, suffix)
	. = ..()
	. += SPAN_NOTICE("You can dismantle [src] with a screwdriver.")
	. += SPAN_NOTICE("You can also tear [src] up with a crowbar, destroying it.")

/turf/simulated/floor/wood/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	remove_tile(user, FALSE, TRUE)

/turf/simulated/floor/wood/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	remove_tile(user, FALSE, FALSE)

/turf/simulated/floor/wood/get_broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/simulated/floor/wood/get_prying_tools()
	return list(TOOL_SCREWDRIVER)

/turf/simulated/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		if(user && !silent)
			to_chat(user, SPAN_NOTICE("You remove the broken planks."))
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, SPAN_NOTICE("You unscrew the planks."))
			if(floor_tile)
				new floor_tile(src)
		else
			if(user && !silent)
				to_chat(user, SPAN_WARNING("You forcefully pry off the planks, destroying them in the process."))
	return make_plating()

/turf/simulated/floor/wood/airless
	name = "wood" // yes really
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/wood/cold
	oxygen = 22
	nitrogen = 82
	temperature = 180

/turf/simulated/floor/wood/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/wood/nitrogen
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

// Grass
/turf/simulated/floor/grass
	name = "grass"
	desc = "Lush green grass. Enough of this in one place can make you forget that you're in deep space."
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)
	layer = ABOVE_OPEN_TURF_LAYER
	floor_tile = /obj/item/stack/tile/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	transform = matrix(1, 0, -9, 0, 1, -9) //Yes, these sprites are 50x50px, big grass control the industry

/turf/simulated/floor/grass/get_broken_states()
	return list("damaged")

/turf/simulated/floor/grass/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/shovel))
		to_chat(user, SPAN_NOTICE("You shovel the grass."))
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		remove_tile()
		return ITEM_INTERACT_COMPLETE

/turf/simulated/floor/grass/jungle
	name = "jungle grass"
	icon = 'icons/turf/floors/junglegrass.dmi'
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)

/turf/simulated/floor/grass/jungle/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/// This vairant shows up under normal turfs so fits in the regular 32x32 sprite
/turf/simulated/floor/grass/no_creep
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null
	layer = GRASS_UNDER_LAYER
	transform = null

/// This vairant shows up under normal turfs so fits in the regular 32x32 sprite
/turf/simulated/floor/grass/jungle/no_creep
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null
	layer = GRASS_UNDER_LAYER
	transform = null

//Carpets
/turf/simulated/floor/carpet
	name = "carpet"
	desc = "Textile flooring often used to try and add more class to a room."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT

/turf/simulated/floor/carpet/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/carpet/update_icon_state()
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
	else
		make_plating()
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)

//Carpet variant for mapping aid, functionally the same as parent after smoothing.
/turf/simulated/floor/carpet/lone
	icon_state = "carpet-0"

/turf/simulated/floor/carpet/break_tile()
	broken = TRUE
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = TRUE
	update_icon()

/turf/simulated/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/carpet/get_broken_states()
	return list("damaged")

/turf/simulated/floor/carpet/black
	name = "black carpet"
	desc = "Elegant black textile flooring with a gold trim around the edges."
	icon = 'icons/turf/floors/carpet_black.dmi'
	floor_tile = /obj/item/stack/tile/carpet/black
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLACK)

/turf/simulated/floor/carpet/blue
	name = "blue carpet"
	desc = "Blue textile flooring with a repeating white diamond pattern, and a thick white border around the edges."
	icon = 'icons/turf/floors/carpet_blue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/blue
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLUE)

/turf/simulated/floor/carpet/cyan
	name = "cyan carpet"
	desc = "Cyan textile flooring with a thick white border and inwards-facing tassels around the edges."
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	floor_tile = /obj/item/stack/tile/carpet/cyan
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_CYAN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_CYAN)

/turf/simulated/floor/carpet/green
	name = "green carpet"
	desc = "Dark green textile flooring with intricate repeating patterns and edges woven with gold colored thread."
	icon = 'icons/turf/floors/carpet_green.dmi'
	floor_tile = /obj/item/stack/tile/carpet/green
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_GREEN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GREEN)

/turf/simulated/floor/carpet/orange
	name = "orange carpet"
	desc = "Warm orange textile flooring with a repeating gold diamond pattern, and a thick gold border around the edges."
	icon = 'icons/turf/floors/carpet_orange.dmi'
	floor_tile = /obj/item/stack/tile/carpet/orange
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_ORANGE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ORANGE)

/turf/simulated/floor/carpet/purple
	name = "purple carpet"
	desc = "Regal purple textile flooring with a repeating white diamond pattern, and a thick white border around the edges."
	icon = 'icons/turf/floors/carpet_purple.dmi'
	floor_tile = /obj/item/stack/tile/carpet/purple
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_PURPLE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_PURPLE)

/turf/simulated/floor/carpet/red
	name = "red carpet"
	desc = "Crimson textile flooring with a repeating white diamond pattern, and a thick white border around the edges."
	icon = 'icons/turf/floors/carpet_red.dmi'
	floor_tile = /obj/item/stack/tile/carpet/red
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_RED)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_RED)

/turf/simulated/floor/carpet/royalblack
	name = "royal black carpet"
	desc = "Jet-black textile flooring with a repeating gold diamond pattern, and a thick gold border around the edges."
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_ROYALBLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYALBLACK)

/turf/simulated/floor/carpet/royalblue
	name = "royal blue carpet"
	desc = "Royal blue textile flooring with a repeating gold diamond pattern, and a thick gold border around the edges."
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET, SMOOTH_GROUP_CARPET_ROYALBLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYALBLUE)

/turf/simulated/floor/carpet/grimey
	name = "cheap carpet"
	desc = "Cheap nasty textile flooring. Close inspection shows that this carpet is full of dirt, grease, and who knows what else. Not something you want to lie down on."
	icon = 'icons/turf/floors/carpet_grimey.dmi'
	floor_tile = /obj/item/stack/tile/carpet/grimey
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET,SMOOTH_GROUP_CARPET_GRIMEY)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GRIMEY)

/turf/simulated/floor/carpet/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/carpet/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/carpet/nitrogen
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

//End of carpets

// Bamboo mats
/turf/simulated/floor/bamboo
	name = "bamboo floor"
	desc = "Lightweight hand-made flooring constructed from bamboo."
	icon = 'icons/turf/floors/bamboo_mat.dmi'
	icon_state = "mat-0"
	base_icon_state = "mat"
	floor_tile = /obj/item/stack/tile/bamboo
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_BAMBOO)
	canSmoothWith = list(SMOOTH_GROUP_BAMBOO)
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW

/turf/simulated/floor/bamboo/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/bamboo/update_icon_state()
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
	else
		make_plating()
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)

/turf/simulated/floor/bamboo/break_tile()
	broken = TRUE
	update_icon()

/turf/simulated/floor/bamboo/burn_tile()
	burnt = TRUE
	update_icon()

/turf/simulated/floor/bamboo/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/bamboo/get_broken_states()
	return list("bamboo-damaged")

/turf/simulated/floor/bamboo/get_prying_tools()
	return list(TOOL_SCREWDRIVER)

/turf/simulated/floor/bamboo/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

// Bamboo tatami mat
/turf/simulated/floor/bamboo/tatami
	desc = "A traditional Japanese floor mat."
	icon_state = "bamboo-green"
	floor_tile = /obj/item/stack/tile/bamboo/tatami
	smoothing_flags = NONE

/turf/simulated/floor/bamboo/tatami/get_broken_states()
	return list("tatami-damaged")

/turf/simulated/floor/bamboo/tatami/purple
	icon_state = "bamboo-purple"
	floor_tile = /obj/item/stack/tile/bamboo/tatami/purple

/turf/simulated/floor/bamboo/tatami/black
	icon_state = "bamboo-black"
	floor_tile = /obj/item/stack/tile/bamboo/tatami/black
// End of bamboo

/turf/simulated/floor/fakespace
	name = "\proper space"
	desc = "The infinite expanse of space. It's hazardous to traverse without proper protection."
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/simulated/floor/fakespace/Initialize(mapload)
	. = ..()
	icon_state = SPACE_ICON_STATE

/turf/simulated/floor/fakespace/get_broken_states()
	return list("damaged")

/turf/simulated/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/turf/simulated/floor/carpet/arcade
	name = "space carpet"
	desc = "A space-themed carpet adorned with planets and rocket ships."
	icon = 'icons/goonstation/turf/floor.dmi'
	icon_state = "arcade"
	floor_tile = /obj/item/stack/tile/arcade_carpet
	smoothing_flags = NONE

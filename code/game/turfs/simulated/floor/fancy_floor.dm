/turf/simulated/floor/wood
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	prying_tool_list = list(TOOL_SCREWDRIVER)
	broken_states = list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

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

/turf/simulated/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the broken planks.</span>")
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, "<span class='notice'>You unscrew the planks.</span>")
			if(floor_tile)
				new floor_tile(src)
		else
			if(user && !silent)
				to_chat(user, "<span class='warning'>You forcefully pry off the planks, destroying them in the process.</span>")
	return make_plating()

/turf/simulated/floor/wood/cold
	oxygen = 22
	nitrogen = 82
	temperature = 180

/turf/simulated/floor/wood/oak
	icon_state = "wood-oak"
	floor_tile = /obj/item/stack/tile/wood/oak
	broken_states = list("wood-oak-broken", "wood-oak-broken2", "wood-oak-broken3", "wood-oak-broken4", "wood-oak-broken5", "wood-oak-broken6", "wood-oak-broken7")

/turf/simulated/floor/wood/birch
	icon_state = "wood-birch"
	floor_tile = /obj/item/stack/tile/wood/birch
	broken_states = list("wood-birch-broken", "wood-birch-broken2", "wood-birch-broken3", "wood-birch-broken4", "wood-birch-broken5", "wood-birch-broken6", "wood-birch-broken7")

/turf/simulated/floor/wood/cherry
	icon_state = "wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/cherry
	broken_states = list("wood-cherry-broken", "wood-cherry-broken2", "wood-cherry-broken3", "wood-cherry-broken4", "wood-cherry-broken5", "wood-cherry-broken6", "wood-cherry-broken7")

/turf/simulated/floor/wood/fancy/oak
	icon_state = "fancy-wood-oak"
	floor_tile = /obj/item/stack/tile/wood/fancy/oak
	broken_states = list("fancy-wood-oak-broken", "fancy-wood-oak-broken2", "fancy-wood-oak-broken3", "fancy-wood-oak-broken4", "fancy-wood-oak-broken5", "fancy-wood-oak-broken6", "fancy-wood-oak-broken7")

/turf/simulated/floor/wood/fancy/birch
	icon_state = "fancy-wood-birch"
	floor_tile = /obj/item/stack/tile/wood/fancy/birch
	broken_states = list("fancy-wood-birch-broken", "fancy-wood-birch-broken2", "fancy-wood-birch-broken3", "fancy-wood-birch-broken4", "fancy-wood-birch-broken5", "fancy-wood-birch-broken6", "fancy-wood-birch-broken7")

/turf/simulated/floor/wood/fancy/cherry
	icon_state = "fancy-wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/fancy/cherry
	broken_states = list("fancy-wood-cherry-broken", "fancy-wood-cherry-broken2", "fancy-wood-cherry-broken3", "fancy-wood-cherry-broken4", "fancy-wood-cherry-broken5", "fancy-wood-cherry-broken6", "fancy-wood-cherry-broken7")

/turf/simulated/floor/wood/fancy/light
	icon_state = "light-fancy-wood"
	floor_tile = /obj/item/stack/tile/wood/fancy/light
	broken_states = list("light-fancy-wood-broken", "light-fancy-wood-broken2", "light-fancy-wood-broken3", "light-fancy-wood-broken4", "light-fancy-wood-broken5", "light-fancy-wood-broken6", "light-fancy-wood-broken7")

// GRASS
/turf/simulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass
	broken_states = list("sand")
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/grass/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/grass/update_icon()
	icon_state = "grass[pick("1","2","3","4")]"

/turf/simulated/floor/grass/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/shovel))
		new /obj/item/stack/ore/glass(src, 2) //Make some sand if you shovel grass
		to_chat(user, "<span class='notice'>You shovel the grass.</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		make_plating()

// CARPETS
/turf/simulated/floor/carpet
	name = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/carpet/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/carpet/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		if(smooth)
			queue_smooth(src)
	else
		make_plating()
		if(smooth)
			queue_smooth_neighbors(src)

/turf/simulated/floor/carpet/break_tile()
	broken = TRUE
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = TRUE
	update_icon()

/turf/simulated/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	floor_tile = /obj/item/stack/tile/carpet/black
	canSmoothWith = list(/turf/simulated/floor/carpet/black)

/turf/simulated/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/blue
	canSmoothWith = list(/turf/simulated/floor/carpet/blue)

/turf/simulated/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	floor_tile = /obj/item/stack/tile/carpet/cyan
	canSmoothWith = list(/turf/simulated/floor/carpet/cyan)

/turf/simulated/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	floor_tile = /obj/item/stack/tile/carpet/green
	canSmoothWith = list(/turf/simulated/floor/carpet/green)

/turf/simulated/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	floor_tile = /obj/item/stack/tile/carpet/orange
	canSmoothWith = list(/turf/simulated/floor/carpet/orange)

/turf/simulated/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	floor_tile = /obj/item/stack/tile/carpet/purple
	canSmoothWith = list(/turf/simulated/floor/carpet/purple)

/turf/simulated/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	floor_tile = /obj/item/stack/tile/carpet/red
	canSmoothWith = list(/turf/simulated/floor/carpet/red)

/turf/simulated/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	canSmoothWith = list(/turf/simulated/floor/carpet/royalblack)

/turf/simulated/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	canSmoothWith = list(/turf/simulated/floor/carpet/royalblue)

// FAKESPACE
/turf/simulated/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	broken_states = list("damaged")
	plane = PLANE_SPACE

/turf/simulated/floor/fakespace/Initialize(mapload)
	. = ..()
	icon_state = SPACE_ICON_STATE

/turf/simulated/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/turf/simulated/floor/carpet/arcade
	icon = 'icons/goonstation/turf/floor.dmi'
	icon_state = "arcade"
	floor_tile = /obj/item/stack/tile/arcade_carpet
	smooth = SMOOTH_FALSE

/// Set the baseturfs of every turf in the /area/ it is placed.
/obj/effect/baseturf_helper
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

	var/baseturf

	layer = POINT_LAYER

/obj/effect/baseturf_helper/Initialize(mapload)
	. = ..()
	var/area/thearea = get_area(src)
	for(var/turf/T in get_area_turfs(thearea, z))
		replace_baseturf(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	if(thing.baseturf != thing.type)
		thing.baseturf = baseturf

/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/space

/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/simulated/floor/plating/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/simulated/floor/plating/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/simulated/floor/plating/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/simulated/floor/plating/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/simulated/floor/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/simulated/floor/beach/water

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/simulated/floor/lava

/obj/effect/baseturf_helper/lava/mapping_lava
	name = "mapping lava baseturf editor"
	baseturf = /turf/simulated/floor/lava/mapping_lava

/obj/effect/baseturf_helper/lava_land
	name = "lavaland baseturf editor"
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface

/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize(mapload)
	..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"
	layer = ON_EDGED_TURF_LAYER

/obj/effect/mapping_helpers/no_lava/New()
	var/turf/T = get_turf(src)
	T.flags |= NO_LAVA_GEN
	..()

/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER
	late = TRUE
	var/list/blacklist = list(/obj/machinery/door/firedoor, /obj/machinery/door/poddoor, /obj/machinery/door/unpowered)

/obj/effect/mapping_helpers/airlock/Initialize(mapload)
	. = ..()

	if(!mapload)
		log_world("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/airlock/LateInitialize()
	. = ..()

	var/list/valid_airlocks = list()
	for(var/obj/machinery/door/D in get_turf(src))
		if(!is_type_in_list(D, blacklist))
			valid_airlocks += D

	if(length(valid_airlocks))
		for(var/obj/machinery/door/D in valid_airlocks)
			payload(D)
	else
		log_world("[src] failed to find any valid airlocks at [AREACOORD(src)]")

	qdel(src)

/obj/effect/mapping_helpers/airlock/proc/payload(obj/machinery/door/airlock/payload)
	return

/obj/effect/mapping_helpers/airlock/polarized
	name = "polarized door helper"
	icon_state = "polarized_helper"
	var/id

/obj/effect/mapping_helpers/airlock/polarized/payload(obj/machinery/door/door)
	if(!door.glass)
		log_world("[src] at [AREACOORD(src)] tried to make a non-glass door polarized!")
		return
	door.polarized_glass = TRUE
	door.id = id

/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/payload(obj/machinery/door/airlock/airlock)
	if(airlock.locked)
		log_world("[src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
	else
		airlock.locked = TRUE
		airlock.update_icon()

/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unresctricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/payload(obj/machinery/door/airlock)
	airlock.unres_sides ^= dir
	airlock.update_icon()

/obj/effect/mapping_helpers/airlock/autoname
	name = "airlock autoname helper"
	icon_state = "airlock_autoname"

/obj/effect/mapping_helpers/airlock/autoname/payload(obj/machinery/door/airlock)
	airlock.name = get_area_name(airlock, TRUE)

//part responsible for windoors (thanks S34N)
/obj/effect/mapping_helpers/airlock/windoor
	blacklist = list(/obj/machinery/door/firedoor, /obj/machinery/door/poddoor, /obj/machinery/door/unpowered, /obj/machinery/door/airlock)

/// Apply to a wall (or floor, technically) to ensure it is instantly destroyed by any explosion, even if usually invulnerable
/obj/effect/mapping_helpers/bombable_wall
	name = "bombable wall helper"
	icon_state = "explodable"
	late = TRUE

/obj/effect/mapping_helpers/bombable_wall/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_debug("[src] spawned outside of mapload!")
		return

	var/turf/our_turf = get_turf(src) // In case a locker ate us or something
	our_turf.AddElement(/datum/element/bombable_turf)
	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/airlock/windoor/autoname
	name = "windoor autoname helper"
	icon_state = "windoor_autoname"

/obj/effect/mapping_helpers/airlock/windoor/autoname/payload(obj/machinery/door/window/windoor)
	if(windoor.dir == dir)
		windoor.name = get_area_name(windoor, TRUE)

/obj/effect/mapping_helpers/airlock/windoor/autoname/desk
	name = "windesk autoname helper"
	icon_state = "windesk_autoname"

/obj/effect/mapping_helpers/airlock/windoor/autoname/desk/payload(obj/machinery/door/window/windoor)
	if(windoor.dir == dir)
		windoor.name = "[get_area_name(windoor, TRUE)] Desk"

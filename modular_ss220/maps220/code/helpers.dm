/obj/effect/mapping_helpers
	icon = 'modular_ss220/maps220/icons/mapping_helpers.dmi'

/obj/effect/mapping_helpers/light
	icon_state = "sunlight_helper"
	light_color = null
	light_power = 1
	light_range = 10

/obj/effect/mapping_helpers/light/New()
	var/turf/T = get_turf(src)
	T.light_color = light_color
	T.light_power = light_power
	T.light_range = light_range
	. = ..()

//Machinery helpers
/obj/effect/mapping_helpers/machinery
	layer = BELOW_MOB_LAYER
	late = TRUE

/obj/effect/mapping_helpers/machinery/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("[src] spawned outside of mapload!")
		return

	if(!(locate(/obj/machinery) in get_turf(src)))
		log_world("[src] failed to find any machinery [AREACOORD(src)]")

	for(var/obj/machinery/M in get_turf(src))
		payload(M)

	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/machinery/proc/payload(obj/machinery/payload)
	return

/obj/effect/mapping_helpers/machinery/damaged
	name = "damaged machinery helper"
	icon_state = "damaged_machine"

/obj/effect/mapping_helpers/machinery/destroyed
	name = "destroyed machinery helper"
	icon_state = "broken_machine"

/obj/effect/mapping_helpers/machinery/damaged/payload(obj/machinery/M)
	M.take_damage(M.obj_integrity - M.integrity_failure)

/obj/effect/mapping_helpers/machinery/destroyed/payload(obj/machinery/M)
	M.take_damage(M.obj_integrity)

//Window helpers
///Deals random damage to the first window found on a tile to appear cracked
/obj/effect/mapping_helpers/damaged_window
	name = "damaged window helper"
	icon_state = "damaged_window"
	layer = ABOVE_OBJ_LAYER
	late = TRUE
	/// Minimum roll of integrity damage in percents needed to show cracks
	var/integrity_damage_min = 0.25
	/// Maximum roll of integrity damage in percents needed to show cracks
	var/integrity_damage_max = 0.85

/obj/effect/mapping_helpers/damaged_window/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL
	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/damaged_window/LateInitialize()
	. = ..()
	var/obj/structure/window/target = locate(/obj/structure/window) in loc

	if(isnull(target))
		var/area/target_area = get_area(src)
		log_world("[src] failed to find a window at [AREACOORD(src)] ([target_area.type]).")
		qdel(src)
		return
	else
		payload(target)

	target.update_appearance()
	qdel(src)

/obj/effect/mapping_helpers/damaged_window/proc/payload(obj/structure/window/target)
	if(target.obj_integrity < target.max_integrity)
		var/area/area = get_area(target)
		log_world("[src] at [AREACOORD(src)] [(area.type)] tried to damage [target] but it's already damaged!")
	target.take_damage(rand(target.max_integrity * integrity_damage_min, target.max_integrity * integrity_damage_max))

//Airlock helpers
/obj/effect/mapping_helpers/airlock/welded
	name = "airlock welded helper"
	icon_state = "airlock_welded"

/obj/effect/mapping_helpers/airlock/welded/payload(obj/machinery/door/airlock/airlock)
	if(airlock.welded)
		log_world("[src] at [AREACOORD(src)] tried to make [airlock] welded but it's already welded closed!")
	airlock.welded = TRUE

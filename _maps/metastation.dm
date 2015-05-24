/*
The /tg/ codebase currently requires you to have 7 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2014/11/24
z1 = station
z2 = centcomm
z3 = derelict telecomms satellite
z4 = derelict station
z5 = mining
z6 = empty space
z7 = empty space
*/

#if !defined(MAP_FILE)

        #include "map_files\MetaStation\MetaStation.v41A.II.dmm"
        #include "map_files\MetaStation\z2.dmm"
        #include "map_files\MetaStation\z3.dmm"
        #include "map_files\MetaStation\z4.dmm"
        #include "map_files\MetaStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"

        #define MAP_FILE "MetaStation.v41A.II.dmm"
        #define MAP_NAME "MetaStation"

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring MetaStation.

#endif

//COMPAT DEFS DO NOT LEAVE IN FINAL

/obj/docking_port
	var/dheight
	var/dwidth
	var/height
	var/id
	var/turf_type
	var/width
	var/area_type
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/docking_port/stationary
/obj/docking_port/stationary/transit
/obj/docking_port/mobile
	var/travelDir
/obj/docking_port/mobile/pod
/obj/docking_port/mobile/supply
/obj/docking_port/mobile/emergency

/obj/machinery/hydroponics/constructable
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/item/weapon/cultivator
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/computer/libraryconsole/bookmanagement
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/atmospherics/unary/outlet_injector/on
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/effect/spawner/lootdrop/maintenance
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/security
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/hos
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/engine
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/ce
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/captain
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/atmos
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/cmo
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/syndicate
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/suit_storage_unit/mining
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/mineral/equipment_vendor
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/item/weapon/beach_ball/holoball/dodgeball
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/computer/shuttle_control/syndicate
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/computer/shuttle_control/ferry
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/computer/shuttle_control/syndicate/recall
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/computer/emergency_shuttle
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/obj/machinery/teleport/hub/syndicate
	icon = 'icons/BadAss.dmi'
	icon_state = "badass"

/area/abductor_ship
/turf/unsimulated/wall/abductor
/obj/machinery/abductor
	var/team
/obj/machinery/abductor/experiment
/obj/machinery/abductor/pad
/obj/effect/landmark/abductor/console/var/team
/turf/unsimulated/floor/abductor/var/team
/obj/machinery/computer/camera_advanced/abductor/var/team
/obj/structure/closet/abductor/var/team
/obj/effect/landmark/abductor/scientist/var/team
/obj/item/weapon/retractor/alien/var/team
/obj/item/weapon/hemostat/alien/var/team
/obj/structure/table/abductor/var/team
/obj/item/weapon/paper/abductor
/obj/item/weapon/scalpel/alien
/obj/item/weapon/cautery/alien
/obj/machinery/abductor/gland_dispenser
/obj/effect/landmark/abductor/agent/var/team
/obj/machinery/optable/abductor
/obj/structure/stool/bed/abductor
/obj/item/weapon/surgicaldrill/alien
/obj/item/weapon/circular_saw/alien

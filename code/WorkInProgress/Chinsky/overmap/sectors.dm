
//===================================================================================
//Hook for building overmap
//===================================================================================
var/global/list/map_sectors = list()

/hook/startup/proc/build_map()
	accessable_z_levels = list() //no space travel with this system, at least not like this
	testing("Building overmap...")
	var/obj/effect/mapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if (data)
			testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			map_sectors["[level]"] = new data.obj_type(data)
	return 1

//===================================================================================
//Metaobject for storing information about sector this zlevel is representing.
//Should be placed only once on every zlevel.
//===================================================================================
/obj/effect/mapinfo/
	name = "map info metaobject"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	invisibility = 101
	var/obj_type		//type of overmap object it spawns
	var/landing_area 	//type of area used as inbound shuttle landing, null if no shuttle landing area
	var/zlevel
	var/mapx			//coordinates on the
	var/mapy			//overmap zlevel
	var/known = 1

/obj/effect/mapinfo/New()
	tag = "sector[z]"
	zlevel = z
	loc = null

/obj/effect/mapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/map/sector

/obj/effect/mapinfo/ship
	name = "generic ship"
	obj_type = /obj/effect/map/ship


//===================================================================================
//Overmap object representing zlevel
//===================================================================================

/obj/effect/map
	name = "map object"
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-plasteel"
	var/map_z = 0
	var/area/shuttle/shuttle_landing
	var/always_known = 1

/obj/effect/map/New(var/obj/effect/mapinfo/data)
	map_z = data.zlevel
	name = data.name
	always_known = data.known
	if (data.icon != 'icons/mob/screen1.dmi')
		icon = data.icon
		icon_state = data.icon_state
	if(data.desc)
		desc = data.desc
	var/new_x = data.mapx ? data.mapx : rand(OVERMAP_EDGE, world.maxx - OVERMAP_EDGE)
	var/new_y = data.mapy ? data.mapy : rand(OVERMAP_EDGE, world.maxy - OVERMAP_EDGE)
	loc = locate(new_x, new_y, OVERMAP_ZLEVEL)

	if(data.landing_area)
		shuttle_landing = locate(data.landing_area)

/obj/effect/map/CanPass(atom/movable/A)
	testing("[A] attempts to enter sector\"[name]\"")
	return 1

/obj/effect/map/Crossed(atom/movable/A)
	testing("[A] has entered sector\"[name]\"")
	if (istype(A,/obj/effect/map/ship))
		var/obj/effect/map/ship/S = A
		S.current_sector = src

/obj/effect/map/Uncrossed(atom/movable/A)
	testing("[A] has left sector\"[name]\"")
	if (istype(A,/obj/effect/map/ship))
		var/obj/effect/map/ship/S = A
		S.current_sector = null

/obj/effect/map/sector
	name = "generic sector"
	desc = "Sector with some stuff in it."
	anchored = 1

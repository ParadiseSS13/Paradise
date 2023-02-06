/area/mine/necropolis
	name = "Necropolis"
	icon_state = "cave"
	tele_proof = TRUE

/obj/effect/landmark/map_loader/lavaland_room
	icon = 'icons/testing/turf_analysis.dmi'
	icon_state = "arrow"

/obj/effect/landmark/map_loader/lavaland_room/Initialize()
	..()
	// load and randomly assign rooms
	var/global/list/south_necropolisroom_templates = list()
	var/global/list/north_necropolisroom_templates = list()
	var/global/list/west_necropolisroom_templates = list()
	var/global/list/east_necropolisroom_templates = list()
	var/static/path = "_maps/map_files/templates/lavaland/"
	var/global/loaded = 0
	if(!loaded)
		loaded = 1
		for(var/map in flist(path))
			if(cmptext(copytext(map, length(map) - 3), ".dmm"))
				var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
				if(copytext(map, 1, 3) == "n_")
					north_necropolisroom_templates += T
				else if(copytext(map, 1, 3) == "s_")
					south_necropolisroom_templates += T
				else if(copytext(map, 1, 3) == "e_")
					east_necropolisroom_templates += T
				else if(copytext(map, 1, 3) == "w_")
					west_necropolisroom_templates += T
				else
					// omnidirectional rooms are randomly assigned
					if(prob(50))
						north_necropolisroom_templates += T
					else
						south_necropolisroom_templates += T

	var/list/room
	switch(dir)
		if(NORTH)
			room = north_necropolisroom_templates
		if(SOUTH)
			room = south_necropolisroom_templates
		if(WEST)
			room = west_necropolisroom_templates
		else
			room = east_necropolisroom_templates


	var/datum/map_template/M = safepick(room)
	if(M)
		switch(dir)
			if(NORTH)
				north_necropolisroom_templates -= M
			if(SOUTH)
				south_necropolisroom_templates -= M
			if(WEST)
				west_necropolisroom_templates -= M
			else
				east_necropolisroom_templates -= M
	load(M)


//----------------------------------------------------------------------------------------------------------------------
//-------------------------------------------door-------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

/obj/machinery/door/poddoor/impassable/necropolisdoor
	name = "necropolis door"
	desc = "Древние двери которые откроются только только избранным"
	icon = 'icons/obj/lavaland/necrdoor.dmi'
	icon_state = "necr"

/obj/machinery/door/poddoor/impassable/necropolisdoor/preopen
	icon_state = "necropen"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/impassable/necropolisdoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("necropening", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		if("closing")
			flick("necrclosing", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, 1)

/obj/machinery/door/poddoor/impassable/necropolisdoor/update_icon()
	if(density)
		icon_state = "necr"
	else
		icon_state = "necropen"

/obj/machinery/door/poddoor/impassable/necropolisdoor/try_to_activate_door(mob/user)
 	return

/obj/machinery/door/poddoor/impassable/necropolisdoor/try_to_crowbar(mob/user, obj/item/I)
		to_chat(user, "<span class='warning'>[src] resists your efforts to force it!</span>")

/mob/living/simple_animal/hostile/megafauna/legion/proc/UnlockBlastDoors(target_id_tag)
	for(var/obj/machinery/door/poddoor/impassable/necropolisdoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()


//----------------------------------------------------------------------------------------------------------------------
//-------------------------------------------multi tile door-------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------


/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/Initialize(mapload)
	. = ..()
	apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/open()
	if(..())
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/close()
	if(..())
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/Destroy()
	apply_opacity_to_my_turfs(0)
	return ..()

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/proc/apply_opacity_to_my_turfs(var/new_opacity)
	for(var/turf/T in locs)
		T.opacity = new_opacity
		T.has_opaque_atom = new_opacity
		T.reconsider_lights()
	update_freelook_sight()

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor
	name = "Заваленный проход"
	desc = "По всей видимости этот проход ведет в основную часть этого места, но камни из неизвестного материала прегродают путь, интрересно есть ли какой то способ их убрать...?"
	icon = 'icons/obj/lavaland/gate_to_the necropolis.dmi'
	icon_state = "blocked_passage"
	width = 3
	dir = EAST
	layer = TABLE_LAYER

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("blocked_passage", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		if("closing")
			flick("blocked_passage", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, 1)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor/update_icon()
	if(density)
		icon_state = "blocked_passage"
	else
		icon_state = "blocked_passage"

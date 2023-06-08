/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = HEAT_CAPACITY_VACUUM

	plane = PLANE_SPACE
	layer = SPACE_LAYER
	light_power = 0.25
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	intact = FALSE

	var/destination_z
	var/destination_x
	var/destination_y
	plane = PLANE_SPACE
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null


/turf/space/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(!istype(src, /turf/space/transit))
		icon_state = SPACE_ICON_STATE
	vis_contents.Cut() //removes inherited overlays

	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if (light_power && light_range)
		update_light()

	if (opacity)
		has_opaque_atom = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/space/BeforeChange()
	..()
	var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
	S.remove_from_transit(src)
	if(light_sources) // Turn off starlight, if present
		set_light(0)

/turf/space/AfterChange(ignore_air, keep_cabling = FALSE)
	..()
	var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
	S.add_to_transit(src)
	S.apply_transition(src)

/turf/space/proc/update_starlight()
	if(config.starlight)
		for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(isspaceturf(t))
				//let's NOT update this that much pls
				continue
			set_light(2)
			return
		set_light(0)

/turf/space/attackby(obj/item/C as obj, mob/user as mob, params)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return
		if(L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a catwalk.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, "<span class='warning'>You need two rods to build a catwalk!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='notice'>Constructing support lattice...</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
		return

	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				ChangeTurf(/turf/simulated/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

	if(istype(C, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/R = C
		var/obj/structure/lattice/fireproof/L = locate(/obj/structure/lattice/fireproof, src)
		var/obj/structure/lattice/catwalk/fireproof/W = locate(/obj/structure/lattice/catwalk/fireproof, src)
		if(W)
			to_chat(user, "<span class='warning'>Здесь уже есть мостик!</span>")
			return
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>Вы установили прочную решётку.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new /obj/structure/lattice/fireproof(src)
			else
				to_chat(user, "<span class='warning'>Вам нужен один огнеупорный стержень для постройки решётки.</span>")
			return
		if(L)
			if(R.use(2))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>Вы установили мостик.</span>")
				new /obj/structure/lattice/catwalk/fireproof(src)

/turf/space/Entered(atom/movable/A as mob|obj, atom/OL, ignoreRest = 0)
	..()
	if((!(A) || !(src in A.locs)))
		return

	if(destination_z && destination_x && destination_y)
		destination_z = check_taipan_availability(A, destination_z)
		A.forceMove(locate(destination_x, destination_y, destination_z))

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.forceMove(T)

		//now we're on the new z_level, proceed the space drifting
		sleep(0)//Let a diagonal move finish, if necessary
		A.newtonian_move(A.inertia_dir)

/turf/space/proc/check_taipan_availability(atom/movable/A as mob|obj, destination_z)
	var/mob/living/check_mob = A
	// if we are from taipan's crew, then we can easily access it.
	if(istype(check_mob) && is_taipan(destination_z))
		if(check_mob.mind in GLOB.taipan_players_active)
			to_chat(A, span_info("Вы вернулись в ваш родной скрытый от чужих глаз сектор..."))
			return destination_z
	// if we are not from taipan's crew, then we cannot get there until there is enought players on Taipan
	if(is_taipan(destination_z) && length(GLOB.taipan_players_active) < 6)
		var/datum/space_level/taipan_zlvl
		var/datum/space_level/direct
		for(var/list_parser in GLOB.space_manager.z_list)
			var/datum/space_level/lvl = GLOB.space_manager.z_list[list_parser]
			if(TAIPAN in lvl.flags)
				taipan_zlvl = lvl
		switch(A.dir)
			if(NORTH)
				direct = taipan_zlvl.get_connection(Z_LEVEL_NORTH)
			if(SOUTH)
				direct = taipan_zlvl.get_connection(Z_LEVEL_SOUTH)
			if(EAST)
				direct = taipan_zlvl.get_connection(Z_LEVEL_EAST)
			if(WEST)
				direct = taipan_zlvl.get_connection(Z_LEVEL_WEST)
		destination_z = direct.zpos
		// if we are still going to get to taipan after all the checks... Then get random available z_lvl instead
		if(is_taipan(destination_z))
			destination_z = pick(get_all_linked_levels_zpos())
	//notification if we do get to taipan
	if(is_taipan(destination_z))
		to_chat(check_mob, span_warning("Вы попадаете в загадочный сектор полный астероидов... Тут стоит быть осторожнее..."))
	return destination_z

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||GLOB.global_map.len)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	else if(src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > GLOB.global_map.len ? 1 : cur_x)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	else if(src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)

	else if(src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	return

/turf/space/singularity_act()
	return

/turf/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0

/turf/space/proc/set_transition_north(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_SOUTH + 1
	destination_z = dest_z

/turf/space/proc/set_transition_south(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_NORTH - 1
	destination_z = dest_z

/turf/space/proc/set_transition_east(dest_z)
	destination_x = TRANSITION_BORDER_WEST + 1
	destination_y = y
	destination_z = dest_z

/turf/space/proc/set_transition_west(dest_z)
	destination_x = TRANSITION_BORDER_EAST - 1
	destination_y = y
	destination_z = dest_z

/turf/space/proc/remove_transitions()
	destination_z = initial(destination_z)

/turf/space/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)

/turf/space/acid_act(acidpwr, acid_volume)
	return 0

/turf/space/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(rcd_mode != RCD_MODE_TURF)
		return RCD_NO_ACT
	if(our_rcd.useResource(1, user))
		to_chat(user, "Building Floor...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
		add_attack_logs(user, src, "Constructed floor with RCD")
		ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/turf/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

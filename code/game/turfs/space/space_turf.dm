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

	atmos_mode = ATMOS_MODE_SPACE

	rad_insulation_alpha = RAD_NO_INSULATION

/turf/space/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(!istype(src, /turf/space/transit))
		icon_state = SPACE_ICON_STATE
	vis_contents.Cut() //removes inherited overlays

	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)

	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(light_power && light_range)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	return INITIALIZE_HINT_NORMAL

/turf/space/BeforeChange()
	..()

	if(light_sources) // Turn off starlight, if present
		set_light(0)

/turf/space/proc/update_starlight()
	if(GLOB.configuration.general.starlight)
		for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(isspaceturf(t))
				//let's NOT update this that much pls
				continue
			set_light(2)
			return
		set_light(0)

/turf/space/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = used
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return ITEM_INTERACT_COMPLETE
		if(L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a catwalk.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new/obj/structure/lattice/catwalk(src)
				return ITEM_INTERACT_COMPLETE
			else
				to_chat(user, "<span class='warning'>You need two rods to build a catwalk!</span>")
				return ITEM_INTERACT_COMPLETE
		if(R.use(1))
			to_chat(user, "<span class='notice'>Constructing support lattice...</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			ReplaceWithLattice()
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
			return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = used
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				ChangeTurf(/turf/simulated/floor/plating)
				return ITEM_INTERACT_COMPLETE
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
				return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")
			return ITEM_INTERACT_COMPLETE

	return ..()

/turf/space/Entered(atom/movable/A as mob|obj, atom/OL, ignoreRest = 0)
	..()
	if((!(A) || !(src in A.locs)))
		return

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
		next_x = (--cur_x||length(GLOB.global_map))
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
				if(A && A.loc)
					A.loc.Entered(A)
	else if(src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > length(GLOB.global_map) ? 1 : cur_x)
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
				if(A && A.loc)
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
		next_y = (--cur_y||length(y_arr))
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
				if(A && A.loc)
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
		next_y = (++cur_y > length(y_arr) ? 1 : cur_y)
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
				if(A && A.loc)
					A.loc.Entered(A)
	return

/turf/space/singularity_act()
	return

/turf/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0

/turf/space/acid_act(acidpwr, acid_volume)
	return 0

/turf/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

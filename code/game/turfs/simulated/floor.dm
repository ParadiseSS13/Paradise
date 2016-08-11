//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"warnplate", "warnplatecorner","metalfoam", "ironfoam",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken", "carpet",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "dont_use_this_floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/floor_tile = null //tile that this floor drops
	var/obj/item/stack/tile/builtin_tile = null //needed for performance reasons when the singularity rips off floor tiles
	var/list/broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	var/list/burnt_states = list()


/turf/simulated/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
	if(floor_tile)
		builtin_tile = new floor_tile

/turf/simulated/floor/Destroy()
	if(builtin_tile)
		qdel(builtin_tile)
		builtin_tile = null
	return ..()


//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
//	if((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if(!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	if(is_shielded())
		return
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
		if(2.0)
			switch(pick(1,2;75,3))
				if(1)
					spawn(0)
						src.ReplaceWithLattice()
						if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ChangeTurf(/turf/space)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if(prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return 1

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/proc/update_icon()
	if(air)
		update_visuals()
	return 1

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	var/turf/simulated/floor/plating/T = make_plating()
	T.break_tile()

/turf/simulated/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/simulated/floor/burn_tile()
	if(broken || burnt)
		return
	if(burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/simulated/floor/proc/make_plating()
	return ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/floor/ChangeTurf(turf/simulated/floor/T, defer_change = FALSE, keep_icon = TRUE)
	if(!istype(src,/turf/simulated/floor)) return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(T,/turf/simulated/floor)) return ..()
	var/old_icon = icon_regular_floor
	var/old_plating = icon_plating
	var/old_dir = dir
	var/turf/simulated/floor/W = ..()
	if(keep_icon)
		W.icon_regular_floor = old_icon
		W.icon_plating = old_plating
		W.dir = old_dir
	W.update_icon()
	return W


/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob, params)
	if(!C || !user)
		return 1
	if(..())
		return 1
	if(intact && istype(C, /obj/item/weapon/crowbar))
		if(broken || burnt)
			broken = 0
			burnt = 0
			to_chat(user, "<span class='danger'>You remove the broken plating.</span>")
		else
			if(istype(src, /turf/simulated/floor/wood))
				to_chat(user, "<span class='danger'>You forcefully pry off the planks, destroying them in the process.</span>")
			else if(!builtin_tile)
				to_chat(user, "<span class='notice'>You are unable to pry up \the [src] with a crowbar.</span>")
				return 1
			else
				to_chat(user, "<span class='danger'>You remove \the [builtin_tile.singular_name].</span>")
				builtin_tile.loc = src
				builtin_tile = null //deassociate tile, it no longer belongs to this turf
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		return 1
	if(istype(C, /obj/item/pipe))
		var/obj/item/pipe/P = C
		if(P.pipe_type != -1) // ANY PIPE
			user.visible_message( \
				"[user] starts sliding [P] along \the [src].", \
				"<span class='notice'>You slide [P] along \the [src].</span>", \
				"You hear the scrape of metal against something.")
			user.drop_item()
			if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
				P.dir = 5
				if(user.dir == 1)
					P.dir = 6
				else if(user.dir == 2)
					P.dir = 9
				else if(user.dir == 4)
					P.dir = 10
			else
				P.dir = user.dir
			P.x = src.x
			P.y = src.y
			P.z = src.z
			P.loc = src
			return 1
	return 0

/turf/simulated/floor/singularity_pull(S, current_size)
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(builtin_tile)
				builtin_tile.loc = src
				builtin_tile = null
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(builtin_tile)
				builtin_tile.loc = src
				builtin_tile = null
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(builtin_tile)
			if(prob(70))
				builtin_tile.loc = src
				builtin_tile = null
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()

/turf/simulated/floor/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/floor/engine/cult)

/turf/simulated/floor/can_have_cabling()
	return !burnt && !broken

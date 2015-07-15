/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	dynamic_lighting = 0
	luminosity = 1

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	var/transition //These is used in transistions as a way to tell where on the "cube" of space you're transitioning from/to
	var/destination_x
	var/destination_y

/turf/space/New()
	. = ..()

	if(!istype(src, /turf/space/transit))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	if(config)
		update_starlight() //MC will initialize all the space turfs that get created before config

/turf/space/Destroy()
	return QDEL_HINT_LETMELIVE

/turf/space/proc/update_starlight()
	if(!config)	return
	if(!config.starlight)
		return
	if(locate(/turf/simulated) in orange(src,1))
		set_light(config.starlight)
	else
		set_light(0)

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored || !isturf(user.pulling.loc))
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob, params)

	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			if(R.amount < 2)
				user << "\red You don't have enough rods to do that."
				return
			user << "\blue You begin to build a catwalk."
			if(do_after(user,30))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				user << "\blue You build a catwalk!"
				R.use(2)
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		user << "\blue Constructing support lattice ..."
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		ReplaceWithLattice()
		R.use(1)
		return

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			qdel(L)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			S.use(1)
			return
		else
			user << "\red The plating is going to need some support."
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || src != A.loc))	return

	inertial_drift(A)

	if(transition)

		if(A.z > MAX_Z)	return //for away missions

		if(destination_x)
			A.x = destination_x

		if(destination_y)
			A.y = destination_y

		var/mob/living/MM = null
		var/fukkendisk = A.GetTypeInAllContents(/obj/item/weapon/disk/nuclear)
		var/obj/item/flag/nation/fukkenflag = A.GetTypeInAllContents(/obj/item/flag/nation)
		if(fukkenflag)
			fukkenflag.loc = fukkenflag.startloc
			if(isliving(A))
				A << "<span class='warning'>The flag you were carrying was just returned to it's base. Nice try.</span>"
		if(fukkendisk)
			if(isliving(A))
				MM = A
				if(MM.client && !MM.stat)
					MM << "<span class='warning'>Something you are carrying is preventing you from leaving. Don't play stupid; you know exactly what it is.</span>"
					if(MM.x <= TRANSITIONEDGE)
						MM.inertia_dir = 4
					else if(MM.x >= world.maxx -TRANSITIONEDGE)
						MM.inertia_dir = 8
					else if(MM.y <= TRANSITIONEDGE)
						MM.inertia_dir = 1
					else if(MM.y >= world.maxy -TRANSITIONEDGE)
						MM.inertia_dir = 2
				else
					qdel(fukkendisk)//Make the disk respawn if it is on a clientless mob or corpse
			else
				qdel(fukkendisk)//Make the disk respawn if it is floating on its own
			return

		A.z =  text2num(transition)

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

		//now we're on the new z_level, proceed the space drifting
		if ((A && A.loc))
			A.loc.Entered(A)

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
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Target Z = [target_z]"
		world << "Next X = [next_x]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Target Z = [target_z]"
		world << "Next X = [next_x]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Next Y = [next_y]"
		world << "Target Z = [target_z]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		world << "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]"
		world << "Next Y = [next_y]"
		world << "Target Z = [target_z]"
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	return


/turf/space/proc/Assign_Destination()

	if(transition)
		if(x <= TRANSITIONEDGE) 							//west
			destination_x = world.maxx - TRANSITIONEDGE - 2
		else if (x >= (world.maxx - TRANSITIONEDGE - 1)) 	//east
			destination_x = TRANSITIONEDGE + 1
		else if (y <= TRANSITIONEDGE) 						//south
			destination_y = world.maxy - TRANSITIONEDGE - 2
		else if (y >= (world.maxy - TRANSITIONEDGE - 1)) 	//north
			destination_y = TRANSITIONEDGE + 1

/*
  Set the space turf transitions for the "space cube"
  Connections:
     ___     ___
   /_A_/|  /_F_/|
  |   |C| |   |E|
  |_B_|/  |_D_|/
  Note that all maps except F are oriented with north towards A. A and F are oriented with north towards D.
  The characters on the second cube should be upside down in this illustration, but aren't because of a lack of unicode support.
*/
proc/setup_map_transitions() //listamania

	var/list/unplaced_z_levels = 			accessable_z_levels
	var/list/free_zones = 					list("A", "B", "C", "D", "E", "F")
	var/list/zone_connections = 			list("D ","C ","B ","E ","A ","C ","F ","E ","A ","D ","F ","B ","A ","E ","F ","C ","A ","B ","F ","D ","D ","C ","B ","E") //This describes the borders of a cube based on free zones, really!
	var/text_zone_connections = 			list2text(zone_connections)
	var/list/final_zone_connections =		list()
	var/list/turfs_needing_transition =		list()
	var/list/turfs_needing_destinations = 	list()
	var/list/z_level_order = 				list()
	var/z_level
	var/placement
	var/total_processed = 0

	for(var/turf/space/S in world) //Define the transistions of the z levels
		total_processed++
		if (S.x == TRANSITIONEDGE || S.x == (world.maxx - TRANSITIONEDGE - 1) || S.y == TRANSITIONEDGE || S.y == (world.maxy - TRANSITIONEDGE - 1))
			turfs_needing_transition += S

	//if we've processed lots of turfs, switch to background processing to prevent being mistaken for an infinite loop
	if(total_processed > 450000)
		set background = 1

	while(free_zones.len != 0) //Assign the sides of the cube
		if(!unplaced_z_levels || !unplaced_z_levels.len) //if we're somehow unable to fill the cube, pad with deep space
			z_level =  6
		else
			z_level = pick(unplaced_z_levels)
		if(z_level > world.maxz) //A safety if one of the unplaced_z_levels doesn't actually exist
			z_level =  6
		placement = pick(free_zones)
		text_zone_connections = replacetext(text_zone_connections, placement, "[z_level]")

		for(var/turf/space/S in turfs_needing_transition) //pass the identity zone to the relevent turfs
			if(S.transition && prob(50)) //In z = 6 (deep space) it's a bit of a crapshoot in terms of navigation
				continue
			if(S.z == z_level)
				S.transition = num2text(z_level)
				if(!(S in turfs_needing_destinations))
					turfs_needing_destinations += S
				if(S.z != 6) //deep space turfs need to hang around in case they get reassigned a zone
					turfs_needing_transition -= S

		z_level_order += num2text(z_level)
		unplaced_z_levels -= z_level
		free_zones -= placement

	zone_connections = text2list(replacetext(text_zone_connections, " ", "\n")) //Convert the string back into a list

	final_zone_connections.len = z_level_order.len

	var/list/temp = list()

	for(var/j=1, j<= 24, j++)
		temp += zone_connections[j]
		if(temp.len == 4) //Chunks of cardinal directions
			final_zone_connections[z_level_order[j/4]] += temp
			temp = list()

	for(var/turf/space/S in turfs_needing_destinations) //replace the identity zone with the destination z-level
		var/list/directions = final_zone_connections[S.transition]
		if(S.x <= TRANSITIONEDGE)
			S.transition = directions[Z_WEST]
		else if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
			S.transition = directions[Z_EAST]
		else if(S.y <= TRANSITIONEDGE)
			S.transition = directions[Z_SOUTH]
		else
			S.transition = directions[Z_NORTH]

		S.Assign_Destination()

/turf/space/singularity_act()
	return
/turf/simulated/floor/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/simulated/floor/chasm
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "smooth"
	canSmoothWith = list(/turf/simulated/floor/chasm)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	var/static/list/falling_atoms = list() //Atoms currently falling into the chasm
	var/static/list/forbidden_types = typecacheof(list(
		/obj/singularity,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/item/projectile,
		/obj/effect/portal,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/particle_effect/ion_trails
		))
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 1

/turf/simulated/floor/chasm/Entered(atom/movable/AM)
	..()
	START_PROCESSING(SSprocessing, src)
	drop_stuff(AM)

/turf/simulated/floor/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
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

/turf/simulated/floor/chasm/proc/is_safe()
	//if anything matching this typecache is found in the chasm, we don't drop things
	var/static/list/chasm_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, chasm_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/turf/simulated/floor/chasm/proc/drop_stuff(AM)
	. = 0
	if(is_safe())
		return FALSE
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(droppable(thing))
			. = 1
			INVOKE_ASYNC(src, .proc/drop, thing)

/turf/simulated/floor/chasm/proc/droppable(atom/movable/AM)
	if(falling_atoms[AM])
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(!AM.simulated || is_type_in_typecache(AM, forbidden_types) || AM.throwing)
		return FALSE
	//Flies right over the chasm
	if(isliving(AM))
		var/mob/M = AM
		if(M.flying)
			return FALSE
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.belt, /obj/item/wormhole_jaunter))
			var/obj/item/wormhole_jaunter/J = H.belt
			//To freak out any bystanders
			visible_message("<span class='boldwarning'>[H] falls into [src]!</span>")
			J.chasm_react(H)
			return FALSE
	return TRUE

/turf/simulated/floor/chasm/proc/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = TRUE
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>GAH! Ah... where are you?</span>")
		T.visible_message("<span class='boldwarning'>[AM] falls from above!</span>")
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Weaken(5)
			L.adjustBruteLoss(30)
	falling_atoms -= AM

/turf/simulated/floor/chasm/straight_down/Initialize()
	. = ..()
	drop_x = x
	drop_y = y
	drop_z = z - 1
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		T.visible_message("<span class='boldwarning'>The ceiling gives way!</span>")
		playsound(T, 'sound/effects/break_stone.ogg', 50, 1)

/turf/simulated/floor/chasm/straight_down/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right

/turf/simulated/floor/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = TRUE
	AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark.</span>")
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Stun(200)
		L.resting = TRUE
	var/oldtransform = AM.transform
	var/oldcolor = AM.color
	var/oldalpha = AM.alpha
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return
		AM.pixel_y--
		sleep(2)

	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	if(isrobot(AM))
		var/mob/living/silicon/robot/S = AM
		qdel(S.mmi)

	falling_atoms -= AM

	qdel(AM)

	if(AM && !QDELETED(AM))	//It's indestructible
		visible_message("<span class='boldwarning'>[src] spits out the [AM]!</span>")
		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform
		AM.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1, 10),rand(1, 10))

/turf/simulated/floor/chasm/straight_down/lava_land_surface/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/chasm/CanPass(atom/movable/mover, turf/target)
	return 1
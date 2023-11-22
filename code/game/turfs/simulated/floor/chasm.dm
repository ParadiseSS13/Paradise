/turf/simulated/floor/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/simulated/floor/chasm
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "chasms-255"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	layer = 1.7
	intact = 0
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
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/abstract,
		/obj/effect/ebeam,
		/obj/effect/spawner,
		/obj/structure/railing,
		/obj/machinery/atmospherics/pipe/simple,
		/obj/effect/projectile,
		/obj/effect/projectile_lighting,
		/mob/living/simple_animal/hostile/megafauna //failsafe
		))
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 2 // so that it doesn't send you to CC if something fucks up.

/turf/simulated/floor/chasm/Entered(atom/movable/AM)
	..()
	START_PROCESSING(SSprocessing, src)
	drop_stuff(AM)

/turf/simulated/floor/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/chasm/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(!isliving(caller))
		return TRUE
	var/mob/living/L = caller
	return (L.flying || ismegafauna(caller))

/turf/simulated/floor/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			var/obj/item/inactive = user.get_inactive_hand()

			if(isrobot(user))
				for(var/obj/item/thing in user.get_all_slots())
					if(thing.tool_behaviour == TOOL_SCREWDRIVER)
						inactive = thing
						break

			if(!inactive || inactive.tool_behaviour != TOOL_SCREWDRIVER)
				to_chat(user, "<span class='warning'>You need to hold a screwdriver in your other hand to secure this lattice.</span>")
				return
			var/obj/item/stack/rods/R = C
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
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
				ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/simulated/floor/chasm/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

/turf/simulated/floor/chasm/ex_act(severity)
	return

/turf/simulated/floor/chasm/proc/drop_stuff(AM)
	. = 0
	if(find_safeties())
		return FALSE
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(droppable(thing))
			. = 1
			INVOKE_ASYNC(src, PROC_REF(drop), thing)

/turf/simulated/floor/chasm/proc/droppable(atom/movable/AM)
	if(falling_atoms[AM])
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(!AM.simulated || is_type_in_typecache(AM, forbidden_types) || AM.throwing)
		return FALSE
	//Flies right over the chasm
	if(isliving(AM))
		var/mob/living/M = AM
		if(M.flying || M.floating)
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
			L.Weaken(10 SECONDS)
			L.adjustBruteLoss(30)
	falling_atoms -= AM

/turf/simulated/floor/chasm/straight_down
	var/obj/effect/abstract/chasm_storage/storage

/turf/simulated/floor/chasm/straight_down/Initialize()
	. = ..()
	var/found_storage = FALSE
	for(var/obj/effect/abstract/chasm_storage/C in contents)
		storage = C
		found_storage = TRUE
		break
	if(!found_storage)
		storage = new /obj/effect/abstract/chasm_storage(src)
	drop_x = x
	drop_y = y
	drop_z = z - 1

/turf/simulated/floor/chasm/straight_down/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface //Chasms should not turn into lava
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right. Ignore the fact the people you pull out are not burning.

/turf/simulated/floor/chasm/straight_down/lava_land_surface/Initialize()
	. = ..()
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface

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
		L.Weaken(20 SECONDS)
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

	falling_atoms -= AM
	if(isliving(AM))
		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform
		var/mob/living/fallen_mob = AM
		fallen_mob.notransform = FALSE
		if(fallen_mob.stat != DEAD)
			fallen_mob.death()
			fallen_mob.adjustBruteLoss(1000) //crunch from long fall, want it to be like legion in damage
		fallen_mob.forceMove(storage)
		return

	if(istype(AM, /obj/item/grenade/jaunter_grenade))
		AM.forceMove(storage)
		return
	for(var/mob/M in AM.contents)
		M.forceMove(src)

	qdel(AM)

/**
 * An abstract object which is basically just a bag that the chasm puts people inside
 */

/obj/effect/abstract/chasm_storage
	name = "chasm depths"
	desc = "The bottom of a hole. You shouldn't be able to interact with this."
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/chasm_storage/Entered(atom/movable/arrived)
	. = ..()
	if(isliving(arrived))
		RegisterSignal(arrived, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))

/obj/effect/abstract/chasm_storage/Exited(atom/movable/gone)
	. = ..()
	if(isliving(gone))
		UnregisterSignal(gone, COMSIG_LIVING_REVIVE)

/**
 * Called if something comes back to life inside the pit. Expected sources are badmins and changelings.
 * Ethereals should take enough damage to be smashed and not revive.
 * Arguments
 * escapee - Lucky guy who just came back to life at the bottom of a hole.
 */
/obj/effect/abstract/chasm_storage/proc/on_revive(mob/living/escapee)
	SIGNAL_HANDLER
	var/turf/ourturf = get_turf(src)
	if(istype(ourturf, /turf/simulated/floor/chasm/straight_down/lava_land_surface))
		ourturf.visible_message("<span class='boldwarning'>After a long climb, [escapee] leaps out of [ourturf]!</span>")
	else
		playsound(ourturf, 'sound/effects/bang.ogg', 50, TRUE)
		ourturf.visible_message("<span class='boldwarning'>[escapee] busts through [ourturf], leaping out of the chasm below!</span>")
		ourturf.ChangeTurf(ourturf.baseturf)
	escapee.flying = TRUE
	escapee.forceMove(ourturf)
	escapee.throw_at(get_edge_target_turf(ourturf, pick(GLOB.alldirs)), rand(2, 10), rand(2, 10))
	escapee.flying = FALSE
	escapee.Sleeping(20 SECONDS)

/turf/simulated/floor/chasm/straight_down/lava_land_surface/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/chasm/CanPass(atom/movable/mover, turf/target)
	return 1

/turf/simulated/floor/chasm/pride/Initialize(mapload)
	. = ..()
	drop_x = x
	drop_y = y
	var/list/target_z = levels_by_trait(SPAWN_RUINS)
	drop_z = pick(target_z)

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

	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/simulated/floor/chasm/Entered(atom/movable/AM)
	..()
	START_PROCESSING(SSprocessing, src)
	drop_stuff(AM)

/turf/simulated/floor/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/chasm/Initialize()
	. = ..()
	drop_z = level_name_to_num(MAIN_STATION)

/turf/simulated/floor/chasm/ex_act()
	return

/turf/simulated/floor/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/R = C
		var/obj/structure/lattice/fireproof/L = locate(/obj/structure/lattice, src)
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

/turf/simulated/floor/chasm/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

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
		var/mob/living/M = AM
		if(M.flying || M.floating || M.incorporeal_move)
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
	..()
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
	if(!AM || QDELETED(AM) || AM.anchored)
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
	if(iscarbon(AM) && prob(25))
		playsound(AM.loc, 'sound/effects/wilhelm_scream.ogg', 150)
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
		AM.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))

/turf/simulated/floor/chasm/straight_down/lava_land_surface/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/chasm/CanPass(atom/movable/mover, turf/target)
	return 1

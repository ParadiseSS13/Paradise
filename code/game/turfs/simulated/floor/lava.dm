/turf/simulated/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturf = /turf/simulated/floor/plating/lava //lava all the way down
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/simulated/floor/plating/lava/ex_act()
	return

/turf/simulated/floor/plating/lava/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/plating/lava/rcd_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	return

/turf/simulated/floor/plating/lava/airless
	temperature = TCMB

/turf/simulated/floor/plating/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/singularity_act()
	return

/turf/simulated/floor/plating/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/lava/make_plating()
	return

/turf/simulated/floor/plating/lava/remove_plating()
	return

/turf/simulated/floor/plating/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/plating/lava/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

/turf/simulated/floor/plating/lava/proc/burn_stuff(AM)
	. = 0

	if(locate(/obj/vehicle/lavaboat) in src.contents)
		return FALSE

	if(find_safeties())
		return FALSE

	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if(!O.simulated)
				continue
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor.getRating("fire") > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor = O.armor.setRating(fire_value = 50)
			O.fire_act(10000, 1000)

		else if(isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.flying || L.incorporeal_move)
				continue	//YOU'RE FLYING OVER IT
			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & LAVA_PROOF)
					continue
			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("lava" in live.weather_immunities)
					continue

			if("lava" in L.weather_immunities)
				continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()


/turf/simulated/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
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
		else
			return
	else return

/turf/simulated/floor/plating/lava/screwdriver_act()
	return

/turf/simulated/floor/plating/lava/welder_act()
	return

/turf/simulated/floor/plating/lava/break_tile()
	return

/turf/simulated/floor/plating/lava/burn_tile()
	return

/turf/simulated/floor/plating/lava/smooth
	name = "lava"
	baseturf = /turf/simulated/floor/plating/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/simulated/floor/plating/lava/smooth)

/turf/simulated/floor/plating/lava/smooth/lava_land_surface
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface

/turf/simulated/floor/plating/lava/smooth/airless
	temperature = TCMB

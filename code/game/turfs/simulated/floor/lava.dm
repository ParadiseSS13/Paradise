/turf/simulated/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturf = /turf/simulated/floor/plating/lava //lava all the way down
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/lava/New()
	..()

/turf/simulated/floor/plating/lava/ex_act()
	return

/turf/simulated/floor/plating/lava/airless
	temperature = TCMB

/turf/simulated/floor/plating/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		processing_objects.Add(src)

/turf/simulated/floor/plating/lava/hitby(atom/movable/AM)
	if(burn_stuff(AM))
		processing_objects.Add(src)

/turf/simulated/floor/plating/lava/process()
	if(!burn_stuff())
		processing_objects.Remove(src)

/turf/simulated/floor/plating/lava/singularity_act()
	return

/turf/simulated/floor/plating/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/lava/make_plating()
	return

/turf/simulated/floor/plating/lava/proc/is_safe()
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/turf/simulated/floor/plating/lava/proc/burn_stuff(AM)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if (istype(thing, /atom/movable/lighting_overlay) || istype(thing, /atom/movable/overlay))
			continue
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			O.fire_act(10000, 1000)

		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.flying)
				continue	//YOU'RE FLYING OVER IT
			if("lava" in L.weather_immunities)
				continue
			if(L.buckled)
				if(isobj(L.buckled))
					var/obj/O = L.buckled
					if(O.resistance_flags & LAVA_PROOF)
						continue
				if(isliving(L.buckled)) //Goliath riding
					var/mob/living/live = L.buckled
					if("lava" in live.weather_immunities)
						continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()


/turf/simulated/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
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
	//baseturf = /turf/simulated/chasm/straight_down/lava_land_surface TODO: Uncomment

/turf/simulated/floor/plating/lava/smooth/airless
	temperature = TCMB
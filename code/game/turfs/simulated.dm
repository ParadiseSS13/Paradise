#define WATER_STUN_TIME 2 //Stun time for water, to edit/find easier
#define WATER_WEAKEN_TIME 1 //Weaken time for water, to edit/find easier
/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/water_act(volume, temperature, source)
	. = ..()

	if(volume >= 3)
		MakeSlippery()

	var/hotspot = (locate(/obj/effect/hotspot) in src)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = remove_air(air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		assume_air(lowertemp)
		qdel(hotspot)

/*
 * Makes a turf slippery using the given parameters
 * @param wet_setting The type of slipperyness used
 * @param time Time the turf is slippery. If null it will pick a random time between 790 and 820 ticks. If INFINITY then it won't dry up ever
*/
/turf/simulated/proc/MakeSlippery(wet_setting = TURF_WET_WATER, time = null) // 1 = Water, 2 = Lube, 3 = Ice, 4 = Permafrost
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting != TURF_DRY)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		var/turf/simulated/floor/F = src
		if(istype(F))
			if(wet_setting >= TURF_WET_ICE)
				wet_overlay = image('icons/effects/water.dmi', src, "ice_floor")
			else
				wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		else
			if(wet_setting >= TURF_WET_ICE)
				wet_overlay = image('icons/effects/water.dmi', src, "ice_floor")
			else
				wet_overlay = image('icons/effects/water.dmi', src, "wet_static")
		wet_overlay.plane = FLOOR_OVERLAY_PLANE
		overlays += wet_overlay
	if(time == INFINITY)
		return
	if(!time)
		time =	rand(790, 820)
	addtimer(CALLBACK(src, .proc/MakeDry, wet_setting), time)

/turf/simulated/MakeDry(wet_setting = TURF_WET_WATER)
	if(wet > wet_setting)
		return
	wet = TURF_DRY
	if(wet_overlay)
		overlays -= wet_overlay

/turf/simulated/Entered(atom/A, atom/OL, ignoreRest = 0)
	..()
	if(!ignoreRest)
		if(ishuman(A))
			var/mob/living/carbon/human/M = A
			if(M.lying)
				return 1

			if(M.flying)
				return ..()

			switch(src.wet)
				if(TURF_WET_WATER)
					if(!(M.slip("the wet floor", WATER_STUN_TIME, WATER_WEAKEN_TIME, tilesSlipped = 0, walkSafely = 1)))
						M.inertia_dir = 0
						return

				if(TURF_WET_LUBE) //lube
					M.slip("the floor", 0, 5, tilesSlipped = 3, walkSafely = 0, slipAny = 1)


				if(TURF_WET_ICE) // Ice
					if(M.slip("the icy floor", 4, 2, tilesSlipped = 0, walkSafely = 0))
						M.inertia_dir = 0
						if(prob(5))
							var/obj/item/organ/external/affected = M.get_organ("head")
							if(affected)
								M.apply_damage(5, BRUTE, "head")
								M.visible_message("<span class='warning'><b>[M]</b> hits their head on the ice!</span>")
								playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)

				if(TURF_WET_PERMAFROST) // Permafrost
					M.slip("the frosted floor", 0, 5, tilesSlipped = 1, walkSafely = 0, slipAny = 1)

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	. = ..()
	queue_smooth_neighbors(src)

/turf/simulated/proc/is_shielded()

#undef WATER_STUN_TIME
#undef WATER_WEAKEN_TIME

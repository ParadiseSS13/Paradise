/// Knockdown time for slipping on water
#define WATER_WEAKEN_TIME 4 SECONDS
/turf/simulated
	name = "station"
	/// Used to check if the turf is wet. Really should just be an object on the turf
	var/wet = 0
	/// Used to store the wet turf overlay. Really should just be an object on the turf
	var/image/wet_overlay = null
	/*
	Atmos Vars
	*/
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	/// The excited group we're linked to. Used for zone atmos calculations
	var/datum/excited_group/excited_group
	/// Is this turf active?
	var/excited = 0
	/// Was this turf recently activated? Probably not needed anymore
	var/recently_active = 0
	var/archived_cycle = 0
	var/current_cycle = 0
	/// The active hotspot on this turf. The fact this is done through a literal object is painful
	var/obj/effect/hotspot/active_hotspot
	/// The temp we were when we got archived
	var/temperature_archived
	/// Current gas overlay. Can be set to plasma or sleeping_gas
	var/atmos_overlay_type = null
	/// If a fire is ongoing, how much fuel did we burn last tick?
	/// Value is not updated while below PLASMA_MINIMUM_BURN_TEMPERATURE.
	var/fuel_burnt = 0
	/// When do we last remember having wind?
	var/wind_tick = null
	/// Wind's X component
	var/wind_x = null
	/// Wind's Y component
	var/wind_y = null
	/// Wind effect
	var/obj/effect/wind/wind_effect = null

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/cleaning_act(mob/user, atom/cleaner, cleanspeed = 50, text_verb = "clean", text_description = " with [cleaner].", text_targetname = name, skip_do_after = FALSE)
	if(!..())
		return

	if(!cleaner.can_clean())
		return

	clean_blood()
	for(var/obj/effect/O in src)
		if(O.is_cleanable())
			qdel(O)

/turf/simulated/water_act(volume, temperature, source)
	. = ..()

	if(volume >= 3)
		MakeSlippery()

	quench(1000, 2)

/// Quenches any fire on the turf, and if it does, cools down the turf's air by the given parameters.
/turf/simulated/proc/quench(delta, divisor)
	var/found = FALSE
	for(var/obj/effect/hotspot/hotspot in src)
		qdel(hotspot)
		found = TRUE

	if(!found)
		return

	var/datum/milla_safe/turf_cool/milla = new()
	milla.invoke_async(src, delta, divisor)

/datum/milla_safe/turf_cool

/datum/milla_safe/turf_cool/on_run(turf/T, delta, divisor)
	var/datum/gas_mixture/air = get_turf_air(T)
	air.set_temperature(max(min(air.temperature()-delta * divisor,air.temperature() / divisor), TCMB))
	air.react()

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
		wet_overlay.appearance_flags = RESET_TRANSFORM
		overlays += wet_overlay
	if(time == INFINITY)
		return
	if(!time)
		time =	rand(790, 820)
	addtimer(CALLBACK(src, PROC_REF(MakeDry), wet_setting), time)

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
			if(IS_HORIZONTAL(M))
				return 1

			if(HAS_TRAIT(M, TRAIT_FLYING))
				return ..()

			switch(src.wet)
				if(TURF_WET_WATER)
					if(!(M.slip("the wet floor", WATER_WEAKEN_TIME, tilesSlipped = 0, walkSafely = 1)))
						return

				if(TURF_WET_LUBE) //lube
					M.slip("the floor", 10 SECONDS, tilesSlipped = 3, walkSafely = 0, slipAny = 1)


				if(TURF_WET_ICE) // Ice
					if(M.slip("the icy floor", 8 SECONDS, tilesSlipped = 0, walkSafely = 0))
						if(prob(5))
							var/obj/item/organ/external/affected = M.get_organ("head")
							if(affected)
								M.apply_damage(5, BRUTE, "head")
								M.visible_message("<span class='warning'><b>[M]</b> hits their head on the ice!</span>")
								playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)

				if(TURF_WET_PERMAFROST) // Permafrost
					M.slip("the frosted floor", 10 SECONDS, tilesSlipped = 1, walkSafely = 0, slipAny = 1)

/turf/simulated/BeforeChange()
	QDEL_NULL(wind_effect)
	return ..()

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)

/turf/simulated/proc/is_shielded()
	return

#undef WATER_WEAKEN_TIME

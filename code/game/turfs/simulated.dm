/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/dirt = 0
	var/dirtoverlay = null
	var/unacidable = FALSE

/turf/simulated/New()
	..()
	levelupdate()
	visibilityChanged()

/turf/simulated/proc/break_tile()
	return

/turf/simulated/proc/burn_tile()
	return

/turf/simulated/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube)
	if(C.flying)
		return FALSE
	if(has_gravity(src))
		var/obj/buckled_obj
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube & GALOSHES_DONT_HELP))
				return FALSE
		else
			if(C.lying || !(C.status_flags & CANWEAKEN)) // can't slip unbuckled mob if they're lying or can't fall.
				return FALSE
			if(C.m_intent == MOVE_INTENT_WALK && (lube & NO_SLIP_WHEN_WALKING))
				return FALSE
		if(!(lube & SLIDE_ICE))
			to_chat(C, "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>")
			playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		var/olddir = C.dir
		C.moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
		if(!(lube & SLIDE_ICE))
			C.Weaken(knockdown_amount)
			C.stop_pulling()
		else
			C.Weaken(2)

		if(buckled_obj)
			buckled_obj.unbuckle_mob(C)
			lube |= SLIDE_ICE

		if(lube & SLIDE)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 3), 1, FALSE)
		else if(lube & SLIDE_ICE)
			if(C.force_moving) //If we're already slipping extend it
				qdel(C.force_moving)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
		return TRUE

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

/turf/simulated/proc/MakeSlippery(wet_setting = TURF_WET_WATER, infinite = FALSE) // 1 = Water, 2 = Lube, 3 = Ice, 4 = Permafrost
	if(wet >= wet_setting)
		return
	wet = wet_setting
	UpdateSlip()
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
		overlays += wet_overlay
	if(!infinite)
		spawn(rand(790, 820)) // Purely so for visual effect
			if(!istype(src, /turf/simulated)) //Because turfs don't get deleted, they change, adapt, transform, evolve and deform. they are one and they are all.
				return
			MakeDry(wet_setting)

/turf/simulated/proc/UpdateSlip()
	switch(wet)
		if(TURF_WET_WATER)
			AddComponent(/datum/component/slippery, 2, NO_SLIP_WHEN_WALKING, CALLBACK(src, .proc/AfterSlip))
		if(TURF_WET_LUBE)
			AddComponent(/datum/component/slippery, 5, SLIDE | GALOSHES_DONT_HELP, CALLBACK(src, .proc/AfterSlip))
		if(TURF_WET_ICE)
			AddComponent(/datum/component/slippery, 2, SLIDE | GALOSHES_DONT_HELP, CALLBACK(src, .proc/AfterSlip))
		if(TURF_WET_PERMAFROST)
			AddComponent(/datum/component/slippery, 5, SLIDE_ICE | GALOSHES_DONT_HELP, CALLBACK(src, .proc/AfterSlip))
		// if anyone wants to port slides
/* 		if(TURF_WET_SLIDE)
			AddComponent(/datum/component/slippery, 80, SLIDE | GALOSHES_DONT_HELP) */
		else
			qdel(GetComponent(/datum/component/slippery))

/turf/simulated/proc/AfterSlip(mob/living/carbon/human/M)
	if(wet == TURF_WET_ICE)
		if(prob(5))
			var/obj/item/organ/external/affected = M.get_organ("head")
			if(affected)
				M.apply_damage(5, BRUTE, "head")
				M.visible_message("<span class='warning'><b>[M]</b> hits their head on the ice!</span>")
				playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)

/turf/simulated/proc/MakeDry(wet_setting = TURF_WET_WATER)
	if(wet > wet_setting)
		return
	wet = TURF_DRY
	if(wet_overlay)
		overlays -= wet_overlay
	UpdateSlip()

/turf/simulated/Entered(atom/A, atom/OL, ignoreRest = 0)
	..()
	if(!ignoreRest)
		if(isliving(A) && prob(50))
			dirt++

		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt) in src
		if(dirt >= 100)
			if(!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(src)
				dirtoverlay.alpha = 10
			else if(dirt > 100)
				dirtoverlay.alpha = min(dirtoverlay.alpha + 10, 200)

		if(ishuman(A))
			var/mob/living/carbon/human/M = A
			if(M.lying)
				return 1

			if(M.flying)
				return ..()

/turf/simulated/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	. = ..()
	queue_smooth_neighbors(src)

/turf/simulated/proc/is_shielded()

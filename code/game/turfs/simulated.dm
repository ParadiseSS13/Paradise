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

/turf/simulated/New()
	..()
	levelupdate()
	visibilityChanged()

/turf/simulated/proc/burn_tile()

/turf/simulated/proc/MakeSlippery(wet_setting = TURF_WET_WATER) // 1 = Water, 2 = Lube, 3 = Ice
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting != TURF_DRY)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		var/turf/simulated/floor/F = src
		if(istype(F))
			wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		else
			wet_overlay = image('icons/effects/water.dmi', src, "wet_static")
		overlays += wet_overlay

	spawn(rand(790, 820)) // Purely so for visual effect
		if(!istype(src, /turf/simulated)) //Because turfs don't get deleted, they change, adapt, transform, evolve and deform. they are one and they are all.
			return
		MakeDry(wet_setting)

/turf/simulated/proc/MakeDry(wet_setting = TURF_WET_WATER)
	if(wet > wet_setting)
		return
	wet = TURF_DRY
	if(wet_overlay)
		overlays -= wet_overlay

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

			//Bloody footprints
			var/turf/T = get_turf(M)
			var/obj/item/organ/external/l_foot = M.get_organ("l_foot")
			var/obj/item/organ/external/r_foot = M.get_organ("r_foot")
			var/hasfeet = 1
			if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
				hasfeet = 0

			if(M.shoes)
				var/obj/item/clothing/shoes/S = M.shoes
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in T
					if(oldFP && oldFP.blood_state == S.blood_state)
						return
					else
						//No oldFP or it's a different kind of blood
						S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state]-BLOOD_LOSS_PER_STEP)
						var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
						FP.blood_state = S.blood_state
						FP.entered_dirs |= dir
						FP.bloodiness = S.bloody_shoes[S.blood_state]
						FP.blood_DNA = S.blood_DNA
						var/currentBloodColor = "#A10808"
						if(S.blood_DNA)
							FP.transfer_blood_dna(S.blood_DNA)
							currentBloodColor = S.blood_DNA["blood_color"]
						FP.basecolor = currentBloodColor
						FP.update_icon()
						M.update_inv_shoes()
			else if(hasfeet && M.bloody_feet[M.blood_state])
				var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in T
				if(oldFP && oldFP.blood_state == M.blood_state)
					return
				else
					M.bloody_feet[M.blood_state] = max(0, M.bloody_feet[M.blood_state]-BLOOD_LOSS_PER_STEP)
					var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
					FP.entered_dirs |= dir
					FP.bloodiness = M.bloody_feet[M.blood_state]
					var/currentBloodColor = "#A10808"
					if(M.feet_blood_DNA)
						FP.transfer_blood_dna(M.feet_blood_DNA)
						currentBloodColor = M.feet_blood_color
					FP.basecolor = currentBloodColor
					FP.update_icon()
					M.update_inv_shoes()
			//End bloody footprints

			switch(src.wet)
				if(TURF_WET_WATER)
					if(!(M.slip("wet floor", 4, 2, 0, 1)))
						M.inertia_dir = 0
						return

				if(TURF_WET_LUBE) //lube
					M.slip("floor", 0, 5, 3, 0, 1)


				if(TURF_WET_ICE) // Ice
					if(!(prob(30) && M.slip("icy floor", 4, 2, 1, 1)))
						M.inertia_dir = 0

/turf/simulated/ChangeTurf(var/path)
	. = ..()
	smooth_icon_neighbors(src)

/turf/simulated/proc/is_shielded()

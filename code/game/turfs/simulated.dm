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

/turf/simulated/proc/AddTracks(var/typepath,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor="#A10808")
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

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

			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor = ""
			if(M.shoes)
				var/obj/item/clothing/shoes/S = M.shoes
				if(S.track_blood && S.blood_DNA)
					bloodDNA = S.blood_DNA
					bloodcolor = S.blood_color
					S.track_blood--
			else
				if(M.track_blood && M.feet_blood_DNA)
					bloodDNA = M.feet_blood_DNA
					bloodcolor = M.feet_blood_color
					M.track_blood--

			if(bloodDNA)
				src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,M.dir,0,bloodcolor) // Coming
				var/turf/simulated/from = get_step(M,reverse_direction(M.dir))
				if(istype(from) && from)
					from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,M.dir,bloodcolor) // Going

				bloodDNA = null

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


//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(mob/living/carbon/human/M)
	if(!..())
		return 0

	if(!istype(M)) // To avoid non-humans from causing runtimes whena dding blood to the floor
		return 0
	var/obj/effect/decal/cleanable/blood/B = locate() in contents	//check for existing blood splatter
	if(!B)
		blood_splatter(src,M.get_blood(M.vessel),1)
		B = locate(/obj/effect/decal/cleanable/blood) in contents
	B.add_blood_list(M)
	return 1 //we bloodied the floor

// Only adds blood on the floor -- Skie
/turf/simulated/add_blood_floor(mob/living/carbon/M as mob)
	if(ishuman(M))
		blood_splatter(src,M,1)
	if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"
	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/blood/oil(src)

/turf/simulated/ChangeTurf(var/path)
	. = ..()
	smooth_icon_neighbors(src)

/turf/simulated/proc/is_shielded()

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
	
/turf/simulated/proc/MakeSlippery(var/wet_setting = 1) // 1 = Water, 2 = Lube
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting == 1)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		overlays += wet_overlay

	spawn(rand(790, 820)) // Purely so for visual effect
		if(!istype(src, /turf/simulated)) //Because turfs don't get deleted, they change, adapt, transform, evolve and deform. they are one and they are all.
			return
		if(wet > wet_setting) return
		wet = 0
		if(wet_overlay)
			overlays -= wet_overlay	

/turf/simulated/proc/AddTracks(var/typepath,var/mob,var/bloodDNA,var/comingdir,var/goingdir)
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(mob,bloodDNA,comingdir,goingdir,typepath)

/turf/simulated/Entered(atom/A, atom/OL)

	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)	return
		dirt++
		if (dirt >= 50)
			var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, src)
			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(src)
				dirtoverlay.alpha = 15
			else if (dirt > 50)
				dirtoverlay.alpha = min(dirtoverlay.alpha+5, 255)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
				var/obj/item/clothing/shoes/clown_shoes/O = H.shoes
				if(H.m_intent == "run")
					if(O.footstep >= 2)
						O.footstep = 0
						playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
					else
						O.footstep++
				else
					playsound(src, "clownstep", 20, 1)
			if(istype(H.shoes, /obj/item/clothing/shoes/jackboots))
				var/obj/item/clothing/shoes/jackboots/O = H.shoes
				if(H.m_intent == "run")
					if(O.footstep >= 2)
						O.footstep = 0
						playsound(src, "jackboot", 50, 1) // this will get annoying very fast.
					else
						O.footstep++
				else
					playsound(src, "jackboot", 20, 1)

			var/list/bloodDNA = null
			if(H.shoes)
				var/obj/item/clothing/shoes/S = H.shoes
				if(S.track_blood && S.blood_DNA)
					bloodDNA = S.blood_DNA
					S.track_blood--
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,H,bloodDNA,H.dir,0) // Coming
					var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
					if(from && istype(from, /turf/simulated))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,H,bloodDNA,0,H.dir) // Going

				if(S.track_blood_green && S.blood_DNA)
					bloodDNA = S.blood_DNA
					S.track_blood_green--
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/green,H,bloodDNA,H.dir,0) // Coming
					var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
					if(from && istype(from, /turf/simulated))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/green,H,bloodDNA,0,H.dir) // Going
			else
				if(H.track_blood && H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
					H.track_blood--
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,H,bloodDNA,H.dir,0) // Coming
					var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
					if(from && istype(from, /turf/simulated))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,H,bloodDNA,0,H.dir) // Going
				if(H.track_blood_green && H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
					H.track_blood_green--
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/green,H,bloodDNA,H.dir,0) // Coming
					var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
					if(from && istype(from, /turf/simulated))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/green,H,bloodDNA,0,H.dir) // Going
			bloodDNA = null

		var/noslip = 0
		for (var/obj/structure/stool/bed/chair/C in loc)
			if (C.buckled_mob == M)
				noslip = 1
		if (noslip)
			return // no slipping while sitting in a chair, plz
		switch (src.wet)
			if(1)
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, (/mob/living/carbon/slime || /mob/living/carbon/human/slime)) || (M:species.bodyflags & FEET_NOSLIP))
					if (M.m_intent == "run")
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return

			if(2) //lube                //can cause infinite loops - needs work
				if(!istype(M, /mob/living/carbon/slime) && !M.buckled)
					M.stop_pulling()
					step(M, M.dir)
					spawn(1) step(M, M.dir)
					spawn(2) step(M, M.dir)
					spawn(3) step(M, M.dir)
					spawn(4) step(M, M.dir)
					M.take_organ_damage(2) // Was 5 -- TLE
					M << "\blue You slipped on the floor!"
					playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
					M.Weaken(10)

			if(3) // Ice
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP) && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the icy floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(5)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/metroid) || (M:species.bodyflags & FEET_NOSLIP))
					if (M.m_intent == "run" && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the icy floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(5)
					else
						M.inertia_dir = 0
						return

	..()

//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	for(var/obj/effect/decal/cleanable/blood/B in contents)
		if(!B.blood_DNA[M.dna.unique_enzymes])
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			B.virus2 = virus_copylist(M.virus2)
		return 1 //we bloodied the floor



	//if there isn't a blood decal already, make one.
	if(M.species.bloodflags &BLOOD_GREEN)
		var/obj/effect/decal/cleanable/blood/green/newblood = new /obj/effect/decal/cleanable/blood/green(src)
		newblood.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
		newblood.virus2 = virus_copylist(M.virus2)
		newblood.update_icon()
	else
		var/obj/effect/decal/cleanable/blood/newblood = new /obj/effect/decal/cleanable/blood(src)
		newblood.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
		newblood.virus2 = virus_copylist(M.virus2)
		newblood.update_icon()

	return 1 //we bloodied the floor


// Only adds blood on the floor -- Skie
/turf/simulated/proc/add_blood_floor(mob/living/carbon/M as mob)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.species.bloodflags &BLOOD_GREEN)
			var/obj/effect/decal/cleanable/blood/green/this = new /obj/effect/decal/cleanable/blood/green(src)
			this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			if (M.virus2.len)
				this.virus2 = virus_copylist(M.virus2)
		else
			var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)
			this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			if (M.virus2.len)
				this.virus2 = virus_copylist(M.virus2)
	if(istype(M, /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)
		this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
		if (M.virus2.len)
			this.virus2 = virus_copylist(M.virus2)

	else if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/xenoblood/this = new /obj/effect/decal/cleanable/xenoblood(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"

	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/oil(src)


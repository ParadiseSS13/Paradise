/proc/gibs(atom/location, datum/dna/MobDNA)		//CARN MARKER
	new /obj/effect/gibspawner/generic(get_turf(location), MobDNA)

/proc/hgibs(atom/location, datum/dna/MobDNA)
	new /obj/effect/gibspawner/human(get_turf(location), MobDNA)

/proc/xgibs(atom/location)
	new /obj/effect/gibspawner/xeno(get_turf(location))

/proc/robogibs(atom/location)
	new /obj/effect/gibspawner/robot(get_turf(location))

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists

	New(location, datum/dna/MobDNA)
		..()

		if(istype(loc,/turf)) //basically if a badmin spawns it
			Gib(loc, MobDNA)

	proc/Gib(atom/location, datum/dna/MobDNA = null)
		if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
			to_chat(world, "<span class='warning'>Gib list length mismatch!</span>")
			return

		var/obj/effect/decal/cleanable/blood/gibs/gib = null

		if(sparks)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(2, 1, location)
			s.start()

		for(var/i = 1, i<= gibtypes.len, i++)
			if(gibamounts[i])
				for(var/j = 1, j<= gibamounts[i], j++)
					var/gibType = gibtypes[i]
					gib = new gibType(location)


					gib.blood_DNA = list()
					if(MobDNA)
						gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.b_type
					else if(istype(src, /obj/effect/gibspawner/xeno))
						gib.blood_DNA["UNKNOWN DNA"] = "X*"
					else if(istype(src, /obj/effect/gibspawner/human)) // Probably a monkey
						gib.blood_DNA["Non-human DNA"] = "A+"
					var/list/directions = gibdirections[i]
					if(directions.len)
						gib.streak(directions)

		qdel(src)

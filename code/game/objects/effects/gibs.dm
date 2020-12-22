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

/obj/effect/gibspawner/New(location, datum/dna/MobDNA)
	..()
	ASSERT(length(gibtypes) == length(gibamounts))
	ASSERT(length(gibamounts) == length(gibdirections))

	if(istype(loc, /turf)) //basically if a badmin spawns it
		Gib(loc, MobDNA)

/obj/effect/gibspawner/proc/Gib(atom/location, datum/dna/MobDNA)
	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		do_sparks(2, 1, location)

	for(var/I in 1 to length(gibtypes))
		if(!gibamounts[I])
			continue
		for(var/J in 1 to gibamounts[I])
			var/gib_type = gibtypes[I]
			gib = new gib_type(location)
			gib.blood_DNA = list()

			gib_dna(gib, MobDNA)

			var/list/directions = gibdirections[I]
			if(length(directions))
				gib.streak(directions)

	qdel(src) // qdel once done

/obj/effect/gibspawner/proc/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/MobDNA)
	if(!MobDNA)
		return TRUE

	gib.basecolor = MobDNA.species.blood_color
	gib.update_icon()
	gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.blood_type

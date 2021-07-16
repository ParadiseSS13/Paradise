/proc/gibs(atom/location, datum/dna/mob_dna)		//CARN MARKER
	new /obj/effect/gibspawner/generic(get_turf(location), mob_dna)

/proc/hgibs(atom/location, datum/dna/mob_dna)
	new /obj/effect/gibspawner/human(get_turf(location), mob_dna)

/proc/xgibs(atom/location)
	new /obj/effect/gibspawner/xeno(get_turf(location))

/proc/robogibs(atom/location)
	new /obj/effect/gibspawner/robot(get_turf(location))

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists

/obj/effect/gibspawner/Initialize(mapload, datum/dna/mob_dna)
	..()
	ASSERT(length(gibtypes) == length(gibamounts))
	ASSERT(length(gibamounts) == length(gibdirections))

	if(isturf(loc))
		spawn_gibs(loc, mob_dna)

	return INITIALIZE_HINT_QDEL // qdel once done

/**
  * Spawns the gibs (and sparks if applicable) from the gib spawner.
  *
  * Arguments:
  * * location - The position to spawn the gibs on.
  * * mob_dna - The [/datum/dna] controlling the blood DNA and colour of the gibs.
  */
/obj/effect/gibspawner/proc/spawn_gibs(atom/location, datum/dna/mob_dna)
	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		do_sparks(2, 1, location)

	for(var/gibtype in 1 to length(gibtypes))
		if(!gibamounts[gibtype])
			continue
		for(var/I in 1 to gibamounts[gibtype])
			var/gib_type = gibtypes[gibtype]
			gib = new gib_type(location)

			gib_dna(gib, mob_dna)

			var/list/directions = gibdirections[gibtype]
			if(length(directions))
				gib.streak(directions)

/**
  * Assigns DNA and blood colour to mob gibs.
  *
  * Returns FALSE if there was no DNA data to transfer to the gibs, and TRUE if there was.
  * Arguments:
  * * gib - The [/obj/effect/decal/cleanable/blood/gibs] that is being edited.
  * * mob_dna - The [/datum/dna] which is being transferred onto the gib.
  */
/obj/effect/gibspawner/proc/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/mob_dna)
	if(!mob_dna)
		return FALSE

	gib.basecolor = mob_dna.species.blood_color
	gib.update_icon()
	gib.blood_DNA[mob_dna.unique_enzymes] = mob_dna.blood_type
	return TRUE

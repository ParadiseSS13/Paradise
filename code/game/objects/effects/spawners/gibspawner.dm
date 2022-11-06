/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/New()
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	..()

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/human/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/mob_dna)
	if(!..()) // Probably admin spawned
		gib.blood_DNA["Non-human DNA"] = "A+"

/obj/effect/gibspawner/alien
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/alien/up,/obj/effect/decal/cleanable/blood/gibs/alien/down,/obj/effect/decal/cleanable/blood/gibs/alien,/obj/effect/decal/cleanable/blood/gibs/alien,/obj/effect/decal/cleanable/blood/gibs/alien/body,/obj/effect/decal/cleanable/blood/gibs/alien/limb,/obj/effect/decal/cleanable/blood/gibs/alien/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/alien/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/alien/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/mob_dna)
	if(!..())
		gib.blood_DNA["UNKNOWN DNA"] = "X*"

/obj/effect/gibspawner/robot
	sparks = 1
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/robot/up,/obj/effect/decal/cleanable/blood/gibs/robot/down,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot/limb)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/robot/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs)
	gibamounts[6] = pick(0,1,2)
	..()

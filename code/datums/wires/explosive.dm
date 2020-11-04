/datum/wires/explosive
	wire_count = 1

#define WIRE_EXPLODE 1

/datum/wires/explosive/GetWireName(index)
	switch(index)
		if(WIRE_EXPLODE)
			return "Explode"

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/UpdatePulsed(index)
	switch(index)
		if(WIRE_EXPLODE)
			explode()
	..()

/datum/wires/explosive/UpdateCut(index, mended)
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				explode()
	..()

/datum/wires/explosive/gibtonite
	holder_type = /obj/item/twohanded/required/gibtonite

/datum/wires/explosive/gibtonite/CanUse(mob/L)
	return 1

/datum/wires/explosive/gibtonite/UpdateCut(index, mended)
	return

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/twohanded/required/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)

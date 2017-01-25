/datum/wires/explosive
	wire_count = 1

var/const/WIRE_EXPLODE = 1

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_EXPLODE)
			explode()

/datum/wires/explosive/UpdateCut(var/index, var/mended)
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				explode()

/datum/wires/explosive/gibtonite
	holder_type = /obj/item/weapon/twohanded/required/gibtonite

/datum/wires/explosive/gibtonite/CanUse(var/mob/living/L)
	return 1

/datum/wires/explosive/gibtonite/UpdateCut(var/index, var/mended)
	return

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/weapon/twohanded/required/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)

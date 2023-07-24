/datum/wires/explosive
	wire_count = 1
	proper_name = "Explosive"
	window_x = 320
	window_y = 50

/datum/wires/explosive/New(atom/_holder)
	wires = list(WIRE_EXPLODE)
	return ..()

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/on_pulse(wire)
	switch(wire)
		if(WIRE_EXPLODE)
			explode()
	..()

/datum/wires/explosive/on_cut(wire, mend)
	switch(wire)
		if(WIRE_EXPLODE)
			if(!mend)
				explode()
	..()

/datum/wires/explosive/gibtonite
	holder_type = /obj/item/gibtonite

/datum/wires/explosive/gibtonite/interactable(mob/user)
	return TRUE

/datum/wires/explosive/gibtonite/on_cut(wire, mend)
	return

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)

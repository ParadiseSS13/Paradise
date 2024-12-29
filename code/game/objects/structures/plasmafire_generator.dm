/obj/structure/plasmafire_generator
	name = "Plasmafire Generator"
	desc = "A magical thing that you really shouldn't be able to see."
	anchored = TRUE
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	flags = NODECONSTRUCT

/obj/structure/plasmafire_generator/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

// for sanity checks
/obj/structure/plasmafire_generator/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/plasmafire_generator/process()
	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	var/datum/gas_mixture/fire = new()
	fire.set_toxins(10)
	fire.set_oxygen(4)
	fire.set_temperature(500)
	T.blind_release_air(fire)

/obj/structure/plasmafire_generator/shadow

/obj/structure/plasmafire_generator/shadow/process()
	var/turf/T = get_turf(src)
	if(!istype(T) || T.z == 1)
		return
	return ..()

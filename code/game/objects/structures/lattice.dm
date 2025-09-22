/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	base_icon_state = "lattice"
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	var/number_of_rods = 1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE)
	canSmoothWith = list(SMOOTH_GROUP_LATTICE, SMOOTH_GROUP_FLOOR, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TURF, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_CATWALK)

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			QDEL_IN(LAT, 0)

/obj/structure/lattice/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)
	. += "<span class='notice'>Add a floor tile to build a floor on top of the lattice.</span>"

/obj/structure/lattice/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The rods look like they could be <b>cut</b>. There's space for more <i>rods</i> or a <i>tile</i>.</span>"

/obj/structure/lattice/wirecutter_act(mob/living/user, obj/item/wirecutters/wirecutters)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(!istype(wirecutters))
		return

	playsound(loc, wirecutters.usesound, 50, 1)
	to_chat(user, "<span class='notice'>Slicing [name] joints...</span>")
	deconstruct()

	return ITEM_INTERACT_COMPLETE

/obj/structure/lattice/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// this is still here for historical reasons though it's
	// not clear if the original intention was to prevent indestructible
	// lattices from e.g. being built over with plating.
	if(resistance_flags & INDESTRUCTIBLE)
		return

	// hand this off to the turf (for building plating, catwalks, etc)
	var/turf/T = get_turf(src)
	return T.item_interaction(user, used, modifiers)

/obj/structure/lattice/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/rods(get_turf(src), number_of_rods)
	qdel(src)


/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	number_of_rods = 2
	smoothing_groups = list(SMOOTH_GROUP_CATWALK, SMOOTH_GROUP_LATTICE, SMOOTH_GROUP_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_CATWALK)

/obj/structure/lattice/catwalk/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The supporting rods look like they could be <b>cut</b>.</span>")

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/mining
	name = "reinforced catwalk"
	desc = "A heavily reinforced catwalk used to build bridges in hostile environments. It doesn't look like anything could make this budge."
	resistance_flags = INDESTRUCTIBLE

/obj/structure/lattice/catwalk/mining/deconstruction_hints(mob/user)
	return

/obj/structure/lattice/lava
	name = "heatproof support lattice"
	desc = "A specialized support beam for building across lava. Watch your step."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF

/obj/structure/lattice/lava/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The supporting rods look like they could be <b>cut</b>.</span>, but the <i>heat treatment will shatter off</i>.")


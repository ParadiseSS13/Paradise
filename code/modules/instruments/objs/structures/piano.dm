/obj/structure/piano
	parent_type = /obj/structure/musician // TODO: Can't edit maps right now due to a freeze, remove and update path when it's done
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "piano"

/obj/structure/piano/unanchored
	anchored = FALSE

/obj/structure/piano/Initialize(mapload)
	. = ..()
	if(prob(50) && icon_state == initial(icon_state))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"

/obj/structure/pianoclassic
	parent_type = /obj/structure/musician
	name = "space minimoog"
	desc = "This is a minimoog, like a space piano, but more spacey!"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minipiano"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "piano"

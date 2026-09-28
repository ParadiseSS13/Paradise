/obj/structure/lattice/flock
	name = "fibrenet"
	desc = "A floating lattice of lightweight gnesis."
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "fibrenet"
	base_icon_state = "fibrenet"
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, RAD = 0, FIRE = 70, ACID = 60)
	max_integrity = 30

/obj/structure/lattice/flock/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/lattice/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Structural Foundation"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/lattice/flock/try_flock_convert(datum/flock/flock, force)
	return

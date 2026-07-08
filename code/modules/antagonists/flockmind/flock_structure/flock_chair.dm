/obj/structure/chair/comfy/flock
	name = "buzzing alcove"
	desc = "It's a chair made of a strange material. Surprisingly soft to the touch, and extremely out of style."
	icon_state = "chair_flock"
	buildstacktype = /obj/item/stack/sheet/gnesis
	max_integrity = 50
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)

/obj/structure/chair/comfy/flock/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/chair/comfy/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Resting Chamber"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/chair/comfy/flock/try_flock_convert(datum/flock/flock, force)
	return

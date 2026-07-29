/obj/structure/shelf/flock
	name = "strange shelf"
	desc = "A shelf (most likley) made of a strange material."
	icon_state = "shelf_flock"
	shelf_style = "flock"
	build_stack_type = /obj/item/stack/sheet/gnesis

/obj/structure/shelf/flock/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/shelf/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Vertical material storage rack."),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/shelf/flock/try_flock_convert(datum/flock/flock, force)
	return

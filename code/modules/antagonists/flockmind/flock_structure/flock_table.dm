/obj/structure/table/reinforced/flock
	name = "odd table"
	desc = "It's a flat surface made of a strange material. Despite its strange appearance, there's not many things this could be except a table."
	icon = 'icons/obj/smooth_structures/tables/flock_table.dmi'
	icon_state = "flock_table-0"
	base_icon_state = "flock_table"
	buildstack = /obj/item/stack/sheet/gnesis
	buildstackamount = 2
	framestack = null
	frame = null
	framestackamount = 0
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_groups = list(SMOOTH_GROUP_FLOCK_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_FLOCK_TABLES)

/obj/structure/table/reinforced/flock/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/table/reinforced/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Table."),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/table/reinforced/flock/screwdriver_act()
	return

/obj/structure/table/reinforced/flock/deconstruct(disassembled = TRUE, wrench_disassembly = FALSE)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
	qdel(src)

/obj/structure/table/reinforced/flock/try_flock_convert(datum/flock/flock, force)
	return

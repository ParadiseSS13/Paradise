/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/abductor.dmi'
	buildstacktype = /obj/item/stack/sheet/mineral/abductor
	icon_state = "bed"

/obj/structure/table_frame/abductor
	name = "alien table frame"
	desc = "A sturdy table frame made from alien alloy."
	icon_state = "alien_frame"
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1
	density = TRUE

/obj/structure/table_frame/abductor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/abductor))
		var/obj/item/stack/sheet/P = I
		if(P.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one alien alloy sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [P] to [src]...</span>")
		if(do_after(user, 50, target = src))
			P.use(1)
			new /obj/structure/table/abductor(loc)
			qdel(src)
		return
	return ..()

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/tables/alien_table.dmi'
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"
	buildstack = /obj/item/stack/sheet/mineral/abductor
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	smoothing_groups = list(SMOOTH_GROUP_ABDUCTOR_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_ABDUCTOR_TABLES)
	frame = /obj/structure/table_frame/abductor

/obj/machinery/optable/abductor
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	desc = "This is where the science happens."
	no_icon_updates = 1 //no icon updates for this; it's static.
	injected_reagents = list("spaceacillin")
	inject_amount = 10
	reagent_target_amount = 31 //the patient needs at least 30u of spaceacillin to prevent necrotizationr.
	material = /obj/item/stack/sheet/mineral/abductor
	material_amount = 5

/obj/machinery/optable/abductor/ufo //Surgery table found on the actual abductor ship. Cant be deconstructed/destroyed and prevents death from abductor experimental surgery.
	injected_reagents = list("corazone","spaceacillin")	
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODECONSTRUCT

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	icon_closed = "abductor"
	icon_opened = "abductor_open"
	material_drop = /obj/item/stack/sheet/mineral/abductor

/obj/structure/door_assembly/door_assembly_abductor
	name = "alien airlock assembly"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	base_name = "alien airlock"
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/abductor
	material_type = /obj/item/stack/sheet/mineral/abductor
	noglass = TRUE

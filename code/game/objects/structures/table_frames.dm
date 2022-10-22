/* Table Frames
 * Contains:
 *		Frames
 *		Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/attackby(obj/item/I, mob/user, params, already_tried)
	var/obj/item/stack/stack = I

	if(already_tried || !(stack?.table_type)) //if we already tried to make a table in a child proc and failed, or we can't use this item to make a table, exit
		to_chat(user, "<span class='warning'>You can't make a table out of [I]!</span>")
		return ..()

	if(stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!(do_after(user, 50, target = src) && stack.use(1)))
		return

	if(stack.table_type)
		make_new_table(stack.table_type)

/obj/structure/table_frame/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		for(var/i = 1, i <= framestackamount, i++)
			new framestack(get_turf(src))
		qdel(src)

/obj/structure/table_frame/proc/make_new_table(table_type) //makes sure the new table made retains what we had as a frame
	var/obj/structure/table/T = new table_type(loc)
	T.frame = type
	T.framestack = framestack
	T.framestackamount = framestackamount
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(loc)
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params, already_tried)
	if(!istype(I, /obj/item/stack/tile/carpet) && !istype(I, /obj/item/stack/sheet/wood))
		already_tried = TRUE
		return ..()

	var/obj/item/stack/stack = I

	if(stack.get_amount() < 1) //no need for safeties as we did an istype earlier
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!(do_after(user, 50, target = src) && stack.use(1)))
		return

	if(istype(stack, /obj/item/stack/tile/carpet))
		make_new_table(/obj/structure/table/wood/poker)
		return

	make_new_table(/obj/structure/table/abductor)

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	framestack = /obj/item/stack/tile/brass
	framestackamount = 1

/obj/structure/table_frame/brass/attackby(obj/item/I, mob/user, params, already_tried)
	if(!istype(I, /obj/item/stack/tile/brass))
		already_tried = TRUE
		return ..()

	var/obj/item/stack/stack = I

	if(stack.get_amount() < 1) //no need for safeties as we did an istype earlier
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(do_after(user, 20, target = src) && stack.use(1))
		make_new_table(/obj/structure/table/reinforced/brass)

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

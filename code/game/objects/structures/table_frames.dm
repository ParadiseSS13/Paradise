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

/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(!try_make_table(I, user))
		return ..()

///Try to make a table with the item used to attack. FALSE if you can't make a table and should attack. TRUE does not necessarily mean a table was made.
/obj/structure/table_frame/proc/try_make_table(obj/item/stack/stack, mob/user)
	if(!istype(stack))
		return FALSE

	if(!stack.table_type)
		return FALSE

	if(stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!(do_after(user, 50, target = src) && stack.use(1)))
		return TRUE

	if(stack.table_type)
		make_new_table(stack.table_type)
		return TRUE

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

/obj/structure/table_frame/wood/try_make_table(obj/item/stack/stack, mob/user)
	if(!istype(stack, /obj/item/stack/tile/carpet) && !istype(stack, /obj/item/stack/sheet/wood))
		return FALSE

	if(stack.get_amount() < 1) //no need for safeties as we did an istype earlier
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!(do_after(user, 50, target = src) && stack.use(1)))
		return TRUE

	if(istype(stack, /obj/item/stack/tile/carpet))
		make_new_table(/obj/structure/table/wood/poker)
		return TRUE

	make_new_table(stack.table_type)
	return TRUE

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	framestack = /obj/item/stack/tile/brass
	framestackamount = 1

/obj/structure/table_frame/brass/try_make_table(obj/item/stack/stack, mob/user)
	if(!istype(stack, /obj/item/stack/tile/brass))
		return FALSE

	if(stack.get_amount() < 1) //no need for safeties as we did an istype earlier
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(do_after(user, 20, target = src) && stack.use(1))
		make_new_table(stack.table_type)

	return TRUE

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

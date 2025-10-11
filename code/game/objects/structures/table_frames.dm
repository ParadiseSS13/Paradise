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
	icon_state = "table_frame"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	///The resource dropped when the table frame is destroyed or deconstructed
	var/framestack = /obj/item/stack/rods
	///How many of framestack resource are dropped
	var/framestackamount = 2
	///How long the table takes to make
	var/construction_time = 5 SECONDS
	///What stacks can be used to make the table, and if it will result in a unique table
	var/list/restrict_table_types = list() //ex: list(/obj/item/stack/tile/carpet = /obj/structure/table/wood/poker, /obj/item/stack/sheet/wood = /obj/item/stack/sheet/wood::table_type), carpet will make poker table, wood will result in standard table_type. If the list is empty, any material can be used for its default table_type.

/obj/structure/table_frame/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(try_make_table(I, user))
		return ITEM_INTERACT_COMPLETE

	return ..()

///Try to make a table with the item used to attack. FALSE if you can't make a table and should attack. TRUE does not necessarily mean a table was made.
/obj/structure/table_frame/proc/try_make_table(obj/item/stack/stack, mob/user)
	if(!istype(stack))
		return FALSE

	var/obj/structure/table/new_table_type = stack.table_type
	if(length(restrict_table_types))
		var/valid_stack_type = FALSE
		for(var/obj/item/stack/current_stack as anything in restrict_table_types)
			if(istype(stack, current_stack))
				new_table_type = restrict_table_types[current_stack]
				valid_stack_type = TRUE
				break
		if(!valid_stack_type)
			return FALSE

	if(!new_table_type)
		return FALSE

	if(stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")
	if(!do_after(user, construction_time, target = src))
		return TRUE

	if(!stack.use(1))
		to_chat(user, "<span class='warning'>You need at least one sheet of [stack] to do this!</span>")
		return TRUE

	var/obj/structure/table/table_already_there = locate(/obj/structure/table) in get_turf(src)
	if(table_already_there) //check again after to make sure one wasnt added since
		to_chat(user, "<span class='warning'>There is already [table_already_there] here.</span>")
		return TRUE

	if(!istype(new_table_type, /obj/structure/table)) //if its something unique, skip the table parts
		new new_table_type(loc)
		qdel(src)
		return TRUE
	make_new_table(new_table_type)
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
	resistance_flags = FLAMMABLE
	restrict_table_types = list(/obj/item/stack/tile/carpet = /obj/structure/table/wood/poker, /obj/item/stack/sheet/wood = /obj/item/stack/sheet/wood::table_type)

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	framestack = /obj/item/stack/tile/brass
	framestackamount = 1
	construction_time = 2 SECONDS
	restrict_table_types = list(/obj/item/stack/tile/brass = /obj/item/stack/tile/brass::table_type)

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/table_frame/cult
	name = "runed metal table frame"
	desc = "Four pieces of runed metal arranged in a square. It's cold to the touch."
	icon_state = "cult_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	framestack = /obj/item/stack/sheet/runed_metal
	framestackamount = 1
	construction_time = 2 SECONDS
	restrict_table_types = list(/obj/item/stack/sheet/runed_metal = /obj/item/stack/sheet/runed_metal::table_type)

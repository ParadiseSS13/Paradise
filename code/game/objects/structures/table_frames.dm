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
	if(!istype(I, /obj/item/stack))
		return ..()

	var/obj/item/stack/stack = I

	if(stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need one [stack] sheet to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!do_after(user, 50, target = src))
		return

	switch(stack.type)
		if(/obj/item/stack/sheet/plasteel)
			make_new_table(/obj/structure/table/reinforced)

		if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg, /obj/item/stack/sheet/metal/fifty)
			make_new_table(/obj/structure/table)

		if(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/glass/cyborg, /obj/item/stack/sheet/glass/fifty)
			make_new_table(/obj/structure/table/glass)

		if(/obj/item/stack/sheet/rglass, /obj/item/stack/sheet/rglass/cyborg)
			make_new_table(/obj/structure/table/glass/reinforced)

		if(/obj/item/stack/sheet/plasmaglass)
			make_new_table(/obj/structure/table/glass/plasma)

		if(/obj/item/stack/sheet/plasmarglass)
			make_new_table(/obj/structure/table/glass/reinforced/plasma)

		if(/obj/item/stack/sheet/titaniumglass)
			make_new_table(/obj/structure/table/glass/reinforced/titanium)

		if(/obj/item/stack/sheet/plastitaniumglass)
			make_new_table(/obj/structure/table/glass/reinforced/plastitanium)

		if(/obj/item/stack/tile/carpet, /obj/item/stack/tile/carpet/black, /obj/item/stack/tile/carpet/blue, /obj/item/stack/tile/carpet/cyan, /obj/item/stack/tile/carpet/green, /obj/item/stack/tile/carpet/orange, /obj/item/stack/tile/carpet/purple, /obj/item/stack/tile/carpet/red, /obj/item/stack/tile/carpet/royalblack, /obj/item/stack/tile/carpet/royalblue, /obj/item/stack/tile/carpet/twenty, /obj/item/stack/tile/carpet/black/twenty, /obj/item/stack/tile/carpet/blue/twenty, /obj/item/stack/tile/carpet/cyan/twenty, /obj/item/stack/tile/carpet/green/twenty, /obj/item/stack/tile/carpet/orange/twenty, /obj/item/stack/tile/carpet/purple/twenty, /obj/item/stack/tile/carpet/red/twenty, /obj/item/stack/tile/carpet/royalblack/twenty, /obj/item/stack/tile/carpet/royalblue/twenty, /obj/item/stack/tile/carpet/royalblack/ten, /obj/item/stack/tile/carpet/royalblue/ten) //yikes
			var/obj/item/stack/tile/carpet/C = I
			make_new_table(C.fancy_table_type)

		else
			return ..()

	stack.use(1)

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

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if(!(istype(I, /obj/item/stack/tile/carpet) || istype(I, /obj/item/stack/sheet/wood)))
		return ..()

	var/obj/item/stack/stack = I

	if(stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need one [stack] sheet to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [stack] to [src]...</span>")

	if(!do_after(user, 50, target = src))
		return

	switch(stack.type)
		if(/obj/item/stack/tile/carpet, /obj/item/stack/tile/carpet/black, /obj/item/stack/tile/carpet/blue, /obj/item/stack/tile/carpet/cyan, /obj/item/stack/tile/carpet/green, /obj/item/stack/tile/carpet/orange, /obj/item/stack/tile/carpet/purple, /obj/item/stack/tile/carpet/red, /obj/item/stack/tile/carpet/royalblack, /obj/item/stack/tile/carpet/royalblue, /obj/item/stack/tile/carpet/twenty, /obj/item/stack/tile/carpet/black/twenty, /obj/item/stack/tile/carpet/blue/twenty, /obj/item/stack/tile/carpet/cyan/twenty, /obj/item/stack/tile/carpet/green/twenty, /obj/item/stack/tile/carpet/orange/twenty, /obj/item/stack/tile/carpet/purple/twenty, /obj/item/stack/tile/carpet/red/twenty, /obj/item/stack/tile/carpet/royalblack/twenty, /obj/item/stack/tile/carpet/royalblue/twenty, /obj/item/stack/tile/carpet/royalblack/ten, /obj/item/stack/tile/carpet/royalblue/ten)
			make_new_table(/obj/structure/table/wood/poker)

		if(/obj/item/stack/sheet/wood, /obj/item/stack/sheet/wood/cyborg)
			make_new_table(/obj/structure/table/wood)

		else
			return ..()

	stack.use(1)

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	framestack = /obj/item/stack/tile/brass
	framestackamount = 1

/obj/structure/table_frame/brass/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/tile/brass))
		return ..()

	var/obj/item/stack/tile/brass/W = I
	if(W.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need one [W] sheet to do this!</span>")
		return

	to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")

	if(do_after(user, 20, target = src) && W.use(1))
		make_new_table(/obj/structure/table/reinforced/brass)


/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

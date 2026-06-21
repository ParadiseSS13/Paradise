// Construction | Deconstruction
#define STATE_EMPTY 	 1 // Add a circuitboard		   | Weld to destroy
#define STATE_CIRCUIT	 2 // Screwdriver the cover closed | Crowbar the circuit
#define STATE_NOWIRES	 3 // Add wires					   | Screwdriver the cover open
#define STATE_WIRES		 4 // Add glass					   | Remove wires
#define STATE_GLASS		 5 // Screwdriver to complete	   | Crowbar glass out

/obj/structure/computerframe
	name = "computer frame"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_frame"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	var/state = STATE_EMPTY
	var/obj/item/circuitboard/circuit = null

/obj/structure/computerframe/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/computerframe/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It is <b>[anchored ? "bolted to the floor" : "unbolted"]</b>.")
	switch(state)
		if(STATE_EMPTY)
			. += SPAN_NOTICE("The frame is <b>welded together</b>, but it is missing a <i>circuit board</i>.")
		if(STATE_CIRCUIT)
			. += SPAN_NOTICE("A circuit board is <b>firmly connected</b>, but the cover is <i>unscrewed and open</i>.")
		if(STATE_NOWIRES)
			. += SPAN_NOTICE("The cover is <b>screwed shut</b>, but the frame is missing <i>wiring</i>.")
		if(STATE_WIRES)
			. += SPAN_NOTICE("The frame is <b>wired</b>, but the <i>glass</i> is missing.")
		if(STATE_GLASS)
			. += SPAN_NOTICE("The glass is <b>loosely connected</b> and needs to be <i>screwed into place</i>.")
	if(!anchored)
		. += SPAN_NOTICE("Alt-Click to rotate it.")

/obj/structure/computerframe/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		drop_computer_parts()
	return ..() // will qdel the frame

/obj/structure/computerframe/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, SPAN_WARNING("The frame is anchored to the floor!"))
		return
	setDir(turn(dir, 90))

/obj/structure/computerframe/obj_break(damage_flag)
	deconstruct()

/obj/structure/computerframe/proc/drop_computer_parts()
	var/location = drop_location()
	new /obj/item/stack/sheet/metal(location, 5)
	if(circuit)
		circuit.forceMove(location)
		circuit = null
	if(state >= STATE_WIRES)
		var/obj/item/stack/cable_coil/C = new(location)
		C.amount = 5
	if(state == STATE_GLASS)
		new /obj/item/stack/sheet/glass(location, 2)

/obj/structure/computerframe/update_overlays()
	..()
	. += "comp_frame_[state]"

/obj/structure/computerframe/welder_act(mob/user, obj/item/I)
	if(state != STATE_EMPTY)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/computerframe/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 2 SECONDS)

/obj/structure/computerframe/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user))
		return

	if(state == STATE_CIRCUIT)
		to_chat(user, SPAN_NOTICE("You remove the circuit board."))
		state = STATE_EMPTY
		name = initial(name)
		circuit.forceMove(drop_location())
		circuit = null
	else if(state == STATE_GLASS)
		to_chat(user, SPAN_NOTICE("You remove the glass panel."))
		state = STATE_WIRES
		new /obj/item/stack/sheet/glass(drop_location(), 2)
	else
		return

	I.play_tool_sound(src)
	update_icon()

/obj/structure/computerframe/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user))
		return

	switch(state)
		if(STATE_CIRCUIT)
			to_chat(user, SPAN_NOTICE("You screw the circuit board into place."))
			state = STATE_NOWIRES
			I.play_tool_sound(src)
			update_icon()
		if(STATE_NOWIRES)
			to_chat(user, SPAN_NOTICE("You unfasten the circuit board."))
			state = STATE_CIRCUIT
			I.play_tool_sound(src)
			update_icon()
		if(STATE_GLASS)
			to_chat(user, SPAN_NOTICE("You connect the monitor."))
			I.play_tool_sound(src)
			var/obj/machinery/computer/B = new circuit.build_path(loc)
			B.setDir(dir)
			if(istype(circuit, /obj/item/circuitboard/supplycomp))
				var/obj/machinery/computer/supplycomp/SC = B
				var/obj/item/circuitboard/supplycomp/C = circuit
				SC.can_order_contraband = C.contraband_enabled
			qdel(src)

/obj/structure/computerframe/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user))
		return

	if(state == STATE_WIRES)
		to_chat(user, SPAN_NOTICE("You remove the cables."))
		var/obj/item/stack/cable_coil/C = new(drop_location())
		C.amount = 5
		state = STATE_NOWIRES
		I.play_tool_sound(src)
		update_icon()

/obj/structure/computerframe/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	switch(state)
		if(STATE_EMPTY)
			if(!istype(I, /obj/item/circuitboard))
				return ..()

			var/obj/item/circuitboard/B = I
			if(B.board_type != "computer")
				to_chat(user, SPAN_WARNING("[src] does not accept circuit boards of this type!"))
				return ITEM_INTERACT_COMPLETE

			if(!B.build_path)
				to_chat(user, SPAN_WARNING("This is not a functional computer circuit board!"))
				return ITEM_INTERACT_COMPLETE

			B.play_tool_sound(src)
			to_chat(user, SPAN_NOTICE("You place [B] inside [src]."))
			name += " ([B.board_name])"
			state = STATE_CIRCUIT
			user.drop_item()
			B.forceMove(src)
			circuit = B
			update_icon()
			return ITEM_INTERACT_COMPLETE

		if(STATE_NOWIRES)
			if(!istype(I, /obj/item/stack/cable_coil))
				return ..()

			var/obj/item/stack/cable_coil/C = I
			if(C.get_amount() < 5)
				to_chat(user, SPAN_WARNING("You need five lengths of cable to wire the frame."))
				return ITEM_INTERACT_COMPLETE

			C.play_tool_sound(src)
			to_chat(user, SPAN_NOTICE("You start to add cables to the frame."))
			if(!do_after(user, 2 SECONDS * C.toolspeed, target = src))
				return ITEM_INTERACT_COMPLETE
			if(C.get_amount() < 5 || !C.use(5))
				to_chat(user, SPAN_WARNING("At some point during construction you lost some cable. Make sure you have five lengths before trying again."))
				return ITEM_INTERACT_COMPLETE

			to_chat(user, SPAN_NOTICE("You add cables to the frame."))
			state = STATE_WIRES
			update_icon()
			return ITEM_INTERACT_COMPLETE

		if(STATE_WIRES)
			if(!istype(I, /obj/item/stack/sheet/glass))
				return ..()

			var/obj/item/stack/sheet/glass/G = I
			if(G.get_amount() < 2)
				to_chat(user, SPAN_WARNING("You need two sheets of glass for this."))
				return ITEM_INTERACT_COMPLETE

			G.play_tool_sound(src)
			to_chat(user, SPAN_NOTICE("You start to add the glass panel to the frame."))
			if(!do_after(user, 2 SECONDS * G.toolspeed, target = src))
				return ITEM_INTERACT_COMPLETE
			if(G.get_amount() < 2 || !G.use(2))
				to_chat(user, SPAN_WARNING("At some point during construction you lost some glass. Make sure you have two sheets before trying again."))
				return ITEM_INTERACT_COMPLETE

			to_chat(user, SPAN_NOTICE("You put in the glass panel."))
			state = STATE_GLASS
			update_icon()
			return ITEM_INTERACT_COMPLETE

	return ..()

#undef STATE_EMPTY
#undef STATE_CIRCUIT
#undef STATE_NOWIRES
#undef STATE_WIRES
#undef STATE_GLASS

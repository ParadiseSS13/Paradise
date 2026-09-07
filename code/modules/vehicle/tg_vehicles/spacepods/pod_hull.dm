/obj/item/spacepod_hull
	name = "space pod hull"
	desc = "The beginning of every space pod."
	icon = 'icons/obj/spacepods/pod_construct.dmi'
	icon_state = "raptor1"
	pixel_x = -32
	pixel_y = -32
	new_attack_chain = TRUE
	var/state = POD_MAIN_BOARD
	var/obj/tgvehicle/sealed/vectorcraft/spacepod/pod_type

/obj/item/spacepod_hull/examine(mob/user)
	. = ..()

	switch(state)
		if(POD_MAIN_BOARD)
			. += SPAN_NOTICE("The hull requires a central control module.")
		if(POD_SEC_BOARD)
			. += SPAN_NOTICE("The hull requires a peripherals control module.")
		if(POD_HULL_WIRES)
			. += SPAN_NOTICE("The boards and equipment require <i>wiring</i> together.")
		if(POD_HULL_WINDOW)
			. += SPAN_NOTICE("The cockpit window is missing <i>glass</i>.")
		if(POD_WINDOW_WRENCH)
			. += SPAN_NOTICE("The cockpit window is installed, but not yet <i>wrenched into place</i>.")
		if(POD_PLATE_INSERT)
			. += SPAN_NOTICE("The pod is missing an armored plating insert.")
		if(POD_ALL_WELD)
			. += SPAN_NOTICE("The seams on the pod must be <i>welded shut</i>.")

/obj/item/spacepod_hull/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(state)
		if(POD_MAIN_BOARD)
			if(istype(tool, /obj/item/circuitboard/mecha/spacepod_main))
				to_chat(user, SPAN_NOTICE("[tool] is inserted into the hull."))
				qdel(tool)
				state = POD_SEC_BOARD
				return ITEM_INTERACT_COMPLETE

		if(POD_SEC_BOARD)
			if(istype(tool, /obj/item/circuitboard/mecha/spacepod_peri))
				to_chat(user, SPAN_NOTICE("[tool] is inserted into the hull."))
				qdel(tool)
				state = POD_HULL_WIRES
				return ITEM_INTERACT_COMPLETE

		if(POD_HULL_WIRES)
			if(istype(tool, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = tool
				if(coil.get_amount() < 15)
					to_chat(user, SPAN_WARNING("You need at least 15 cable!"))
				else
					user.visible_message(
						SPAN_NOTICE("[user] starts running cable through the pod hull..."),
						SPAN_NOTICE("You start running cable through the pod hull..."))
					coil.use(15)
					icon_state = "raptor2"
					update_icon(UPDATE_ICON_STATE)
					to_chat(user, SPAN_NOTICE("You finish running cable through the hull."))
					state = POD_HULL_WINDOW
				return ITEM_INTERACT_COMPLETE

		if(POD_HULL_WINDOW)
			if(istype(tool, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/glass = tool
				if(glass.get_amount() < 15)
					to_chat(user, SPAN_WARNING("You need at least 15 glass sheets!"))
				else
					user.visible_message(
						SPAN_NOTICE("[user] starts installing glass into the cockpit..."),
						SPAN_NOTICE("You start installing glass into the cockpit..."))
					glass.use(15)
					icon_state = "raptor4"
					update_icon(UPDATE_ICON_STATE)
					state = POD_WINDOW_WRENCH
					to_chat(user, SPAN_NOTICE("You finish installing the cockpit glass."))
				return ITEM_INTERACT_COMPLETE

		if(POD_WINDOW_WRENCH)
			if(tool.tool_behaviour == TOOL_WRENCH)
				user.visible_message(
					SPAN_NOTICE("[user] starts tightening the bolts to the hull..."),
					SPAN_NOTICE("You start tightening the bolts to the hull..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = POD_PLATE_INSERT
					icon_state = "raptor5"
					update_icon(UPDATE_ICON_STATE)
					to_chat(user, SPAN_NOTICE("You finish tightening the bolts."))
				return ITEM_INTERACT_COMPLETE

		if(POD_PLATE_INSERT)
			if(istype(tool, /obj/item/spacepod_plate))
				if(istype(tool, /obj/item/spacepod_plate))
					pod_type = /obj/tgvehicle/sealed/vectorcraft/spacepod
					to_chat(user, SPAN_NOTICE("You install the standard plating."))
				else if(istype(tool, /obj/item/spacepod_plate/sci))
					pod_type = /obj/tgvehicle/sealed/vectorcraft/spacepod/sci
					to_chat(user, SPAN_NOTICE("You install the expedition plating."))
				else if(istype(tool, /obj/item/spacepod_plate/sec))
					pod_type = /obj/tgvehicle/sealed/vectorcraft/spacepod/sec
					to_chat(user, SPAN_NOTICE("You install the security plating."))
				state = POD_ALL_WELD
				icon_state = "raptor6"
				update_icon(UPDATE_ICON_STATE)
				qdel(tool)
				return ITEM_INTERACT_COMPLETE

		if(POD_ALL_WELD)
			var/obj/tgvehicle/sealed/vectorcraft/spacepod/spawned_pod
			if(tool.tool_behaviour == TOOL_WELDER)
				user.visible_message(
					SPAN_NOTICE("[user] starts welding the hull seams..."),
					SPAN_NOTICE("You start welding the hull seams..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					to_chat(user, SPAN_NOTICE("The pod is complete."))
					spawned_pod = new pod_type(src.loc)
					spawned_pod.dir = dir
					qdel(src)
				return ITEM_INTERACT_COMPLETE

	return ..()

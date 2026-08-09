/obj/item/pods_parts
	name = "space pod part"
	icon = 'icons/obj/spacepods/pod_construct.dmi'
	icon_state = "raptor0"
	w_class = WEIGHT_CLASS_GIGANTIC
	flags = CONDUCT
	new_attack_chain = TRUE

/obj/item/pods_parts/plate/basic
	name = "standard armor plate"
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate"
	desc = "White armor plate"

/obj/item/pods_parts/plate/sci
	name = "expeditor armor plate"
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate_sci"
	desc = "Has average defense. Just right for space exploration."

/obj/item/pods_parts/plate/sec
	name = "security armor plate"
	icon = 'icons/obj/spacepods/plate.dmi'
	icon_state = "plate_sec"
	desc = "Well-fortified protection for your Pod. Sold only under license!"

/obj/item/pods_parts/hull
	name = "space pod hull"
	desc = "The beginning of every space pod."
	icon_state = "raptor0"
	var/state = POD_MAIN_BOARD
	var/obj/tgvehicle/sealed/vectorcraft/spacepod/pod_type
	pixel_x = -32
	pixel_y = -32

/obj/item/pods_parts/hull/examine(mob/user)
	. = ..()

	switch(state)
		if(POD_MAIN_BOARD)
			. += SPAN_NOTICE("The pod's hull requires a central control module.")
		if(POD_MAIN_SECURE)
			. += SPAN_NOTICE("The central control module is installed, but is not yet <i>screwed in</i>.")
		if(POD_SEC_BOARD)
			. += SPAN_NOTICE("The central control module is secured. A peripherals control module is required.")
		if(POD_SEC_SECURE)
			. += SPAN_NOTICE("The peripherals control module is installed, but not yet <i>screwed in</i>.")
		if(POD_HULL_METAL)
			. += SPAN_NOTICE("The control modules are installed, but the hull is missing <i>metal plating</i>.")
		if(POD_METAL_WRENCH)
			. += SPAN_NOTICE("The hull is reinforced but the plating must be <i>wrenched into place</i>.")
		if(POD_HULL_WIRES)
			. += SPAN_NOTICE("The boards and equipment require <i>wiring</i> together.")
		if(POD_WIRES_WIRECUTTERS)
			. += SPAN_NOTICE("The extra cable must be cut with <i>wirecutters</i>.")
		if(POD_HULL_WINDOW)
			. += SPAN_NOTICE("The cockpit window is missing <i>glass</i>.")
		if(POD_WINDOW_WRENCH)
			. += SPAN_NOTICE("The cockpit window is installed, but not yet <i>wrenched into place</i>.")
		if(POD_PLATE_INSERT)
			. += SPAN_NOTICE("The pod is missing an armored plating insert.")
		if(POD_ALL_WELD)
			. += SPAN_NOTICE("The seams on the pod must be <i>welded shut</i>.")

/obj/item/pods_parts/hull/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(state)
		if(POD_MAIN_BOARD)
			if(istype(tool, /obj/item/circuitboard/mecha/spacepod_main))
				to_chat(user, SPAN_NOTICE("[tool] is inserted into the hull."))
				qdel(tool)
				icon_state = "raptor1"
				update_icon(UPDATE_ICON_STATE)
				state = POD_MAIN_SECURE
				return ITEM_INTERACT_COMPLETE

		if(POD_MAIN_SECURE)
			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(
					SPAN_NOTICE("[user] screws the control module into place..."),
					SPAN_NOTICE("You screw the control module into place..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = POD_SEC_BOARD
					to_chat(user, SPAN_NOTICE("The control module is secured in the hull."))
				return ITEM_INTERACT_COMPLETE

		if(POD_SEC_BOARD)
			if(istype(tool, /obj/item/circuitboard/mecha/spacepod_peri))
				to_chat(user, SPAN_NOTICE("[tool] is inserted into the hull."))
				qdel(tool)
				state = POD_SEC_SECURE
				return ITEM_INTERACT_COMPLETE

		if(POD_SEC_SECURE)
			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(
					SPAN_NOTICE("[user] screws the peripheral module into place..."),
					SPAN_NOTICE("You screw the peripheral module into place..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = POD_HULL_METAL
					to_chat(user, SPAN_NOTICE("The peripheral module is secured in the hull."))
				return ITEM_INTERACT_COMPLETE

		if(POD_HULL_METAL)
			if(istype(tool, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/metal = tool
				if(metal.get_amount() < 15)
					to_chat(user, SPAN_WARNING("You require 15 sheets of metal."))
				else
					user.visible_message(
						SPAN_NOTICE("[user] inserts 15 [tool] into the hull..."),
						SPAN_NOTICE("You insert 15 [tool] into the hull..."))
					metal.use(15)
					state = POD_METAL_WRENCH
					to_chat(user, SPAN_NOTICE("The metal is seated in the pod's frame."))
				return ITEM_INTERACT_COMPLETE

		if(POD_METAL_WRENCH)
			if(tool.tool_behaviour == TOOL_WRENCH)
				user.visible_message(
					SPAN_NOTICE("[user] screws the hull's bolts into place..."),
					SPAN_NOTICE("You screw the hull's bolts into place..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = POD_HULL_WIRES
					to_chat(user, SPAN_NOTICE("You finish screwing the bolts into place."))
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
					state = POD_WIRES_WIRECUTTERS
					to_chat(user, SPAN_NOTICE("You finish running cable through the hull."))
				return ITEM_INTERACT_COMPLETE

		if(POD_WIRES_WIRECUTTERS)
			if(tool.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(
					SPAN_NOTICE("[user] starts trimming excess wire from the pod hull..."),
					SPAN_NOTICE("You start trimming excess wire from the pod hull..."))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = POD_HULL_WINDOW
					icon_state = "raptor3"
					update_icon(UPDATE_ICON_STATE)
					to_chat(user, SPAN_NOTICE("You finish trimming the excess wire."))
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
			if(istype(tool, /obj/item/pods_parts/plate))
				if(istype(tool, /obj/item/pods_parts/plate/basic))
					pod_type = /obj/tgvehicle/sealed/vectorcraft/spacepod
					to_chat(user, SPAN_NOTICE("You install the standard plating."))
				else if(istype(tool, /obj/item/pods_parts/plate/sci))
					pod_type = /obj/tgvehicle/sealed/vectorcraft/spacepod/sci
					to_chat(user, SPAN_NOTICE("You install the expedition plating."))
				else if(istype(tool, /obj/item/pods_parts/plate/sec))
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



/obj/machinery/power/apc/proc/has_electronics()
	return electronics_state != APC_ELECTRONICS_NONE

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_OFF)
			opened = APC_COVER_OFF
			cover_locked = FALSE
			visible_message(
				span_warning("The cover falls off [src]!"),
				span_warning("You hear a small flat object falling to the floor!")
				)
			update_icon()

/obj/machinery/power/apc/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return

	// 1. Opened APC
	if(opened)
		if(cell)
			if(opened == APC_OPENED) // Do not magically create a new cover if it broke off.
				opened = APC_CLOSED
				cover_locked = TRUE //closing cover relocks it
				update_icon()
				user.visible_message(
					span_notice("[user] closes the cover of [src]."),
					span_notice("You close the cover of [src]."))
				return

			else
				to_chat(user, span_warning("Remove the cell first!"))
				return

		if(electronics_state == APC_ELECTRONICS_NONE)
			to_chat(user, span_warning("There's nothing inside!"))
			return

		if(terminal)
			to_chat(user, span_warning("Disconnect the wires first!"))
			return

		if(I.use_tool(src, user, FALSE, volume = I.tool_volume))
			if(has_electronics())
				electronics_state = APC_ELECTRONICS_NONE
				if(stat & BROKEN)
					user.visible_message(
						span_notice("[user] rips out the broken the APC electronics inside [src]!"),
						span_notice("You break the charred APC electronics and remove the remains."),
						span_warning("You hear metallic levering and a crack."))
					stat |= MAINT
					update_icon()
					return

				if(emagged) // We emag board, not APC's frame
					emagged = FALSE
					user.visible_message(
						span_notice("[user] has discarded the shorted APC electronics from [src]!"),
						span_notice("You discarded the shorted board."),
						span_warning("You hear metallic levering.")
					)
					stat |= MAINT
					update_icon()
					return

				if(malfhack) // AI hacks board, not APC's frame
					user.visible_message(\
						span_notice("[name] has discarded the strangely programmed APC electronics from [src]!"),
						span_notice("You discarded the strangely programmed board."),
						span_warning("You hear metallic levering.")
						)
					malfai = null
					malfhack = FALSE
					stat |= MAINT
					update_icon()
					return

				user.visible_message(
					span_notice("[user] has removed the APC electronics from [src]!"),
					span_notice("You remove the APC electronics."),
					span_warning("You hear metallic levering.")
					)
				new /obj/item/apc_electronics(loc)
				stat |= MAINT
				update_icon()
				return

	// 2. Closed APC
	if(!(stat & BROKEN))
		if(panel_open) // wires are exposed
			to_chat(user, span_warning("Exposed wiring prevents you from opening [src]!"))
			return

		if(cover_locked && !(stat & MAINT)) // locked...
			to_chat(user, span_warning("The cover of [src] is locked!"))
			return

		to_chat(user, span_notice("You open the cover of [src]."))
		opened = APC_OPENED
		update_icon()

	// 3. Broken, closed APC
	if((stat & BROKEN) && opened == APC_CLOSED)
		if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume))
			return

		user.visible_message(
			span_notice("[user] rips the cover off [src]."),
			span_notice("You rip the cover off [src]."),
			span_warning("You hear metallic levering and a small flat object falling to the floor!")
			)
		panel_open = FALSE // Avoid wacky behavour with wires.
		opened = APC_COVER_OFF
		update_icon()

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE

	if(opened)
		to_chat(user, span_warning("Close the APC first!"))
		return

	if(emagged)
		to_chat(user, span_warning("The interface is broken!"))
		return

	if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
		return

	panel_open = !panel_open
	to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]"))
	update_icon()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE

	if(terminal && opened)
		if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
			return
		terminal.dismantle(user, I)
		return

	if(panel_open && !opened)
		if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
			return
		wires.Interact(user)

/obj/machinery/power/apc/multitool_act(mob/living/user, obj/item/I)
	. = TRUE

	if(panel_open && !opened)
		if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
			return
		wires.Interact(user)

/obj/machinery/power/apc/welder_act(mob/user, obj/item/I)
	if(!opened || has_electronics() || terminal)
		return

	. = TRUE
	if(!I.tool_use_check(user, 3))
		return

	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, apc_frame_welding_time, amount = 3, volume = I.tool_volume))
		if((stat & BROKEN) || opened == APC_COVER_OFF)
			new /obj/item/stack/sheet/metal(loc)
			user.visible_message(\
				span_notice("[user] has cut [src] apart with [I]."),
				span_notice("You disassembled the broken APC frame."),
				span_warning("You hear welding.")
				)
		else
			new /obj/item/mounted/frame/apc_frame(loc)
			user.visible_message(\
				span_notice("[user] has cut [src] from the wall with [I]."),
				span_notice("You cut the APC frame from the wall."),
				span_warning("You hear welding.")
				)
		qdel(src)

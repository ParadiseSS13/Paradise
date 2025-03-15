

/obj/machinery/power/apc/proc/has_electronics()
	return electronics_state != APC_ELECTRONICS_NONE

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_OFF)
			opened = APC_COVER_OFF
			coverlocked = FALSE
			visible_message(
				"<span class='warning'>The APC cover falls off!</span>",
				"<span class='warning'>You hear a small flat object falling to the floor!</span>"
				)
			update_icon()

/obj/machinery/power/apc/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return

	if(opened) // a) on open apc
		if(electronics_state == APC_ELECTRONICS_INSTALLED)
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect the wires first!</span>")
				return

			to_chat(user, "<span class='notice'>You start trying to remove the APC electronics...</span>" )
			if(I.use_tool(src, user, 50, volume = I.tool_volume))
				if(has_electronics())
					electronics_state = APC_ELECTRONICS_NONE
					if(stat & BROKEN)
						user.visible_message(
							"<span class='notice'>[user.name] rips out the broken the APC electronics inside [name]!</span>",
							"<span class='notice'>You break the charred APC electronics and remove the remains.</span>",
							"<span class='warning'>You hear metallic levering and a crack.</span>")
						stat |= MAINT
						update_icon()
						return

						//SSticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
					if(emagged) // We emag board, not APC's frame
						emagged = FALSE
						user.visible_message(
							"<span class='notice'>[user.name] has discarded the shorted APC electronics from [name]!</span>",
							"<span class='notice'>You discarded the shorted board.</span>",
							"<span class='warning'>You hear metallic levering.</span>"
							)
						stat |= MAINT
						update_icon()
						return

					if(malfhack) // AI hacks board, not APC's frame
						user.visible_message(\
							"<span class='notice'>[user.name] has discarded the strangely programmed APC electronics from [name]!</span>",
							"<span class='notice'>You discarded the strangely programmed board.</span>",
							"<span class='warning'>You hear metallic levering.</span>"
							)
						malfai = null
						malfhack = FALSE
						stat |= MAINT
						update_icon()
						return

					user.visible_message(\
						"<span class='notice'>[user.name] has removed the APC electronics from [name]!</span>",
						"<span class='notice'>You remove the APC electronics.</span>",
						"<span class='warning'>You hear metallic levering.</span>"
						)
					new /obj/item/apc_electronics(loc)
					stat |= MAINT
					update_icon()
					return

		if(opened != APC_COVER_OFF) //cover isn't removed
			opened = APC_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_icon()
			return

	if(!(stat & BROKEN)) // b) on closed and not broken APC
		if(coverlocked && !(stat & MAINT)) // locked...
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			return

		if(panel_open) // wires are exposed
			to_chat(user, "<span class='warning'>Exposed wires prevents you from opening it!</span>")
			return

		opened = APC_OPENED
		update_icon()

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(opened)
		to_chat(user, "<span class='warning'>Close the APC first!</span>") //Less hints more mystery!
		return

	if(emagged)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
		return

	panel_open = !panel_open
	to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"]</span>")
	update_icon()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(panel_open && !opened)
		wires.Interact(user)
	else if(terminal && opened)
		terminal.dismantle(user, I)

/obj/machinery/power/apc/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(panel_open && !opened)
		wires.Interact(user)

/obj/machinery/power/apc/welder_act(mob/user, obj/item/I)
	if(!opened || has_electronics() || terminal)
		return

	. = TRUE
	if(!I.tool_use_check(user, 3))
		return

	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, amount = 3, volume = I.tool_volume))
		if((stat & BROKEN) || opened == APC_COVER_OFF)
			new /obj/item/stack/sheet/metal(loc)
			user.visible_message(\
				"<span class='notice'>[user.name] has cut [src] apart with [I].</span>",
				"<span class='notice'>You disassembled the broken APC frame.</span>",
				"<span class='warning'>You hear welding.</span>"
				)
		else
			new /obj/item/mounted/frame/apc_frame(loc)
			user.visible_message(\
				"<span class='notice'>[user.name] has cut [src] from the wall with [I].</span>",
				"<span class='notice'>You cut the APC frame from the wall.</span>",
				"<span class='warning'>You hear welding.</span>"
				)
		qdel(src)

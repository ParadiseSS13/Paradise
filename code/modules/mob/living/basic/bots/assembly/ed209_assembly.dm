// TODO: Allow for creation of laser tag ED-209s

/obj/item/bot_assembly/ed209
	name = "incomplete ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon_state = "ed209_frame"
	inhand_icon_state = null
	created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""
	var/vest_type = /obj/item/clothing/suit/armor/vest

/obj/item/bot_assembly/ed209/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP, ASSEMBLY_SECOND_STEP)
			if(!istype(tool, /obj/item/robot_parts/l_leg) && !istype(tool, /obj/item/robot_parts/r_leg))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]."))
			qdel(tool)
			name = "legs/frame assembly"
			if(build_step == ASSEMBLY_FIRST_STEP)
				inhand_icon_state = "ed209_leg"
				icon_state = "ed209_leg"
			else
				inhand_icon_state = "ed209_legs"
				icon_state = "ed209_legs"
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_THIRD_STEP)
			if(!istype(tool, /obj/item/clothing/suit/armor/vest))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]."))
			qdel(tool)
			name = "vest/legs/frame assembly"
			inhand_icon_state = "ed209_shell"
			icon_state = "ed209_shell"
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_FOURTH_STEP)
			if(tool.tool_behaviour != TOOL_WELDER)
				return NONE
			if(!tool.use_tool(src, user, 0, volume=40))
				return ITEM_INTERACT_COMPLETE
			name = "shielded frame assembly"
			to_chat(user, SPAN_NOTICE("You weld the vest to [src]."))
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_FIFTH_STEP)
			if(!istype(tool, /obj/item/clothing/head/helmet))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]."))
			qdel(tool)
			name = "covered and shielded frame assembly"
			inhand_icon_state = "ed209_hat"
			icon_state = "ed209_hat"
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_SIXTH_STEP)
			if(!isprox(tool))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			build_step++
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]."))
			qdel(tool)
			name = "covered, shielded and sensored frame assembly"
			inhand_icon_state = "ed209_prox"
			icon_state = "ed209_prox"
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_SEVENTH_STEP)
			if(!istype(tool, /obj/item/stack/cable_coil))
				return NONE
			var/obj/item/stack/cable_coil/coil = tool
			if(coil.get_amount() < 1)
				to_chat(user, SPAN_WARNING("You need one length of cable to wire the ED-209!"))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You start to wire [src]..."))
			if(!do_after(user, 4 SECONDS, target = src))
				return ITEM_INTERACT_COMPLETE
			if(coil.get_amount() < 1 || build_step != ASSEMBLY_SEVENTH_STEP)
				return ITEM_INTERACT_COMPLETE
			coil.use(1)
			to_chat(user, SPAN_NOTICE("You wire [src]."))
			name = "wired ED-209 assembly"
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_EIGHTH_STEP)
			if(!istype(tool, /obj/item/gun/energy/disabler))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			name = "[tool.name] ED-209 assembly"
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]."))
			inhand_icon_state = "ed209_taser"
			icon_state = "ed209_taser"
			qdel(tool)
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_NINTH_STEP)
			if(tool.tool_behaviour != TOOL_SCREWDRIVER)
				return NONE
			to_chat(user, SPAN_NOTICE("You start attaching the gun to the frame..."))
			if(!tool.use_tool(src, user, 40, volume=100))
				return ITEM_INTERACT_COMPLETE
			var/mob/living/basic/bot/secbot/ed209/new_bot = new(drop_location())
			new_bot.name = created_name
			to_chat(user, SPAN_NOTICE("You complete the ED-209."))
			qdel(src)
			return ITEM_INTERACT_COMPLETE

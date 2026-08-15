/obj/item/bot_assembly/secbot
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon_state = "helmet_signaler"
	inhand_icon_state = "helmet"
	lefthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	created_name = "Securitron" // To preserve the name if it's a unique securitron I guess
	/// If you're converting it into a grievousbot, how many swords have you attached
	var/swordamt = 0
	/// Honk
	var/toyswordamt = 0

/obj/item/bot_assembly/secbot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/atom/drop_loc = drop_location()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(tool.tool_behaviour == TOOL_WELDER)
				if(!tool.use_tool(src, user, 0, volume=40))
					return ITEM_INTERACT_BLOCKING
				add_overlay("hs_hole")
				to_chat(user, span_notice("You weld a hole in [src]!"))
				build_step++
				return ITEM_INTERACT_SUCCESS

			if(tool.tool_behaviour != TOOL_SCREWDRIVER) //deconstruct
				return NONE

			new /obj/item/assembly/signaler(drop_loc)
			new /obj/item/clothing/head/helmet/sec(drop_loc)
			to_chat(user, span_notice("You disconnect the signaler from the helmet."))
			qdel(src)
			return ITEM_INTERACT_SUCCESS

		if(ASSEMBLY_SECOND_STEP)
			if(isprox(tool))
				if(!user.temporarilyRemoveItemFromInventory(tool))
					return ITEM_INTERACT_BLOCKING
				to_chat(user, span_notice("You add [tool] to [src]!"))
				add_overlay("hs_eye")
				name = "helmet/signaler/prox sensor assembly"
				qdel(tool)
				build_step++
				return ITEM_INTERACT_SUCCESS

			if(tool.tool_behaviour != TOOL_WELDER) //deconstruct
				return NONE

			if(!tool.use_tool(src, user, 0, volume=40))
				return ITEM_INTERACT_BLOCKING

			cut_overlay("hs_hole")
			to_chat(user, span_notice("You weld the hole in [src] shut!"))
			build_step--
			return ITEM_INTERACT_SUCCESS

		if(ASSEMBLY_THIRD_STEP)
			if((istype(tool, /obj/item/bodypart/arm/left/robot)) || (istype(tool, /obj/item/bodypart/arm/right/robot)))
				if(!user.temporarilyRemoveItemFromInventory(tool))
					return ITEM_INTERACT_BLOCKING
				to_chat(user, span_notice("You add [tool] to [src]!"))
				name = "helmet/signaler/prox sensor/robot arm assembly"
				add_overlay("hs_arm")
				robot_arm = tool.type
				qdel(tool)
				build_step++
				return ITEM_INTERACT_SUCCESS

			if(tool.tool_behaviour != TOOL_SCREWDRIVER) //deconstruct
				return NONE

			cut_overlay("hs_eye")
			new /obj/item/assembly/prox_sensor(drop_loc)
			to_chat(user, span_notice("You detach the proximity sensor from [src]."))
			build_step--
			return ITEM_INTERACT_SUCCESS

		if(ASSEMBLY_FOURTH_STEP)
			if(istype(tool, /obj/item/melee/baton/security))
				if(!can_finish_build(tool, user))
					return ITEM_INTERACT_BLOCKING
				to_chat(user, span_notice("You complete the Securitron! Beep boop."))
				var/mob/living/basic/bot/secbot/new_bot = new(drop_loc)
				new_bot.name = created_name
				new_bot.baton_type = tool.type
				new_bot.robot_arm = robot_arm
				qdel(tool)
				qdel(src)
				return ITEM_INTERACT_SUCCESS

			if(tool.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You adjust [src]'s arm slots to mount extra weapons."))
				build_step++
				return ITEM_INTERACT_SUCCESS

			if(tool.tool_behaviour == TOOL_SCREWDRIVER) //deconstruct
				cut_overlay("hs_arm")
				var/obj/item/bodypart/dropped_arm = new robot_arm(drop_loc)
				robot_arm = null
				to_chat(user, span_notice("You remove [dropped_arm] from [src]."))
				build_step--
				if(toyswordamt > 0 || toyswordamt)
					toyswordamt = 0
					icon_state = initial(icon_state)
					to_chat(user, span_notice("The superglue binding [src]'s toy swords to its chassis snaps!"))
					for(var/IS in 1 to toyswordamt)
						new /obj/item/toy/sword(drop_loc)
				return ITEM_INTERACT_SUCCESS

			if(!istype(tool, /obj/item/toy/sword))
				return NONE

			if(toyswordamt < 3 && swordamt <= 0)
				if(!user.temporarilyRemoveItemFromInventory(tool))
					return ITEM_INTERACT_BLOCKING
				created_name = "General Beepsky"
				name = "helmet/signaler/prox sensor/robot arm/toy sword assembly"
				icon_state = "grievous_assembly"
				to_chat(user, span_notice("You superglue [tool] onto one of [src]'s arm slots."))
				qdel(tool)
				toyswordamt++
				return ITEM_INTERACT_SUCCESS

			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_BLOCKING

			to_chat(user, span_notice("You complete the Securitron!...Something seems a bit wrong with it..?"))
			var/mob/living/basic/bot/secbot/grievous/toy/new_bot = new(drop_loc)
			new_bot.name = created_name
			new_bot.robot_arm = robot_arm
			qdel(tool)
			qdel(src)
			return ITEM_INTERACT_SUCCESS

		if(ASSEMBLY_FIFTH_STEP)
			if(tool.tool_behaviour == TOOL_SCREWDRIVER) //deconstruct
				build_step--
				swordamt = 0
				icon_state = initial(icon_state)
				to_chat(user, span_notice("You unbolt [src]'s energy swords."))
				for(var/IS in 1 to swordamt)
					new /obj/item/melee/energy/sword/saber(drop_loc)
				return ITEM_INTERACT_SUCCESS

			if(!istype(tool, /obj/item/melee/energy/sword/saber))
				return NONE

			if(swordamt < 3)
				if(!user.temporarilyRemoveItemFromInventory(tool))
					return ITEM_INTERACT_BLOCKING
				created_name = "General Beepsky"
				name = "helmet/signaler/prox sensor/robot arm/energy sword assembly"
				icon_state = "grievous_assembly"
				to_chat(user, span_notice("You bolt [tool] onto one of [src]'s arm slots."))
				qdel(tool)
				swordamt++
				return ITEM_INTERACT_SUCCESS

			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_BLOCKING

			to_chat(user, span_notice("You complete the Securitron!...Something seems a bit wrong with it..?"))
			var/mob/living/basic/bot/secbot/grievous/new_bot = new(drop_loc)
			new_bot.name = created_name
			new_bot.robot_arm = robot_arm
			qdel(tool)
			qdel(src)
			return ITEM_INTERACT_SUCCESS

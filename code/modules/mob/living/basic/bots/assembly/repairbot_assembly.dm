/obj/item/bot_assembly/repairbot
	name = "Repairbot Chasis"
	desc = "It's a toolbox with tiles sticking out the top."
	icon_state = "repairbot_box"
	throwforce = 10
	created_name = "Repairbot"
	///the toolbox our repairbot is made of
	var/toolbox = /obj/item/storage/toolbox/mechanical
	///the color of our toolbox
	var/toolbox_color = ""

/obj/item/bot_assembly/repairbot/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/bot_assembly/repairbot/proc/set_color(new_color)
	add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	toolbox_color = new_color

/obj/item/bot_assembly/repairbot/update_desc()
	. = ..()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			desc = "It's a toolbox with a giant monitor sticking out!."
		else
			desc = initial(desc)

/obj/item/bot_assembly/repairbot/update_overlays()
	. = ..()
	if(build_step >= ASSEMBLY_FIRST_STEP)
		. += mutable_appearance(icon, "repairbot_base_sensor", appearance_flags = RESET_COLOR|KEEP_APART)
	if(build_step >= ASSEMBLY_SECOND_STEP)
		. += mutable_appearance(icon, "repairbot_base_arms", appearance_flags = RESET_COLOR|KEEP_APART)

/obj/item/bot_assembly/repairbot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(!istype(tool, /obj/item/robot_parts/l_arm) && !istype(tool, /obj/item/robot_parts/r_arm))
				return NONE
			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_COMPLETE
			build_step++
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]. Boop beep!"))
			qdel(tool)
			update_appearance()
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_SECOND_STEP)
			if(!istype(tool, /obj/item/conveyor_construct))
				return NONE
			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_COMPLETE
			var/mob/living/basic/bot/repairbot/repair = new(drop_location())
			repair.name = created_name
			repair.toolbox = toolbox
			repair.set_color(toolbox_color)
			to_chat(user, SPAN_NOTICE("You add [tool] to [src]. Boop beep!"))
			var/obj/item/stack/crafting_stack = tool
			crafting_stack.use(1)
			qdel(src)
			return ITEM_INTERACT_COMPLETE

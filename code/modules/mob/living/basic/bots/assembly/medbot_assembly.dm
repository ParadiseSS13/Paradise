/obj/item/bot_assembly/medbot
	name = "incomplete medibot assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon_state = "medbot_assembly_generic"
	base_icon_state = "medbot_assembly"
	created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	var/healthanalyzer = /obj/item/healthanalyzer
	var/medkit_type = /obj/item/storage/medkit

/obj/item/bot_assembly/medbot/proc/set_skin(skin)
	src.skin = skin
	if(skin)
		icon_state = "[base_icon_state]_[skin]"

/obj/item/bot_assembly/medbot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(!istype(tool, /obj/item/healthanalyzer))
				return NONE
			if(!user.temporarilyRemoveItemFromInventory(tool))
				return ITEM_INTERACT_BLOCKING
			healthanalyzer = tool.type
			to_chat(user, span_notice("You add [tool] to [src]."))
			qdel(tool)
			name = "first aid/robot arm/health analyzer assembly"
			add_overlay("[base_icon_state]_analyzer")
			build_step++
			return ITEM_INTERACT_SUCCESS

		if(ASSEMBLY_SECOND_STEP)
			if(!isprox(tool))
				return NONE
			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_BLOCKING
			qdel(tool)
			var/mob/living/basic/bot/medbot/medbot = new(drop_location(), skin)
			to_chat(user, span_notice("You complete the Medbot. Beep boop!"))
			medbot.name = created_name
			medbot.medkit_type = medkit_type
			medbot.robot_arm = robot_arm
			medbot.health_analyzer = healthanalyzer
			var/obj/item/storage/medkit/medkit = medkit_type
			medbot.damage_type_healer = initial(medkit.damagetype_healed) ? initial(medkit.damagetype_healed) : BRUTE
			qdel(src)
			return ITEM_INTERACT_SUCCESS

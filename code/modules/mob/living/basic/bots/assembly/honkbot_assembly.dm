/obj/item/bot_assembly/honkbot
	name = "incomplete honkbot assembly"
	desc = "The clown's up to no good once more"
	icon_state = "honkbot_arm"
	created_name = "Honkbot"

/obj/item/bot_assembly/honkbot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(!isprox(tool))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add the [tool] to [src]!"))
			icon_state = "honkbot_proxy"
			name = "incomplete Honkbot assembly"
			qdel(tool)
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_SECOND_STEP)
			if(!istype(tool, /obj/item/bikehorn))
				return NONE
			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add the [tool] to [src]! Honk!"))
			var/mob/living/basic/bot/secbot/honkbot/new_honkbot = new(drop_location())
			new_honkbot.name = created_name
			playsound(new_honkbot, 'sound/machines/ping.ogg', 50, TRUE, -1)
			qdel(tool)
			qdel(src)
			return ITEM_INTERACT_COMPLETE

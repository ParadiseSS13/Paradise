/obj/item/bot_assembly/firebot
	name = "incomplete firebot assembly"
	desc = "A fire extinguisher with an arm attached to it."
	icon_state = "firebot_red"
	base_icon_state = "firebot"
	created_name = "Firebot"
	var/skin = "red"
	var/hat = "yellow"

/obj/item/bot_assembly/firebot/Initialize(mapload)
	. = ..()
	add_overlay("[base_icon_state]_arm")

/obj/item/bot_assembly/firebot/proc/set_skin(skin)
	src.skin = skin
	if(skin)
		icon_state = "[base_icon_state]_[skin]"

/obj/item/bot_assembly/firebot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(!istype(tool, /obj/item/clothing/head/hardhat))
				return NONE
			if(!user.unequip(tool))
				return ITEM_INTERACT_COMPLETE
			to_chat(user,SPAN_NOTICE("You add the [tool] to [src]!"))
			var/obj/item/clothing/head/hardhat/new_hat = tool
			hat = new_hat.hat_color
			add_overlay("[base_icon_state]_hat_[hat]_idle")
			desc = "An incomplete firebot assembly with a fire helmet."
			qdel(tool)
			build_step++
			return ITEM_INTERACT_COMPLETE

		if(ASSEMBLY_SECOND_STEP)
			if(!isprox(tool))
				return NONE
			if(!can_finish_build(tool, user))
				return ITEM_INTERACT_COMPLETE
			to_chat(user, SPAN_NOTICE("You add the [tool] to [src]! Beep Boop!"))
			var/mob/living/basic/bot/firebot/firebot = new(drop_location())
			firebot.name = created_name
			firebot.skin = skin
			firebot.hat = hat
			firebot.update_appearance()
			firebot.create_extinguisher()
			qdel(tool)
			qdel(src)
			return ITEM_INTERACT_COMPLETE

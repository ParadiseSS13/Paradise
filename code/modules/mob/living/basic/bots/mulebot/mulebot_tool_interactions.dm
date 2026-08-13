/mob/living/basic/bot/mulebot/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	update_appearance()

/mob/living/basic/bot/mulebot/crowbar_act(mob/living/user, obj/item/tool)
	if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN) || user.combat_mode)
		return
	if(!cell)
		to_chat(user, SPAN_WARNING("[src] doesn't have a power cell!"))
		return ITEM_INTERACT_COMPLETE
	cell.add_fingerprint(user)
	user.visible_message(
		SPAN_NOTICE("[user] crowbars [cell] out from [src]."),
		SPAN_NOTICE("You pry [cell] out of [src]."),
	)
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(cell)
	else
		cell.forceMove(drop_location())
	return ITEM_INTERACT_COMPLETE

/mob/living/basic/bot/mulebot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stock_parts/cell) && (bot_access_flags & BOT_COVER_MAINTS_OPEN))
		if(cell)
			to_chat(user, SPAN_WARNING("[src] already has a power cell!"))
			return ITEM_INTERACT_COMPLETE
		if(!user.transfer_item_to(tool, src))
			return ITEM_INTERACT_COMPLETE
		user.visible_message(
			SPAN_NOTICE("[user] inserts \a [cell] into [src]."),
			SPAN_NOTICE("You insert [cell] into [src]."),
		)
		return ITEM_INTERACT_COMPLETE
	if(is_wire_tool(tool) && (bot_access_flags & BOT_COVER_MAINTS_OPEN))
		attack_hand(user)
		return ITEM_INTERACT_COMPLETE
	return ..()


/mob/living/basic/bot/mulebot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		return
	flick("[base_icon_state]-emagged", src)
	playsound(src, "sparks", 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/item/bot_assembly/cleanbot
	desc = "It's a bucket with a sensor attached."
	name = "incomplete cleanbot assembly"
	icon_state = "cleanbot_assembly"
	throwforce = 5
	created_name = "Cleanbot"
	var/obj/item/reagent_containers/glass/bucket/bucket_obj

/obj/item/bot_assembly/cleanbot/Initialize(mapload, obj/item/reagent_containers/glass/bucket/new_bucket)
	if(!new_bucket)
		new_bucket = new()
	new_bucket.forceMove(src)
	return ..()

/obj/item/bot_assembly/cleanbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /obj/item/reagent_containers/glass/bucket))
		if(bucket_obj && bucket_obj != arrived)
			qdel(bucket_obj)
		bucket_obj = arrived
	return ..()

/obj/item/bot_assembly/cleanbot/Exited(atom/movable/gone, direction)
	if(gone == bucket_obj)
		bucket_obj = null
	return ..()

/obj/item/bot_assembly/cleanbot/Destroy(force)
	QDEL_NULL(bucket_obj)
	return ..()


/obj/item/bot_assembly/cleanbot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/robot_parts/l_arm) && !istype(tool, /obj/item/robot_parts/r_arm))
		return NONE

	if(!can_finish_build(tool, user))
		return ITEM_INTERACT_COMPLETE

	var/mob/living/basic/bot/cleanbot/bot = new(drop_location())
	bucket_obj.forceMove(bot)
	bot.name = created_name
	bot.robot_arm = tool.type
	to_chat(user, SPAN_NOTICE("You add [tool] to [src]. Beep boop!"))
	qdel(tool)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

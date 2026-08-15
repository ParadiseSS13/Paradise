//Bot Construction

/obj/item/bot_assembly
	icon = 'icons/mob/silicon/aibots.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throw_speed = 2
	throw_range = 5
	obj_flags = UNIQUE_RENAME | RENAME_NO_DESC
	var/created_name
	var/build_step = ASSEMBLY_FIRST_STEP
	var/robot_arm = /obj/item/bodypart/arm/right/robot

/obj/item/bot_assembly/nameformat(input, user)
	created_name = input
	return input

/obj/item/bot_assembly/rename_reset()
	created_name = initial(created_name)

/**
 * Checks if the user can finish constructing a bot with a given item.
 *
 * Arguments:
 * * tool - Item to be used
 * * user - Mob doing the construction
 * * drop_item - Whether or no the item should be dropped; defaults to 1. Should be set to 0 if the item is a tool, stack, or otherwise doesn't need to be dropped. If not set to 0, item must be deleted afterwards.
 */
/obj/item/bot_assembly/proc/can_finish_build(obj/item/tool, mob/user, drop_item = 1)
	if(istype(loc, /obj/item/storage/backpack))
		to_chat(user, span_warning("You must take [src] out of [loc] first!"))
		return FALSE
	if(!tool || !user || (drop_item && !user.temporarilyRemoveItemFromInventory(tool)))
		return FALSE
	return TRUE

//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	return selected_item

/mob/living/silicon/robot/get_all_slots()
	return all_active_items

/*-------TODOOOOOOOOOO--------*/
/mob/living/silicon/robot/proc/uneq_module(obj/item/O)
	if(!O)
		return FALSE
	var/index = all_active_items.Find(O)
	if(!index)
		return FALSE

	O.mouse_opacity = MOUSE_OPACITY_OPAQUE

	observer_screen_update(O, add = FALSE)
	if(client)
		client.screen -= O
	contents -= O
	if(module)
		O.loc = module	//Return item to module so it appears in its contents, so it can be taken out again.
		for(var/X in O.actions) // Remove assocated actions
			var/datum/action/A = X
			A.Remove(src)
	all_active_items[index] = CYBORG_EMPTY_MODULE
	SEND_SIGNAL(O, COMSIG_CYBORG_ITEM_DEACTIVATED, src)
	selected_item = null
	var/atom/movable/screen/robot/active_module/screen = inventory_screens[index]
	screen.icon_state = screen.deactivated_icon_string

	if(hud_used)
		hud_used.update_robot_modules_display()
	return TRUE
/*
* Returns the index of the first open module slot a borg has, or FALSE if they already have a full hotbar.
*/
/mob/living/silicon/robot/proc/get_open_slot()
	for(var/i in 1 to CYBORG_MAX_MODULES)
		if(!all_active_items[i]) // Since CYBORG_EMPTY_MODULE is 0 this has to be a ! check.
			return i
	return FALSE

/mob/living/silicon/robot/proc/activate_item(obj/item/O)
	if(!(locate(O) in module.modules) && !(O in module.emag_modules))
		return
	if(activated(O))
		to_chat(src, "Already activated")
		return
	if(is_component_functioning("power cell") && cell)
		if(istype(O, /obj/item/borg))
			var/obj/item/borg/B = O
			if(B.powerneeded)
				if((cell.charge * 100 / cell.maxcharge) < B.powerneeded)
					to_chat(src, "Not enough power to activate [B.name]!")
					return
	var/slot = get_open_slot()
	if(!slot)
		to_chat(src, "You need to disable a module first!")
		return
	SEND_SIGNAL(O, COMSIG_CYBORG_ITEM_ACTIVATED, src)
	O.mouse_opacity = initial(O.mouse_opacity)
	all_active_items[slot] = O
	deactivate_all()
	var/atom/movable/screen/robot/active_module/to_activate = inventory_screens[slot]
	to_activate.activate()
	selected_item = O
	O.layer = ABOVE_HUD_LAYER
	O.plane = ABOVE_HUD_PLANE
	O.screen_loc = CYBORG_HUD_LOCATIONS[slot]
	contents += O
	set_actions(O)
	observer_screen_update(O, add = TRUE)
	check_module_damage(FALSE)
	update_icons()

/mob/living/silicon/robot/proc/set_actions(obj/item/I)
	for(var/X in I.actions)
		var/datum/action/A = X
		A.Grant(src)

/mob/living/silicon/robot/proc/uneq_active()
	uneq_module(selected_item)

/mob/living/silicon/robot/proc/uneq_all()
	for(var/obj/item/O in all_active_items)
		uneq_module(O)

/// Deactivate all the screen objects, removing the green background from all of them
/mob/living/silicon/robot/proc/deactivate_all()
	for(var/atom/movable/screen/robot/active_module/to_deactivate in inventory_screens)
		to_deactivate.deactivate()

/mob/living/silicon/robot/proc/uneq_numbered(index)
	if(module < 1 || module > CYBORG_MAX_MODULES)
		return
	uneq_module(all_active_items[index])

/// Returns true if O is in the cyborg's hotbar, false otherwise
/mob/living/silicon/robot/proc/activated(obj/item/O)
	return (O in all_active_items)

/mob/living/silicon/robot/drop_item()
	var/obj/item/gripper/G = get_active_hand()
	if(istype(G)) // The gripper is special because it has a normal item inside that we can drop.
		return G.drop_gripped_item(silent = TRUE) // This only returns true if there's actually an item to drop so we don't drop the gripper accidentaly.
	return FALSE // All robot inventory items have NODROP, so they should return FALSE.

//Helper procs for cyborg modules on the UI.
//These are hackish but they help clean up code elsewhere.

//module_selected(module) - Checks whether the module slot specified by "index" is currently selected.
/mob/living/silicon/robot/proc/module_selected(index) //Index is 1-3
	return index == get_selected_module()

//is_module_active(module) - Checks whether there is a item active in the slot specified by "index".
/mob/living/silicon/robot/proc/is_module_active(index) //Index is 1-3
	return all_active_items[index]

//get_selected_module() - Returns the slot number of the currently selected item.  Returns 0 if no items are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	if(!selected_item)
		return FALSE
	return all_active_items.Find(selected_item)

/*
* Returns a list of the slots of a cyborg's hotbar that have an item in it, or false if all are empty
*/
/mob/living/silicon/robot/proc/get_filled_modules()
	var/list/indicies = list()
	for(var/i in 1 to length(all_active_items))
		if(!all_active_items[i])
			continue
		indicies += i
	if(!length(indicies))
		return FALSE
	return indicies

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(module) //Module is 1-3
	if(module < 1 || module > CYBORG_MAX_MODULES)
		return
	selected_item = null
	for(var/i in 1 to CYBORG_MAX_MODULES)
		var/atom/movable/screen/robot/active_module/inventory = inventory_screens[i]
		if(module == i)
			inventory.activate()
			selected_item = all_active_items[module]
		else
			inventory.deactivate()
	update_icons()

//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(module) //Module is 1-3
	if(module < 1 || module > CYBORG_MAX_MODULES)
		return
	selected_item = null
	for(var/i in 1 to CYBORG_MAX_MODULES)
		var/atom/movable/screen/robot/active_module/inventory = inventory_screens[i]
		inventory.deactivate()
	update_icons()

//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(module) //Module is 1-3
	if(module < 1 || module > CYBORG_MAX_MODULES)
		return
	if(module_selected(module))
		deselect_module(module)
		return
	select_module(module)

//cycle_modules() - Cycles through the cyborg's modules, or selects the first module if none are selected.
/mob/living/silicon/robot/proc/cycle_modules()
	var/active_slot = 0
	for(var/atom/movable/screen/robot/active_module/item in inventory_screens)
		if(item.active)
			active_slot = item.module_number
	var/next_slot = (active_slot % CYBORG_MAX_MODULES) + 1
	select_module(next_slot)


/mob/living/silicon/robot/unequip_to(obj/item/target, atom/destination, force = FALSE, silent = FALSE, drop_inventory = TRUE, no_move = FALSE)
	if(target == selected_item)
		uneq_active(target)
	return ..()

/*
* Tries to find and return the module number/index of an item in a borg's inventory using a path
* to_find - ther path of an item that you want to check if it is in any of the borg's 3 active slots
* Returns the index, or FALSE if it's not active
*/
/mob/living/silicon/robot/proc/get_module_by_item(obj/item/to_check)
	for(var/i in 1 to CYBORG_MAX_MODULES)
		if(istype(all_active_items[i], to_check.type))
			return i
	return FALSE

/mob/living/silicon/robot/proc/update_module_icon()
	if(!hands)
		return
	if(!module)
		hands.icon_state = "nomod"
	else
		hands.icon_state = lowertext(module.module_type)


/**
 * Updates the observers's screens with cyborg itemss.
 * Arguments
 * * item_module - the item being added or removed from the screen
 * * add - whether or not the item is being added, or removed.
 */
/mob/living/silicon/robot/proc/observer_screen_update(obj/item/item_module, add = TRUE)
	if(!length(observers))
		return
	for(var/mob/dead/observe in observers)
		if(observe.client && observe.client.eye == src)
			if(add)
				observe.client.screen += item_module
			else
				observe.client.screen -= item_module
		else
			observers -= observe
			if(!length(observers))
				observers = null
				break

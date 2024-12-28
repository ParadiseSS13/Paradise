//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	return module_active

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
		if(!all_active_items[i])
			return i
	return FALSE

/mob/living/silicon/robot/proc/activate_module(obj/item/O)
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
	O.mouse_opacity = initial(O.mouse_opacity)
	all_active_items[slot] = O
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
	uneq_module(module_active)

/mob/living/silicon/robot/proc/uneq_all()
	for(var/obj/item/O in all_active_items)
		uneq_module(O)

/mob/living/silicon/robot/proc/uneq_numbered(module)
	if(module < 1 || module > 3)
		return
	uneq_module(all_active_items[module])

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

//is_module_active(module) - Checks whether there is a module active in the slot specified by "module".
/mob/living/silicon/robot/proc/is_module_active(index) //Index is 1-3
	return all_active_items[index]

//get_selected_module() - Returns the slot number of the currently selected module.  Returns 0 if no modules are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	return all_active_items.Find(module_active)

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(module) //Module is 1-3
	if(module < 1 || module > 3)
		return
	if(!is_module_active(module))
		return
	for(var/i in 1 to CYBORG_MAX_MODULES)
		var/atom/movable/screen/robot/active_module/inventory = inventory_screens[i]
		if(module == i)
			inventory.icon_state = inventory.activated_icon_string
			module_active = all_active_items[module]
		else
			inventory.icon_state = inventory.deactivated_icon_string
	update_icons()
	return

//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(module) //Module is 1-3
	if(module < 1 || module > 3)
		return
	module_active = null
	for(var/i in 1 to CYBORG_MAX_MODULES)
		var/atom/movable/screen/robot/active_module/inventory = inventory_screens[i]
		inventory.icon_state = inventory.deactivated_icon_string
	update_icons()
	return

//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(module) //Module is 1-3
	if(module < 1 || module > 3) return

	if(module_selected(module))
		deselect_module(module)
	else
		if(is_module_active(module))
			select_module(module)
		else
			deselect_module(get_selected_module()) //If we can't do select anything, at least deselect the current module.
	return

//cycle_modules() - Cycles through the list of selected modules.
/mob/living/silicon/robot/proc/cycle_modules()
	var/slot_start = get_selected_module()
	if(slot_start) deselect_module(slot_start) //Only deselect if we have a selected slot.

	var/slot_num
	if(slot_start == 0)
		slot_num = 0
		slot_start = 3
	else
		slot_num = slot_start

	do
		slot_num++
		if(slot_num > 3) slot_num = 1 //Wrap around.
		if(is_module_active(slot_num))
			select_module(slot_num)
			return
	while(slot_start != slot_num) //If we wrap around without finding any free slots, just give up.
	return

/mob/living/silicon/robot/unEquip(obj/item/I, force, silent = FALSE)
	if(I == module_active)
		uneq_active(I)
	return ..()

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

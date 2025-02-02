/*
===Модуль сдвига оверлея
Компонент должен цепляться на моба.
При инициализации предаются сдвиги.
*/
#define MOB_OVERLAY_SHIFT_HAND "inhand"
#define MOB_OVERLAY_SHIFT_BELT "belt"
#define MOB_OVERLAY_SHIFT_BACK "back"
#define MOB_OVERLAY_SHIFT_HEAD "head"
#define MOB_OVERLAY_SHIFT_SIDE "side"
#define MOB_OVERLAY_SHIFT_FRONT "front"
#define MOB_OVERLAY_SHIFT_CENTER "center"

/datum/component/mob_overlay_shift
	var/dir = NORTH
	var/list/shift_data = list()

/datum/component/mob_overlay_shift/Initialize(list/shift_list)
	// Define body parts and positions
	var/list/body_parts = list(MOB_OVERLAY_SHIFT_HAND, MOB_OVERLAY_SHIFT_BELT, MOB_OVERLAY_SHIFT_BACK, MOB_OVERLAY_SHIFT_HEAD)
	var/list/positions = list(MOB_OVERLAY_SHIFT_CENTER, MOB_OVERLAY_SHIFT_SIDE, MOB_OVERLAY_SHIFT_FRONT)
	// Initialize shifts using the provided shift_data list or default to zero
	for(var/body_part in body_parts)
		// Create a nested list for each body part if it doesn't exist
		shift_data[body_part] = shift_list[body_part] ? shift_list[body_part] : list()

		for(var/position in positions)
			// Create a nested list for each position within the body part
			shift_data[body_part][position] = shift_list[body_part][position] ? shift_list[body_part][position] : list()

			// Set default values for x and y shifts if not provided
			shift_data[body_part][position]["x"] = shift_list[body_part][position]["x"] || 0
			shift_data[body_part][position]["y"] = shift_list[body_part][position]["y"] || 0

	shift_call(parent)

/datum/component/mob_overlay_shift/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_MOB_ON_EQUIP, COMSIG_MOB_ON_CLICK), PROC_REF(shift_call))
	RegisterSignal(parent, list(COMSIG_MOB_GET_OVERLAY_SHIFTS_LIST), PROC_REF(get_list))

/datum/component/mob_overlay_shift/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_MOB_ON_EQUIP, COMSIG_MOB_ON_CLICK, COMSIG_MOB_GET_OVERLAY_SHIFTS_LIST))

/datum/component/mob_overlay_shift/proc/shift_call(mob/living/carbon/human/mob)
	SIGNAL_HANDLER
	if(mob.dir)
		dir = mob.dir

	var/list/body_parts = list(MOB_OVERLAY_SHIFT_HAND, MOB_OVERLAY_SHIFT_BELT, MOB_OVERLAY_SHIFT_BACK, MOB_OVERLAY_SHIFT_HEAD)
	var/position
	switch(dir)
		if(EAST)
			position = MOB_OVERLAY_SHIFT_SIDE
		if(SOUTH)
			position = MOB_OVERLAY_SHIFT_FRONT
		if(WEST)
			position = MOB_OVERLAY_SHIFT_SIDE
		if(NORTH)
			position = MOB_OVERLAY_SHIFT_FRONT

	var/flip = (dir == WEST || dir == SOUTH) ? -1 : 1

	// Update shift values based on direction
	for(var/body_part in body_parts)
		var/x_shift_key = "shift_x"
		var/y_shift_key = "shift_y"

		var/x_shift_value = shift_data[body_part][position]["x"]
		var/y_shift_value = shift_data[body_part][position]["y"]
		var/x_central_value = shift_data[body_part][MOB_OVERLAY_SHIFT_CENTER]["x"]
		var/y_central_value = shift_data[body_part][MOB_OVERLAY_SHIFT_CENTER]["y"]

		shift_data[body_part][x_shift_key] = flip * x_shift_value + x_central_value
		shift_data[body_part][y_shift_key] = flip * y_shift_value + y_central_value

	update_call(mob)

/datum/component/mob_overlay_shift/proc/update_call(mob/living/carbon/human/mob)
	mob.update_inv_r_hand()
	mob.update_inv_l_hand()
	mob.update_inv_belt()
	mob.update_inv_back()
	mob.update_inv_wear_mask()
	mob.update_inv_head()
	mob.update_inv_glasses()
	mob.update_inv_ears()

/datum/component/mob_overlay_shift/proc/get_list(mob/component_holder, overlay, list/info_data)
	SIGNAL_HANDLER
	info_data += list("shift_x" = shift_data[overlay]["shift_x"])
	info_data += list("shift_y" = shift_data[overlay]["shift_y"])

#undef MOB_OVERLAY_SHIFT_HAND
#undef MOB_OVERLAY_SHIFT_BELT
#undef MOB_OVERLAY_SHIFT_BACK
#undef MOB_OVERLAY_SHIFT_HEAD
#undef MOB_OVERLAY_SHIFT_SIDE
#undef MOB_OVERLAY_SHIFT_FRONT
#undef MOB_OVERLAY_SHIFT_CENTER

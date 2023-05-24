/datum/keybinding
	/// The user-facing name.
	var/name
	/// The UI category to belong to.
	var/category = KB_CATEGORY_UNSORTED
	/// The default key(s) assigned to the keybind.
	var/list/keys

/**
  * Returns whether the keybinding can be pressed by the client's current mob.
  *
  * Arguments:
  * * C - The client.
  * * M - The client's mob.
  */
/datum/keybinding/proc/can_use(client/C, mob/M)
	return TRUE

/**
  * Called when the client presses the keybind.
  *
  * Arguments:
  * * C - The client.
  */
/datum/keybinding/proc/down(client/C)
	if(should_start_looping(C))
		SSinput.processing[C] = world.time

/**
  * Called when the client releases the keybind.
  *
  * Arguments:
  * * C - The client.
  */
/datum/keybinding/proc/up(client/C)
	if(should_stop_looping(C))
		SSinput.processing -= C

/**
  * Called on keybind press to determine looping behaviour.
  * If TRUE is returned, the client will be added to SSinput's processing loop. Use VERY sparingly.
  *
  * Arguments:
  * * C - The client.
  */
/datum/keybinding/proc/should_start_looping(client/C)
	return FALSE

/**
  * Called on keybind release to determine looping behaviour.
  * If TRUE is returned, the client will be removed from SSinput's processing loop.
  *
  * Arguments:
  * * C - The client.
  */
/datum/keybinding/proc/should_stop_looping(client/C)
	return FALSE

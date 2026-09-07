// This tool calls forceMove() on an object/mob that is selected with right-click.
// Once the atom is moved, its selection is cleared to avoid any further moves by accident.
/datum/buildmode_mode/forcemove
	key = "forcemove"
	var/atom/movable/selected_atom		// The atom we want to move
	var/image/selected_overlay			// Overlay for the selected atom only visible for the build mode user

/datum/buildmode_mode/forcemove/show_help(mob/user)
	to_chat(user, SPAN_NOTICE("***********************************************************"))
	to_chat(user, SPAN_NOTICE("Left Mouse Button on obj/mob = Select destination"))
	to_chat(user, SPAN_NOTICE("Right Mouse Button on obj/mob = Select atom to move"))
	to_chat(user, SPAN_NOTICE("<b>Notice:</b> You need to select the movable atom first, then left-click its destination."))
	to_chat(user, SPAN_NOTICE("***********************************************************"))

/datum/buildmode_mode/forcemove/handle_click(mob/user, params, atom/A)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	// Selecting the atom to move
	if(right_click)
		if(!ismovable(A) || iseffect(A))
			to_chat(user, SPAN_DANGER("You cannot move effects, turfs or areas."))
			return

		// If we had something previously selected, handle its signal and overlay
		if(selected_atom)
			UnregisterSignal(selected_atom, COMSIG_PARENT_QDELETING)

		if(selected_overlay)
			remove_selected_overlay(user)

		// We ensure it properly gets GC'd
		selected_atom = A
		RegisterSignal(selected_atom, COMSIG_PARENT_QDELETING, PROC_REF(on_selected_atom_deleted))

		// Green overlay for selection
		selected_overlay = image(icon = selected_atom.icon, loc = A, icon_state = selected_atom.icon_state)
		selected_overlay.color = "#15d12d"
		user.client.images += selected_overlay

		to_chat(user, SPAN_NOTICE("'[selected_atom]' is selected to be moved."))
		return

	// Selecting the destination to move to
	if(!left_click)
		return

	var/atom/destination = A

	if(!selected_atom)
		to_chat(user, SPAN_DANGER("Select an atom to move first (with right-click)."))
		return

	// Block these as they can only lead to issues
	if(iseffect(destination) || isobserver(destination))
		to_chat(user, SPAN_DANGER("You should not move atoms into effects or ghosts."))
		return

	selected_atom.forceMove(destination)

	to_chat(user, SPAN_NOTICE("'[selected_atom]' is moved to '[destination]'."))
	log_admin("Build Mode: [key_name(user)] forcemoved [selected_atom] to [destination] at ([destination.x],[destination.y],[destination.z]).")

	UnregisterSignal(selected_atom, COMSIG_PARENT_QDELETING)
	selected_atom = null
	remove_selected_overlay(user)

// Remove the green selection (only visible for the user)
/datum/buildmode_mode/forcemove/proc/remove_selected_overlay(mob/user)
	user.client.images -= selected_overlay
	selected_overlay = null

// If it gets deleted mid-movement, remove the overlay and its attachment to the forcemove tool
/datum/buildmode_mode/forcemove/proc/on_selected_atom_deleted()
	SIGNAL_HANDLER
	UnregisterSignal(selected_atom, COMSIG_PARENT_QDELETING)
	selected_atom = null

// This tool calls forceMove() on an object/mob that is selected with right-click.
// Once the atom is moved, its selection is cleared to avoid any further moves by accident.
/datum/buildmode_mode/forcemove
	key = "forcemove"
	/// The atom we want to move
	var/atom/movable/selected_atom
	/// Overlay for the selected atom, only visible for the build mode user
	var/image/selected_overlay

/datum/buildmode_mode/forcemove/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/mob = Select destination</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/mob = Select atom to move</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Clear the current selection</span>")
	to_chat(user, "<span class='notice'><b>Notice:</b> You need to select the movable atom first, then left-click its destination.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/forcemove/handle_click(mob/user, params, atom/A)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	// Selecting the atom to move
	if(right_click)
		if(!ismovable(A) || iseffect(A))
			to_chat(user, "<span class='danger'>You cannot move effects, turfs or areas.</span>")
			return

		// If we had something previously selected, handle its signal and overlay
		clear_selection()

		// We ensure it properly gets GC'd
		selected_atom = A
		RegisterSignal(selected_atom, COMSIG_PARENT_QDELETING, PROC_REF(on_selected_atom_deleted))

		// Green overlay for selection
		selected_overlay = image(icon = selected_atom.icon, loc = A, icon_state = selected_atom.icon_state, layer = HUD_PLANE_BUILDMODE)
		selected_overlay.color = "#15d12d"
		user.client.images += selected_overlay

		to_chat(user, "<span class='notice'>'<b>[selected_atom]</b>' is selected to be moved.</span>")
		return

	// Selecting the destination to move to
	if(!left_click)
		return

	var/atom/destination = A

	if(!selected_atom)
		to_chat(user, "<span class='danger'>Select an atom to move first (with right-click).</span>")
		return

	// Block these as they can only lead to issues
	if(iseffect(destination) || isobserver(destination))
		to_chat(user, "<span class='danger'>You should not move atoms into effects or ghosts.</span>")
		return

	selected_atom.forceMove(destination)

	to_chat(user, "<span class='notice'>'<b>[selected_atom]</b>' is moved to '[destination]'.</span>")
	log_admin("Build Mode: [key_name(user)] forcemoved [selected_atom] to [destination] at ([destination.x],[destination.y],[destination.z]).")
	clear_selection()

/datum/buildmode_mode/forcemove/proc/clear_selection()
	if(selected_atom)
		UnregisterSignal(selected_atom, COMSIG_PARENT_QDELETING)
		selected_atom = null

	if(selected_overlay)
		BM.holder.images -= selected_overlay
		selected_overlay = null

// Right-clicking the build mode icon will clear all selections
/datum/buildmode_mode/forcemove/change_settings(mob/user)
	to_chat(user, "<span class='notice'>Selection cancelled.</span>")
	clear_selection()

// Exiting forcemove mode will clear all selections too
/datum/buildmode_mode/forcemove/exit_mode(datum/click_intercept/buildmode/BM)
	clear_selection()

/datum/buildmode_mode/forcemove/Destroy()
	clear_selection()
	..()

// If it gets deleted mid-movement, remove the overlay and its attachment to the forcemove tool
/datum/buildmode_mode/forcemove/proc/on_selected_atom_deleted()
	SIGNAL_HANDLER
	UnregisterSignal(selected_atom, COMSIG_PARENT_QDELETING)
	selected_atom = null

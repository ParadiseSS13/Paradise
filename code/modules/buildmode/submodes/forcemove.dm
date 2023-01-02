// This tool calls forceMove() on an object/mob that is selected with right-click.
// Once the atom is moved, its selection is cleared to avoid any further moves by accident.
/datum/buildmode_mode/forcemove
	key = "forcemove"
	var/atom/selected_atom		// The atom we want to move

/datum/buildmode_mode/forcemove/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/mob = Select destination</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/mob = Select atom to move</span>")
	to_chat(user, "<span class='notice'><b>Notice:</b> You need to select the movable atom first, then double-click its destination.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/forcemove/handle_click(user, params, atom/A)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	// Selecting the atom to move
	if(right_click)
		if(!ismovable(A) || iseffect(A))
			to_chat(user, "<span class='danger'>You cannot move effects, turfs or areas.</span>")
			return

		selected_atom = A
		to_chat(user, "<span class='notice'>'[selected_atom]' is selected to be moved.</span>")

	// Selecting the destination to move to
	if(left_click)
		var/atom/destination = A

		if(!selected_atom)
			to_chat(user, "<span class='danger'>Select an atom to move first (with right-click).</span>")
			return

		if(iseffect(destination))	// Cannot imagine a single scenario where this is a good idea
			to_chat(user, "<span class='danger'>You should not move atoms into effects.</span>")
			return

		// Typecasting for the right forceMove()
		if(ismob(selected_atom))
			var/mob/M = selected_atom
			M.forceMove(destination)
		else
			var/atom/movable/AM = selected_atom
			AM.forceMove(destination)

		to_chat(user, "<span class='notice'>'[selected_atom]' is moved to '[destination]'.</span>")
		log_admin("Build Mode: [key_name(user)] forcemoved [selected_atom] to [destination] at ([destination.x],[destination.y],[destination.z]).")

		selected_atom = null
		return

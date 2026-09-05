/datum/construction/space_pod/basic
	steps = list(
		list("key" = /obj/item/spacepod_part/engine),
		list("key" = /obj/item/spacepod_part/engine),
		list("key" = /obj/item/spacepod_part/nacelle),
		list("key" = /obj/item/spacepod_part/nacelle),
		list("key" = /obj/item/spacepod_part/wing),
		list("key" = /obj/item/spacepod_part/wing),
		list("key" = /obj/item/spacepod_part/cockpit),
	)
	result = /obj/item/spacepod_hull

	var/list/added_parts = list()

/datum/construction/space_pod/basic/custom_action(step, atom/used_atom, mob/user)
	user.visible_message(
		SPAN_NOTICE("[user] has connected [used_atom] to the [holder]."),
		SPAN_NOTICE("You connect [used_atom] to the [holder].")
	)
	if(used_atom.type in added_parts)
		holder.overlays += used_atom.icon_state + "_right"
	else
		holder.overlays += used_atom.icon_state
		added_parts += used_atom.type

	qdel(used_atom)

	return TRUE

/datum/construction/space_pod/basic/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom, user)

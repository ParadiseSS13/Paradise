/// Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents()
	. = list(src)
	var/idx = 0
	while(idx < length(.))
		var/atom/checked_atom = .[++idx]
		if(checked_atom.flags)
			continue
		. += checked_atom.contents

/// Same as get_all_contents(), but returns a list of atoms of the passed type
/atom/proc/get_all_contents_type(type)
	var/list/processing_list = list(src)
	. = list()
	while(length(processing_list))
		var/atom/checked_atom = processing_list[1]
		processing_list.Cut(1, 2)
		processing_list += checked_atom.contents
		if(istype(checked_atom, type))
			. += checked_atom

/// Forces atom to drop all the important items while dereferencing them from their
/// containers both ways. To be used to preserve important items before mob gib/self-gib.
/atom/proc/drop_ungibbable_items()
	for(var/atom/movable/I in contents)
		if(!is_type_in_list(I, GLOB.ungibbable_items_types))
			if(length(I.contents))
				I.drop_ungibbable_items()
			continue

		var/mob/holder_mob = I.loc
		if(istype(holder_mob))
			holder_mob.unEquip(I)
			continue

		I.forceMove(get_turf(I))
		for(var/var_name in vars)
			// Item may be referenced in some properties of container.
			// E.g. holsters.
			if(vars[var_name] == I)
				vars[var_name] = null
			// Item may be referenced in some list properties of container.
			// E.g. medals.
			else if(I in vars[var_name])
				vars[var_name] -= I
		for(var/var_name in I.vars)
			// Item may reference container in some properties.
			// E.g. medals.
			if(I.vars[var_name] == src)
				I.vars[var_name] = null

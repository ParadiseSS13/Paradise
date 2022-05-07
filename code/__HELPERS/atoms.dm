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

// BY DONKIE~
//Converts a list to a string
/proc/list_implode(var/list/li, var/separator)
	if(istype(li) && (istext(separator) || isnull(separator)))
		return jointext(li, separator)

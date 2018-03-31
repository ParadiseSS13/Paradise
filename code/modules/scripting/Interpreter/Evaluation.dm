/proc/isobject(x)
	return (istype(x, /datum) || istype(x, /list) || istype(x, /savefile) || istype(x, /client) || (x == world))


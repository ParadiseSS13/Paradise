/*
 * Experimental procs by ESwordTheCat!
 */

/*
 * Get index of last char occurence to string.
 *
 * @args
 * A, string to be search
 * B, char used for search
 *
 * @return
 * >0, index of char at string
 *  0, char not found
 * -1, parameter B is not a char
 * -2, parameter A is not a string
 */
/proc/strpos(const/A, const/B)
	if(istext(A) == 0 || length(A) < 1)
		return -2

	if(istext(B) == 0 || length(B) > 1)
		return -1

	var/i = findtext(A, B)

	if(0 == i)
		return 0

	while(i)
		. = i
		i = findtext(A, B, i + 1)

/proc/isInTypes(atom/Object, types)
	var/prototype = Object.type
	Object = null

	for(var/type in params2list(types))
		if(ispath(prototype, text2path(type)))
			return 1

	return 0


/obj/machinery/proc/getArea()
	var/area/A = loc.loc

	if(A != myArea)
		myArea = A

	. = myArea
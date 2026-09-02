//TimSort interface
/proc/sortTim(list/L, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative, fromIndex = 1, toIndex = 0)
	if(L && length(L) >= 2)
		fromIndex = fromIndex % length(L)
		toIndex = toIndex % (length(L) + 1)
		if(fromIndex <= 0)
			fromIndex += length(L)
		if(toIndex <= 0)
			toIndex += length(L) + 1

		var/datum/sort_instance/SI = GLOB.sortInstance
		if(!SI)
			SI = new

		SI.L = L
		SI.cmp = cmp
		SI.associative = associative

		SI.timSort(fromIndex, toIndex)
	return L

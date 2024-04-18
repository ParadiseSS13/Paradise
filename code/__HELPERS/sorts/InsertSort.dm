//simple insertion sort - generally faster than merge for runs of 7 or smaller
/proc/sortInsert(list/L, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative, fromIndex = 1, toIndex = 0)
	if(L && length(L) >= 2)
		fromIndex = fromIndex % L.len
		toIndex = toIndex % (length(L) + 1)
		if(fromIndex <= 0)
			fromIndex += L.len
		if(toIndex <= 0)
			toIndex += length(L) + 1

		var/datum/sortInstance/SI = GLOB.sortInstance
		if(!SI)
			SI = new
		SI.L = L
		SI.cmp = cmp
		SI.associative = associative

		SI.binarySort(fromIndex, toIndex, fromIndex)
	return L

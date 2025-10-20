/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/****
	* Binary search sorted insert from TG
	* INPUT: Object to be inserted
	* LIST: List to insert object into
	* TYPECONT: The typepath of the contents of the list
	* COMPARE: The object to compare against, usualy the same as INPUT
	* COMPARISON: The variable on the objects to compare
	* COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT_TG(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

#define SORT_FIRST_INDEX(list) (list[1])
#define SORT_COMPARE_DIRECTLY(thing) (thing)
#define SORT_VAR_NO_TYPE(varname) var/varname

/****
	* Even more custom binary search sorted insert, using defines instead of vars
	* INPUT: Item to be inserted
	* LIST: List to insert INPUT into
	* TYPECONT: A define setting the var to the typepath of the contents of the list
	* COMPARE: The item to compare against, usualy the same as INPUT
	* COMPARISON: A define that takes an item to compare as input, and returns their comparable value
	* COMPTYPE: How should the list be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT_DEFINE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			##TYPECONT(__BIN_ITEM);\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(##COMPARISON(__BIN_ITEM) <= ##COMPARISON(COMPARE)) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = ##COMPARISON(__BIN_ITEM) > ##COMPARISON(COMPARE) ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

// Generic listoflist safe add and removal macros:
///If value is a list, wrap it in a list so it can be used with list add/remove operations
#define LIST_VALUE_WRAP_LISTS(value) (islist(value) ? list(value) : value)
///Add an untyped item to a list, taking care to handle list items by wrapping them in a list to remove the footgun
#define UNTYPED_LIST_ADD(list, item) (list += LIST_VALUE_WRAP_LISTS(item))

//Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(input)
	if(!total)
		return "[nothing_text]"
	else if(total == 1)
		return "[input[1]]"
	else if(total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while(index < total)
			if(index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

// Returns a map in plain english as a string
/proc/english_map(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(input)
	if(!total)
		return "[nothing_text]"
	else if(total == 1)
		return "[input[1]]"
	else if(total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while(index < total)
			if(index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]] : [input[input[index]]][comma_text]"
			index++

		return "[output][and_text][input[index]] : [input[input[index]]]"

//Returns list element or null. Should prevent "index out of bounds" error.
/proc/listgetindex(list/list, index)
	if(istype(list) && length(list))
		if(isnum(index))
			if(InRange(index,1,length(list)))
				return list[index]
		else if(index in list)
			return list[index]
	return

//Return either pick(list) or null if list is not of type /list or is empty
/proc/safepick(list/list)
	if(!islist(list) || !length(list))
		return
	return pick(list)

//Checks if the list is empty
/proc/isemptylist(list/list)
	if(!length(list))
		return 1
	return 0

//Checks for specific types in a list
/proc/is_type_in_list(datum/D, list/L)
	if(!L || !length(L) || !D)
		return FALSE
	for(var/type in L)
		if(istype(D, type))
			return TRUE
	return FALSE

/proc/is_path_in_list(P, list/L)
	if(!L || !length(L) || !P)
		return FALSE
	for(var/type in L)
		if(ispath(P, type))
			return TRUE
	return FALSE

//Checks for specific types in specifically structured (Assoc "type" = TRUE) lists ('typecaches')
/proc/is_type_in_typecache(atom/A, list/L)
	if(!L || !length(L) || !A)
		return 0
	return L[A.type]

//returns a new list with only atoms that are in typecache L
/proc/typecache_filter_list(list/atoms, list/typecache)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(typecache[A.type])
			. += A

/proc/typecache_filter_list_reverse(list/atoms, list/typecache)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(!typecache[A.type])
			. += A

/proc/typecache_filter_multi_list_exclusion(list/atoms, list/typecache_include, list/typecache_exclude)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(typecache_include[A.type] && !typecache_exclude[A.type])
			. += A

//Like typesof() or subtypesof(), but returns a typecache instead of a list
/proc/typecacheof(path, ignore_root_path, only_root_path = FALSE)
	if(ispath(path))
		var/list/types = list()
		if(only_root_path)
			types = list(path)
		else
			types = ignore_root_path ? subtypesof(path) : typesof(path)
		var/list/L = list()
		for(var/T in types)
			L[T] = TRUE
		return L
	else if(islist(path))
		var/list/pathlist = path
		var/list/L = list()
		if(ignore_root_path)
			for(var/P in pathlist)
				for(var/T in subtypesof(P))
					L[T] = TRUE
		else
			for(var/P in pathlist)
				if(only_root_path)
					L[P] = TRUE
				else
					for(var/T in typesof(P))
						L[T] = TRUE
		return L

//Removes any null entries from the list
/proc/listclearnulls(list/list)
	if(istype(list))
		while(null in list)
			list -= null
	return

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = list()
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second

	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniquemergelist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = list()
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

/**
 * Picks an element based on its weight.
 * L - The input list
 *
 * example: list("a" = 1, "b" = 2) will pick "b" 2/3s of the time
 */
/proc/pickweight(list/L)
	var/total = 0
	var/item
	for(item in L)
		if(!L[item])
			L[item] = 1
		total += L[item]

	total = rand(1, total)
	for(item in L)
		total -=L [item]
		if(total <= 0)
			return item

	return null

/**
 * Picks an element based on its weight. Weight can be any real number
 * L - The input list
 *
 * example: list("a" = 0.33, "b" = 0.67) will have a 67% chance to pick "b"
 */
/proc/pickweight_fraction(list/L)
	var/total = 0
	var/item
	for(item in L)
		if(L[item] < 0)
			continue
		total += L[item]

	total = rand() * total
	for(item in L)
		total -=L [item]
		if(total <= 0)
			return item

	return null

//Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/listfrom)
	if(length(listfrom) > 0)
		var/picked = pick(listfrom)
		listfrom -= picked
		return picked
	return null

/**
 * Picks multiple unique elements from the suplied list.
 * If the given list has a length less than the amount given then it will return a list with an equal amount
 *
 * Arguments:
 * * listfrom - The list where to pick from
 * * amount - The amount of elements it tries to pick.
 */
/proc/pick_multiple_unique(list/listfrom, amount)
	var/list/result = list()
	var/list/copy = listfrom.Copy() // Ensure the original ain't modified
	while(length(copy) && length(result) < amount)
		var/picked = pick(copy)
		result += picked
		copy -= picked
	return result

//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(length(L))
		. = L[length(L)]
		L.len--

/proc/popleft(list/L)
	if(length(L))
		. = L[1]
		L.Cut(1,2)


/*
 * Sorting
 */

//Reverses the order of items in the list
/proc/reverselist(list/L)
	var/list/output = list()
	if(L)
		for(var/i = length(L); i >= 1; i--)
			output += L[i]
	return output

//Randomize: Return the list in a random order
/proc/shuffle(list/L)
	if(!L)
		return
	L = L.Copy()

	for(var/i=1, i<length(L), ++i)
		L.Swap(i,rand(i,length(L)))

	return L

//Return a list with no duplicate entries
/proc/uniquelist(list/L)
	. = list()
	for(var/i in L)
		. |= i

//Mergesort: divides up the list into halves to begin the sort
/proc/sortKey(list/client/L, order = 1)
	if(isnull(L) || length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeKey(sortKey(L.Copy(0,middle)), sortKey(L.Copy(middle)), order)

//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeKey(list/client/L, list/client/R, order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		var/client/rL = L[Li]
		var/client/rR = R[Ri]
		if(sorttext(rL.ckey, rR.ckey) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

//Mergesort: divides up the list into halves to begin the sort
/proc/sortAtom(list/atom/L, order = 1)
	listclearnulls(L)
	if(isnull(L) || length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeAtoms(sortAtom(L.Copy(0,middle)), sortAtom(L.Copy(middle)), order)

//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeAtoms(list/atom/L, list/atom/R, order = 1)
	if(!L || !R) return 0
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		var/atom/rL = L[Li]
		var/atom/rR = R[Ri]
		if(sorttext(rL.name, rR.name) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))




//Mergesort: Specifically for record datums in a list.
/proc/sortRecord(list/datum/data/record/L, field = "name", order = 1)
	if(isnull(L))
		return list()
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeRecordLists(sortRecord(L.Copy(0, middle), field, order), sortRecord(L.Copy(middle), field, order), field, order)

//Mergsort: does the actual sorting and returns the results back to sortRecord
/proc/mergeRecordLists(list/datum/data/record/L, list/datum/data/record/R, field = "name", order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	if(!isnull(L) && !isnull(R))
		while(Li <= length(L) && Ri <= length(R))
			var/datum/data/record/rL = L[Li]
			if(isnull(rL))
				L -= rL
				continue
			var/datum/data/record/rR = R[Ri]
			if(isnull(rR))
				R -= rR
				continue
			if(sorttext(rL.fields[field], rR.fields[field]) == order)
				result += L[Li++]
			else
				result += R[Ri++]

		if(Li <= length(L))
			return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))




//Mergesort: any value in a list
/proc/sortList(list/L)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return mergeLists(sortList(L.Copy(0,middle)), sortList(L.Copy(middle))) //second parameter null = to end of list

/proc/mergeLists(list/L, list/R)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R[Ri++]
		else
			result += L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))


// List of lists, sorts by element[key] - for things like crew monitoring computer sorting records by name.
/proc/sortByKey(list/L, key)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeKeyedLists(sortByKey(L.Copy(0, middle), key), sortByKey(L.Copy(middle), key), key)

/proc/mergeKeyedLists(list/L, list/R, key)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li][key], R[Ri][key]) < 1)
			// Works around list += list2 merging lists; it's not pretty but it works
			result += "temp item"
			result[length(result)] = R[Ri++]
		else
			result += "temp item"
			result[length(result)] = L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))


//Mergesort: any value in a list, preserves key=value structure
/proc/sortAssoc(list/L)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return mergeAssoc(sortAssoc(L.Copy(0,middle)), sortAssoc(L.Copy(middle))) //second parameter null = to end of list

/proc/mergeAssoc(list/L, list/R)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R&R[Ri++]
		else
			result += L&L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

//Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield2list(bitfield = 0, list/wordlist)
	var/list/r = list()
	if(istype(wordlist,/list))
		var/max = min(length(wordlist),16)
		var/bit = 1
		for(var/i=1, i<=max, i++)
			if(bitfield & bit)
				r += wordlist[i]
			bit = bit << 1
	else
		for(var/bit=1, bit<=65535, bit = bit << 1)
			if(bitfield & bit)
				r += bit

	return r

// Returns the key based on the index
/proc/get_key_by_index(list/L, index)
	var/i = 1
	for(var/key in L)
		if(index == i)
			return key
		i++
	return null

/proc/count_by_type(list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i

//Don't use this on lists larger than half a dozen or so
/proc/insertion_sort_numeric_list_ascending(list/L)
	//log_world("ascending len input: [length(L)]")
	var/list/out = list(pop(L))
	for(var/entry in L)
		if(isnum(entry))
			var/success = 0
			for(var/i=1, i<=length(out), i++)
				if(entry <= out[i])
					success = 1
					out.Insert(i, entry)
					break
			if(!success)
				out.Add(entry)

	//log_world("	output: [length(out)]")
	return out

/proc/insertion_sort_numeric_list_descending(list/L)
	//log_world("descending len input: [length(L)]")
	var/list/out = insertion_sort_numeric_list_ascending(L)
	//log_world("	output: [length(out)]")
	return reverselist(out)

//Copies a list, and all lists inside it recusively
//Does not copy any other reference type
/proc/deepCopyList(list/l)
	if(!islist(l))
		return l
	. = l.Copy()
	for(var/i = 1 to length(l))
		if(islist(.[i]))
			.[i] = .(.[i])

/proc/dd_sortedObjectList(list/L, list/cache = list())
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return dd_mergeObjectList(dd_sortedObjectList(L.Copy(0,middle), cache), dd_sortedObjectList(L.Copy(middle), cache), cache) //second parameter null = to end of list

/proc/dd_mergeObjectList(list/L, list/R, list/cache)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= length(L) && Ri <= length(R))
		var/LLi = L[Li]
		var/RRi = R[Ri]
		var/LLiV = cache[LLi]
		var/RRiV = cache[RRi]
		if(!LLiV)
			LLiV = LLi:dd_SortValue()
			cache[LLi] = LLiV
		if(!RRiV)
			RRiV = RRi:dd_SortValue()
			cache[RRi] = RRiV
		if(LLiV < RRiV)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// Insert an object into a sorted list, preserving sortedness
/proc/dd_insertObjectList(list/L, O)
	var/min = 1
	var/max = length(L)
	var/Oval = O:dd_SortValue()

	while(1)
		var/mid = min+round((max-min)/2)

		if(mid == max)
			L.Insert(mid, O)
			return

		var/Lmid = L[mid]
		var/midval = Lmid:dd_SortValue()
		if(Oval == midval)
			L.Insert(mid, O)
			return
		else if(Oval < midval)
			max = mid
		else
			min = mid+1

/proc/dd_sortedtextlist(list/incoming, case_sensitive = 0)
	// Returns a new list with the text values sorted.
	// Use binary search to order by sortValue.
	// This works by going to the half-point of the list, seeing if the node in question is higher or lower cost,
	// then going halfway up or down the list and checking again.
	// This is a very fast way to sort an item into a list.
	var/list/sorted_text = list()
	var/low_index
	var/high_index
	var/insert_index
	var/midway_calc
	var/current_index
	var/current_item
	var/list/list_bottom
	var/sort_result

	var/current_sort_text
	for(current_sort_text in incoming)
		low_index = 1
		high_index = length(sorted_text)
		while(low_index <= high_index)
			// Figure out the midpoint, rounding up for fractions.  (BYOND rounds down, so add 1 if necessary.)
			midway_calc = (low_index + high_index) / 2
			current_index = round(midway_calc)
			if(midway_calc > current_index)
				current_index++
			current_item = sorted_text[current_index]

			if(case_sensitive)
				sort_result = sorttextEx(current_sort_text, current_item)
			else
				sort_result = sorttext(current_sort_text, current_item)

			switch(sort_result)
				if(1)
					high_index = current_index - 1	// current_sort_text < current_item
				if(-1)
					low_index = current_index + 1	// current_sort_text > current_item
				if(0)
					low_index = current_index		// current_sort_text == current_item
					break

		// Insert before low_index.
		insert_index = low_index

		// Special case adding to end of list.
		if(insert_index > length(sorted_text))
			sorted_text += current_sort_text
			continue

		// Because BYOND lists don't support insert, have to do it by:
		// 1) taking out bottom of list, 2) adding item, 3) putting back bottom of list.
		list_bottom = sorted_text.Copy(insert_index)
		sorted_text.Cut(insert_index)
		sorted_text += current_sort_text
		sorted_text += list_bottom
	return sorted_text


/proc/dd_sortedTextList(list/incoming)
	var/case_sensitive = 1
	return dd_sortedtextlist(incoming, case_sensitive)

/proc/subtypesof(path) //Returns a list containing all subtypes of the given path, but not the given path itself.
	if(!path || !ispath(path))
		CRASH("Invalid path, failed to fetch subtypes of \"[path]\".")
	return (typesof(path) - path)

/datum/proc/dd_SortValue()
	return "[src]"

/obj/machinery/dd_SortValue()
	return "[sanitize(name)]"

/obj/machinery/camera/dd_SortValue()
	return "[c_tag]"

//Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((istype(L, /list) && L:len) ? pick(L) : default)

///Initialize the lazylist
#define LAZYINITLIST(L) if(!L) { L = list() }
///If the provided list is empty, set it to null
#define UNSETEMPTY(L) if(L && !length(L)) L = null
///If the provided key -> list is empty, remove it from the list
#define ASSOC_UNSETEMPTY(L, K) if(!length(L[K])) L -= K;
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )
///Remove an item from the list, set the list to null if empty
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
///Add an item to the list, if the list is null it will initialize it
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
///Add an item to the list if not already present, if the list is null it will initialize it
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
///Adds I to L, initializing L if necessary, if I is not already in L
#define LAZYDISTINCTADD(L, I) if(!L) { L = list(); } L |= I;
///returns L[I] if L exists and I is a valid index of L, runtimes if L is not a list
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
///Returns the length of L
#define LAZYLEN(L) length(L) // Despite how pointless this looks, it's still needed in order to convey that the list is specificially a 'Lazy' list.
///Sets a list to null
#define LAZYNULL(L) L = null
///Removes all elements from the list
#define LAZYCLEARLIST(L) if(L) L.Cut()
//Clears a list and then re-initializes it
#define LAZYREINITLIST(L) LAZYCLEARLIST(L); LAZYINITLIST(L);
///Use LAZYLISTDUPLICATE instead if you want it to null with no entries
#define LAZYCOPY(L) (L ? L.Copy() : list() )
///Sets the item K to the value V, if the list is null it will initialize it
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
///Sets the length of a lazylist
#define LAZYSETLEN(L, V) if(!L) { L = list(); } L.len = V;
///Adds to the item K the value V, if the list is null it will initialize it
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
///Removes the value V from the item K, if the item K is empty will remove it from the list, if the list is empty will set the list to null
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
///Accesses an associative list, returns null if nothing is found
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
///Qdel every item in the list before setting the list to null
#define QDEL_LAZYLIST(L) for(var/I in L) qdel(I); L = null;
///If the lazy list is currently initialized find item I in list L
#define LAZYIN(L, I) (L && (I in L))
///Returns whether a numerical index is within a given list's bounds. Faster than isnull(LAZYACCESS(L, I)).
#define ISINDEXSAFE(L, I) (I >= 1 && I <= length(L))

///Performs an insertion on the given lazy list with the given key and value. If the value already exists, a new one will not be made.
#define LAZYORASSOCLIST(lazy_list, key, value) \
	LAZYINITLIST(lazy_list); \
	LAZYINITLIST(lazy_list[key]); \
	lazy_list[key] |= value;

///Ensures the length of a list is at least I, prefilling it with V if needed. if V is a proc call, it is repeated for each new index so that list() can just make a new list for each item.
#define LISTASSERTLEN(L, I, V...) \
	if(length(L) < I) { \
		var/_OLD_LENGTH = length(L); \
		L.len = I; \
		/* Convert the optional argument to a if check */ \
		for(var/_USELESS_VAR in list(V)) { \
			for(var/_INDEX_TO_ASSIGN_TO in _OLD_LENGTH+1 to I) { \
				L[_INDEX_TO_ASSIGN_TO] = V; \
			} \
		} \
	}

//same, but returns nothing and acts on list in place
/proc/shuffle_inplace(list/L)
	if(!L)
		return

	for(var/i=1, i<length(L), ++i)
		L.Swap(i,rand(i,length(L)))

//Return a list with no duplicate entries
/proc/uniqueList(list/L)
	. = list()
	for(var/i in L)
		. |= i

//same, but returns nothing and acts on list in place (also handles associated values properly)
/proc/uniqueList_inplace(list/L)
	var/temp = L.Copy()
	L.len = 0
	for(var/key in temp)
		if(isnum(key))
			L |= key
		else
			L[key] = temp[key]

//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, L.len+1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,L.len+1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex + 1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex + 1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len = 1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i = 0, i < distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex + 1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i = 0, i < len, ++i)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex + 1)

//Move elements from [fromIndex, fromIndex+len) to [toIndex, toIndex+len)
//Move any elements being overwritten by the move to the now-empty elements, preserving order
//Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swapRange(list/L, fromIndex, toIndex, len = 1)
	var/distance = abs(toIndex - fromIndex)
	if(len > distance)	//there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(fromIndex < toIndex)
			toIndex += len
		else
			fromIndex += len

		for(var/i = 0, i < distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex + 1)
	else
		if(toIndex > fromIndex)
			var/a = toIndex
			toIndex = fromIndex
			fromIndex = a

		for(var/i = 0, i < len, ++i)
			L.Swap(fromIndex++, toIndex++)

//replaces reverseList ~Carnie
/proc/reverseRange(list/L, start = 1, end = 0)
	if(length(L))
		start = start % length(L)
		end = end % (length(L) + 1)
		if(start <= 0)
			start += length(L)
		if(end <= 0)
			end += length(L) + 1

		--end
		while(start < end)
			L.Swap(start++, end--)

	return L

/proc/counterlist_scale(list/L, scalar)
	var/list/out = list()
	for(var/key in L)
		out[key] = L[key] * scalar
	. = out

/proc/counterlist_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/proc/counterlist_normalise(list/L)
	var/avg = counterlist_sum(L)
	if(avg != 0)
		. = counterlist_scale(L, 1 / avg)
	else
		. = L

/proc/counterlist_combine(list/L1, list/L2)
	for(var/key in L2)
		var/other_value = L2[key]
		if(key in L1)
			L1[key] += other_value
		else
			L1[key] = other_value

/**
  * A proc for turning a list into an associative list.
  *
  * A simple proc for turning all things in a list into an associative list, instead
  * Each item in the list will have an associative value of TRUE

  * Arguments:
  * * flat_list - the list that it passes to make associative
  */

/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

///compare two lists, returns TRUE if they are the same
/proc/compare_list(list/l, list/d)
	if(!islist(l) || !islist(d))
		return FALSE

	if(length(l) != length(d))
		return FALSE

	for(var/i in 1 to length(l))
		if(l[i] != d[i])
			return FALSE

	return TRUE

// Pick something else from a list than we last picked
/proc/pick_excluding(list/l, exclude)
	return pick(l - exclude)

///takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
///use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key

/// Turns an associative list into a flat list of keys
/proc/assoc_to_keys(list/input)
	var/list/keys = list()
	for(var/key in input)
		UNTYPED_LIST_ADD(keys, key)
	return keys

/**
 * Given a list, return a copy where values without defined weights are given weight 1.
 * For example, fill_with_ones(list(A, B=2, C)) = list(A=1, B=2, C=1)
 * Useful for weighted random choices (loot tables, syllables in languages, etc.)
 */
/proc/fill_with_ones(list/list_to_pad)
	if(!islist(list_to_pad))
		return list_to_pad

	var/list/final_list = list()

	for(var/key in list_to_pad)
		if(list_to_pad[key])
			final_list[key] = list_to_pad[key]
		else
			final_list[key] = 1

	return final_list

/**
 * Like pick_weight, but allowing for nested lists.
 *
 * For example, given the following list:
 * list(A = 1, list(B = 1, C = 1))
 * A would have a 50% chance of being picked,
 * and list(B, C) would have a 50% chance of being picked.
 * If list(B, C) was picked, B and C would then each have a 50% chance of being picked.
 * So the final probabilities would be 50% for A, 25% for B, and 25% for C.
 *
 * Weights should be integers. Entries without weights are assigned weight 1 (so unweighted lists can be used as well)
 */
/proc/pick_weight_recursive(list/list_to_pick)
	var/result = pickweight(fill_with_ones(list_to_pick))
	while(islist(result))
		result = pickweight(fill_with_ones(result))
	return result

/**
 * Checks to make sure that the lists have the exact same contents, ignores the order of the contents.
 */
/proc/lists_equal_unordered(list/list_one, list/list_two)
	// This ensures that both lists contain the same elements by checking if the difference between them is empty in both directions.
	return !length(list_one ^ list_two)

/**
 * Removes any null entries from the list
 * Returns TRUE if the list had nulls, FALSE otherwise
**/
/proc/list_clear_nulls(list/list_to_clear)
	return (list_to_clear.RemoveAll(null) > 0)

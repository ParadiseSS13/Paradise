#define pick_list(FILE, KEY) (pick(strings(FILE, KEY)))
#define pick_list_replacements(FILE, KEY) (strings_replacement(FILE, KEY))
#define json_load(FILE) (json_decode(wrap_file2text(FILE)))
///If value is a list, wrap it in a list so it can be used with list add/remove operations
#define LIST_VALUE_WRAP_LISTS(value) (islist(value) ? list(value) : value)

GLOBAL_LIST_EMPTY(string_cache)
GLOBAL_LIST_EMPTY(string_filename_current_key)


/proc/strings_replacement(filename, key)
	load_strings_file(filename)

	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		var/response = pick(GLOB.string_cache[filename][key])
		var/regex/r = regex("@pick\\((\\D+?)\\)", "g")
		response = r.Replace(response, /proc/strings_subkey_lookup)
		return response
	else
		CRASH("strings list not found: strings/[filename], index=[key]")

/proc/strings(filename as text, key as text)
	load_strings_file(filename)
	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		return GLOB.string_cache[filename][key]
	else
		CRASH("strings list not found: strings/[filename], index=[key]")

/proc/strings_subkey_lookup(match, group1)
	return pick_list(GLOB.string_filename_current_key, group1)

/proc/load_strings_file(filename)
	GLOB.string_filename_current_key = filename
	if(filename in GLOB.string_cache)
		return //no work to do

	if(!GLOB.string_cache)
		GLOB.string_cache = new

	if(fexists("strings/[filename]"))
		GLOB.string_cache[filename] = json_load("strings/[filename]")
	else
		CRASH("file not found: strings/[filename]")

///Return a list with no duplicate entries
/proc/unique_list(list/inserted_list)
	. = list()
	for(var/i in inserted_list)
		. |= LIST_VALUE_WRAP_LISTS(i)

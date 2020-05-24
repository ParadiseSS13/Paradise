///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////

//As of 3.6.2016
//global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_DATUM_INIT(_preloader, /dmm_suite/preloader, new())

/dmm_suite
	// These regexes are global - meaning that starting the maploader again mid-load will
	// reset progress - which means we need to track our index per-map, or we'll
	// eternally recurse
		// /"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}/g
	var/static/regex/dmmRegex = new/regex({""(\[a-zA-Z]+)" = \\(((?:.|\n)*?)\\)\n(?!\t)|\\((\\d+),(\\d+),(\\d+)\\) = \\{"(\[a-zA-Z\n]*)"\\}"}, "g")
		// /^[\s\n]+"?|"?[\s\n]+$|^"|"$/g
	var/static/regex/trimQuotesRegex = new/regex({"^\[\\s\n]+"?|"?\[\\s\n]+$|^"|"$"}, "g")
		// /^[\s\n]+|[\s\n]+$/
	var/static/regex/trimRegex = new/regex("^\[\\s\n]+|\[\\s\n]+$", "g")
	var/static/list/modelCache = list()

/**
 * Construct the model map and control the loading process
 *
 * WORKING :
 *
 * 1) Makes an associative mapping of model_keys with model
 *		e.g aa = /turf/unsimulated/wall{icon_state = "rock"}
 * 2) Read the map line by line, parsing the result (using parse_grid)
 *
 * If `measureOnly` is set, then no atoms will be created, and all this will do
 * is return the bounds after parsing the file
 *
 * If you need to freeze init while you're working, you can use the spacial allocator's
 * "add_dirt" and "remove_dirt" which will put initializations on hold until you say
 * the word. This is important for loading large maps such as the cyberiad, where
 * atmos will attempt to start before it's ready, causing runtimes galore if init is
 * allowed to romp unchecked.
 */
/dmm_suite/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num)
	var/tfile = dmm_file//the map file we're creating
	var/fname = "Lambda"
	if(isfile(tfile))
		fname = "[tfile]"
		tfile = file2text(tfile)
		if(length(tfile) == 0)
			throw EXCEPTION("Map path '[fname]' does not exist!")

	if(!x_offset)
		x_offset = 1
	if(!y_offset)
		y_offset = 1
	if(!z_offset)
		z_offset = world.maxz + 1

	var/list/bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	var/list/grid_models = list()
	var/key_len = 0

	var/dmm_suite/loaded_map/LM = new
	// This try-catch is used as a budget "Finally" clause, as the dirt count
	// needs to be reset
	var/watch = start_watch()
	log_debug("[measureOnly ? "Measuring" : "Loading"] map: [fname]")
	try
		LM.index = 1
		while(dmmRegex.Find(tfile, LM.index))
			LM.index = dmmRegex.next

			// "aa" = (/type{vars=blah})
			if(dmmRegex.group[1]) // Model
				var/key = dmmRegex.group[1]
				if(grid_models[key]) // Duplicate model keys are ignored in DMMs
					continue
				if(key_len != length(key))
					if(!key_len)
						key_len = length(key)
					else
						throw EXCEPTION("Inconsistant key length in DMM")
				if(!measureOnly)
					grid_models[key] = dmmRegex.group[2]

			// (1,1,1) = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
			else if(dmmRegex.group[3]) // Coords
				if(!key_len)
					throw EXCEPTION("Coords before model definition in DMM")

				var/xcrdStart = text2num(dmmRegex.group[3]) + x_offset - 1
				//position of the currently processed square
				var/xcrd
				var/ycrd = text2num(dmmRegex.group[4]) + y_offset - 1
				var/zcrd = text2num(dmmRegex.group[5]) + z_offset - 1

				if(!measureOnly)
					if(zcrd > world.maxz)
						if(cropMap)
							continue
						else
							GLOB.space_manager.increase_max_zlevel_to(zcrd) //create a new z_level if needed

				bounds[MAP_MINX] = min(bounds[MAP_MINX], xcrdStart)
				bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
				bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)

				var/list/gridLines = splittext(dmmRegex.group[6], "\n")

				var/leadingBlanks = 0
				while(leadingBlanks < gridLines.len && gridLines[++leadingBlanks] == "")
				if(leadingBlanks > 1)
					gridLines.Cut(1, leadingBlanks) // Remove all leading blank lines.

				if(!gridLines.len) // Skip it if only blank lines exist.
					continue

				if(gridLines.len && gridLines[gridLines.len] == "")
					gridLines.Cut(gridLines.len) // Remove only one blank line at the end.

				bounds[MAP_MINY] = min(bounds[MAP_MINY], ycrd)
				ycrd += gridLines.len - 1 // Start at the top and work down

				if(!cropMap && ycrd > world.maxy)
					if(!measureOnly)
						world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
					bounds[MAP_MAXY] = max(bounds[MAP_MAXY], ycrd)
				else
					bounds[MAP_MAXY] = max(bounds[MAP_MAXY], min(ycrd, world.maxy))

				var/maxx = xcrdStart
				if(measureOnly)
					for(var/line in gridLines)
						maxx = max(maxx, xcrdStart + length(line) / key_len - 1)
				else
					for(var/line in gridLines)
						if(ycrd <= world.maxy && ycrd >= 1)
							xcrd = xcrdStart
							for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
								if(xcrd > world.maxx)
									if(cropMap)
										break
									else
										world.maxx = xcrd

								if(xcrd >= 1)
									var/model_key = copytext(line, tpos, tpos + key_len)
									if(!grid_models[model_key])
										throw EXCEPTION("Undefined model key in DMM: [model_key]. Map file: [fname].")
									parse_grid(grid_models[model_key], xcrd, ycrd, zcrd, LM)
									// After this call, it is NOT safe to reference `dmmRegex` without another call to
									// "Find" - we might've hit a map loader here and changed its state
									CHECK_TICK

								maxx = max(maxx, xcrd)
								++xcrd
						--ycrd
				bounds[MAP_MAXX] = max(bounds[MAP_MAXX], cropMap ? min(maxx, world.maxx) : maxx)

			CHECK_TICK
	catch(var/exception/e)
		GLOB._preloader.reset()
		throw e

	GLOB._preloader.reset()
	log_debug("Loaded map in [stop_watch(watch)]s.")
	qdel(LM)
	if(bounds[MAP_MINX] == 1.#INF) // Shouldn't need to check every item
		log_runtime(EXCEPTION("Bad Map bounds in [fname]"), src, list(
		"Min x: [bounds[MAP_MINX]]",
		"Min y: [bounds[MAP_MINY]]",
		"Min z: [bounds[MAP_MINZ]]",
		"Max x: [bounds[MAP_MAXX]]",
		"Max y: [bounds[MAP_MAXY]]",
		"Max z: [bounds[MAP_MAXZ]]"))
		return null
	else
		if(!measureOnly)
			for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
				var/turf/T = t
				//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
				T.AfterChange(1, keep_cabling = TRUE)
		return bounds

/**
 * Fill a given tile with its area/turf/objects/mobs
 * Variable model is one full map line (e.g /turf/unsimulated/wall{icon_state = "rock"},/area/mine/dangerous/explored)
 *
 * WORKING :
 *
 * 1) Read the model string, member by member (delimiter is ',')
 *
 * 2) Get the path of the atom and store it into a list
 *
 * 3) a) Check if the member has variables (text within '{' and '}')
 *
 * 3) b) Construct an associative list with found variables, if any (the atom index in members is the same as its variables in members_attributes)
 *
 * 4) Instanciates the atom with its variables
 *
 */
/dmm_suite/proc/parse_grid(model as text,xcrd as num,ycrd as num,zcrd as num, dmm_suite/loaded_map/LM)
	/*Method parse_grid()
	- Accepts a text string containing a comma separated list of type paths of the
		same construction as those contained in a .dmm file, and instantiates them.
	*/

	var/list/members //will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/dangerous/explored)
	var/list/members_attributes //will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())
	var/list/cached = modelCache[model]
	var/index

	if(cached)
		members = cached[1]
		members_attributes = cached[2]
	else
		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		members = list()
		members_attributes = list()
		index = 1

		var/old_position = 1
		var/dpos

		do
			//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/dangerous/explored)
			dpos = find_next_delimiter_position(model, old_position, ",", "{", "}") //find next delimiter (comma here) that's not within {...}

			var/full_def = trim_text(copytext(model, old_position, dpos)) //full definition, e.g : /obj/foo/bar{variables=derp}
			var/variables_start = findtext(full_def, "{")
			var/atom_text = trim_text(copytext(full_def, 1, variables_start))
			var/atom_def = text2path(atom_text) //path definition, e.g /obj/foo/bar
			old_position = dpos + 1

			if(!atom_def) // Skip the item if the path does not exist.  Fix your crap, mappers!
				log_runtime(EXCEPTION("Bad path: [atom_text]"), src, list("Source String: [model]", "dpos: [dpos]"))
				continue
			members.Add(atom_def)

			//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
			var/list/fields = list()

			if(variables_start)//if there's any variable
				full_def = copytext(full_def,variables_start+1,length(full_def))//removing the last '}'
				fields = readlist(full_def, ";")

			//then fill the members_attributes list with the corresponding variables
			members_attributes.len++
			members_attributes[index++] = fields

			CHECK_TICK
		while(dpos != 0)

		modelCache[model] = list(members, members_attributes)


	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile

	//first instance the /area and remove it from the members list
	index = members.len

	var/turf/crds = locate(xcrd,ycrd,zcrd)
	if(members[index] != /area/template_noop)
		// We assume `members[index]` is an area path, as above, yes? I will operate
		// on that assumption.
		if(!ispath(members[index], /area))
			throw EXCEPTION("Oh no, I thought this was an area!")

		var/atom/instance
		GLOB._preloader.setup(members_attributes[index])//preloader for assigning  set variables on atom creation
		instance = LM.area_path_to_real_area(members[index])

		if(crds)
			instance.contents.Add(crds)

		if(GLOB.use_preloader && instance)
			GLOB._preloader.load(instance)

	//then instance the /turf and, if multiple tiles are presents, simulates the DMM underlays piling effect

	var/first_turf_index = 1
	while(!ispath(members[first_turf_index],/turf)) //find first /turf object in members
		first_turf_index++

	//instanciate the first /turf
	var/turf/T
	if(members[first_turf_index] != /turf/template_noop)
		T = instance_atom(members[first_turf_index],members_attributes[first_turf_index],xcrd,ycrd,zcrd)

	if(T)
		//if others /turf are presents, simulates the underlays piling effect
		index = first_turf_index + 1
		while(index <= members.len - 1) // Last item is an /area
			var/underlay
			if(istype(T, /turf)) // I blame this on the stupid clown who coded the BYOND map editor
				underlay = T.appearance
			T = instance_atom(members[index],members_attributes[index],xcrd,ycrd,zcrd)//instance new turf
			if(ispath(members[index],/turf))
				T.underlays += underlay

			index++

	//finally instance all remainings objects/mobs
	for(index in 1 to first_turf_index-1)
		instance_atom(members[index],members_attributes[index],xcrd,ycrd,zcrd)
		CHECK_TICK

////////////////
//Helpers procs
////////////////

//Instance an atom at (x,y,z) and gives it the variables in attributes
/dmm_suite/proc/instance_atom(path,list/attributes, x, y, z)
	var/atom/instance
	GLOB._preloader.setup(attributes, path)

	var/turf/T = locate(x,y,z)
	if(T)
		if(ispath(path, /turf))
			T.ChangeTurf(path, defer_change = TRUE, keep_icon = FALSE)
			instance = T
		else if(ispath(path, /area))

		else
			instance = new path (T)//first preloader pass

	if(GLOB.use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
		GLOB._preloader.load(instance)

	return instance

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/dmm_suite/proc/trim_text(what as text,trim_quotes=0)
	if(trim_quotes)
		return trimQuotesRegex.Replace(what, "")
	else
		return trimRegex.Replace(what, "")


//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/dmm_suite/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape=quote,closing_escape=quote)
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter


//build a list from variables in text form (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
//return the filled list
/dmm_suite/proc/readlist(text as text, delimiter=",")

	var/list/to_return = list()

	var/position
	var/old_position = 1

	do
		//find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter)

		//check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		var/equal_position = findtext(text,"=",old_position, position)

		var/trim_left = trim_text(copytext(text,old_position,(equal_position ? equal_position : position)),1)//the name of the variable, must trim quotes to build a BYOND compliant associatives list
		old_position = position + 1

		if(equal_position)//associative var, so do the association
			var/trim_right = trim_text(copytext(text,equal_position+1,position))//the content of the variable

			//Check for string
			// Make it read to the next delimiter, instead of the quote
			if(findtext(trim_right,quote,1,2))
				var/endquote = findtext(trim_right,quote,-1)
				if(!endquote)
					log_runtime(EXCEPTION("Terminating quote not found!"), src)
				// Our map writer escapes quotes and curly brackets to avoid
				// letting our simple parser choke on meanly-crafted names/etc
				// - so we decode it here so it's back to good ol' legibility
				trim_right = dmm_decode(copytext(trim_right,2,endquote))

			//Check for number
			else if(isnum(text2num(trim_right)))
				trim_right = text2num(trim_right)

			//Check for null
			else if(trim_right == "null")
				trim_right = null

			//Check for list
			else if(copytext(trim_right,1,5) == "list")
				trim_right = readlist(copytext(trim_right,6,length(trim_right)))

			//Check for file
			else if(copytext(trim_right,1,2) == "'")
				trim_right = file(copytext(trim_right,2,length(trim_right)))

			//Check for path
			else if(ispath(text2path(trim_right)))
				trim_right = text2path(trim_right)

			to_return[trim_left] = trim_right

		else//simple var
			to_return[trim_left] = null

	while(position != 0)

	return to_return

/dmm_suite/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

//////////////////
//Preloader datum
//////////////////

// This ain't re-entrant, but we had this before the maploader update
/dmm_suite/preloader
	parent_type = /datum
	var/list/attributes
	var/target_path
	var/json_ready = 0

/dmm_suite/preloader/proc/setup(list/the_attributes, path)
	if(the_attributes.len)
		json_ready = 0
		if("map_json_data" in the_attributes)
			json_ready = 1
		GLOB.use_preloader = TRUE
		attributes = the_attributes
		target_path = path

/dmm_suite/preloader/proc/load(atom/what)
	if(json_ready)
		var/json_data = attributes["map_json_data"]
		attributes -= "map_json_data"
		json_data = dmm_decode(json_data)
		try
			what.deserialize(json_decode(json_data))
		catch(var/exception/e)
			log_runtime(EXCEPTION("Bad json data: '[json_data]'"), src)
			throw e
	for(var/attribute in attributes)
		var/value = attributes[attribute]
		if(islist(value))
			value = deepCopyList(value)
		what.vars[attribute] = value
	GLOB.use_preloader = FALSE

// If the map loader fails, make this safe
/dmm_suite/preloader/proc/reset()
	GLOB.use_preloader = FALSE
	attributes = list()
	target_path	= null

// A datum for use within the context of loading a single map,
// so that one can have separate "unpowered" areas for ruins or whatever,
// yet have a single area type for use of mapping, instead of creating
// a new area type for each new ruin
/dmm_suite/loaded_map
	parent_type = /datum
	var/list/area_list = list()
	var/index = 1 // To store the state of the regex

/dmm_suite/loaded_map/proc/area_path_to_real_area(area/A)
	if(!ispath(A, /area))
		throw EXCEPTION("Wrong argument to `area_path_to_real_area`")

	if(!(A in area_list))
		if(initial(A.there_can_be_many))
			area_list[A] = new A
		else
			area_list[A] = locate(A)

	return area_list[A]

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"

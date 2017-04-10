#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24
#define DMM_USE_JSON 32
/dmm_suite
	var/quote = "\""
	var/list/letter_digits = list(
			"a","b","c","d","e",
			"f","g","h","i","j",
			"k","l","m","n","o",
			"p","q","r","s","t",
			"u","v","w","x","y",
			"z",
			"A","B","C","D","E",
			"F","G","H","I","J",
			"K","L","M","N","O",
			"P","Q","R","S","T",
			"U","V","W","X","Y",
			"Z"
			)

/dmm_suite/save_map(var/turf/t1 as turf, var/turf/t2 as turf, var/map_name as text, var/flags as num)
	//Check for illegal characters in file name... in a cheap way.
	if(!((ckeyEx(map_name)==map_name) && ckeyEx(map_name)))
		CRASH("Invalid text supplied to proc save_map, invalid characters or empty string.")
	//Check for valid turfs.
	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc save_map, arguments were not turfs.")

	var/map_prefix = "_maps/quicksave/"
	var/map_path = "[map_prefix][map_name].dmm"
	if(fexists(map_path))
		fdel(map_path)
	var/saved_map = file(map_path)
	var/map_text = write_map(t1,t2,flags,saved_map)
	saved_map << map_text
	return saved_map

/dmm_suite/write_map(var/turf/t1 as turf, var/turf/t2 as turf, var/flags as num)
	//Check for valid turfs.
	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc write_map, arguments were not turfs.")

	var/turf/ne = locate(max(t1.x,t2.x),max(t1.y,t2.y),max(t1.z,t2.z)) // Outer corner
	var/turf/sw = locate(min(t1.x,t2.x),min(t1.y,t2.y),min(t1.z,t2.z)) // Inner corner
	var/list/templates[0]
	var/list/template_buffer = list()
	var/template_buffer_text
	var/dmm_text = ""

	var/total_timer = start_watch()
	var/timer = start_watch()
	log_debug("Reading turfs...")
	// Read the contents of all the turfs we were given
	for(var/pos_z in sw.z to ne.z)
		for(var/pos_y in ne.y to sw.y step -1) // We're reversing this because the map format is silly
			for(var/pos_x in sw.x to ne.x)
				var/turf/test_turf = locate(pos_x,pos_y,pos_z)
				var/test_template = make_template(test_turf, flags)
				var/template_number = templates.Find(test_template)
				if(!template_number)
					templates.Add(test_template)
					template_number = templates.len
				template_buffer += "[template_number],"
				CHECK_TICK

			template_buffer += ";"

		template_buffer += "."
	template_buffer_text = jointext(template_buffer,"")
	log_debug("Reading turfs took [stop_watch(timer)]s.")

	if(templates.len == 0)
		CRASH("No templates found!")
	var/key_length = round/*floor*/(log(letter_digits.len,templates.len-1)+1)
	var/list/keys[templates.len]
	// Write the list of key/model pairs to the file
	timer = start_watch()
	log_debug("Writing out key/model pairs to file header...")
	var/list/key_models = list()
	for(var/key_pos in 1 to templates.len)
		keys[key_pos] = get_model_key(key_pos,key_length)
		key_models += "\"[keys[key_pos]]\" = ([templates[key_pos]])\n"
		CHECK_TICK
	dmm_text += jointext(key_models,"")
	log_debug("Writing key/model pairs complete, took [stop_watch(timer)]s.")

	var/z_level = 0
	// Loop over all z in our zone
	timer = start_watch()
	log_debug("Writing out key map...")
	var/list/key_map = list()
	for(var/z_pos=1;TRUE;z_pos=findtext(template_buffer_text,".",z_pos)+1)
		if(z_pos>=length(template_buffer_text))	break
		if(z_level)	key_map += "\n"
		key_map += "\n(1,1,[++z_level]) = {\"\n"
		var/z_block = copytext(template_buffer_text,z_pos,findtext(template_buffer_text,".",z_pos))
		for(var/y_pos=1;TRUE;y_pos=findtext(z_block,";",y_pos)+1)
			if(y_pos>=length(z_block))	break
			var/y_block = copytext(z_block,y_pos,findtext(z_block,";",y_pos))
			// A row of keys
			for(var/x_pos=1;TRUE;x_pos=findtext(y_block,",",x_pos)+1)
				if(x_pos>=length(y_block))	break
				var/x_block = copytext(y_block,x_pos,findtext(y_block,",",x_pos))
				var/key_number = text2num(x_block)
				var/temp_key = keys[key_number]
				key_map += temp_key
				CHECK_TICK
			key_map += "\n"
		key_map += "\"}"
	dmm_text += jointext(key_map,"")
	log_debug("Writing key map complete, took [stop_watch(timer)]s.")
	log_debug("TOTAL TIME: [stop_watch(total_timer)]s.")
	return dmm_text

/dmm_suite/proc/make_template(var/turf/model as turf, var/flags as num)
	var/use_json = 0
	if(flags & DMM_USE_JSON)
		use_json = 1
	var/template = ""
	var/turf_template = ""
	var/list/obj_template = list()
	var/list/mob_template = list()
	var/area_template = ""



	// Turf
	if(!(flags & DMM_IGNORE_TURFS))
		turf_template = "[model.type][check_attributes(model,use_json=use_json)],"
	else	turf_template = "[world.turf],"

	// Objects loop
	if(!(flags & DMM_IGNORE_OBJS))
		for(var/obj/O in model.contents)
			if(O.dont_save || !isnull(O.gcDestroyed))
				continue
			obj_template += "[O.type][check_attributes(O,use_json=use_json)],"

	// Mobs Loop
	for(var/mob/M in model.contents)
		if(M.dont_save || !isnull(M.gcDestroyed))
			continue
		if(M.client)
			if(!(flags & DMM_IGNORE_PLAYERS))
				mob_template += "[M.type][check_attributes(M,use_json=use_json)],"
		else
			if(!(flags & DMM_IGNORE_NPCS))
				mob_template += "[M.type][check_attributes(M,use_json=use_json)],"

	// Area
	if(!(flags & DMM_IGNORE_AREAS))
		var/area/m_area = model.loc
		area_template = "[m_area.type][check_attributes(m_area,use_json=use_json)]"
	else	area_template = "[world.area]"

	template = "[jointext(obj_template,"")][jointext(mob_template,"")][turf_template][area_template]"
	return template

/dmm_suite/proc/check_attributes(var/atom/A,use_json=0)
	var/attributes_text = "{"
	var/list/attributes = list()
	if(!use_json)
		for(var/V in A.vars)
			CHECK_TICK
			if((!issaved(A.vars[V])) || (A.vars[V]==initial(A.vars[V])))	continue

			attributes += var_to_dmm(A.vars[V], V)
	else
		var/list/yeah = A.serialize()
		// We'll want to write out vars that are important to the editor
		// So that the map is legible as before
		for(var/thing in A.map_important_vars())
			// Save vars that are important for the map editor, so that
			// json-encoded maps are legible for standard editors
			if(A.vars[thing] != initial(A.vars[thing]))
				yeah -= thing
				attributes += var_to_dmm(A.vars[thing],thing)

		// Remove useless info
		yeah -= "type"
		if(yeah.len)
			var/json_stuff = json_encode(yeah)
			attributes += var_to_dmm(json_stuff, "map_json_data")
	if(attributes.len == 0)
		return

	// Trim a trailing semicolon - `var_to_dmm` always appends a semicolon,
	// so the last one will be trailing.
	if(copytext(attributes_text, length(attributes_text)-1, 0) == "; ")
		attributes_text = copytext(attributes_text, 1, length(attributes_text)-1)
	attributes_text = "{[jointext(attributes,"; ")]}"
	return attributes_text


/dmm_suite/proc/get_model_key(var/which as num, var/key_length as num)
	var/list/key = list()
	var/working_digit = which-1
	for(var/digit_pos in key_length to 1 step -1)
		var/place_value = round/*floor*/(working_digit/(letter_digits.len**(digit_pos-1)))
		working_digit-=place_value*(letter_digits.len**(digit_pos-1))
		key += letter_digits[place_value+1]
	return jointext(key,"")


/dmm_suite/proc/var_to_dmm(attr, name)
	if(istext(attr))
		// dmm_encode will strip out characters that would be capable of disrupting
		// parsing - namely, quotes and curly braces
		return "[name] = \"[dmm_encode(attr)]\""
	else if(isnum(attr)||ispath(attr))
		return "[name] = [attr]"
	else if(isicon(attr)||isfile(attr))
		if(length("[attr]") == 0)
			// The DM map reader is unable to read files that have a '' file/icon entry
			return
		return "[name] = '[attr]'"
	else
		return ""

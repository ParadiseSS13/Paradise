#define DMM_IGNORE_AREAS 	(1<<0)
#define DMM_IGNORE_TURFS 	(1<<1)
#define DMM_IGNORE_OBJS 	(1<<2)
#define DMM_IGNORE_NPCS 	(1<<3)
#define DMM_IGNORE_PLAYERS 	(1<<4)
#define DMM_IGNORE_MOBS 	(DMM_IGNORE_NPCS | DMM_IGNORE_PLAYERS)
#define DMM_USE_JSON 		(1<<5)

/datum/dmm_suite/proc/save_map(turf/t1, turf/t2, map_name = "", flags = 0)
	// Check for illegal characters in file name... in a cheap way.
	if(!((ckeyEx(map_name) == map_name) && ckeyEx(map_name)))
		CRASH("Invalid text supplied to proc save_map, invalid characters or empty string.")
	// Check for valid turfs.
	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc save_map, arguments were not turfs.")

	var/map_prefix = "_maps/quicksave/"
	var/map_path = "[map_prefix][map_name].dmm"
	if(fexists(map_path))
		fdel(map_path)
	var/saved_map = wrap_file(map_path)
	var/map_text = write_map(t1, t2, flags, saved_map)
	saved_map << map_text
	return saved_map

/datum/dmm_suite/proc/write_map(turf/t1, turf/t2, flags = 0)
	// Check for valid turfs.
	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc write_map, arguments were not turfs.")

	var/turf/ne = locate(max(t1.x, t2.x), max(t1.y, t2.y), max(t1.z, t2.z)) // Outer corner
	var/turf/sw = locate(min(t1.x, t2.x), min(t1.y, t2.y), min(t1.z, t2.z)) // Inner corner
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
				var/turf/test_turf = locate(pos_x, pos_y, pos_z)
				var/test_template = make_template(test_turf, flags)
				var/template_number = templates.Find(test_template)
				if(!template_number)
					templates.Add(test_template)
					template_number = length(templates)
				template_buffer += "[template_number],"
				CHECK_TICK
			template_buffer += ";"
		template_buffer += "."

	template_buffer_text = jointext(template_buffer, "")
	log_debug("Reading turfs took [stop_watch(timer)]s.")

	if(length(templates) == 0)
		CRASH("No templates found!")

	var/key_length = round(log(length(letter_digits), max(length(templates) - 1, 1)) + 1) // or floor
	var/list/keys[length(templates)]

	// Write the list of key/model pairs to the file
	timer = start_watch()
	log_debug("Writing out key/model pairs to file header...")
	var/list/key_models = list()
	for(var/key_pos in 1 to length(templates))
		keys[key_pos] = get_model_key(key_pos, key_length)
		key_models += "\"[keys[key_pos]]\" = ([templates[key_pos]])\n"
		CHECK_TICK

	dmm_text += jointext(key_models,"")
	log_debug("Writing key/model pairs complete, took [stop_watch(timer)]s.")

	var/z_level = 0
	// Loop over all z in our zone
	timer = start_watch()
	log_debug("Writing out key map...")

	var/list/key_map = list()
	var/z_pos = 1
	while(TRUE)
		if(z_pos >= length(template_buffer_text))
			break

		if(z_level)
			key_map += "\n"

		key_map += "\n(1,1,[++z_level]) = {\"\n"

		var/z_block = copytext(template_buffer_text, z_pos, findtext(template_buffer_text, ".", z_pos))
		var/y_pos = 1
		while(TRUE)
			if(y_pos >= length(z_block))
				break

			var/y_block = copytext(z_block, y_pos, findtext(z_block, ";", y_pos))
			// A row of keys
			y_pos = findtext(z_block, ";", y_pos) + 1
			var/x_pos = 1
			while(TRUE)
				if(x_pos >= length(y_block))
					break

				var/x_block = copytext(y_block, x_pos, findtext(y_block, ",", x_pos))
				var/key_number = text2num(x_block)
				var/temp_key = keys[key_number]
				key_map += temp_key
				CHECK_TICK
				x_pos = findtext(y_block, ",", x_pos) + 1
			key_map += "\n"
		key_map += "\"}"
		z_pos = findtext(template_buffer_text, ".", z_pos) + 1

	dmm_text += jointext(key_map, "")
	log_debug("Writing key map complete, took [stop_watch(timer)]s.")
	log_debug("TOTAL TIME: [stop_watch(total_timer)]s.")

	return dmm_text

/datum/dmm_suite/proc/make_template(turf/model, flags = 0)
	var/use_json = (flags & DMM_USE_JSON) ? TRUE : FALSE

	var/template = ""
	var/turf_template = ""
	var/list/obj_template = list()
	var/list/mob_template = list()
	var/area_template = ""

	// Turf
	if(!(flags & DMM_IGNORE_TURFS))
		turf_template = "[model.type][check_attributes(model,use_json=use_json)],"
	else
		turf_template = "[world.turf],"

	// Objects loop
	if(!(flags & DMM_IGNORE_OBJS))
		for(var/obj/O in model.contents)
			if(QDELETED(O))
				continue

			obj_template += "[O.type][check_attributes(O,use_json=use_json)],"

	// Area
	if(!(flags & DMM_IGNORE_AREAS))
		var/area/m_area = model.loc
		area_template = "[m_area.type][check_attributes(m_area,use_json=use_json)]"
	else
		area_template = "[world.area]"

	template = "[jointext(obj_template,"")][jointext(mob_template,"")][turf_template][area_template]"
	return template

/datum/dmm_suite/proc/check_attributes(atom/A, use_json = FALSE)
	var/attributes_text = "{"
	var/list/attributes = list()
	if(!use_json)
		for(var/V in A.vars)
			CHECK_TICK
			if((!issaved(A.vars[V])) || (A.vars[V] == initial(A.vars[V])))
				continue

			attributes += var_to_dmm(A.vars[V], V)
	else
		var/list/to_encode = A.serialize()
		// We'll want to write out vars that are important to the editor
		// So that the map is legible as before
		for(var/T in A.map_important_vars())
			// Save vars that are important for the map editor, so that
			// json-encoded maps are legible for standard editors
			if(A.vars[T] != initial(A.vars[T]))
				to_encode -= T
				attributes += var_to_dmm(A.vars[T], T)

		// Remove useless info
		to_encode -= "type"
		if(length(to_encode))
			var/json_stuff = json_encode(to_encode)
			attributes += var_to_dmm(json_stuff, "map_json_data")

	if(length(attributes) == 0)
		return

	// Trim a trailing semicolon - `var_to_dmm` always appends a semicolon,
	// so the last one will be trailing.
	if(copytext(attributes_text, length(attributes_text) - 1, 0) == "; ")
		attributes_text = copytext(attributes_text, 1, length(attributes_text) - 1)

	attributes_text = "{[jointext(attributes,"; ")]}"
	return attributes_text

/datum/dmm_suite/proc/get_model_key(which, key_length)
	var/list/key = list()
	var/working_digit = which - 1
	for(var/digit_pos in key_length to 1 step -1)
		var/place_value = round/*floor*/(working_digit / (length(letter_digits) ** (digit_pos - 1)))
		working_digit -= place_value * (length(letter_digits) ** (digit_pos - 1))
		key += letter_digits[place_value + 1]

	return jointext(key,"")

/datum/dmm_suite/proc/var_to_dmm(attr, name)
	if(istext(attr))
		// dmm_encode will strip out characters that would be capable of disrupting
		// parsing - namely, quotes and curly braces
		return "[name] = \"[dmm_encode(attr)]\""
	else if(isnum(attr) || ispath(attr))
		return "[name] = [attr]"
	else if(isicon(attr) || isfile(attr))
		if(length("[attr]") == 0)
			// The DM map reader is unable to read files that have a '' file/icon entry
			return
		return "[name] = '[attr]'"
	else
		return ""

#undef DMM_IGNORE_AREAS
#undef DMM_IGNORE_TURFS
#undef DMM_IGNORE_OBJS
#undef DMM_IGNORE_NPCS
#undef DMM_IGNORE_PLAYERS
#undef DMM_IGNORE_MOBS
#undef DMM_USE_JSON

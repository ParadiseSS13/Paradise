#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24
#define DMM_USE_JSON 32
dmm_suite{
	var{
		quote = "\""
		list/letter_digits = list(
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
		}
	save_map(var/turf/t1 as turf, var/turf/t2 as turf, var/map_name as text, var/flags as num){
		//Check for illegal characters in file name... in a cheap way.
		if(!((ckeyEx(map_name)==map_name) && ckeyEx(map_name))){
			CRASH("Invalid text supplied to proc save_map, invalid characters or empty string.")
			}
		//Check for valid turfs.
		if(!isturf(t1) || !isturf(t2)){
			CRASH("Invalid arguments supplied to proc save_map, arguments were not turfs.")
			}
		var/map_prefix = "_maps/quicksave/"
		var/map_path = "[map_prefix][map_name].dmm"
		if(fexists(map_path)){
			fdel(map_path)
			}
		var/saved_map = file(map_path) // We give the map writer the file directly
		// Because repeated string appending is super murder for performance
		var/map_text = write_map(t1,t2,flags,saved_map)
		saved_map << map_text
		return saved_map
		}
	write_map(var/turf/t1 as turf, var/turf/t2 as turf, var/flags as num, var/map_file as file){
		//Check for valid turfs.
		if(!isturf(t1) || !isturf(t2)){
			CRASH("Invalid arguments supplied to proc write_map, arguments were not turfs.")
			}
		var/turf/ne = locate(max(t1.x,t2.x),max(t1.y,t2.y),max(t1.z,t2.z)) // Outer corner
		var/turf/sw = locate(min(t1.x,t2.x),min(t1.y,t2.y),min(t1.z,t2.z)) // Inner corner
		var/list/templates[0]
		var/template_buffer = {""}
		var/buffer_line = {""}
		var/dmm_text = {""}

		for(var/pos_z in sw.z to ne.z){
			for(var/pos_y = ne.y, pos_y >= sw.y, pos_y--){ // We're reversing this because the map format is silly
				for(var/pos_x in sw.x to ne.x){
					var/turf/test_turf = locate(pos_x,pos_y,pos_z)
					var/test_template = make_template(test_turf, flags)
					var/template_number = templates.Find(test_template)
					if(!template_number){
						templates.Add(test_template)
						template_number = templates.len
						}
					buffer_line += "[template_number],"
					CHECK_TICK
					}
				template_buffer += "[buffer_line];"
				buffer_line = ""
				}
			template_buffer += "."
			}
		if(templates.len == 0)
			CRASH("No templates found!")
		var/key_length = round/*floor*/(log(letter_digits.len,templates.len-1)+1)
		var/list/keys[templates.len]
		for(var/key_pos in 1 to templates.len){
			keys[key_pos] = get_model_key(key_pos,key_length)
			dmm_text += {""[keys[key_pos]]" = ([templates[key_pos]])\n"}
			}
		var/z_level = 0
		for(var/z_pos=1;TRUE;z_pos=findtext(template_buffer,".",z_pos)+1){
			if(z_pos>=length(template_buffer)){break}
			if(z_level){dmm_text += {"\n"}}
			dmm_text += {"\n(1,1,[++z_level]) = {"\n"}
			var/z_block = copytext(template_buffer,z_pos,findtext(template_buffer,".",z_pos))
			for(var/y_pos=1;TRUE;y_pos=findtext(z_block,";",y_pos)+1){
				if(y_pos>=length(z_block)){break}
				var/y_block = copytext(z_block,y_pos,findtext(z_block,";",y_pos))
				for(var/x_pos=1;TRUE;x_pos=findtext(y_block,",",x_pos)+1){
					if(x_pos>=length(y_block)){break}
					var/x_block = copytext(y_block,x_pos,findtext(y_block,",",x_pos))
					var/key_number = text2num(x_block)
					var/temp_key = keys[key_number]
					buffer_line += temp_key
					CHECK_TICK
					}
				dmm_text += {"[buffer_line]\n"}
				buffer_line = ""
				}
			dmm_text += {"\"}"}
			}
		return dmm_text
		}
	proc{
		make_template(var/turf/model as turf, var/flags as num){
			var/use_json = 0
			if(flags & DMM_USE_JSON)
				use_json = 1
			var/template = ""
			var/obj_template = ""
			var/mob_template = ""
			var/turf_template = ""
			if(!(flags & DMM_IGNORE_TURFS)){
				turf_template = "[model.type][check_attributes(model,use_json=use_json)],"
				} else{ turf_template = "[world.turf],"}
			var/area_template = ""
			if(!(flags & DMM_IGNORE_OBJS)){
				for(var/obj/O in model.contents){
					if(O.dont_save)
						continue
					obj_template += "[O.type][check_attributes(O,use_json=use_json)],"
					}
				}
			for(var/mob/M in model.contents){
				if(M.dont_save)
					continue
				if(M.client){
					if(!(flags & DMM_IGNORE_PLAYERS)){
						mob_template += "[M.type][check_attributes(M,use_json=use_json)],"
						}
					}
				else{
					if(!(flags & DMM_IGNORE_NPCS)){
						mob_template += "[M.type][check_attributes(M,use_json=use_json)],"
						}
					}
				}
			if(!(flags & DMM_IGNORE_AREAS)){
				var/area/m_area = model.loc
				area_template = "[m_area.type][check_attributes(m_area,use_json=use_json)]"
				} else{ area_template = "[world.area]"}
			template = "[obj_template][mob_template][turf_template][area_template]"
			return template
			}
		check_attributes(var/atom/A,use_json=0){
			var/attributes_text = {"{"}
			if(!use_json){
				for(var/V in A.vars){
					sleep(-1)
					if((!issaved(A.vars[V])) || (A.vars[V]==initial(A.vars[V]))){continue}
					if(istext(A.vars[V])){
						attributes_text += {"[V] = "[A.vars[V]]""}
						}
					else if(isnum(A.vars[V])||ispath(A.vars[V])){
						attributes_text += {"[V] = [A.vars[V]]"}
						}
					else if(isicon(A.vars[V])||isfile(A.vars[V])){
						attributes_text += {"[V] = '[A.vars[V]]'"}
						}
					else{
						continue
						}
					if(attributes_text != {"{"}){
						attributes_text+={"; "}
						}
					}
				} else {
				var/list/yeah = A.serialize()
				// Remove useless info
				yeah -= "type"
				if(yeah.len) {
					var/json_stuff = json_encode(yeah)
					json_stuff = dmm_encode(json_stuff)
					attributes_text += {"map_json_data = "[json_stuff]""}
					}
				}
			if(attributes_text=={"{"}){
				return
				}
			if(copytext(attributes_text, length(attributes_text)-1, 0) == {"; "}){
				attributes_text = copytext(attributes_text, 1, length(attributes_text)-1)
				}
			attributes_text += {"}"}
			return attributes_text
			}
		get_model_key(var/which as num, var/key_length as num){
			var/key = ""
			var/working_digit = which-1
			for(var/digit_pos in key_length to 1 step -1){
				var/place_value = round/*floor*/(working_digit/(letter_digits.len**(digit_pos-1)))
				working_digit-=place_value*(letter_digits.len**(digit_pos-1))
				key = "[key][letter_digits[place_value+1]]"
				}
			return key
			}
		}
	}

var/list/forbidden_varedit_object_types = list(
										/datum/admins,						//Admins editing their own admin-power object? Yup, sounds like a good idea.
										/obj/machinery/blackbox_recorder,	//Prevents people messing with feedback gathering
										/datum/feedback_variable			//Prevents people messing with feedback gathering
									)

/*
/client/proc/cmd_modify_object_variables(obj/O as obj|mob|turf|area in world)
	set category = "Debug"
	set name = "Edit Variables"
	set desc="(target) Edit a target item's variables"
	src.modify_variables(O)
	feedback_add_details("admin_verb","EDITV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/

/client/proc/cmd_modify_ticker_variables()
	set category = "Debug"
	set name = "Edit Ticker Variables"

	if(ticker == null)
		to_chat(src, "Game hasn't started yet.")
	else
		src.modify_variables(ticker)
		feedback_add_details("admin_verb","ETV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mod_list_add_ass() //haha

	var/class = "text"
	var/list/allowed_types = list("text", "num","type", "type from text","reference","mob reference", "icon","file","list","edit referenced object","restore to default")
	if(src.holder && src.holder.marked_datum)
		allowed_types += "marked datum ([holder.marked_datum.type])"
	class = input("What kind of variable?","Variable Type") as null|anything in allowed_types
	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as null|message

		if("num")
			var_value = input("Enter new number:","Num") as null|num

		if("type")
			var_value = input("Enter type:","Type") as null|anything in typesof(/obj,/mob,/area,/turf)

		if("type from text")
			var/type_text = input("Enter type:", "Type") as null|message
			var_value = text2path(type_text)
			if(!var_value)
				to_chat(src, "<span class='warning'>[type_text] is not a valid path!</span>")

		if("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in world

		if("file")
			var_value = input("Pick file:","File") as null|file

		if("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	return var_value


/client/proc/mod_list_add(var/list/L)

	var/class = "text"
	var/list/allowed_types = list("text", "num","type", "type from text","reference","mob reference", "icon","file","list","edit referenced object","restore to default")
	if(src.holder && src.holder.marked_datum)
		allowed_types += "marked datum ([holder.marked_datum.type])"
	class = input("What kind of variable?","Variable Type") as null|anything in allowed_types

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as message|null

		if("num")
			var_value = input("Enter new number:","Num") as num

		if("type")
			var_value = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("type from text")
			var/type_text = input("Enter type:", "Type") as null|message
			var_value = text2path(type_text)
			if(!var_value)
				to_chat(src, "<span class='warning'>[type_text] is not a valid path!</span>")

		if("reference")
			var_value = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as mob in world

		if("file")
			var_value = input("Pick file:","File") as file

		if("icon")
			var_value = input("Pick icon:","Icon") as icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L += var_value
			L[var_value] = mod_list_add_ass() //haha
		if("No")
			L += var_value

/client/proc/mod_list(var/list/L)
	if(!check_rights(R_VAREDIT))	return

	if(!istype(L,/list))
		to_chat(src, "Not a List.")
	if(L.len > 1000)
		var/confirm = alert(src, "The list you're trying to edit is very long, continuing may crash the server.", "Warning", "Continue", "Abort")
		if(confirm != "Continue")
			return

	var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine", "poo", "icon", "icon_state", "step_x", "step_y")

	var/assoc = 0
	if(L.len > 0)
		var/a = L[1]
		if(istext(a) && L[a] != null)
			assoc = 1 //This is pretty weak test but i can't think of anything else
			to_chat(usr, "List appears to be associative.")

	var/list/names = null
	if(!assoc)
		names = sortList(L)

	var/variable
	var/assoc_key
	if(assoc)
		variable = input("Which var?","Var") as null|anything in L + "(ADD VAR)"
	else
		variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(assoc)
		assoc_key = variable
		variable = L[assoc_key]

	if(!assoc && !variable || assoc && !assoc_key)
		return

	var/default

	var/dir

	if(variable in locked)
		if(!check_rights(R_DEBUG))	return

	default = variable_to_type(variable)

	to_chat(usr, "Variable contains: [variable]")
	if(default == "num")
		dir = dir2text(variable)

		if(dir)
			to_chat(usr, "If a direction, direction is: [dir]")

	var/class = "text"
	var/list/allowed_types = list("text", "num","type", "type from text", "reference","mob reference", "icon","file","list","edit referenced object","restore to default","DELETE FROM LIST")
	if(src.holder && src.holder.marked_datum)
		allowed_types += "marked datum ([holder.marked_datum.type])"

	class = input("What kind of variable?","Variable Type",default) as null|anything in allowed_types

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.

		if("list")
			mod_list(variable)

		if("restore to default")
			if(assoc)
				L[assoc_key] = initial(variable)
			else
				L[L.Find(variable)]=initial(variable)

		if("edit referenced object")
			modify_variables(variable)

		if("DELETE FROM LIST")
			L -= variable
			return

		if("text")
			if(assoc)
				L[assoc_key] = input("Enter new text:","Text") as text
			else
				L[L.Find(variable)] = input("Enter new text:","Text") as text

		if("num")
			if(assoc)
				L[assoc_key] = input("Enter new number:","Num") as num
			else
				L[L.Find(variable)] = input("Enter new number:","Num") as num

		if("type")
			if(assoc)
				L[assoc_key] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)
			else
				L[L.Find(variable)] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			if(assoc)
				L[assoc_key] = input("Select reference:","Reference") as mob|obj|turf|area in world
			else
				L[L.Find(variable)] = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			if(assoc)
				L[assoc_key] = input("Select reference:","Reference") as mob in world
			else
				L[L.Find(variable)] = input("Select reference:","Reference") as mob in world

		if("file")
			if(assoc)
				L[assoc_key] = input("Pick file:","File") as file
			else
				L[L.Find(variable)] = input("Pick file:","File") as file

		if("icon")
			if(assoc)
				L[assoc_key] = input("Pick icon:","Icon") as icon
			else
				L[L.Find(variable)] = input("Pick icon:","Icon") as icon

		if("marked datum")
			if(assoc)
				L[assoc_key] = holder.marked_datum
			else
				L[L.Find(variable)] = holder.marked_datum


/client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)
	if(!check_rights(R_VAREDIT))	return

	var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "cuffed", "ka", "last_eaten", "icon", "icon_state")

	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
			return

	if(istype(O, /client) && (param_var_name == "ckey" || param_var_name == "key"))
		to_chat(usr, "<span class='warning'>You cannot edit ckeys on client objects.</span>")
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])")
			return

		if(param_var_name == "holder" || (param_var_name in locked))
			if(!check_rights(R_DEBUG))	return

		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			class = variable_to_type(var_value)
			if(!class)
				autodetect_class = null
			else if(class == "num")
				dir = 1
	else

		var/list/names = list()
		for(var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)	return
		var_value = O.vars[variable]

		if(variable == "holder" || (variable in locked))
			if(!check_rights(R_DEBUG))	return

	if(!autodetect_class)

		var/dir
		var/default
		default = variable_to_type(var_value)
		if(default == "num")
			dir = 1
		else if(default == "icon")
			var_value = "[bicon(var_value)]"

		to_chat(usr, "Variable contains: [var_value]")
		if(dir)
			dir = dir2text(var_value)
			if(dir)
				to_chat(usr, "If a direction, direction is: [dir]")

		var/list/allowed_types = list("text", "num","type","reference","mob reference", "path", "matrix", "icon","file","list","edit referenced object","restore to default")
		if(src.holder && src.holder.marked_datum)
			allowed_types += "marked datum ([holder.marked_datum.type])"

		class = input("What kind of variable?","Variable Type",default) as null|anything in allowed_types

		if(!class)
			return

	var/original_name

	if(!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_as_text = null
	switch(class)

		if("list")
			mod_list(O.vars[variable])
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/var_new = input("Enter new text:","Text",O.vars[variable]) as null|message
			if(var_new==null) return
			O.vars[variable] = var_new

		if("num")
			if(variable=="light_range")
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				O.set_light(var_new)
			else if(variable=="stat") // ow, but I guess I'm glad you're trying to prevent at least one kind of inconsistent state...? This is the VARIABLE EDITOR, I'm not sure we need to worry...?
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				if((O.vars[variable] == DEAD) && (var_new < DEAD))//Bringing the dead back to life
					dead_mob_list -= O
					living_mob_list += O
				if((O.vars[variable] < DEAD) && (var_new == DEAD))//Kill he
					living_mob_list -= O
					dead_mob_list += O
				O.vars[variable] = var_new
			else
				var/var_new =  input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new==null) return
				O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("path")
			var/path_text = input("Enter path:", "Path",O.vars[variable]) as null|text
			var/var_new = text2path(path_text)
			if(!var_new && path_text != null) // So aborting doesn't bother the VVer
				to_chat(usr, "<span class='warning'>[path_text] does not appear to be a valid path.</span>")
				return
			O.vars[variable] = var_new

		if("matrix")
			var/matrix_text = input("Enter a, b, c, d, e, and f, separated by a space.", "Matrix", "1 0 0 0 1 0") as null|text
			var/var_new = text2matrix(matrix_text)
			if(!var_new && matrix_text != null)
				to_chat(usr, "<span class='warning'>[matrix_text] is not a valid matrix string.</span>")
				return
			O.vars[variable] = var_new
			var_as_text = "matrix([matrix_text])"

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new

		if("marked datum")
			O.vars[variable] = holder.marked_datum

	if(var_as_text == null)
		var_as_text = "[O.vars[variable]]"
	log_to_dd("### VarEdit by [src]: [O.type] [variable]=[html_encode("[var_as_text]")]")
	log_admin("[key_name(src)] modified [original_name]'s [variable] to [var_as_text]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [var_as_text]", 1)

// Let's get this all in one place.
// You'll need to take care of setting dir or iconizing the variable yourself once you've called this
/proc/variable_to_type(var/variable)
	var/class
	if(isnull(variable))
		to_chat(usr, "Unable to determine variable type.")
		class = null
	else if(isnum(variable))
		to_chat(usr, "Variable appears to be <b>NUM</b>.")
		class = "num"

	else if(istext(variable))
		to_chat(usr, "Variable appears to be <b>TEXT</b>.")
		class = "text"

	else if(isloc(variable))
		to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
		class = "reference"

	else if(isicon(variable))
		to_chat(usr, "Variable appears to be <b>ICON</b>.")
		variable = "[bicon(variable)]"
		class = "icon"

	else if(istype(variable,/matrix))
		to_chat(usr, "Variable appears to be <b>MATRIX</b>")
		class = "matrix"

	else if(istype(variable,/atom) || istype(variable,/datum))
		to_chat(usr, "Variable appears to be <b>TYPE</b>.")
		class = "type"

	else if(istype(variable,/list))
		to_chat(usr, "Variable appears to be <b>LIST</b>.")
		class = "list"

	else if(istype(variable,/client))
		to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
		class = "cancel"

	else if(ispath(variable))
		to_chat(usr, "Variable appears to be <b>PATH</b>.")
		class = "path"

	else if(isfile(variable))
		to_chat(usr, "Variable appears to be <b>FILE</b>.")
		class = "file"

	else
		to_chat(usr, "Variable type is <b>UNKNOWN</b>.")
		class = null

	return class
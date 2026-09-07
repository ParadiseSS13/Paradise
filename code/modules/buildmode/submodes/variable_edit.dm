/datum/buildmode_mode/varedit
	key = "edit"
	// Varedit mode
	var/varholder = "name"
	var/valueholder = "value"

/datum/buildmode_mode/varedit/show_help(mob/user)
	to_chat(user, SPAN_NOTICE("***********************************************************"))
	to_chat(user, SPAN_NOTICE("Right Mouse Button on buildmode button = Select var(type) & value"))
	to_chat(user, SPAN_NOTICE("Left Mouse Button on turf/obj/mob      = Set var(type) & value"))
	to_chat(user, SPAN_NOTICE("Right Mouse Button on turf/obj/mob     = Reset var's value"))
	to_chat(user, SPAN_NOTICE("***********************************************************"))

// FIXME: This needs to use a standard var-editing interface instead of
// doing its own thing here
/datum/buildmode_mode/varedit/change_settings(mob/user)
	var/temp_varname = tgui_input_text(user, "Enter variable name:", "Name", "name")
	if(!vv_varname_lockcheck(temp_varname))
		return

	var/temp_value = user.client.vv_get_value()
	if(isnull(temp_value["class"]))
		Reset()
		to_chat(user, SPAN_NOTICE("Variable unset."))
		return
	// we assign this once all user input is done, since things could get wonky otherwise
	varholder = temp_varname
	valueholder = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(isnull(varholder))
		to_chat(user, SPAN_WARNING("Choose a variable to modify first."))
		return
	if(left_click)
		if(object.vars.Find(varholder))
			if(!object.vv_edit_var(varholder, valueholder))
				to_chat(user, SPAN_WARNING("Your edit was rejected by [object]."))
				return
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
		else
			to_chat(user, SPAN_WARNING("[initial(object.name)] does not have a var called '[varholder]'"))
	if(right_click)
		if(object.vars.Find(varholder))
			var/reset_value = initial(object.vars[varholder])
			if(!object.vv_edit_var(varholder, reset_value))
				to_chat(user, SPAN_WARNING("Your edit was rejected by [object]."))
				return
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [reset_value]")
		else
			to_chat(user, SPAN_WARNING("[initial(object.name)] does not have a var called '[varholder]'"))


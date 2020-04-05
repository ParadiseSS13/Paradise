/datum/buildmode_mode/save
	key = "save"

	use_corner_selection = TRUE
	var/use_json = TRUE

/datum/buildmode_mode/save/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/save/change_settings(mob/user)
	use_json = (alert("Would you like to use json (Default is \"Yes\")?",,"Yes","No") == "Yes")

/datum/buildmode_mode/save/handle_selected_region(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if(left_click)
		var/map_name = input(user, "Please select a name for your map", "Buildmode", "")
		if(map_name == "")
			return
		var/map_flags = 0
		if(use_json)
			map_flags = 32 // Magic number defined in `writer.dm` that I can't use directly
			// because #defines are for some reason our coding standard
		var/our_map = GLOB.maploader.save_map(cornerA, cornerB, map_name, map_flags)
		user << ftp(our_map) // send the map they've made! Or are stealing, whatever
		to_chat(user, "Map saving complete! [our_map]")

/client/proc/admin_redo_space_transitions()
	set name = "Remake Space Transitions"
	set desc = "Re-assigns all space transitions"
	set category = "Debug"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/choice = alert("Do you want to rebuild space transitions?", null,"Yes", "No")

	if(choice == "No")
		return


	message_admins("[key_name_admin(usr)] re-assigned all space transitions")
	GLOB.space_manager.do_transition_setup()
	log_admin("[key_name(usr)] re-assigned all space transitions")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remake Space Transitions") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/client/proc/make_turf_space_map()
	set name = "Make Space Map"
	set desc = "Create a map of the space levels as turfs at your feet"
	set category = "Debug"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/choice = alert("Are you sure you want to make a space map out of turfs?", null,"Yes","No")

	if(choice == "No")
		return

	var/static/list/sectortypes = list(TRANSITION_TAG_SPACE, TRANSITION_TAG_LAVALAND)
	var/sectortype = tgui_input_list(usr, "Please select sector type", "", sectortypes)

	if(!(sectortype in sectortypes))
		return

	message_admins("[key_name_admin(usr)] made a space map")

	GLOB.space_manager.map_as_turfs(get_turf(usr), sectortype)
	log_admin("[key_name(usr)] made a space map")


/proc/save_lavaland_maps()
	for(var/zlvl in levels_by_trait(ORE_LEVEL))
		GLOB.maploader.save_map(locate(1, 1, zlvl), locate(world.maxx, world.maxy, zlvl), "lavaland_[zlvl]")

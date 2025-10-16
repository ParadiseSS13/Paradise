ADMIN_VERB_VISIBILITY(redo_space_transitions, VERB_VISIBILITY_FLAG_MOREDEBUG)
ADMIN_VERB(redo_space_transitions, R_ADMIN|R_DEBUG, "Remake Space Transitions", "Re-assigns all space transitions", VERB_CATEGORY_DEBUG)
	var/choice = alert(user, "Do you want to rebuild space transitions?", null,"Yes", "No")

	if(choice == "No")
		return

	message_admins("[key_name_admin(usr)] re-assigned all space transitions")
	GLOB.space_manager.do_transition_setup()
	log_admin("[key_name(usr)] re-assigned all space transitions")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remake Space Transitions") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB_VISIBILITY(make_turf_space_map, VERB_VISIBILITY_FLAG_MOREDEBUG)
ADMIN_VERB(make_turf_space_map, R_ADMIN|R_DEBUG, "Make Space Map", "Create a map of the space levels as turfs at your feet", VERB_CATEGORY_DEBUG)
	var/choice = alert("Are you sure you want to make a space map out of turfs?", null,"Yes","No")

	if(choice == "No")
		return

	var/static/list/sectortypes = list(TRANSITION_TAG_SPACE, TRANSITION_TAG_LAVALAND)
	var/sectortype = tgui_input_list(user, "Please select sector type", "", sectortypes)

	if(!(sectortype in sectortypes))
		return

	message_admins("[key_name_admin(user)] made a space map")

	GLOB.space_manager.map_as_turfs(get_turf(user), sectortype)
	log_admin("[key_name(user)] made a space map")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Space Map") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

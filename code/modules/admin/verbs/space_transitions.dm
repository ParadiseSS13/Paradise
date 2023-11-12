/client/proc/admin_redo_space_transitions()
	set name = "Remake Space Transitions"
	set desc = "Re-assigns all space transitions"
	set category = "Debug"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/choice = alert("Do you want to rebuild space transitions?",,"Yes", "No")

	if(choice == "No")
		return


	message_admins("[key_name_admin(usr)] re-assigned all space transitions")
	GLOB.space_manager.do_transition_setup()
	log_admin("[key_name(usr)] re-assigned all space transitions")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remake Space Transitions") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


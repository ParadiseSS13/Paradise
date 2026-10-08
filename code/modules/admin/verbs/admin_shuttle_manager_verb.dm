USER_VERB(open_shuttle_manager, R_ADMIN, "Shuttle Manager", "Opens the Shuttle Manager UI", VERB_CATEGORY_ADMIN)
	if(!SSshuttle || !SSshuttle.initialized)
		to_chat(client, "<span class='notice'>SSshuttle has not initialized yet, Shuttle Manager is not available yet.</span>")
		return

	message_admins("[key_name_admin(client)] is using the Shuttle Manager")
	var/datum/ui_module/admin/shuttle_manager/SM = get_admin_ui_module(/datum/ui_module/admin/shuttle_manager)
	SM.ui_interact(client.mob)

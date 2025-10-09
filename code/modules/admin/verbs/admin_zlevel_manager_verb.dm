ADMIN_VERB(open_zlevel_manager, R_ADMIN, "Z-Level Manager", "Opens the Z-Level Manager.", VERB_CATEGORY_ADMIN)
	if(!SSmapping || !SSmapping.initialized)
		to_chat(user, "<span class='notice'>SSmapping has not initialized yet, Z-Level Manager is not available yet.</span>")
		return

	message_admins("[key_name_admin(user)] is using the Z-Level Manager")
	var/datum/ui_module/admin/z_level_manager/ZLM = get_admin_ui_module(/datum/ui_module/admin/z_level_manager)
	ZLM.ui_interact(user)

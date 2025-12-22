USER_VERB(open_zlevel_manager, R_ADMIN, "Z-Level Manager", "Opens the Z-Level Manager.", VERB_CATEGORY_ADMIN)
	if(!SSmapping || !SSmapping.initialized)
		to_chat(client, SPAN_NOTICE("SSmapping has not initialized yet, Z-Level Manager is not available yet."))
		return

	message_admins("[key_name_admin(client)] is using the Z-Level Manager")
	var/datum/ui_module/admin/z_level_manager/ZLM = get_admin_ui_module(/datum/ui_module/admin/z_level_manager)
	ZLM.ui_interact(client.mob)

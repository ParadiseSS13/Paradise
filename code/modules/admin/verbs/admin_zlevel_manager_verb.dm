/client/proc/open_admin_zlevel_manager()
	set name = "Z-Level Manager"
	set desc = "Opens the Z-Level Manager UI"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if(!SSmapping || !SSmapping.initialized)
		to_chat(usr, "<span class='notice'>SSmapping has not initialized yet, Z-Level Manager is not available yet.</span>")
		return

	message_admins("[key_name_admin(usr)] is using the Z-Level Manager")
	var/datum/ui_module/admin/z_level_manager/ZLM = get_admin_ui_module(/datum/ui_module/admin/z_level_manager)
	ZLM.ui_interact(usr)

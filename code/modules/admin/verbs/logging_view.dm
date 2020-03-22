GLOBAL_LIST_INIT(open_logging_views, list())

/client/proc/cmd_admin_open_logging_view()
	set category = "Admin"
	set name = "Open Logging View"
	set desc = "Opens the detailed logging viewer"

	if(!GLOB.open_logging_views[usr.client.ckey])
		GLOB.open_logging_views[usr.client.ckey] = new /datum/log_viewer()
	GLOB.open_logging_views[usr.client.ckey].show_ui(usr)
GLOBAL_LIST_EMPTY(open_logging_views)

/client/proc/cmd_admin_open_logging_view()
	set category = "Admin"
	set name = "Logging View"
	set desc = "Opens the detailed logging viewer"
	open_logging_view()

/client/proc/open_logging_view(list/mob/mobs_to_add = null, clear_view = FALSE)
	var/datum/log_viewer/cur_view = GLOB.open_logging_views[usr.client.ckey]
	if(!cur_view)
		cur_view = new /datum/log_viewer()
		GLOB.open_logging_views[usr.client.ckey] = cur_view
	else if(clear_view)
		cur_view.clear_all()

	if(length(mobs_to_add))
		cur_view.add_mobs(mobs_to_add)

	cur_view.show_ui(usr)


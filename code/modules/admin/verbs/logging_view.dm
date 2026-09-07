GLOBAL_LIST_EMPTY(open_logging_views)

USER_VERB(logging_view, R_ADMIN, "Logging View", "Opens the detailed logging viewer", VERB_CATEGORY_ADMIN, mob/M as null, clear_view as null)
	var/datum/log_viewer/cur_view = GLOB.open_logging_views[client.ckey]
	if(!cur_view)
		cur_view = new /datum/log_viewer()
		GLOB.open_logging_views[client.ckey] = cur_view
	else if(clear_view)
		cur_view.clear_all()

	if(istype(M))
		cur_view.add_mobs(list(M))

	cur_view.show_ui(client.mob)

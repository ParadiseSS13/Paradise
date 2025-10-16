GLOBAL_LIST_EMPTY(open_logging_views)

ADMIN_VERB(logging_view, R_ADMIN, "Logging View", "Opens the detailed logging viewer", VERB_CATEGORY_ADMIN, list/mob/mobs_to_add = null, clear_view = FALSE)
	var/datum/log_viewer/cur_view = GLOB.open_logging_views[user.ckey]
	if(!cur_view)
		cur_view = new /datum/log_viewer()
		GLOB.open_logging_views[user.ckey] = cur_view
	else if(clear_view)
		cur_view.clear_all()

	if(length(mobs_to_add))
		cur_view.add_mobs(mobs_to_add)

	cur_view.show_ui(user.mob)

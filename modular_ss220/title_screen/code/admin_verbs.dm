GLOBAL_LIST_INIT(admin_verbs_title_screen, list(
	/client/proc/admin_change_title_screen,
	/client/proc/change_title_screen_html,
	/client/proc/change_title_screen_notice,
))

/client/add_admin_verbs()
	. = ..()
	if(holder.rights & R_EVENT)
		verbs += GLOB.admin_verbs_title_screen

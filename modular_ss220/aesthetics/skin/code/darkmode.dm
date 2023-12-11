/client/activate_darkmode()
	. = ..()
	winset(src, "rpane.fullscreenb", "background-color=#40628a;text-color=#ffffff")

/client/deactivate_darkmode()
	. = ..()
	winset(src, "rpane.fullscreenb", "background-color=none;text-color=#000000")

/datum/preferences/New(client/C, datum/db_query/Q)
	toggles |= PREFTOGGLE_UI_DARKMODE
	. = ..()

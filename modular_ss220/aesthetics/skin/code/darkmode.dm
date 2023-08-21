/client/activate_darkmode()
	. = ..()
	winset(src, "rpane.fullscreenb", "background-color=#494949;text-color=#a4bad6")

/client/deactivate_darkmode()
	. = ..()
	winset(src, "rpane.fullscreenb", "background-color=none;text-color=#000000")

/datum/preferences/New(client/C, datum/db_query/Q)
	toggles |= PREFTOGGLE_UI_DARKMODE
	. = ..()

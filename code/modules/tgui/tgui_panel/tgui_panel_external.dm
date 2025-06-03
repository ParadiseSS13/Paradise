/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/* check_grep:ignore */ /client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "Special Verbs"
	var/action
	log_tgui(src, "Started fixing.")

	nuke_chat()

	// Failed to fix
	action = alert(src, "Did that work?", "", "Yes", "No, switch to old ui")
	if(action == "No, switch to old ui")
		winset(src, "legacy_output_selector", "left=output_legacy")
		log_tgui(src, "Failed to fix.")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "legacy_output_selector", "left=output_legacy")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing")
		tgui_panel = new(src, "chat_panel")
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "legacy_output_selector", "left=output_browser")
	if(byond_version >= 516)
		winset(src, null, "browser-options=byondstorage,find")

/client/verb/refresh_tgui()
	set name = "Refresh TGUI"
	set category = "Special Verbs"

	var/choice = alert(usr,
		"Use it ONLY if you have trouble with TGUI window.\
		That's UI's with EYE on top-left corner.\
		Otherwise, you can get a white window that will only close when you restart the game!", "Refresh TGUI", "Refresh", "Cancel")
	if(choice != "Refresh")
		return
	var/refreshed_count = 0
	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		if(!window.locked)
			window.acquire_lock()
			continue
		window.reinitialize()
		refreshed_count++
	to_chat(usr, "<span class='notice'>TGUI windows refreshed - [refreshed_count].<br>If you have blank window - restart the game, or open previous TGUI window.</span>")


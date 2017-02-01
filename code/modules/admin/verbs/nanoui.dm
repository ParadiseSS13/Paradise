/client/proc/reload_nanoui_resources()
	set category = "Debug"
	set name = "Reload NanoUI Resources"
	set desc = "Force the client to redownload NanoUI Resources"

	// Close open NanoUIs.
	nanomanager.close_user_uis(usr)

	// Re-load the assets.
	var/datum/asset/assets = get_asset_datum(/datum/asset/nanoui)
	assets.register()

	// Clear the user's cache so they get resent.
	usr.client.cache = list()

/client/proc/toggle_nano_firebug()
	set category = "Debug"
	set name = "Enable/Disable NanoUI Firebug"
	set desc = "Toggle including a debugger on NanoUIs you view"

	if(!check_rights(R_DEBUG))
		return

	if(holder.nanoui_use_firebug)
		to_chat(src, "<span class='notice'>Firebug disabled</span>")
		holder.nanoui_use_firebug = FALSE
	else
		to_chat(src, "<span class='notice'>Firebug enabled</span>")
		holder.nanoui_use_firebug = TRUE

/datum/keybinding/admin
	category = KB_CATEGORY_ADMIN
	/// The rights to use with [/proc/check_rights] if any
	var/rights

/datum/keybinding/admin/can_use(client/C, mob/M)
	if(rights && !check_rights(rights, FALSE, M))
		return FALSE
	return !isnull(C.holder) && ..()

/datum/keybinding/admin/mc_debug
	name = "MC Debug"
	keys = list("F3")
	rights = R_VIEWRUNTIMES | R_DEBUG

/datum/keybinding/admin/mc_debug/down(client/C)
	. = ..()
	if(C in SSdebugview.processing)
		SSdebugview.stop_processing(C)
		return
	SSdebugview.start_processing(C)

/datum/keybinding/admin/aghost
	name = "Aghost"
	keys = list("F6")

/datum/keybinding/admin/aghost/down(client/C)
	. = ..()
	C.admin_ghost()

/datum/keybinding/admin/player_panel
	name = "Player Panel"
	keys = list("F7")
	rights = R_ADMIN | R_MOD

/datum/keybinding/admin/player_panel/down(client/C)
	. = ..()
	C.holder.player_panel_new()

/datum/keybinding/admin/apm
	name = "Admin PM"
	keys = list("F8")

/datum/keybinding/admin/apm/down(client/C)
	. = ..()
	C.cmd_admin_pm_panel()

/datum/keybinding/admin/invisimin
	name = "Invisimin"
	keys = list("F9")

/datum/keybinding/admin/invisimin/down(client/C)
	. = ..()
	C.invisimin()
